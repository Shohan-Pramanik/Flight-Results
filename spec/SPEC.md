# Flight Results — Technical Spec

**Task:** GoZayaan iOS take-home
**Screen:** Flight Results (single screen, four states)
**Architecture:** MVVM + Coordinator
**UI Framework:** SwiftUI
**Author:** Shohan Pramanik
**Status:** Written before prompting the AI (Option A)

---

## 1. What this screen does

One screen that shows one-way flight search results for a fixed route/date
(no search form to build). It has to work correctly in all four states —
loading, success, empty, error — and it has to look like the Figma reference
in each of them.

Reference search used throughout this spec and for the mock/fixture data:

```
GET https://serpapi.com/search?engine=google_flights
    &departure_id=LAX&arrival_id=HND&outbound_date=2026-09-30
    &type=2&currency=USD&hl=en&api_key=YOUR_SERPAPI_KEY
```

I'm using a real captured response for this exact search as my local fixture
(cached JSON, checked into the repo under `/Fixtures`) so I'm not burning
SerpApi trial calls while iterating on UI and not hitting the network in
unit tests. LAX→HND turned out to be a genuinely good pick for a fixture:
this one search's results cover all three stop counts the design needs —
`best_flights` are all non-stop, and `other_flights` has both a clean 1-stop
(LAX → KIX → HND) and a real 2-stop (LAX → HNL → GUM → HND, three legs, two
layovers) — so a single checked-in response exercises every case the task
asks for, rather than needing multiple fixtures stitched together.

---

## 2. Screen states

