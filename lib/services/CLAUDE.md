# services/

The I/O boundary. Everything that talks to Firestore, Firebase Auth, or
local assets lives here. Services are the **only** place the rest of the
app touches external systems.

## Rules

1. **Services return data or throw.** Never return `null` for an error case
   — define a typed exception (`AuthException`, `WeddingException`,
   `VendorLoadException`) and throw it. Providers wrap the throw into
   `AsyncError`.
2. **No UI imports.** Services never import `material.dart` or any widget.
   They deal in models, not visuals.
3. **No Riverpod imports.** Services are plain classes. Providers wrap them.
4. **One service per external concern.**
   - `AuthService` — Firebase Auth (sign in, sign up, sign out, current user
     stream).
   - `WeddingService` — `weddings/` collection: create with invite code,
     join by code, listen to wedding doc, favorites CRUD on the subcollection.
   - `VendorRepository` — loads the vendor catalog from `assets/data/vendors.json`
     once, caches it, and exposes filter methods.

## Firestore document layout

See `docs/ARCHITECTURE.md` "Firestore schema" for the full structure.
Service methods translate between Firestore `DocumentSnapshot`s and our
model classes — UI never sees raw Firestore types.

## Invite codes

Format: `WED-XXXX` where X is uppercase alphanumeric, excluding ambiguous
characters (0, O, I, 1). `WeddingService.createWedding` generates the code
and retries on the (extremely unlikely) collision.
