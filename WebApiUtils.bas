﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.1
@EndOfDesignText@
' Web API Utility
' Version 2.05
Sub Process_Globals
	Private const CONTENT_TYPE_JSON As String = "application/json"
	Private const CONTENT_TYPE_HTML As String = "text/html"
	Type HttpResponseMessage (ResponseCode As Int, ResponseString As String, ResponseData As List, ResponseObject As Map, ResponseMessage As String, ResponseError As Object, ResponseType As String, ContentType As String, SimpleResponse As SimpleResponse)
	Type HttpResponseContent (ResponseBody As String)
	Type ApiElement (Name As String, Versioning As Boolean)
	Type WebElement (Root As String, Path As String)
	Type Element (Web As WebElement, Api As ApiElement, Elements As List, PathIndex As Int, ApiVersionIndex As Int, ApiControllerIndex As Int, WebControllerIndex As Int)
	Type SimpleResponse (Enable As Boolean, Format As String, DataKey As String)
	Type KeyValueList (Keys As List, Values As List)
End Sub

Public Sub CheckMaxElements (Elements() As String, Max_Elements As Int) As Boolean
	If Elements.Length > Max_Elements Or Elements.Length = 0 Then
		Return False
	End If
	Return True
End Sub

Public Sub CheckAllowedVerb (SupportedMethods As List, Method As String) As Boolean
	'Methods: POST, GET, PUT, PATCH, DELETE
	If SupportedMethods.IndexOf(Method) = -1 Then
		Return False
	End If
	Return True
End Sub

Public Sub CheckInteger (Input As Object) As Boolean
	Try
		Return Input > -1
	Catch
		'Log(LastException.Message)
		Return False
	End Try
End Sub

Public Sub GetApiPathElements (Path As String) As String()
	Dim element() As String = Regex.Split("\/", Path)
	Return element
End Sub

Public Sub GetUriElements (Uri As String) As String()
	Dim element() As String = Regex.Split("\/", Uri)
	Return element
End Sub

Public Sub BuildHtml (strHTML As String, Settings As Map) As String
	' Replace $KEY$ tag with new content from Map
	strHTML = ReplaceMap(strHTML, Settings)
	Return strHTML
End Sub

Public Sub BuildView (strHTML As String, View As String) As String
	' Replace @VIEW@ tag with new content
	strHTML = strHTML.Replace("@VIEW@", View)
	Return strHTML
End Sub

Public Sub BuildCsrfToken (strHTML As String, Content As String) As String
	' Replace meta name="csrf-token" tag with new content
	Dim strMetaTag As String = $"<meta name="csrf-token" content="${Content}">"$
	strHTML = strHTML.Replace($"<meta name="csrf-token" content="">"$, strMetaTag)
	Return strHTML
End Sub

Public Sub BuildTag (strHTML As String, Tag As String, Value As String) As String
	' Replace @TAG@ keyword with new content
	strHTML = strHTML.Replace("@" & Tag & "@", Value)
	Return strHTML
End Sub

Public Sub BuildDocView (strHTML As String, View As String) As String
	' Replace @DOCVIEW@ tag with new content
	strHTML = strHTML.Replace("@DOCVIEW@", View)
	Return strHTML
End Sub

'Public Sub BuildDocScript (strHTML As String, Script As String) As String
'	' Replace @DOCSCRIPT@ tag with new content
'	strHTML = strHTML.Replace("@DOCSCRIPT@", Script)
'	Return strHTML
'End Sub
'Public Sub BuildDocScript (strHTML As String, Script As String) As String
'	' Replace @DOCSCRIPT@ tag with new content
'	If Script.Length > 0 Then
'		Script = $"  <script>
'    $(document).ready(function() {
'    ${Script}
'    });
'  </script>"$
'		strHTML = strHTML.Replace("@DOCSCRIPT@", Script)
'	Else
'		strHTML = strHTML.Replace("@DOCSCRIPT@", "")
'	End If
'	Return strHTML
'End Sub

Public Sub BuildScript (strHTML As String, Script As String) As String
	' Replace @SCRIPT@ tag with new content
	strHTML = strHTML.Replace("@SCRIPT@", Script)
	Return strHTML
End Sub

' Insert inline JavaScript
Public Sub BuildScript2 (strHTML As String, Script As String, Settings As Map) As String
	' Replace @SCRIPT@ tag with new content
	Dim strScript As String = $"	<script type="text/javascript">
		${Script}
	</script>"$
	strScript = BuildHtml(strScript, Settings)
	strHTML = strHTML.Replace("@SCRIPT@", strScript)
	Return strHTML