| State | Trigger | What's shown |
|---|---|---|
| `loading` | ViewModel just fired the request | Route header + date/price strip render immediately (they're static/dummy), flight card area shows shimmer skeleton cards |
| `success` | Request returned ≥1 offers | Route header, date/price strip, discount carousel, and the mapped flight cards |
| `empty` | Request returned 0 offers | Route header + date/price strip stay visible; an empty-state view replaces the list ("No flights found for this route" + illustration/icon) |
| `error` | Request failed (network/HTTP/decoding) | Route header + date/price strip stay visible; an error view replaces the list, with a message and a Retry button that re-triggers the same request |

Transitions the ViewModel needs to support, in order: `loading → success`,
`loading → empty`, `loading → error`, and `error → loading` (via Retry).

I'm keeping the route header and date strip visible in all four states
rather than hiding everything — only the results area (skeleton / cards /
empty view / error view) swaps out. That matches how the Figma frames are
laid out and avoids the whole screen jumping around when the state changes.

---

## 3. UI components

### 3.1 Route header
- Origin → destination (IATA codes or city names — going with city names
  for readability, e.g. "Paris → Austin", pulled from the search request,
  not from the API response, since the header doesn't depend on results
  coming back)
- Date (from the search request, e.g. "30th Sep 2026")
- Passenger count — hardcoded to "1 Adult" (no passenger picker in scope)
- "One Way" label — static, since `type=2` is the only mode we support
- Edit button — present, tappable, but decorative. Tapping it does nothing;
  there's no edit flow to build. I'll wire it to a no-op so it's obviously
  intentional rather than just missing an action.

### 3.2 Date and price strip
- Horizontally scrollable row of day chips, each showing a short date
  (`Sun 08 Feb`) and a fare underneath (`USD 2,129`)
- One chip is visually selected/highlighted
- Entirely **dummy, hardcoded data** — 7 chips is enough to prove it
  scrolls
- Taps are ignored per the brief. I'm still wiring a tap handler that does
  nothing (rather than disabling interaction on the chips) so the highlight
  state is clearly a fixed default and not a bug.

### 3.3 Sort & filter bar
Sitting directly above the flight cards (below the date/price strip),
visible from the screenshot but not called out in the written brief:

- **Cheapest** — a pill button with a chevron, left-aligned. This is the
  control the "Extra credit — Sorting" section refers to (§6). If sorting
  isn't implemented, the pill is still shown for visual accuracy but does
  nothing when tapped — same "present but decorative" treatment as Edit.
  If sorting *is* implemented, tapping it reveals the `SortOption` choices
  (Cheapest / Fastest) and drives `sortedOffers(by:)`.
- **Filter** — a pill button with a filter icon, right-aligned. No filter
  criteria are described anywhere in the brief and no filter flow is in
  scope, so this is decorative only, wired to a no-op — the same reasoning
  as Edit in the route header.

### 3.4 Loading skeletons
- Shimmer-style placeholder cards, same size/shape as a real flight card
- Shown only in the `loading` state, only in the results area
- 3–4 skeleton cards is enough

### 3.5 Flight cards
From the reference screenshot, top to bottom, left to right:

- **Header row:** airline logo image + airline name on the left (e.g. the
  Biman Bangladesh Airlines mark next to "Biman Bangladesh Airlines"); a
  **"Get Points"** badge on the right (star icon + orange text). The logo
  is real — SerpApi returns an `airline_logo` URL per leg — loaded with
  `AsyncImage`, with a generic plane-icon placeholder while it loads or if
  it fails. "Get Points" isn't mentioned anywhere in the written brief and
  there's no corresponding field in the SerpApi response — it's a purely
  cosmetic, hardcoded badge shown identically on every card, not something
  driven by `FlightOffer`. I'm including it because "UI correctness" is
  explicitly scored against matching the design, but it carries no real
  data or interaction.
- **Route row:** departure time (bold) with the origin airport code below
  it, on the left; arrival time (bold) with the destination airport code
  below it, on the right; in between, the duration (e.g. "4h 40m") above a
  dotted line with a small plane icon, and the stops label (**Non-Stop /
  1 Stop / 2 Stop**) below that same dotted line.
- **Price row:** right-aligned, "Starting from" in small gray text above
  the price in bold (e.g. "BDT 37,400").

All of the above except the "Get Points" badge is sourced from the mapped
`FlightOffer` (§4.3):
- Airline name and logo
- Departure time and arrival time
- Total duration, formatted as `XhYYm` (e.g. `810` minutes → `"13h 30m"`)
- Stops label
- Origin and destination airport codes
- Starting price, formatted with the currency code and thousands
  separator (e.g. `"BDT 37,400"`)

### 3.6 Discount carousel
- Horizontally scrollable promo cards, each with an image, a title, and a
  "Learn more" link
- Data is dummy/hardcoded (image name or URL, title, target URL) — the API
  has nothing to do with this
- **Placement:** I'm inserting it once, after the second flight card in the
  results list, rather than repeating it every N cards or pinning it above
  the list. Once is enough to demonstrate it works, putting it above the
  list would make it look like part of the header instead of "sitting
  between the flight cards" as the brief describes, and repeating it every
  N cards adds visual noise for a promo unit with no real content behind
  it. If the results list is short (e.g. only 1–2 cards, or the empty
  state), the carousel is simply not shown — there's nothing to sit
  "between."
- Tapping **Learn more** is the one real navigation in the task: it opens
  `https://gozayaan.com` via the Coordinator (see §5).

---

## 4. Data layer

### 4.1 Raw API response shape (SerpApi `google_flights`, one-way)

This is what actually comes back — nested legs, layovers as a separate
array, everything keyed by `id`/`time` pairs for airports:

```json
{
  "best_flights": [
    {
      "flights": [
        {
          "departure_airport": { "id": "LAX", "time": "2026-09-30 16:50" },
          "arrival_airport":   { "id": "HND", "time": "2026-10-01 21:00" },
          "duration": 730,
          "airline": "ANA",
          "airline_logo": "https://www.gstatic.com/flights/airline_logos/70px/NH.png"
        }
      ],
      "total_duration": 730,
      "price": 652
    }
  ],
  "other_flights": [
    {
      "flights": [
        {
          "departure_airport": { "id": "LAX", "time": "2026-09-30 09:05" },
          "arrival_airport":   { "id": "HNL", "time": "2026-09-30 11:51" },
          "duration": 346,
          "airline": "United",
          "airline_logo": "https://www.gstatic.com/flights/airline_logos/70px/UA.png"
        },
        {
          "departure_airport": { "id": "HNL", "time": "2026-09-30 14:25" },
          "arrival_airport":   { "id": "GUM", "time": "2026-10-01 18:05" },
          "duration": 460,
          "airline": "United",
          "airline_logo": "https://www.gstatic.com/flights/airline_logos/70px/UA.png"
        },
        {
          "departure_airport": { "id": "GUM", "time": "2026-10-01 19:35" },
          "arrival_airport":   { "id": "HND", "time": "2026-10-01 22:30" },
          "duration": 235,
          "airline": "United",
          "airline_logo": "https://www.gstatic.com/flights/airline_logos/70px/UA.png"
        }
      ],
      "layovers": [
        { "duration": 154, "name": "Daniel K. Inouye International Airport", "id": "HNL" },
        { "duration": 90, "name": "Antonio B. Won Pat International Airport", "id": "GUM" }
      ],
      "total_duration": 1285,
      "price": 486
    }
  ]
}
```

The first group above is as simple as this API gets — a single leg, no
layovers, straight to `stops == 0`. The second is the shape that actually
needs careful flattening: three legs, two layovers, and it has to come out
as **2 Stop**, not 1 and not 3.

`departure_token` and `booking_token` are ignored entirely, as instructed —
they belong to multi-step search/booking flows this task doesn't build.

### 4.2 Raw Codable models (mirror the API, nothing more)

```swift
struct FlightSearchResponse: Codable {
    let bestFlights: [RawFlightGroup]?
    let otherFlights: [RawFlightGroup]?

    enum CodingKeys: String, CodingKey {
        case bestFlights = "best_flights"
        case otherFlights = "other_flights"
    }
}

struct RawFlightGroup: Codable {
    let flights: [RawFlightLeg]
    let layovers: [RawLayover]?
    let totalDuration: Int
    let price: Int?

    enum CodingKeys: String, CodingKey {
        case flights, layovers, price
        case totalDuration = "total_duration"
    }
}

struct RawFlightLeg: Codable {
    let departureAirport: RawAirportStop
    let arrivalAirport: RawAirportStop
    let duration: Int
    let airline: String
    let airlineLogo: String?

    enum CodingKeys: String, CodingKey {
        case departureAirport = "departure_airport"
        case arrivalAirport = "arrival_airport"
        case duration, airline
        case airlineLogo = "airline_logo"
    }
}

struct RawAirportStop: Codable {
    let id: String
    let time: String
}

struct RawLayover: Codable {
    let duration: Int
    let name: String
    let id: String
}
```

Fields present in the real payload but not needed anywhere in the UI —
`airplane`, `legroom`, `extensions`, `carbon_emissions`,
`ticket_also_sold_by`, `often_delayed_by_over_30_min`, `booking_token`,
`price_insights`, `airports` — are simply left out of these structs.
`airline_logo` was originally on that list too, until the reference
screenshot made it clear the card shows a real airline logo image, not a
generic icon — so it's kept and mapped through. `Codable` only decodes
keys you declare, so omitting the rest is a safe, deliberate choice rather
than something that will crash on unexpected fields.

### 4.3 Domain model — what the UI actually binds to

```swift
struct FlightOffer: Identifiable, Equatable {
    let id: String              // synthesized (UUID), since booking_token is off-limits
    let airline: String         // airline of the first leg
    let airlineLogoURL: URL?    // airline_logo of the first leg, if present
    let originCode: String      // departure_airport.id of the first leg
    let destinationCode: String // arrival_airport.id of the last leg
    let departureTime: Date
    let arrivalTime: Date
    let totalDurationMinutes: Int   // total_duration, straight through
    let stops: Int                  // layovers.count
    let price: Int
    let currencyCode: String        // from the request, e.g. "USD"

    var stopsLabel: String {
        switch stops {
        case 0: return "Non-Stop"
        case 1: return "1 Stop"
        default: return "\(stops) Stop"
        }
    }
}

struct FlightSearchRequest {
    let departureId: String
    let arrivalId: String
    let outboundDate: Date
    let currency: String
    let type: Int = 2   // one-way, fixed — this screen never does round trip
}
```

### 4.4 Mapping rules (`RawFlightGroup` → `FlightOffer`)

- `stops` = `layovers?.count ?? 0`. This is the important one: a group
  with 3 legs and 2 layovers must map to `stops == 2`, i.e. **"2 Stop"** —
  not derived from `flights.count`, which would need a `- 1` and is an
  easy off-by-one to get wrong. Counting layovers directly is more
  literal and harder to mess up.
- `departureTime` = `flights.first!.departureAirport.time`, parsed with a
  fixed `"yyyy-MM-dd HH:mm"` `DateFormatter` (that's the exact format
  SerpApi returns).
- `arrivalTime` = `flights.last!.arrivalAirport.time`, same parsing.
- `originCode` = `flights.first!.departureAirport.id`.
- `destinationCode` = `flights.last!.arrivalAirport.id`.
- `airline` = `flights.first!.airline`. On an itinerary where the legs are
  operated by different carriers, this only shows the first one — the card
  only has room for one airline name; a "+1 more" treatment would be a
  reasonable follow-up but is out of scope here.
- `airlineLogoURL` = `flights.first!.airlineLogo`, parsed into a `URL`
  (nil if the field is missing or fails to parse — `FlightCardView` falls
  back to a generic plane icon in that case rather than showing a broken
  image).
- `totalDurationMinutes` = `totalDuration`, used as-is (already in
  minutes, already summed across legs by the API).
- `price` / `currencyCode` = `price` from the group, and the currency
  code from the original `FlightSearchRequest` (the response itself
  doesn't repeat the currency per item). `price` is modeled as `Int?`,
  not `Int` — a response I captured on a different search (JFK→SIN with
  `show_hidden=true`) had several entries missing the `price` key
  entirely, including an otherwise-valid non-stop result. None of the
  entries in the default LAX→HND fixture happen to do this, but the raw
  model has to tolerate it regardless, so it's covered by a synthetic
  test rather than relying on the checked-in fixture happening to
  reproduce the quirk. A group with no price can't produce a usable
  "starting from" price, so it's dropped like any other malformed group.
- A `RawFlightGroup` that fails to decode a required field (e.g. an
  empty `flights` array) is dropped rather than crashing the whole
  mapping pass — one bad entry shouldn't take down the results screen.

### 4.5 Combining `best_flights` and `other_flights`

The brief calls this out as intentionally open. My approach: map both
arrays through the exact same function above, then concatenate
`bestFlights` first, followed by `otherFlights`, into one
`[FlightOffer]` — no visual distinction between the two in the UI.

Reasoning: "best" here is Google's own ranking (a mix of price and
duration), so keeping best_flights first gives a sensible default order
for free, without extra logic on our side. I'm not badging them in the UI
because the design doesn't show a badge and I'd rather not invent a UI
element the reference screens don't have. If sorting is applied (§6), it
sorts across the whole combined list, so the best/other distinction stops
mattering anyway.

---

## 5. Architecture

**MVVM + Coordinator**, boundaries enforced as follows:

- **Model** — the `Raw*` Codable structs (§4.2) plus the domain model
  `FlightOffer` / `FlightSearchRequest` (§4.3). No UIKit/SwiftUI imports
  anywhere in this layer.

- **ViewModel** (`FlightResultsViewModel`) — owns a published state:

  ```swift
  enum FlightResultsState {
      case loading
      case success([FlightOffer])
      case empty
      case error(String)
  }
  ```

  It calls the network service, maps the raw response into `[FlightOffer]`
  using §4.4/§4.5, and publishes the resulting state. It does **not**
  import `UIKit` navigation types (`UIViewController`, `UINavigationController`,
  etc.) and has no reference to the Coordinator type at all — it only knows
  about a delegate protocol it can report through.

- **Coordinator delegate** — the ViewModel reports outward through this,
  never by calling navigation methods directly:

  ```swift
  protocol FlightResultsCoordinatorDelegate: AnyObject {
      func didSelectFlight(_ offer: FlightOffer)
      func didTapLearnMore(url: URL)
  }
  ```

  The brief's own example only shows `didSelectFlight`. I've added
  `didTapLearnMore(url:)` because the one actual required navigation in
  this task is the discount carousel's "Learn more" link opening
  `gozayaan.com` — that has to go through the Coordinator too, and
  `didSelectFlight` doesn't cover it. `didSelectFlight` itself is kept
  for tapping a flight card; there's no further screen to build for it
  (same "decorative" status as the Edit button), but the plumbing is in
  place and correctly routed through the Coordinator rather than handled
  inside the ViewModel or View.

- **Coordinator** (`FlightResultsCoordinator`) — in SwiftUI there's no
  `UINavigationController` to push onto, so the Coordinator is implemented
  as its own `ObservableObject` that owns navigation/presentation *state*,
  and the View reads that state to decide what to show. It creates the
  `FlightResultsViewModel`, sets itself as `FlightResultsCoordinatorDelegate`,
  and exposes the root `View` for this screen:

  ```swift
  final class FlightResultsCoordinator: ObservableObject, FlightResultsCoordinatorDelegate {
      @Published var presentedURL: IdentifiableURL?   // drives a .sheet(item:) in the View

      private let viewModel: FlightResultsViewModel

      init(viewModel: FlightResultsViewModel) {
          self.viewModel = viewModel
          viewModel.delegate = self
      }

      func start() -> some View {
          FlightResultsView(viewModel: viewModel)
              .environmentObject(self)
      }

      // MARK: FlightResultsCoordinatorDelegate

      func didTapLearnMore(url: URL) {
          presentedURL = IdentifiableURL(url: url)
      }

      func didSelectFlight(_ offer: FlightOffer) {
          // No destination screen in scope — intentionally a no-op,
          // but the call is still routed through the Coordinator, not
          // handled locally in the View or ViewModel.
      }
  }
  ```

  `FlightResultsView` gets the Coordinator through `@EnvironmentObject` and
  attaches `.sheet(item: $coordinator.presentedURL) { SafariView(url: $0.url) }`
  at its root. `SafariView` is a thin `UIViewControllerRepresentable`
  wrapper around `SFSafariViewController` — SwiftUI has no native in-app
  browser, so this is the standard way to open a real web page without
  leaving the app. `.sheet(item:)` requires `Identifiable`, and `URL`
  doesn't conform to it, so `presentedURL` is wrapped in a tiny
  `IdentifiableURL` struct rather than a raw `URL?`.

  This keeps the same separation the brief asks for: the View never talks
  to the ViewModel's delegate directly, the ViewModel never touches
  `URL`-opening or `SFSafariViewController`, and the Coordinator is the
  only place that knows navigation/presentation exists.

**Test for correctness:** `FlightResultsViewModel` must be instantiable
and testable with zero UIKit and zero Coordinator involved — its
dependencies are just a network/service protocol that can be mocked.

---

## 6. Extra credit — sorting (optional)

The "Cheapest" dropdown, if I get to it:

- A plain function on the ViewModel, not something the View computes
  while rendering:

  ```swift
  func sortedOffers(_ offers: [FlightOffer], by option: SortOption) -> [FlightOffer]

  enum SortOption {
      case cheapest   // ascending by price
      case fastest    // ascending by totalDurationMinutes
  }
  ```

- Selecting an option re-sorts the currently-held `[FlightOffer]` in
  `state` and republishes `.success(sorted)` — it does not re-fetch from
  the network.
- Ties (equal price or equal duration) keep their original relative order
  (stable sort), since Swift's `sorted(by:)` is guaranteed stable.

---

## 7. SwiftUI view hierarchy

```
FlightResultsView                       // root, owns @StateObject viewModel
├─ RouteHeaderView                      // static, fixed at top, never scrolls away
│   (origin, destination, date, "1 Adult", "One Way", Edit — no-op button)
├─ ScrollView(.vertical) {
│    DatePriceStripView                 // horizontal ScrollView of DateChip, hardcoded
│    SortFilterBarView                  // "Cheapest" pill + "Filter" pill
│    ResultsAreaView                    // switches on viewModel.state
│  }
```

`ResultsAreaView` is a `switch` over `FlightResultsState`, one case per
state — this is the only part of the screen that changes shape:

```swift
struct ResultsAreaView: View {
    let state: FlightResultsState
    let onRetry: () -> Void
    let onSelect: (FlightOffer) -> Void
    let onLearnMore: (URL) -> Void

    var body: some View {
        switch state {
        case .loading:
            LazyVStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in FlightCardSkeletonView() }
            }
        case .success(let offers):
            LazyVStack(spacing: 12) {
                ForEach(rows(for: offers)) { row in
                    switch row {
                    case .flight(let offer):
                        FlightCardView(offer: offer)
                            .onTapGesture { onSelect(offer) }
                    case .promo:
                        DiscountCarouselView(onLearnMore: onLearnMore)
                    }
                }
            }
        case .empty:
            EmptyResultsView()
        case .error(let message):
            ErrorResultsView(message: message, onRetry: onRetry)
        }
    }
}
```

`rows(for:)` is a small pure function that takes `[FlightOffer]` and
returns `[ResultRow]` (`enum ResultRow: Identifiable { case flight(FlightOffer); case promo }`),
inserting a single `.promo` row after the second flight offer (§3.5). It's
a plain function, not something computed inline in the `ForEach`, so it's
trivially unit-testable on its own (e.g. "3 offers in → 4 rows out, promo
at index 2").

**Skeleton shimmer:** `FlightCardSkeletonView` uses the same layout as
`FlightCardView` with gray placeholder blocks instead of text, animated
with a moving `LinearGradient` mask (a small reusable `.shimmer()`
`ViewModifier`) rather than SwiftUI's built-in `.redacted(reason:
.placeholder)`. `.redacted` needs real text/content to redact against,
which doesn't exist yet while the network call is in flight — a
gradient-based shimmer over static gray shapes is the more direct fit here.

**State ownership:** `FlightResultsViewModel` is `ObservableObject` with
`@Published private(set) var state: FlightResultsState = .loading`, and it
kicks off the initial request from `init` (or a `.task` modifier on
`FlightResultsView`, calling `viewModel.load()` — `.task` is preferable
since it's cancellable and tied to the view's lifecycle). Retry calls the
same `load()` again.

**App entry point:** the `App` struct's `body` creates one
`FlightResultsCoordinator` and shows `coordinator.start()` as the root
view — there's no navigation stack to set up since this is the only screen
in the task.

---

## 8. Testing plan (optional extra credit, but worth doing)

All tests run against the local fixture JSON (the LAX→HND response) or a
mocked service — no live network calls in the test target.

1. **Mapping tests**
   - A single-leg group (no layovers) maps to `stops == 0`,
     `stopsLabel == "Non-Stop"`.
   - A two-leg group (one layover) maps to `stops == 1`, `"1 Stop"`.
   - The LAX → HNL → GUM → HND group (three legs, two layovers) maps to
     `stops == 2`, `stopsLabel == "2 Stop"` — this is the specific case
     called out in the brief.
   - `originCode`/`destinationCode` come from the first leg's departure
     and the last leg's arrival, not any leg in between.
   - A group with a malformed/empty `flights` array is dropped, not
     force-unwrapped into a crash.
   - A group with no `price` key at all maps to `nil`, not a crash —
     tested synthetically (§4.4) rather than relying on the checked-in
     fixture happening to contain one.
   - `airlineLogoURL` maps through when `airline_logo` is present, and is
     `nil` (not a crash) when it's missing — `FlightCardView` falls back
     to a generic plane icon in that case.

2. **ViewModel state transition tests**
   - Mocked service returns a non-empty response → state ends at
     `.success` with the expected count.
   - Mocked service returns an empty `best_flights`/`other_flights` →
     state ends at `.empty`.
   - Mocked service throws/returns an HTTP error → state ends at
     `.error`, and Retry re-enters `.loading` then re-runs the request.

3. **Sort logic tests** (if implemented)
   - `sortedOffers(by: .cheapest)` returns ascending price.
   - `sortedOffers(by: .fastest)` returns ascending duration.
   - Equal values preserve original order.

---

## 9. Definition of done

- [ ] All four states (`loading`, `success`, `empty`, `error`) are reachable
      and visually match the Figma reference where a reference exists
      (loading + success)
- [ ] Route header, date/price strip, and discount carousel use hardcoded
      dummy data exactly as specified
- [ ] Flight cards are populated from real SerpApi data via the
      `RawFlightGroup → FlightOffer` mapping, including correct stop counts
- [ ] A `RawFlightGroup` with no `price` field decodes without error and is
      dropped during mapping rather than crashing or showing a garbage price
- [ ] `FlightResultsViewModel` has no import of `UIKit` navigation types and
      no reference to any Coordinator type
- [ ] "Learn more" opens `gozayaan.com` through
      `FlightResultsCoordinatorDelegate`, not directly from the View or
      ViewModel
- [ ] The Coordinator is an `ObservableObject`; `FlightResultsView` never
      imports or references `SFSafariViewController` directly — it only
      reacts to `coordinator.presentedURL` via `.sheet(item:)`
- [ ] API key is not hardcoded in source under version control (loaded from
      a local, gitignored config or `.xcconfig`)
- [ ] Responses are cached locally during development to avoid burning the
      SerpApi trial quota
- [ ] (Optional) Cheapest/fastest sort works and lives in the ViewModel
- [ ] (Optional) Unit tests cover mapping, state transitions, and sorting
