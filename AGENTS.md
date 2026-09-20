# Project Guidelines: Expense Tracker

## UI & Interaction Affordances
- **Editable Values**: Never rely solely on clickability of text. Always attach a visible visual indicator (such as an edit pencil icon or chevron) next to editable fields or tap targets.
- **Progressive Complexity**: Keep the default flow zero-friction for single-source tracking. Complex tracking modes (e.g. multi-wallet cash tracking) must be opt-in via a Settings toggle.

## Architecture & State Testing
- **Async Storage Resilience**: When state controllers persist data to `SharedPreferences` or local disk, always provide synchronous test-only mutators (e.g. `setXForTest`) to prevent asynchronous deadlocks during `testWidgets` execution.

## Visual UI & Screenshot Navigation Index (AI Map)
- **Consult `UI_MAP.md` First**: Whenever the user provides a screenshot, asks to modify a visual component, or iterates on UI elements, the agent MUST consult `UI_MAP.md` before making edits. `UI_MAP.md` contains the authoritative visual ASCII wireframes, screenshot filename matching table, component file paths, and fast modification recipes.
- **Semantic UIKeys**: All primary interactive widgets and screen containers are annotated with strongly-typed `UIKeys` located in `lib/core/constants/ui_keys.dart`. When targeting elements in tests or widget trees, use `UIKeys.<keyName>`.