End Sub

Public Sub ReadMapFile (FileDir As String, FileName As String) As Map
	Dim strPath As String = File.Combine(FileDir, FileName)
	Log($"Reading file (${strPath})..."$)
	Return File.ReadMap(FileDir, FileName)
End Sub

Public Sub ReadTextFile (FileName As String) As String
	Return File.ReadString(File.DirAssets, FileName)
End Sub

Public Sub WriteTextFile (FileName As String, Contents As String)
	File.WriteString(File.DirApp, FileName, Contents)
End Sub

Public Sub WriteAssetFile (FileName As String, Contents As String)
	File.WriteString(File.Combine(File.DirApp, "www"), FileName, Contents)
End Sub

Public Sub DeleteAssetFile (FileName As String)
	File.Delete(File.Combine(File.DirApp, "www"), FileName)
End Sub

Public Sub AssetFileExist (FileName As String) As Boolean
	Return File.Exists(File.Combine(File.DirApp, "www"), FileName)
End Sub

Public Sub Map2Json (M As Map) As String
	Return M.As(JSON).ToString
End Sub

Public Sub List2Json (L As List) As String
	Return L.As(JSON).ToString
End Sub

Public Sub Object2Json (O As Object) As String
	Return O.As(JSON).ToString
End Sub

' Make a copy of an object
'Public Sub CopyObject (obj As Object) As Object
'	Dim ser As B4XSerializator
'	Return ser.ConvertBytesToObject(ser.ConvertObjectToBytes(obj))
'End Sub

Public Sub ConvertMap2KeyValueList (obj As Map) As KeyValueList
	Dim Keys As List
	Dim Values As List
	Keys.Initialize
	Values.Initialize
	For Each key As String In obj.Keys
		Keys.Add(key)
		Values.Add(obj.Get(key))
	Next
	Return CreateKeyValueList(Keys, Values)
End Sub

Public Sub GetCurrentTimezone As String
	Dim CurrentTimezone As Double = DateTime.GetTimeZoneOffsetAt(DateTime.Now)
	Return CurrentTimezone
End Sub

Public Sub CurrentDateTime As String
	Dim CurrentDateFormat As String = DateTime.DateFormat
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss"
	DateTime.SetTimeZone(0)
	Dim Current As String = DateTime.Date(DateTime.Now)
	DateTime.DateFormat = CurrentDateFormat
	Return Current
End Sub

Public Sub FileNameByCurrentDateTime As String
	Dim CurrentDateFormat As String = DateTime.DateFormat
	DateTime.DateFormat = "yyyyMMddHHmmss"
	DateTime.SetTimeZone(0)
	Dim Current As String = DateTime.Date(DateTime.Now)
	DateTime.DateFormat = CurrentDateFormat
	Return Current
End Sub

' Read Request Cookie As Map
Public Sub RequestCookie (req As ServletRequest) As Object
	Dim Munchies() As Cookie = req.GetCookies
	Dim M As Map
	M.Initialize
	For Each bite As Cookie In Munchies
		M.Put(bite.Name, bite.Value)
	Next
	Return M
End Sub

' Tip about POST requests: if you want to get a URL parameter (req.GetParameter)
' then do it only after reading the payload, otherwise the payload will be searched
' for the parameter and will be lost.
Public Sub RequestData (Request As ServletRequest) As Map
	Dim data As Map
	Dim inp As InputStream = Request.InputStream
	If inp.BytesAvailable <= 0 Then
		Return data
	End If
	'Dim tr As TextReader
	'tr.Initialize(inp)
	'Dim json As JSONParser
	'json.Initialize(tr.ReadAll)
	'data = json.NextObject
	Dim buffer() As Byte = Bit.InputStreamToBytes(inp)
	Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF-8")
	data = str.As(JSON).ToMap
	Return data
End Sub

'Public Sub RequestMultipartList (Request As ServletRequest, Folder As String, MaxSize As Long) As List
'	Dim config As JavaObject
'	'config.InitializeNewInstance("javax.servlet.MultipartConfigElement", Array(Folder, MaxSize, MaxSize, 81920))
'	config.InitializeNewInstance("jakarta.servlet.MultipartConfigElement", Array(Folder, MaxSize, MaxSize, 81920))
'	Dim f As JavaObject
'	f.InitializeNewInstance("java.io.File", Array(Folder))
'	Dim parser As JavaObject
'	'parser.InitializeNewInstance("org.eclipse.jetty.util.MultiPartInputStreamParser", Array(Request.InputStream, Request.ContentType, config, f))
'	parser.InitializeNewInstance("org.eclipse.jetty.server.MultiPartFormInputStream", Array(Request.InputStream, Request.ContentType, config, f))
'	Dim parts As JavaObject = parser.RunMethod("getParts", Null)
'	Dim result() As Object = parts.RunMethod("toArray", Null)
'	Return result
'End Sub

