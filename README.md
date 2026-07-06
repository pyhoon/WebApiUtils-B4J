# WebApiUtils
Version: 6.96

A B4J utility library for the [Pakai Server](https://github.com/pyhoon/pakai-server-b4j) framework. \
Provides HTTP request/response handling, JSON/XML APIs, cookie management, authentication, file uploads, HTML templating, database ORM integration, and auto-generated API documentation.

---

## Features

- **JSON/XML API Framework** — Helper functions for generating JSON/XML responses
- **HelpHandler class template** — SPA-like experience using HTMX partial page updates, zero custom JavaScript needed
- **Auto-Generated API Docs** — Interactive `/help` page with Swagger-like test console (Alpine.js + HTMX) 
- **OpenAPI 3.0 JSON** at `/help?format=openapi`
- **Swagger UI** — Bundled Swagger UI in `Objects/www/swagger/`
- **Authentication** — Basic Auth, Bearer Token, API Key extraction
- **CSRF Protection** — Token validation utilities
- **File Uploads** — Multipart file handling
- **HTML Templating** — Token replacement (`$KEY$`, `@VIEW@`, `@TAG@`, etc.) + MiniHtml builder
- **Code Snippets** — Templates for rapidly scaffolding new API and Web handlers

---

## Architecture

```
Code modules
└── WebApiUtils.bas   — Core utilities (responses, parsing, cookies, auth, etc.)

Handlers (Class templates)
└── HelpHandler.b4x_excluded   — /help auto-generated docs

Code Snippets (with Entity placeholders)
├── Handler (Api).txt   — Code Snippets for Api Handler
└── Handler (Web).txt   — Code Snippets for Web Handler
```

### Dependencies

| Library       |
|---------------|
| JavaObject    |
| Json          |
| jStringUtils  |
| Xml2Map       |
---

## Getting Started

1. **Create a new Pakai Server Api project** using the template
2. **Add WebApiUtils.b4xlib** from the `release/` folder to your B4J IDE
3. **Configure** `config.ini` (copied from `config.example` on first run):
   ```ini
   PORT=8080
   ROOT_URL=http://127.0.0.1
   ROOT_PATH=
   API_NAME=api
   HOME_TITLE=My App
   APP_TITLE=MyApp
   ```
4. **Add Help Handler** from menu **Project -> Add New Module -> Class Module -> Help Handler**
5. **Run** the project
6. **HelpHandler** generates API handlers and serves documentation at `/help`

## Use Swagger-UI

1. **Swagger-UI** is integrated inside HelpHandler
2. **Download swagger-ui** and copy `/dist` to `www` folder of the project. Rename the folder `/dist` to `/swagger`
3. **Edit swagger-initializer.js** by replacing the url of petstore:
```javascript
  window.ui = SwaggerUIBundle({
      // Tell Swagger to request the raw OpenAPI JSON specification from HelpHandler
    //url: "https://petstore.swagger.io/v2/swagger.json",
    url: "../help?format=openapi", 
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  });
```
4. **Ready to use /swagger folder** is also available in `/source/Objects/www`
5. **Run the project and navigate to** `http://127.0.0.1:8080/swagger`
6. **HelpHandler** generates an **OpenAPI 3.0 Specification structure** json from endpoint `/help?format=openapi` to serve the UI

## Response Format

All API responses use a consistent envelope (VerboseMode):

### JSON Success
```json
{
  "a": 200,
  "s": "success",
  "m": "Products retrieved successfully",
  "e": null,
  "r": [ { "id": 1, "product_name": "Hammer", ... } ]
}
```

### JSON Error
```json
{
  "a": 422,
  "s": "error",
  "m": "Query execution error",
  "e": "Column 'xyz' not found",
  "r": null
}
```

Envelope keys are configurable via `ResponseKeys` (default: `a`, `s`, `m`, `e`, `r`, `t`) and `ResponseKeysAlias` in `HttpResponseMessage`.

---

## API Response Helpers

The `ReturnHttpResponse` sub is the central response handler. It reads `HRM` properties and formats accordingly:

| HRM Property      | Type     | Description                            |
|-------------------|----------|----------------------------------------|
| `ResponseCode`    | Int      | HTTP status code                       |
| `ResponseMessage` | String   | Success message                        |
| `ResponseStatus`  | String   | `"success"` or `"error"`               |
| `ResponseData`    | List     | Array result for collection endpoints  |
| `ResponseObject`  | Map      | Single object result                   |
| `ResponseError`   | Object   | Error details                          |
| `PayloadType`     | String   | `"application/json"` or `"application/xml"` |
| `VerboseMode`     | Boolean  | Include extra debug fields             |
| `OrderedKeys`     | Boolean  | Preserve key ordering                  |

Helper methods for common HTTP responses:
- `ReturnBadRequest(HRM, Response)` — 400
- `ReturnAuthorizationRequired(HRM, Response)` — 401
- `ReturnTokenExpired(HRM, Response)` — 401
- `ReturnMethodNotAllow(HRM, Response)` — 405
- `ReturnErrorUnprocessableEntity(HRM, Response)` — 422
- `ReturnContent(Content, ContentType, Response)` — raw content
- `ReturnHtml(Str, Response)` — HTML content
- `ReturnFileInline(Ins, FileName, Response)` — stream file inline
- `ReturnFileAttachment(Ins, FileName, Response)` — download attachment

---

## Auto-Generated Documentation

The `HelpHandler` at `/help` reads `#hashtag` comments from handler source files to build:
- An interactive API console (powered by Alpine.js + HTMX)
- Color-coded HTTP verbs (GET=blue, POST=green, PUT=orange, DELETE=red)
- Request builders and response viewers
- OpenAPI 3.0 spec at `/help?format=openapi`

Enable verbose mode in config for richer documentation:

```ini
API_VERBOSE_MODE=True
```

---

## License

MIT License — Copyright (c) 2022-2026 Poon Yip Hoon (Aeric). See [LICENSE](LICENSE).
