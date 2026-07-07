# WebApiUtils v6.99 — What's New

## B4X Client Code Snippet Generation

New **`/help?format=snippets`** endpoint that auto-generates ready-to-use B4X `HttpJob` subroutines for every registered API endpoint. Each snippet includes proper URL construction, authentication headers, and async job handling — just copy and paste into your B4J/B4A client app.

- GET endpoints generate `j.Download(...)` calls
- POST/PUT endpoints generate `j.PostString(...)` with `application/json` content type
- Path variables (`{id}`) become subroutine parameters
- Bearer token authentication is automatically injected when `Authenticate = "token"` is set in `BuildMethods`
- Powered by the new `GenerateAppSnippet` sub in `HelpHandler`

## Redesigned Swagger UI — Split-Pane Layout

The bundled Swagger UI (`/swagger/`) has been rebuilt as a side-by-side workspace:

- **Left pane:** Interactive Swagger UI console for testing endpoints
- **Right pane:** Live B4X code snippets panel (480px) with:
  - **Sync** button — refreshes snippets from the server
  - **Copy All** button — copies all generated code to clipboard
  - **Hide** button — collapses the sidebar
  - **⚡ Toggle B4X Snippets** button injected into Swagger's top bar (desktop)
  - **Mobile support** — slide-out drawer, floating toggle buttons, dark mode toggle

## Other Changes

- Added `Authenticate = "token"` demo to `PostProduct` in `BuildMethods` to showcase protected endpoint documentation
- Cleaned up commented-out code in `ServeOpenApiJson`
- Updated `manifest.txt` and version strings across all modules
- Comprehensive README documentation of `BuildMethods`, `GenerateAppSnippet`, `#hashtag` deprecation, and Swagger UI setup

## Upgrading

1. Replace `WebApiUtils.b4xlib` in your additional libraries folder
2. Update `HelpHandler` module with the new `GenerateAppSnippet` sub (or re-add from the Custom Class Template)
3. Replace `swagger/index.html` and `swagger/swagger-initializer.js` with the updated versions
4. Run `/help?format=snippets` to verify code generation
5. Navigate to `/swagger/` to see the new split-pane layout