Public Sub RequestMultipartData (Request As ServletRequest) As Map
	Try
		Dim fd As String =  File.DirApp & "\www\tmp" ' & Main.inspectFolder
		Dim data As Map = Request.GetMultipartData(fd, 100000000 * 1000) 'max 10000000000 bytes
		For Each key As String In data.Keys
			Dim p As Part = data.Get(key)
			Dim name As String = p.SubmittedFilename 'data.Get("fn")
			Dim temp As String = File.GetName(p.TempFile)
			If key.StartsWith("post-") Then
				If File.Exists(fd, name) Then File.Delete(fd, name)
				Dim inp As InputStream = File.OpenInput(fd, temp)
				Dim out As OutputStream = File.OpenOutput(fd, name, False)
				File.Copy2(inp, out)
				out.Close
			End If
			If key.StartsWith("json") Then
				Dim ins As InputStream = File.OpenInput(fd, temp)
				'Dim tr As TextReader
				'tr.Initialize(ins)
				'Dim json As JSONParser
				'json.Initialize(tr.ReadAll)
				'data = json.NextObject
				Dim buffer() As Byte = Bit.InputStreamToBytes(ins)
				Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF-8")
				data = str.As(JSON).ToMap
			End If
			If File.Exists(fd, name) Then File.Delete(fd, temp) ' Delete temp file if new file generated
		Next
	Catch
		LogError(LastException.Message)
	End Try
	Return data
End Sub

' ====================================================
' Requires StringUtils library
' ====================================================
'Public Sub RequestBasicAuth (Auths As List) As Map
'	Dim client As Map = CreateMap("CLIENT_ID": "", "CLIENT_SECRET": "")
'	If Auths.Size > 0 Then
'		Dim auth As String = Auths.Get(0)
'		If auth.StartsWith("Basic") Then
'			Dim b64 As String = auth.SubString("Basic ".Length)
'			Dim su As StringUtils
'			Dim b() As Byte = su.DecodeBase64(b64)
'			Dim raw As String = BytesToString(b, 0, b.Length, "utf8")
'			Dim UsernameAndPassword() As String = Regex.Split(":", raw)
'			If UsernameAndPassword.Length = 2 Then
'				client.Put("CLIENT_ID", UsernameAndPassword(0))
'				client.Put("CLIENT_SECRET", UsernameAndPassword(1))
'			End If
'		End If
'	End If
'	Return client
'End Sub
' ====================================================

' Get Access Token from Header
Public Sub RequestAccessToken (req As ServletRequest) As String
	Dim token As String
'	Dim jo As JavaObject = req
'	Dim collections As JavaObject
'	collections.InitializeStatic("java.util.Collections")
'	Dim headers As List = collections.RunMethod("list", Array(jo.RunMethodJO("getHeaderNames", Null)))
'	For Each h As String In headers
'		Log(h & ": " & req.GetHeader(h))
'	Next
	Dim auths As List = req.GetHeaders("Authorization")
	If auths.Size > 0 Then
		token = auths.Get(0)
	End If
	Return token
End Sub

' Get Refresh Token from Cookie
'Public Sub RequestRefreshToken (req As ServletRequest) 'As String
''	Dim Munchies() As Cookie = req.GetCookies
''	Log(Munchies)
'	Log(req.GetCookies)
''	Dim DeliciousCookie As List = Munchies
''	For Each DeliciousCookie In Munchies
''		Log(DeliciousCookie)
''	Next
''	For i = 0 To Munchies.Length - 1
''		Log(Munchies(i))
''	Next
''	For i = 0 To DeliciousCookie.Size - 1
''		Log(DeliciousCookie.Get(i))
''	Next
'	'Return Cookie
'End Sub

Public Sub RequestBearerToken (req As ServletRequest) As String
	Dim Auths As List = req.GetHeaders("Authorization")
	If Auths.Size > 0 Then
		Dim auth As String = Auths.Get(0)
		If auth.StartsWith("Bearer") Then
			Return auth.SubString("Bearer ".Length)
		End If
	End If
	Return ""
