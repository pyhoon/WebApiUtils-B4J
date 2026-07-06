# WebApiUtils
Version: 6.96

A B4J library for building REST APIs with the [Pakai Server](https://github.com/pyhoon/pakai-server-b4j) framework. Provides HTTP request/response handling, JSON/XML parsing, cookie management, authentication, file uploads, HTML templating, and auto-generated OpenAPI 3.0 documentation with Swagger UI integration.

---

## Library Contents

The `WebApiUtils.b4xlib` contains:

| File | Description |
|------|-------------|
| `WebApiUtils.bas` | Core utility module — request parsing, response helpers, auth, validation, templating, file I/O |
| `HelpHandler.b4x_excluded` | Auto-generated API documentation handler (available as a Custom Class Template in the IDE) |
| `Snippets/Handler (Api).txt` | Code snippet template for creating new REST API handlers |
| `Snippets/Handler (Web).txt` | Code snippet template for creating new Web UI handlers |
| `LICENSE` | MIT License |

> **Note:** Other modules like `ORM.bas`, `MH.bas`, `MC.bas`, `ProductsHandler`, `CategoriesHandler`, etc. are part of the **Pakai Server template project**, not this library.

### Dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| JavaObject | 2.07 | Java interop |
| Json | 1.30 | JSON parsing |
| jStringUtils | 1.03 | String utilities |
| Xml2Map | 1.01 | XML parsing |

---

## Features

- **Unified JSON/XML Response Envelope** — Consistent format with configurable key names
- **Ordered JSON/XML Serialization** — Preserves key order via `__order` metadata
- **Request Parsing** — JSON, XML, URL-encoded, multipart form data and file uploads
- **Authentication Helpers** — Basic Auth, Bearer Token, API Key extraction
- **Cookie Management** — Read/write cookies with SameSite, HttpOnly, Secure flags
- **CSRF Protection** — Token validation utilities
- **HTML Templating** — Token replacement (`$KEY$`, `@VIEW@`, `@TAG@`)
- **Validation** — Email, content type (JSON/XML), integer, HTTP method validation
- **Auto-Generated API Documentation** — Interactive API console served by `HelpHandler` with OpenAPI 3.0 JSON spec
- **Swagger UI Integration** — Works with the Swagger UI distribution for a full OpenAPI explorer
- **Code Snippets** — Template files for rapidly scaffolding new API and Web handlers

---

## Getting Started

### 1. Create a Pakai Server project

Use the Pakai Server B4J template or create a new B4J server project.

### 2. Add WebApiUtils as a library

Copy `release/WebApiUtils.b4xlib` to your B4J additional libraries folder, or use the IDE's library manager.

The library registers a **Custom Class Template** named `Help Handler` — you can add `HelpHandler` to any project via `Project → Add New Module → Help Handler`.

### 3. Using HelpHandler (auto-generated API docs)

`HelpHandler` is a class that:
- Reads `#hashtag` metadata comments from your handler modules
- Builds an interactive HTML documentation page at `/help` (powered by Alpine.js + HTMX)
- Serves an **OpenAPI 3.0 JSON specification** at `/help?format=openapi`

```b4x
' In your main server module
App.Get("/help", "HelpHandler")
```

To register API handlers for documentation discovery, add your handler name to the `Handlers` list in `HelpHandler.Initialize`:

```b4x
Public Sub Initialize
    Handlers.Initialize
    Handlers.Add("ProductsApiHandler")
    Handlers.Add("CategoriesApiHandler")
    Handlers.Add("FindApiHandler")
End Sub
```

### 4. Customizing API Documentation with BuildMethods

The `BuildMethods` sub (`HelpHandler.bas:307`) is the **recommended way** to define endpoint metadata for both the interactive `/help` page and the OpenAPI 3.0 JSON spec at `/help?format=openapi`. Unlike `ReadHandlers` which parses `#hashtag` comments from source code at compile time (Debug mode only), `BuildMethods` constructs endpoint properties programmatically and works in **both Debug and Release modes** without source file access.

#### How BuildMethods works

Each endpoint is represented as a **Map** of properties. You retrieve an existing entry, modify its properties, and replace it. The key helper methods:

| Method | Purpose |
|--------|---------|
| `RetrieveMethod(Group, SubName)` | Gets the method's default Map (auto-populated by parsing the sub signature). If not found, calls `CreateMethodProperties` to build a new Map. |
| `CreateMethodProperties(Group, SubName)` | Creates a fresh Map with auto-detected Verb (from sub name prefix like `Get`, `Post`, `Put`, `Delete` or `#hashtag` overrides) and Parameters (from sub arguments). |
| `ReplaceMethod(Method)` | Finds existing entry by method name and replaces it in-place (keeping list order). |
| `RemoveMethodAndReAdd(Method)` | Removes then appends to end of list (for ordering control). |
| `FindMethod(MethodName)` | Returns the index of a method in `AllMethods`, or -1. |

#### Available Method Map Keys

| Key | Description |
|-----|-------------|
| `Group` | Heading/group name for categorizing endpoints (e.g., "Products", "Categories") |
| `Name` | URL path segment override (defaults to Group). Used for the `/api/{name}/...` route |
| `Method` | Sub name (read-only identifier for matching) |
| `Desc` | Description text shown in the accordion header |
| `Verb` | HTTP method: `GET`, `POST`, `PUT`, `DELETE` |
| `Params` | Parameter display string like `"id [Int]"` or `"Not required"` |
| `Format` | JSON string showing the expected request body format (displayed as a sample) |
| `Body` | JSON string with default values for the request body editor |
| `Elements` | JSON array string for URL path elements (e.g., `["{id}"]`) |
| `Noapi` | Boolean — set `True` for routes outside `/api/` (uses `$SERVER_URL$/` instead) |
| `Expected` | HTML string describing expected response codes |
| `FileUpload` | File upload type (`"image"`, `"pdf"`) — shows upload UI in the docs page |
| `Authenticate` | Auth type (`"basic"`, `"token"`, `"apikey"`) — shows auth badge |

#### Example: Adding a custom endpoint

```b4x
Private Sub BuildMethods
    ' --- Using RetrieveMethod (auto-detects from sub signature) ---
    Dim Method As Map = RetrieveMethod("Products", "GetProducts")
    Method.Put("Desc", "Read all Products")
    ReplaceMethod(Method)

    ' --- Adding path element (URL variable) ---
    Dim Method As Map = RetrieveMethod("Products", "GetProductById (id As Int)")
    Method.Put("Desc", "Read one Product by id")
    Method.Put("Elements", $"["{id}"]"$)
    ReplaceMethod(Method)

    ' --- Creating from scratch with CreateMethodProperties ---
    ' Useful when there is no matching sub (e.g. sub name doesn't start with a verb)
    ' The Verb will be inferred from the sub name prefix (Get, Post, Put, Delete)
    ' or from #hashtag overrides like '#POST
    Dim Method As Map = CreateMethodProperties("Products", "PostProduct")
    Method.Put("Desc", "Add new Product")
    Dim FormatMap As Map = CreateMap("category_id": 3, "product_code": "E001", "product_name": "Wireless Mouse", "product_price": 29.99)
    Method.Put("Format", FormatMap.As(JSON).ToString)
    Method.Put("Body", FormatMap.As(JSON).ToString)
    ReplaceMethod(Method)

    ' --- POST/PUT endpoints with request body examples ---
    Dim Method As Map = RetrieveMethod("Find", "SearchByKeywords ' #post")
    Dim FormatMap As Map = CreateMap("keyword": "text")
    Dim BodyMap As Map = CreateMap("keyword": "")
    Method.Put("Format", FormatMap.As(JSON).ToString)
    Method.Put("Body", BodyMap.As(JSON).ToString)
    Method.Put("Desc", "Filter Products (with Category name)")
    Method.Put("Expected", GetExpectedResponse(""))
    ReplaceMethod(Method)

    ' --- Move an endpoint to the end of list ---
    Dim Method As Map = RetrieveMethod("Categories", "DeleteCategoryById (id As Int)")
    Method.Put("Desc", "Delete Category by id")
    Method.Put("Elements", $"["{id}"]"$)
    RemoveMethodAndReAdd(Method)
End Sub
```

#### How it connects to OpenAPI

The `ServeOpenApiJson` sub (`HelpHandler.bas:1200`) iterates through the same `AllMethods` list populated by `BuildMethods`. For each entry it:
- Calls `GenerateVerbSection` to extract Verb, Link, Description, Params, Format, Body
- Builds dynamic OpenAPI path parameters from `{id}` / `{category}` placeholders in the URL
- Constructs `requestBody` schemas for POST/PUT endpoints with field names and types
- Assembles the full OpenAPI 3.0 JSON root with `openapi`, `info`, and `paths` keys

This means **any endpoint defined in BuildMethods automatically appears in both the interactive `/help` page and the Swagger UI `/swagger/` page**.

### 5. Swagger UI Setup

The `HelpHandler` serves OpenAPI 3.0 JSON at `/help?format=openapi`. To use Swagger UI:

1. Download the [Swagger UI dist folder](https://github.com/swagger-api/swagger-ui/tree/master/dist)
2. Place it in your project at `Objects/www/swagger/`
3. Modify `swagger-initializer.js` to point to the HelpHandler endpoint:

```js
window.onload = function() {
  window.ui = SwaggerUIBundle({
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
};
```

4. Navigate to `/swagger/` to access the Swagger UI explorer

---

## WebApiUtils API Reference

### Response Helpers

```b4x
' Central response handler — formats JSON or XML with envelope keys
WebApiUtils.ReturnHttpResponse(HRM As HttpResponseMessage, Response As ServletResponse)

' Shorthand HTTP responses
WebApiUtils.ReturnSuccess(Message, Response, Code, Data)
WebApiUtils.ReturnError(Message, Response, Code, Error)
WebApiUtils.ReturnConnect(Message, Response)
WebApiUtils.ReturnBadRequest(Message, Response)                     ' 400
WebApiUtils.ReturnAuthorizationRequired(Message, Response)          ' 401
WebApiUtils.ReturnTokenExpired(Message, Response)                   ' 401
WebApiUtils.ReturnMethodNotAllow(Message, Response)                 ' 405
WebApiUtils.ReturnErrorUnprocessableEntity(Message, Response)       ' 422
WebApiUtils.ReturnErrorCredentialNotProvided(Message, Response)     ' 400
WebApiUtils.ReturnErrorExecuteQuery(Message, Response)              ' 422
WebApiUtils.ReturnLocation(Location, Response)                      ' 302 redirect
WebApiUtils.ReturnContent(Content, ContentType, Response)           ' Raw content
WebApiUtils.ReturnHtml(Str, Response)                               ' HTML page
WebApiUtils.ReturnHtmlBody(Cont, Response)                          ' HTML from HttpResponseContent
WebApiUtils.ReturnHtmlPageNotFound(Response)                        ' HTML 404 page
WebApiUtils.ReturnHtmlBadRequest(Response)                          ' HTML 400 page
WebApiUtils.ReturnHtmlMethodNotAllowed(Response)                    ' HTML 405 page
WebApiUtils.ReturnOutputStream(Ins, Response)                       ' Binary stream
WebApiUtils.ReturnFileInline(Ins, FileName, Response)               ' Inline file
WebApiUtils.ReturnFileAttachment(Ins, FileName, Response)           ' Download attachment
```

### HttpResponseMessage Structure

| Field | Type | Description |
|-------|------|-------------|
| `ResponseCode` | Int | HTTP status code |
| `ResponseMessage` | String | Success/status message |
| `ResponseStatus` | String | `"success"` or `"error"` |
| `ResponseType` | String | Response type identifier |
| `ResponseError` | Object | Error details |
| `ResponseData` | List | Collection result |
| `ResponseObject` | Map | Single object result |
| `ResponseBody` | Object | Raw response body |
| `PayloadType` | String | `"application/json"` or `"application/xml"` |
| `ContentType` | String | Response content type |
| `XmlRoot` | String | XML root element name |
| `XmlElement` | String | XML element name |
| `VerboseMode` | Boolean | Include debug fields |
| `OrderedKeys` | Boolean | Preserve key ordering |
| `ResponseKeys` | List | Custom envelope key names |
| `ResponseKeysAlias` | List | Envelope key aliases |

### Request Parsing

```b4x
' Read request body
Dim text As String = WebApiUtils.RequestDataText(Request)     ' Raw text
Dim json As Map = WebApiUtils.RequestDataJson(Request)        ' JSON → Map
Dim xml As Map = WebApiUtils.RequestDataXml(Request)          ' XML → Map
Dim data As Map = WebApiUtils.RequestData(Request)            ' JSON (alias)

' Parse strings
Dim parsedMap As Map = WebApiUtils.ParseJSON(text)
Dim parsedMap As Map = WebApiUtils.ParseXML(text)

' Multipart uploads
Dim part As Part = WebApiUtils.RequestMultiPart(Request, Folder, MaxSize)
Dim parts As List = WebApiUtils.RequestMultipartList(Request, Folder, MaxSize)
Dim formData As Map = WebApiUtils.RequestMultipartData(Request, Folder, MaxSize)

' Cookies
Dim cookies As Map = WebApiUtils.RequestCookie(Request)
```

### Authentication

```b4x
' Extract credentials
Dim auth As Map = WebApiUtils.RequestBasicAuth(AuthsList)        ' Basic Auth
Dim token As String = WebApiUtils.RequestBearerToken(Request)    ' Bearer token
Dim apiKey As String = WebApiUtils.RequestApiKey(Request)        ' X-API-Key header
Dim accessToken As String = WebApiUtils.RequestAccessToken(Request) ' Authorization header
```

### Cookie Writing

```b4x
' Simple cookie
WebApiUtils.ReturnCookie(Key, Value, MaxAge, HttpOnly, Response)

' Full control
WebApiUtils.ReturnCookie2(Key, Value, Path, SameSite, MaxAge, HttpOnly, Secure, Response)
```

### URL / Encoding

```b4x
Dim encoded As String = WebApiUtils.EncodeURL(str)
Dim decoded As String = WebApiUtils.DecodeURL(str)
Dim b64 As String = WebApiUtils.EncodeBase64(bytes)
Dim bytes() As Byte = WebApiUtils.DecodeBase64(str)
```

### Validation

```b4x
Dim valid As Boolean = WebApiUtils.Validate_Email("user@example.com")
Dim valid As Boolean = WebApiUtils.ValidateContent(text, WebApiUtils.MIME_TYPE_JSON)
Dim valid As Boolean = WebApiUtils.CheckInteger(value)
Dim valid As Boolean = WebApiUtils.CheckAllowedVerb(supportedMethods, method)
Dim valid As Boolean = WebApiUtils.Ch‌eckMaxElements(elements, maxCount)
Dim valid As Boolean = WebApiUtils.ValidateCsrfToken(sessionName, headerName, Request)
```

### HTML Templating

```b4x
' Replace $KEY$ tokens with Map values
Dim result As String = WebApiUtils.BuildHtml(template, settings)

' Replace @VIEW@, @DOCVIEW@, @SCRIPT@, @KEY@ placeholders
Dim result As String = WebApiUtils.BuildView(html, viewContent)
Dim result As String = WebApiUtils.BuildDocView(html, docViewContent)
Dim result As String = WebApiUtils.BuildScript(html, scriptContent)
Dim result As String = WebApiUtils.BuildScript2(html, script, settings)
Dim result As String = WebApiUtils.BuildTag(html, "KEY", value)
Dim result As String = WebApiUtils.BuildCsrfToken(html, token)

' Regex-based $KEY$ replacement
Dim result As String = WebApiUtils.ReplaceMap(base, replacements)
```

### File I/O

```b4x
Dim text As String = WebApiUtils.ReadTextFile("file.txt")             ' From assets
WebApiUtils.WriteTextFile("file.txt", contents)                       ' To File.DirApp
WebApiUtils.WriteAssetFile("file.txt", contents)                      ' To www/
WebApiUtils.DeleteAssetFile("file.txt")
Dim exists As Boolean = WebApiUtils.AssetFileExist("file.txt")
Dim map As Map = WebApiUtils.ReadMapFile(File.DirApp, "config.ini")
```

### Utilities

```b4x
Dim guid As String = WebApiUtils.GUID                                 ' New GUID
Dim dt As String = WebApiUtils.CurrentDateTime                        ' yyyy-MM-dd HH:mm:ss
Dim ts As String = WebApiUtils.FileNameByCurrentDateTime              ' yyyyMMddHHmmss
Dim tz As String = WebApiUtils.GetCurrentTimezone                     ' Timezone offset
Dim json As String = WebApiUtils.Object2Json(obj)                     ' Object → JSON string
Dim proper As String = WebApiUtils.ProperCase("word")                 ' Capitalize first letter
Dim escaped As String = WebApiUtils.EscapeHtml("<tag>")               ' HTML entity escape
Dim escaped As String = WebApiUtils.EscapeXml("<tag>")                ' XML entity escape
Dim clean As String = WebApiUtils.LinearizeXML(xmlText)               ' Strip XML comments/whitespace
Dim cropped() As String = WebApiUtils.CropElements(full, startIndex)  ' URL element cropping
Dim pathParts() As String = WebApiUtils.GetApiPathElements(path)
Dim uriParts() As String = WebApiUtils.GetUriElements(uri)
```

### MIME Type Constants

```b4x
WebApiUtils.MIME_TYPE_HTML  = "text/html"
WebApiUtils.MIME_TYPE_JSON  = "application/json"
WebApiUtils.MIME_TYPE_XML   = "application/xml"
WebApiUtils.MIME_TYPE_PDF   = "application/pdf"
WebApiUtils.MIME_TYPE_PNG   = "image/png"
```

### Response Envelope Keys

```b4x
WebApiUtils.RESPONSE_ELEMENT_MESSAGE = "m"
WebApiUtils.RESPONSE_ELEMENT_CODE    = "a"
WebApiUtils.RESPONSE_ELEMENT_STATUS  = "s"
WebApiUtils.RESPONSE_ELEMENT_TYPE    = "t"
WebApiUtils.RESPONSE_ELEMENT_ERROR   = "e"
WebApiUtils.RESPONSE_ELEMENT_RESULT  = "r"
```

---

## `#hashtag` Comments (Deprecated)

`HelpHandler` originally supported **`#hashtag` comments** in handler source files to provide endpoint metadata. These are parsed by `ReadHandlers` → `ParseHashtags` at runtime.

> **⚠ Deprecated:** `#hashtag` parsing is **Debug mode only** (`#If Debug` in `ShowHelpPage`), requires the `.bas` source files to be present at runtime, and is fragile (can break from simple comment changes). **Use `BuildMethods` instead** — it works in both Debug and Release, doesn't depend on source files, and gives full control over all endpoint properties.

### How ParseHashtags works

`ReadHandlers` (`HelpHandler.bas:390`) scans each registered handler's `.bas` file line-by-line:

1. Lines containing `Sub` with a verb prefix (`Get`, `Post`, `Put`, `Delete`) or `#VERB` override are picked up as endpoint entries
2. Subsequent comment lines containing `#keyword=value` are passed to `ParseHashtags` which attaches metadata to the **last detected method**
3. Boolean-only hashtags (`#hide`, `#noapi`) are set to `True` when present

### Supported hashtag keywords

| Keyword | Type | Example |
|---------|------|---------|
| `#name` | `=value` | `#name = Products` (URL path segment) |
| `#desc` | `=value` | `#desc = List all products` (accordion header text) |
| `#version` | `=value` | `#version = 2.0` (version suffix) |
| `#elements` | `=value` | `#elements = ["{id}"]` (path elements as JSON array) |
| `#body` | `=value` | `#body = {"key": ""}` (JSON body for editor) |
| `#format` | `=value` | `#format = {"key": "value"}` (JSON format example) |
| `#fileupload` | `=value` | `#fileupload = image` (shows upload UI) |
| `#authenticate` | `=value` | `#authenticate = token` (shows auth badge) |
| `#hide` | flag | hides the endpoint from the docs page |
| `#noapi` | flag | endpoint is outside `/api/` path |

### Example in source code

```b4x
'#POST /api/products
' Creates a new product in the database
'#desc = Add new Product
'#authenticate = token
'#elements = []
'#body = {"category_id": 1, "product_code": "E001", "product_name": "Wireless Mouse", "product_price": 29.99}
'#format = {"category_id": 3, "product_code": "CODE", "product_name": "Name", "product_price": 0}
Private Sub PostProduct
```

For Release builds, convert to `BuildMethods`:

```b4x
Dim Method As Map = CreateMethodProperties("Products", "PostProduct")
Method.Put("Desc", "Add new Product")
Method.Put("Authenticate", "token")
Dim FormatMap As Map = CreateMap("category_id": 3, "product_code": "E001", "product_name": "Wireless Mouse", "product_price": 29.99)
Dim BodyMap As Map = CreateMap("category_id": 3, "product_code": "", "product_name": "", "product_price": 0)
Method.Put("Format", FormatMap.As(JSON).ToString)
Method.Put("Body", BodyMap.As(JSON).ToString)
ReplaceMethod(Method)
```

---

## Creating a New API Handler

Using the `Handler (Api).txt` snippet template in the IDE.

### 1. Create a Model class

```b4x
' MyModel.bas
Sub Class_Globals
    Private DB As MiniORM
End Sub

Public Sub Initialize
    DB = Main.DB
End Sub

Public Sub Read As List
    DB.Open
    DB.Table = "tbl_my_entities"
    DB.Query
    Return DB.Results
End Sub

Public Sub Create (Name As String)
    DB.Open
    DB.Table = "tbl_my_entities"
    DB.Columns = Array("name")
    DB.Parameters = Array(Name)
    DB.ReturnRow = True
    DB.Save
End Sub
```

### 2. Create an API Handler class

```b4x
' MyApiHandler.bas
Sub Class_Globals
    Private Path As String
    Private Method As String
    Private Request As ServletRequest
    Private Response As ServletResponse
    Private HRM As HttpResponseMessage
    Private Model As MyModel
End Sub

Public Sub Initialize
    HRM = Main.HRM
    Model.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
    Request = req
    Response = resp
    Path = Request.RequestURI
    Method = Request.Method.ToUpperCase
    If Path = "/api/myentities" And Method = "GET" Then
        GetEntities
    Else If Path = "/api/myentities" And Method = "POST" Then
        PostEntity
    Else If Path.StartsWith("/api/myentities/") And Method = "GET" Then
        GetEntityById
    Else If Path.StartsWith("/api/myentities/") And Method = "PUT" Then
        PutEntityById
    Else If Path.StartsWith("/api/myentities/") And Method = "DELETE" Then
        DeleteEntityById
    Else
        WebApiUtils.ReturnBadRequest(HRM, Response)
    End If
End Sub

Private Sub GetEntities
    Dim Data As List = Model.Read
    If Model.Error.IsInitialized Then
        HRM.ResponseCode = 422
        HRM.ResponseError = Model.Error.Message
    Else
        HRM.ResponseCode = 200
        HRM.ResponseData = Data
    End If
    WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub
```

### 3. Register in the server module

```b4x
App.Rest("/api/myentities/*", MyApiHandler)

' Or selectively:
' App.Route("/api/myentities", MyApiHandler, Array("get", "post"))
' App.Get("/api/myentities/*", MyApiHandler)
' etc.
```

### 4. Register for HelpHandler discovery

Add your handler name to the `Handlers` list in `HelpHandler.Initialize`, then define endpoint metadata in `BuildMethods`:

```b4x
' In HelpHandler.Initialize
Handlers.Add("MyApiHandler")

' In HelpHandler.BuildMethods
Dim Method As Map = RetrieveMethod("MyEntity", "GetEntities")
Method.Put("Desc", "List all entities")
ReplaceMethod(Method)
```

---

## Response Format

All API responses use a consistent envelope. Default key names:

```json
{
  "a": 200,
  "s": "success",
  "m": "Products retrieved successfully",
  "e": null,
  "r": [ { "id": 1, "product_name": "Hammer" } ]
}
```

```json
{
  "a": 422,
  "s": "error",
  "m": "Query execution error",
  "e": "Column 'xyz' not found",
  "r": null
}
```

Keys can be customized via `ResponseKeys` and `ResponseKeysAlias` in `HttpResponseMessage`.

---

## Snippet Templates

The library includes two snippet templates accessible from the B4J IDE:

### Handler (Api).txt
A full CRUD API handler template with route dispatching for GET, POST, PUT, DELETE. Uses `$Endpoint$` / `$endpoints$` placeholders for find-and-replace. Includes:
- Input validation (required keys, content type)
- Conflict detection (unique code checks)
- Standardized response formatting

### Handler (Web).txt
A Web UI handler template using HTMX partial page updates. Includes:
- Route dispatching for page, table, add/edit/delete modals
- Table rendering with search/filter support
- Form validation
- Toast notifications via custom events

---

## License

MIT License — Copyright (c) 2022-2026 Poon Yip Hoon (Aeric). See [LICENSE](LICENSE).

---

## Links

- [Pakai Server Template](https://github.com/pyhoon/pakai-server-b4j)
- [B4X Forum Thread](https://www.b4x.com/android/forum/threads/web-project-template-pakai-server-v6.169224/)
- [Swagger UI](https://github.com/swagger-api/swagger-ui)
