# Notes

## AI tool used
Claude Code (Sonnet 5), used interactively in the terminal across several
sessions: spec correction, MVVM+Coordinator implementation, UI polish passes,
unit/UI test suites, and error-message copy.

## Decisions I made where the task left things open

The task explicitly leaves several things open — route/date, API key
location, price formatting, what "empty" means, how `best_flights`/
`other_flights` become one list — so here's what I chose and why:

- **Route/date:** fixed LAX→HND, 2026-09-30. Chosen because that search's
  real SerpApi response happens to cover all three stop counts the design
  needs (`best_flights` all non-stop, `other_flights` has both a clean
  1-stop and a genuine 2-stop) from a single fixture, rather than stitching
  several together.
- **API key location:** `Config/Secrets.xcconfig`, gitignored, with a
  `Secrets.xcconfig.example` checked in as the template. Reasoning: this repo
  goes to GoZayaan over a public/shared git host, and a SerpApi key is a
  personal credential tied to my account's trial quota — if it were committed,
  anyone with repo access could exhaust it (or worse, it'd sit in git history
  forever even after "removing" it later). Keeping it out of version control
  and reading it at build time via `APIConfig` means the app never has the
  key hard-coded in source, and `LiveFlightSearchService` throws a typed
  `.missingAPIKey` error instead of crashing if it's absent — which is also
  exactly the DEBUG path `FixtureFlightSearchService` sidesteps entirely.
- **`best_flights` + `other_flights` → one list:** concatenated best-first.
  "Best" is Google's own ranking, so keeping it first gives a sensible
  default order for free — the UI has no badge distinguishing the two
  groups anyway.
- **Price formatting:** grouped decimal (`37,400`) with the currency code
  shown separately, not a localized currency symbol — matches the design's
  `BDT 70,129` style rather than `NumberFormatter`'s currency style.
- **Empty state:** any group that fails to map (missing price, unparseable
  times, etc.) is dropped rather than crashing the screen; `.empty` fires
  when the fully-mapped offer list is empty, not just when the raw arrays
  are.
