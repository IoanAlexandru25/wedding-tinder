# core/

Design system + cross-cutting primitives. **No business logic, no I/O.**
Everything here is safe to import from any feature.

## What's where

- `theme/` — design tokens (colors, typography, spacing, radii) + `ThemeData`.
  Reference `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii` everywhere
  instead of raw values.
- `widgets/` — reusable UI primitives. Compose feature widgets out of these,
  don't build one-off versions.
- `constants/` — `VendorCategory` enum, list of județe, shared Romanian
  strings. Feature-specific strings stay in the feature.
- `utils/` — pure helper functions (formatters, invite-code generator).

## When to add a new widget here

Two-strikes rule: if a UI element appears in **two** feature folders, lift it
to `core/widgets/`. Don't pre-emptively create components for hypothetical
reuse.

When adding one:
1. Make it dumb — no providers, no Firestore. Inputs in, widget out.
2. Style it via `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`. Never
   hardcode hex / px values.
3. Match the editorial direction (`docs/ARCHITECTURE.md`): no gradients on
   buttons, no glass effects, no full-pill chips, no Material ripples.

## When to add a token

A new spacing/color/radius constant goes in if it's reused in 2+ places.
One-off values stay local to the call site only if they're geometrically
necessary (e.g., a photo's intrinsic aspect ratio).

## Editorial primitives

`EditorialHeading` does the signature mixed italic + regular Cormorant
composition. Use it for hero moments (sign-up titles, swipe-card vendor
names, empty states). Don't reach for plain `Text` with a Cormorant style
when the content is a heading — that misses the brand.
