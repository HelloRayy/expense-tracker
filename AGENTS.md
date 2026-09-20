# Project Guidelines: Expense Tracker

## UI & Interaction Affordances
- **Editable Values**: Never rely solely on clickability of text. Always attach a visible visual indicator (such as an edit pencil icon or chevron) next to editable fields or tap targets.
- **Progressive Complexity**: Keep the default flow zero-friction for single-source tracking. Complex tracking modes (e.g. multi-wallet cash tracking) must be opt-in via a Settings toggle.

## Architecture & State Testing
- **Async Storage Resilience**: When state controllers persist data to `SharedPreferences` or local disk, always provide synchronous test-only mutators (e.g. `setXForTest`) to prevent asynchronous deadlocks during `testWidgets` execution.
