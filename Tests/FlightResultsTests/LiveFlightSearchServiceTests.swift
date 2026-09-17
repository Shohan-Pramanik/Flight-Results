import XCTest
@testable import FlightResults

/// Intercepts requests made through a `URLSession` configured with this
/// protocol class, so `LiveFlightSearchService` can be tested without any
/// real network access.
private final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class LiveFlightSearchServiceTests: XCTestCase {
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        MockURLProtocol.handler = nil
        session = nil
        super.tearDown()
    }

    private func response(statusCode: Int, url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: API key

    func test_search_missingAPIKey_throwsWithoutHittingNetwork() async {
        var networkWasCalled = false
        MockURLProtocol.handler = { request in
            networkWasCalled = true
            return (self.response(statusCode: 200, url: request.url!), Data())
        }
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { nil })

        do {
            _ = try await sut.search(TestFixtures.request())
            XCTFail("expected missingAPIKey to be thrown")
        } catch let error as FlightSearchServiceError {
            XCTAssertEqual(error, .missingAPIKey)
        } catch {
            XCTFail("expected FlightSearchServiceError, got \(error)")
        }
        XCTAssertFalse(networkWasCalled)
    }

    func test_search_emptyAPIKey_throwsMissingAPIKey() async {
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { "" })

        do {
            _ = try await sut.search(TestFixtures.request())
            XCTFail("expected missingAPIKey to be thrown")
        } catch let error as FlightSearchServiceError {
            XCTAssertEqual(error, .missingAPIKey)
        } catch {
            XCTFail("expected FlightSearchServiceError, got \(error)")
        }
    }

    // MARK: success

    func test_search_success_decodesResponse() async throws {
        let group = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Live Air")], price: 999)
        let payload = FlightSearchResponse(bestFlights: [group], otherFlights: nil)
        let data = try JSONEncoder().encode(payload)

        MockURLProtocol.handler = { request in
            (self.response(statusCode: 200, url: request.url!), data)
        }
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { "test-key" })

        let result = try await sut.search(TestFixtures.request())

        XCTAssertEqual(result.bestFlights?.first?.price, 999)
    }

    func test_search_buildsExpectedQueryItems() async throws {
        let payload = FlightSearchResponse(bestFlights: nil, otherFlights: nil)
        let data = try JSONEncoder().encode(payload)
        var capturedURL: URL?

        MockURLProtocol.handler = { request in
            capturedURL = request.url
            return (self.response(statusCode: 200, url: request.url!), data)
        }
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { "test-key" })
        let request = TestFixtures.request(departureId: "LAX", arrivalId: "HND", currency: "USD")

        _ = try await sut.search(request)

        let query = try XCTUnwrap(capturedURL?.query)
        XCTAssertTrue(query.contains("departure_id=LAX"))
        XCTAssertTrue(query.contains("arrival_id=HND"))
        XCTAssertTrue(query.contains("currency=USD"))
        XCTAssertTrue(query.contains("type=2"))
        XCTAssertTrue(query.contains("api_key=test-key"))
        XCTAssertTrue(query.contains("engine=google_flights"))
    }

    // MARK: HTTP errors

    func test_search_non2xxStatus_throwsHTTPError() async {
        MockURLProtocol.handler = { request in
            (self.response(statusCode: 404, url: request.url!), Data())
        }
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { "test-key" })

        do {
            _ = try await sut.search(TestFixtures.request())
            XCTFail("expected httpError to be thrown")
        } catch let error as FlightSearchServiceError {
            XCTAssertEqual(error, .httpError(statusCode: 404))
        } catch {
            XCTFail("expected FlightSearchServiceError, got \(error)")
        }
    }

    func test_search_serverError_throwsHTTPErrorWithStatusCode() async {
        MockURLProtocol.handler = { request in
            (self.response(statusCode: 500, url: request.url!), Data())
        }
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { "test-key" })

        do {
            _ = try await sut.search(TestFixtures.request())
            XCTFail("expected httpError to be thrown")
        } catch let error as FlightSearchServiceError {
            XCTAssertEqual(error, .httpError(statusCode: 500))
        } catch {
            XCTFail("expected FlightSearchServiceError, got \(error)")
        }
    }

    // MARK: malformed payload

    func test_search_undecodableBody_throwsDecodingError() async {
        MockURLProtocol.handler = { request in
            (self.response(statusCode: 200, url: request.url!), Data("not json".utf8))
        }
        let sut = LiveFlightSearchService(session: session, apiKeyProvider: { "test-key" })

        do {
            _ = try await sut.search(TestFixtures.request())
            XCTFail("expected a decoding error to be thrown")
        } catch is DecodingError {
            // expected
        } catch {
            XCTFail("expected DecodingError, got \(error)")
        }
    }
}