End Sub

'Public Sub RequestCookie (req As ServletRequest) As Cookie
'	Return req.GetCookies
'End Sub

Public Sub ReturnCookie (key As String, value As String, max_age As Int, http_only As Boolean, resp As ServletResponse)
	Dim session_cookie As Cookie
	session_cookie.Initialize(key, value)
	session_cookie.HttpOnly = http_only
	session_cookie.MaxAge = max_age
	resp.AddCookie(session_cookie)
End Sub

Public Sub ReturnLocation (Location As String, resp As ServletResponse) ' Code = 302
	resp.SendRedirect(Location)
End Sub

Public Sub ReturnConnect (resp As ServletResponse)
	Dim Data As List
	Data.Initialize
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 200
	mess.ResponseObject = CreateMap("connect": True)
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnConnect2 (resp As ServletResponse)
	Dim Data As List
	Data.Initialize
	Data.Add(CreateMap("connect": True))
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 200
	mess.ResponseData = Data
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnError (Error As String, Code As Int, resp As ServletResponse)
	If Code = 0 Then Code = 400
	If Error = "" Then Error = "Bad Request"
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = Code
	mess.ResponseError = Error
	mess.ResponseString = "error"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnSuccess (Data As Map, Code As Int, resp As ServletResponse)
	If Data.IsInitialized = False Then Data.Initialize
	If Code = 0 Then Code = 200
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = Code
	mess.ResponseObject = Data
	mess.ResponseString = "ok"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnSuccess2 (Data As List, Code As Int, resp As ServletResponse)
	If Data.IsInitialized = False Then Data.Initialize
	If Code = 0 Then Code = 200
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = Code
	mess.ResponseData = Data
	mess.ResponseString = "ok"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnBadRequest (resp As ServletResponse)
	'ReturnError("Bad Request", 400, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 400
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnAuthorizationRequired (resp As ServletResponse)
	'ReturnError("Authentication required", 401, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 401
	mess.ResponseError = "Authentication required"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnTokenExpired (resp As ServletResponse)
	'ReturnError("Token Expired", 401, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 401
	mess.ResponseError = "Token Expired"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnMethodNotAllow (resp As ServletResponse)
	'ReturnError("Method Not Allowed", 405, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 405
	mess.ResponseError = "Method Not Allowed"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnErrorUnprocessableEntity (resp As ServletResponse)
	'ReturnError("Error Unprocessable Entity", 422, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 422
	mess.ResponseError = "Unprocessable Entity"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnErrorCredentialNotProvided (resp As ServletResponse)
	'ReturnError("Error Credential Not Provided", 400, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 400
	mess.ResponseError = "Credential Not Provided"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnErrorExecuteQuery (resp As ServletResponse)
	'ReturnError("Error Execute Query", 422, resp)
	Dim mess As HttpResponseMessage
	mess.Initialize
	mess.ResponseCode = 422
	mess.ResponseError = "Execute Query"
	mess.SimpleResponse = Main.SimpleResponse
	ReturnHttpResponse(mess, resp)
End Sub

