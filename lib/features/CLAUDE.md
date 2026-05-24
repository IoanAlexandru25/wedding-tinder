# features/

Each subfolder is one user-facing feature: its screens, plus the local
widgets that only that feature uses.

## Folder pattern

```
features/<feature>/
  <feature>_screen.dart        ← the screen(s) — top-level widgets
  widgets/                     ← widgets used only inside this feature
    <component>.dart
  <feature>_providers.dart     ← (optional) feature-scoped providers if they
                                 don't belong in lib/providers/
```

Cross-cutting providers (auth, wedding, vendors, favorites) live in
`lib/providers/`. Feature-scoped providers (e.g., a sign-up form's loading
state) can stay co-located with the feature.

## Screen responsibilities

- Read providers via `ref.watch` / `ref.read`. Render their data.
- Never call Firestore or services directly. Always go through a provider.
- Handle `.when(loading:, error:, data:)` for async data. Use `AppLoading`,
  `AppErrorState`, `AppEmptyState` from `core/widgets/`.
- Romanian UI strings, English code.

## When to extract a widget

If a UI block is used twice within a screen — make it a private widget
(`_Foo` in the same file). If used in two screens within the same feature
— promote to `features/<feature>/widgets/`. If used in two different
features — promote to `core/widgets/`.

## Two-strikes for design tokens too

If a hardcoded color, padding, or text style appears twice, lift it into
`AppColors` / `AppSpacing` / `AppTypography`. No magic values in feature code.
