# WebApiUtils v7.00 — What's New

Highlights since v6.99:

- **Expanded `MH` MiniHtml helpers:** Bootstrap layout, form inputs, cards, badges, alerts, progress bars, spinners, navigation, and HTMX helpers; added responsive images, links, and page components.
- **Cache management:** Added `MC.ClearFromCache` and `MC.ClearAllFromCache` to remove one or matching cached entries.
- **HTTP utilities:** Added `RequestAuthorization`, `ResponseCookie` with Path/SameSite/Secure options, and `ResponseLocation`.
- **Basic Auth flexibility:** `RequestBasicAuth` now accepts an optional caller-provided client Map.
- **Improved response error handling:** Handles an uninitialized `ResponseError` when building API responses.
- **B4X client snippets:** Generated code now uses the matching HTTP method for GET, POST, PUT, and DELETE requests.
- **Help handler template:** Renamed the B4J custom class template from **Help Handler** to **Server Handler (Help)**.
- **Pakai Server example refresh:** Reworked the sample page to build its layout with MiniHtml helpers, removed bundled static HTML page templates, and updated configuration/resource setup.
- **Swagger UI distribution:** Added `release/swagger.zip` with the customized Swagger UI files.
- **Deprecation guidance:** Marked legacy WebApiUtils helpers as deprecated to guide new code toward the newer APIs.

## Upgrade Notes

- Update the WebApiUtils library and the Pakai Server example project together.
- If your code uses newly deprecated methods, they remain available in v7.00; migrate at your convenience to their newer alternatives.
- The sample project now uses the updated EndsMeet configuration/startup APIs (`ApplyConfig`, `StartupMessage`) and MiniHtml 3.10 helpers.
- Extract `release/swagger.zip` into your server's `www/swagger` directory if you want to host the bundled Swagger UI.