' Remember to add the following code when initialize a Controller <code>
' HRM.Initialize
' HRM.SimpleResponse = Main.SimpleResponse</code>
Public Sub ReturnHttpResponse (mess As HttpResponseMessage, resp As ServletResponse)
	' =======================
	' SimpleResponse = False
	' =======================
	' {
	'  "m": "Success",
	'  "e": Null,
	'  "s": "ok",
	'  "r": [ { "connect": "true" } ]
	'  "a": 200
	' }
	' =======================
	' SimpleResponse = True
	' =======================
	' Format: Auto
	' {
	'  "connect": "true"
	' }
	'
	' Format = List
	' [
	'  {
	'   "connect": "true"
	'  }
	' ]
	'
	' Format = Map
	' {
	'  "data": [
	'    {
	'     "connect": "true"
	'    }
	'  ]
	' }
	If mess.ResponseCode >= 200 And mess.ResponseCode < 300 Then ' SUCCESS
		If mess.ResponseType = "" Then mess.ResponseType = "SUCCESS"
		If mess.ResponseString = "" Then mess.ResponseString = "ok"
		If mess.ResponseMessage = "" Then mess.ResponseMessage = "Success"
		mess.ResponseError = Null
	Else ' ERROR
		If mess.ResponseCode = 0 Then mess.ResponseCode = 400
		If mess.ResponseType = "" Then mess.ResponseType = "ERROR"
		If mess.ResponseString = "" Then mess.ResponseString = "error"
		'If mess.ResponseMessage = "" Then mess.ResponseMessage = "Bad Request"
		'mess.ResponseMessage = "" 'Null
		If mess.ResponseError.As(String).StartsWith("java.lang.Object") Then
			mess.ResponseError = "Bad Request"
			If mess.ResponseCode = 404 Then mess.ResponseError = "Not Found"
			If mess.ResponseCode = 405 Then mess.ResponseError = "Method Not Allowed"
			If mess.ResponseCode = 422 Then mess.ResponseError = "Unprocessable Entity"
			'If mess.ResponseError = "" Then mess.ResponseError = "Bad Request"
		End If
	End If
	If mess.ContentType = "" Then mess.ContentType = CONTENT_TYPE_JSON
	resp.ContentType = mess.ContentType
	
	If mess.SimpleResponse.Enable Then
		resp.Status = mess.ResponseCode
	Else
		' Override Status Code
		If mess.ResponseCode < 200 Or mess.ResponseCode > 299 Then
			resp.Status = 200
		Else
			resp.Status = mess.ResponseCode
		End If
	End If

	If mess.SimpleResponse.Enable Then
		Select mess.SimpleResponse.Format
			Case "List"
				' force List format
				If mess.ResponseData.IsInitialized = False Then
					' Initialize an empty list
					mess.ResponseData.Initialize
					If mess.ResponseObject.IsInitialized Then
						' Add object to List
						If mess.ResponseObject.Size > 0 Then mess.ResponseData.Add(mess.ResponseObject)
					Else
						mess.ResponseObject.Initialize
					End If
				End If
				resp.Write(mess.ResponseData.As(JSON).ToString)
			Case "Map"
				' force Map format with "data" as key
				If mess.ResponseObject.IsInitialized = False Then
					' Initialize an empty map
					mess.ResponseObject.Initialize
					If mess.ResponseData.IsInitialized = False Then
						' Initialize an empty list
						mess.ResponseData.Initialize
					End If
					' Add object to Map
					If mess.SimpleResponse.DataKey = Null Then
						mess.ResponseObject.Put("data", mess.ResponseData)
					Else
						mess.ResponseObject.Put(mess.SimpleResponse.DataKey, mess.ResponseData)
					End If
				End If
				resp.Write(mess.ResponseObject.As(JSON).ToString)
			Case Else ' "Auto" or other value
				' Depends on which object is initialized
				If mess.ResponseObject.IsInitialized Then
					resp.Write(mess.ResponseObject.As(JSON).ToString)
				Else If mess.ResponseData.IsInitialized Then
					resp.Write(mess.ResponseData.As(JSON).ToString)
				Else
					' Default to an initialized List
					'mess.ResponseData.Initialize
					'resp.Write(mess.ResponseData.As(JSON).ToString)
					' or
					' Default to an initialized Map
					mess.ResponseObject.Initialize
					Select mess.ResponseType.ToUpperCase
						Case "SUCCESS"
							mess.ResponseObject.Put("message", mess.ResponseMessage)
						Case "ERROR", "FAILED"
							mess.ResponseObject.Put("error", mess.ResponseError)
					End Select
					resp.Write(mess.ResponseObject.As(JSON).ToString)
				End If
		End Select
	Else
		If Not(mess.ResponseData.IsInitialized) Then
			mess.ResponseData.Initialize
			If mess.ResponseObject.IsInitialized Then
				' Do not add an empty map
				If mess.ResponseObject.Size > 0 Then mess.ResponseData.Add(mess.ResponseObject)
			End If
		End If
		Dim Map1 As Map = CreateMap("s": mess.ResponseString, "a": mess.ResponseCode, "r": mess.ResponseData, "m": mess.ResponseMessage, "e": mess.ResponseError)
		resp.Write(Map2Json(Map1))
	End If
End Sub

Public Sub ReturnHtml (str As String, resp As ServletResponse)
	resp.ContentType = CONTENT_TYPE_HTML
	resp.Write(str)
End Sub

Public Sub ReturnHtmlBody (cont As HttpResponseContent, resp As ServletResponse)
	resp.ContentType = CONTENT_TYPE_HTML
	resp.Write(cont.ResponseBody)
End Sub

'Public Sub ReturnHtmlBadRequest (resp As ServletResponse)
'	Dim str As String = $"<h1>Bad Request</h1>"$
'	ReturnHtml(str, resp)
'End Sub

Public Sub ReturnHtmlPageNotFound (resp As ServletResponse)
	Dim str As String = $"<h1>404 Page Not Found</h1>"$
	ReturnHtml(str, resp)
End Sub

' // Source: http://www.b4x.com/android/forum/threads/validate-a-correctly-formatted-email-address.39803/
Public Sub Validate_Email (EmailAddress As String) As Boolean
	Dim MatchEmail As Matcher = Regex.Matcher("^(?i)[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$", EmailAddress)
 
	If MatchEmail.Find = True Then
		'Log(MatchEmail.Match)
		Return True
	Else
		'Log("Oops, please double check your email address...")
		Return False
	End If
End Sub

' Check anti csrf-token variable sent from client in request header is same as variable stored in server session  
Public Sub ValidateCsrfToken (session_name As String, header_name As String, req As ServletRequest) As Boolean
	Dim headers As List = req.GetHeaders(header_name)
	'Log(session_name)
	'Log(headers.Get(0))
	'Log(req.GetSession.GetAttribute(session_name).As(String))
	If req.GetSession.GetAttribute2(session_name, "").As(String).EqualsIgnoreCase(headers.Get(0)) Then
		'Log("matched")
		Return True
	Else
		'Log("unmatched!")
		Return False
	End If
End Sub

Public Sub GUID As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			sb.Append(Chr(c))
		Next
	Next
	Return sb.ToString
End Sub

Public Sub Slugify (str As String) As String
	str = str.ToLowerCase.Trim
	str = Regex.Replace("/[^\w\s-]/g", str, "")
	str = Regex.Replace("/[\s_-]+/g", str, "-")
	str = Regex.Replace("/^-+|-+$/g", str, "")
	Return str
End Sub

Public Sub ProperCase (Word As String) As String
	If Word.Length = 0 Then Return ""
	If Word.Length = 1 Then Return Word.ToUpperCase
	Return Word.CharAt(0).As(String).ToUpperCase & Word.SubString(1)
End Sub

' ====================================================
' Requires StringUtils library
' ====================================================
'Public Sub EncodeBase64 (data() As Byte) As String
'	Dim su As StringUtils
'	Return su.EncodeBase64(data)
'End Sub
'
'Public Sub DecodeBase64 (str As String) As Byte()
'	Dim su As StringUtils
'	Return su.DecodeBase64(str)
'End Sub
'
'Public Sub EncodeURL (str As String) As String
'	Dim su As StringUtils
'	Return su.EncodeUrl(str, "UTF8")
'End Sub
'
'Public Sub DecodeURL (str As String) As String
'	Dim su As StringUtils
'	Return su.DecodeUrl(str, "UTF8")
'End Sub
' ====================================================

Public Sub CreateKeyValueList (Keys As List, Values As List) As KeyValueList
	Dim t1 As KeyValueList
	t1.Initialize
	t1.Keys = Keys
	t1.Values = Values
	Return t1
End Sub

' ===================================================================
' Taken from WebUtils
' ===================================================================
Public Sub ReplaceMap(Base As String, Replacements As Map) As String
	Dim pattern As StringBuilder
	pattern.Initialize
	For Each k As String In Replacements.Keys
		If pattern.Length > 0 Then pattern.Append("|")
		pattern.Append("\$").Append(k).Append("\$")
	Next
	Dim m As Matcher = Regex.Matcher(pattern.ToString, Base)
	Dim result As StringBuilder
	result.Initialize
	Dim lastIndex As Int
	Do While m.Find
		result.Append(Base.SubString2(lastIndex, m.GetStart(0)))
		Dim replace As String = Replacements.Get(m.Match.SubString2(1, m.Match.Length - 1))
		If m.Match.ToLowerCase.StartsWith("$h_") Then replace = EscapeHtml(replace)
		result.Append(replace)
		lastIndex = m.GetEnd(0)
	Loop
	If lastIndex < Base.Length Then result.Append(Base.SubString(lastIndex))
	Return result.ToString
End Sub

Public Sub EscapeHtml(Raw As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i = 0 To Raw.Length - 1
		Dim C As Char = Raw.CharAt(i)
		Select C
			Case QUOTE
				sb.Append("&quot;")
			Case "'"
				sb.Append("&#39;")
			Case "<"
				sb.Append("&lt;")
			Case ">"
				sb.Append("&gt;")
			Case "&"
				sb.Append("&amp;")
			Case Else
				sb.Append(C)
		End Select
	Next
	Return sb.ToString
End Sub
' ===================================================================