B4J=true
Group=Classes
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
' Web API Utility
' Version 4.70
Sub Process_Globals
	Public Const CONTENT_TYPE_HTML As String = "text/html"
	Public Const CONTENT_TYPE_JSON As String = "application/json"
	Public Const CONTENT_TYPE_XML As String = "application/xml"
	Public Const CONTENT_TYPE_PDF As String = "application/pdf"
	Public Const CONTENT_TYPE_PNG As String = "image/png"
	Public Const RESPONSE_ELEMENT_MESSAGE As String = "m"
	Public Const RESPONSE_ELEMENT_CODE As String 	= "a"
	Public Const RESPONSE_ELEMENT_STATUS As String 	= "s"
	Public Const RESPONSE_ELEMENT_TYPE As String 	= "t"
	Public Const RESPONSE_ELEMENT_ERROR As String 	= "e"
	Public Const RESPONSE_ELEMENT_RESULT As String 	= "r"
	Type HttpResponseContent (ResponseBody As String)
	Type HttpResponseMessage (ResponseMessage As String, ResponseCode As Int, ResponseStatus As String, ResponseType As String, ResponseError As Object, ResponseData As List, ResponseObject As Map, ResponseBody As Object, PayloadType As String, ContentType As String, XmlRoot As String, XmlElement As String, VerboseMode As Boolean, OrderedKeys As Boolean, ResponseKeys As List, ResponseKeysAlias As List)
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

Public Sub CheckInteger (Value As Object) As Boolean
	Try
		Return Value > -1
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

' Use the following code sample if your API URL pattern looks like this:
' Web = /products
' Api = /api/products
' <code>Elements = WebApiUtils.CropElements(FullElements, 2) ' for Web handler</code>
' <code>Elements = WebApiUtils.CropElements(FullElements, 3) ' for Api handler</code>
Public Sub CropElements (FullElements() As String, StartingElementIndex As Int) As String()
	If StartingElementIndex > FullElements.Length Then
		StartingElementIndex = FullElements.Length
	End If
	Dim TempList As List
	TempList.Initialize
	For n = StartingElementIndex To FullElements.Length - 1
		TempList.Add(FullElements(n))
	Next
	Dim NewArray(TempList.Size) As String
	For n = 0 To NewArray.Length - 1
		NewArray(n) = TempList.Get(n)
	Next
	Return NewArray
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

Public Sub BuildTag (strHTML As String, Key As String, Value As String) As String
	' Replace @KEY@ keyword with new content
	strHTML = strHTML.Replace("@" & Key & "@", Value)
	Return strHTML
End Sub

Public Sub BuildDocView (strHTML As String, View As String) As String
	' Replace @DOCVIEW@ tag with new content
	strHTML = strHTML.Replace("@DOCVIEW@", View)
	Return strHTML
End Sub

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

Public Sub Object2Json (O As Object) As String
	Return O.As(JSON).ToString
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
Public Sub RequestCookie (req As ServletRequest) As Map
	Dim Munchies() As Cookie = req.GetCookies
	Dim M As Map
	M.Initialize
	For Each bite As Cookie In Munchies
		M.Put(bite.Name, bite.Value)
	Next
	Return M
End Sub

' Same as RequestDataJson (for backward compatibility)
' Next version may point to RequestDataText
' Tip about POST requests: if you want to get a URL parameter (req.GetParameter)
' then do it only after reading the payload, otherwise the payload will be searched
' for the parameter and will be lost.
Public Sub RequestData (Request As ServletRequest) As Map
	Return RequestDataJson(Request)
End Sub

Public Sub RequestDataText (Request As ServletRequest) As String
	Dim str As String
	Dim inp As InputStream = Request.InputStream
	If inp.BytesAvailable <= 0 Then
		Return Null
	End If
	Dim buffer() As Byte = Bit.InputStreamToBytes(inp)
	str = BytesToString(buffer, 0, buffer.Length, "UTF8")
	Return str
End Sub

Public Sub RequestDataJson (Request As ServletRequest) As Map
	Dim data As Map
	Dim inp As InputStream = Request.InputStream
	If inp.BytesAvailable <= 0 Then
		Return data
	End If
	Dim buffer() As Byte = Bit.InputStreamToBytes(inp)
	Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF8")
	data = str.As(JSON).ToMap
	Return data
End Sub

Public Sub RequestDataXml (Request As ServletRequest) As Map
	Dim data As Map
	Dim inp As InputStream = Request.InputStream
	If inp.BytesAvailable <= 0 Then
		Return data
	End If
	Dim buffer() As Byte = Bit.InputStreamToBytes(inp)
	Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF8")
	'str = LinearizeXML(str)
	'Dim xm As Xml2Map
	'xm.Initialize
	'xm.StripNamespaces = True
	'data = xm.Parse(str)
	'Return data
	Return ParseXML(str)
End Sub

' Remove comments, line breaks, tabs and spaces
Public Sub LinearizeXML (Text As String) As String
	Text = Regex.Replace("<!--[\s\S]*?-->", Text, "")
	Return Regex.Replace("\s+", Text, " ").Trim
End Sub

Public Sub ParseXML (Text As String) As Map
	Dim data As Map
	Dim xm As Xml2Map
	xm.Initialize
	xm.StripNamespaces = True
	data = xm.Parse(Text)
	Return data
End Sub

Public Sub RequestMultiPart (Request As ServletRequest, Folder As String, MaxSize As Long) As Part
	Dim part As Part
	Dim config As JavaObject
	config.InitializeNewInstance("jakarta.servlet.MultipartConfigElement", Array(Folder, MaxSize, MaxSize, 81920))
	Dim f As JavaObject
	f.InitializeNewInstance("java.io.File", Array(Folder))
	Dim parser As JavaObject
	parser.InitializeNewInstance("org.eclipse.jetty.server.MultiPartFormInputStream", Array(Request.InputStream, Request.ContentType, config, f))
	Dim parts As JavaObject = parser.RunMethod("getParts", Null)
	Dim result() As Object = parts.RunMethod("toArray", Null)
	Dim list As List = result
	If list.Size > 0 Then
		part = list.Get(0)
	End If
	Return part
End Sub

Public Sub RequestMultipartList (Request As ServletRequest, Folder As String, MaxSize As Long) As List
	Dim config As JavaObject
	config.InitializeNewInstance("jakarta.servlet.MultipartConfigElement", Array(Folder, MaxSize, MaxSize, 81920))
	Dim f As JavaObject
	f.InitializeNewInstance("java.io.File", Array(Folder))
	Dim parser As JavaObject
	parser.InitializeNewInstance("org.eclipse.jetty.server.MultiPartFormInputStream", Array(Request.InputStream, Request.ContentType, config, f))
	Dim parts As JavaObject = parser.RunMethod("getParts", Null)
	Dim result() As Object = parts.RunMethod("toArray", Null)
	Return result
End Sub

Public Sub RequestMultipartData (Request As ServletRequest, Folder As String, MaxSize As Long) As Map
	Try
		Dim data As Map = Request.GetMultipartData(Folder, MaxSize)
		For Each key As String In data.Keys
			Dim part As Part = data.Get(key)
			Dim name As String = part.SubmittedFilename
			Dim temp As String = File.GetName(part.TempFile)
			If key.StartsWith("post-") Then
				If File.Exists(Folder, name) Then File.Delete(Folder, name)
				Dim inp As InputStream = File.OpenInput(Folder, temp)
				Dim out As OutputStream = File.OpenOutput(Folder, name, False)
				File.Copy2(inp, out)
				out.Close
			End If
			If key.StartsWith("json") Then
				Dim ins As InputStream = File.OpenInput(Folder, temp)
				Dim buffer() As Byte = Bit.InputStreamToBytes(ins)
				Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF-8")
				data = str.As(JSON).ToMap
			End If
			If File.Exists(Folder, name) Then File.Delete(Folder, temp) ' Delete temp file if new file generated
		Next
	Catch
		LogError(LastException.Message)
	End Try
	Return data
End Sub

Public Sub RequestBasicAuth (Auths As List) As Map
	Dim client As Map = CreateMap("CLIENT_ID": "", "CLIENT_SECRET": "")
	If Auths.Size > 0 Then
		Dim auth As String = Auths.Get(0)
		If auth.StartsWith("Basic") Then
			Dim b64 As String = auth.SubString("Basic ".Length)
			Dim su As StringUtils
			Dim ab() As Byte = su.DecodeBase64(b64)
			Dim str As String = BytesToString(ab, 0, ab.Length, "UTF8")
			Dim UsernameAndPassword() As String = Regex.Split(":", str)
			If UsernameAndPassword.Length = 2 Then
				client.Put("CLIENT_ID", UsernameAndPassword(0))
				client.Put("CLIENT_SECRET", UsernameAndPassword(1))
			End If
		End If
	End If
	Return client
End Sub

Public Sub EncodeBase64 (data() As Byte) As String
	Dim su As StringUtils
	Return su.EncodeBase64(data)
End Sub

Public Sub DecodeBase64 (str As String) As Byte()
	Dim su As StringUtils
	Return su.DecodeBase64(str)
End Sub

Public Sub EncodeURL (str As String) As String
	Dim su As StringUtils
	Return su.EncodeUrl(str, "UTF8")
End Sub

Public Sub DecodeURL (str As String) As String
	Dim su As StringUtils
	Return su.DecodeUrl(str, "UTF8")
End Sub

' Get Access Token from Header
Public Sub RequestAccessToken (req As ServletRequest) As String
	Dim token As String
	Dim auths As List = req.GetHeaders("Authorization")
	If auths.Size > 0 Then
		token = auths.Get(0)
	End If
	Return token
End Sub

Public Sub RequestBearerToken (req As ServletRequest) As String
	Dim Auths As List = req.GetHeaders("Authorization")
	If Auths.Size > 0 Then
		Dim auth As String = Auths.Get(0)
		If auth.StartsWith("Bearer") And auth.Length > "Bearer ".Length Then
			Return auth.SubString("Bearer ".Length)
		End If
	End If
	Return ""
End Sub

Public Sub RequestApiKey (req As ServletRequest) As String
	Dim Auths As List = req.GetHeaders("X-API-Key")
	If Auths.Size > 0 Then
		Return Auths.Get(0)
	End If
	Return ""
End Sub

' max_age = number of seconds the cookie is valid, 0 to expire immediately
Public Sub ReturnCookie (key As String, value As String, max_age As Int, http_only As Boolean, resp As ServletResponse)
	Dim session_cookie As Cookie
	session_cookie.Initialize(key, value)
	session_cookie.HttpOnly = http_only
	session_cookie.MaxAge = max_age
	'resp.SetHeader(key, session_cookie.Value & "; SameSite=Lax")
	resp.AddCookie(session_cookie)
End Sub

Public Sub ReturnLocation (Location As String, resp As ServletResponse) ' Code = 302
	resp.SendRedirect(Location)
End Sub

Public Sub ReturnConnect (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 200
	mess.ResponseObject = CreateMap("connect": True)
	ReturnHttpResponse(mess, resp)
End Sub

'Public Sub ReturnConnect2 (mess As HttpResponseMessage, resp As ServletResponse)
'	Dim Data As List
'	Data.Initialize
'	Data.Add(CreateMap("connect": True))
'	mess.ResponseCode = 200
'	mess.ResponseData = Data
'	ReturnHttpResponse(mess, resp)
'End Sub

Public Sub ReturnError (mess As HttpResponseMessage, resp As ServletResponse, Code As Int, Error As String)
	'If Code = 0 Then Code = 400
	If Error = "" Then Error = "Bad Request"
	mess.ResponseCode = Code
	mess.ResponseError = Error
	mess.ResponseStatus = "error"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnSuccess (mess As HttpResponseMessage, resp As ServletResponse, Code As Int, Data As Map)
	'If Data.IsInitialized = False Then Data.Initialize
	'mess.ResponseObject = Data
	If Code = 0 Then Code = 200
	mess.ResponseCode = Code
	mess.ResponseStatus = "ok"
	ReturnHttpResponse(mess, resp)
End Sub

'Public Sub ReturnSuccess2 (mess As HttpResponseMessage, resp As ServletResponse, Code As Int, Data As List)
'	'If Data.IsInitialized = False Then Data.Initialize
'	'mess.ResponseData = Data
'	If Code = 0 Then Code = 200
'	mess.ResponseCode = Code
'	mess.ResponseStatus = "ok"
'	ReturnHttpResponse(mess, resp)
'End Sub

Public Sub ReturnBadRequest (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 400
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnAuthorizationRequired (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 401
	mess.ResponseError = "Authentication required"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnTokenExpired (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 401
	mess.ResponseError = "Token Expired"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnMethodNotAllow (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 405
	mess.ResponseError = "Method Not Allowed"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnErrorUnprocessableEntity (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 422
	mess.ResponseError = "Unprocessable Entity"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnErrorCredentialNotProvided (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 400
	mess.ResponseError = "Credential Not Provided"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ReturnErrorExecuteQuery (mess As HttpResponseMessage, resp As ServletResponse)
	mess.ResponseCode = 422
	mess.ResponseError = "Execute Query"
	ReturnHttpResponse(mess, resp)
End Sub

Public Sub ProcessOrderedJsonFromList (L As List, Indent As String, Indentation As String) As String
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append("[")
	Dim First As Boolean = True
	For Each value As Object In L
		If First = False Then
			SB.Append(",")
		Else
			First = False
		End If
		SB.Append(CRLF)
		Select True
			Case value Is List
				SB.Append(ProcessOrderedJsonFromList(value, Indent, Indentation))
			Case value Is Map
				SB.Append(ProcessOrderedJsonFromMap(value, Indent & Indentation, Indentation))
			Case value Is String
				SB.Append(Indent & QUOTE & value & QUOTE)
			Case Else
				SB.Append(Indent & value)
		End Select
	Next
	SB.Append(CRLF & Indent & "]")
	Return SB.ToString
End Sub

Public Sub ProcessOrderedJsonFromMap (M As Map, Indent As String, Indentation As String) As String
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append(Indent & "{")
	Dim order As List = M.Get("__order")
	Dim First As Boolean = True
	For Each key As String In order
		If First = False Then
			SB.Append(",")
		Else
			First = False
		End If
		SB.Append(CRLF)
		Dim value As Object = m.Get(key)
		If key <> "__order" Then
			Select True
				Case value Is List
					SB.Append(Indent & Indentation & QUOTE & key & QUOTE & ": " & ProcessOrderedJsonFromList(value, Indent & Indentation, Indentation))
				Case value Is Map
					SB.Append(Indent & Indentation & QUOTE & key & QUOTE & ": " & ProcessOrderedJsonFromMap(value, Indent & Indentation & Indentation, Indentation))
				Case value Is String
					SB.Append(Indent & Indentation & QUOTE & key & QUOTE & ": " & QUOTE & value & QUOTE)
				Case Else
					SB.Append(Indent & Indentation & QUOTE & key & QUOTE & ": " & value)
			End Select
		End If
	Next
	SB.Append(CRLF & Indent & "}")
	Return SB.ToString
End Sub

Public Sub ProcessOrderedXmlFromList (Tag As String, L As List, Indent As String, Indentation As String) As String
	Dim SB As StringBuilder
	SB.Initialize
	Dim First As Boolean = True
	For Each value As Object In L
		Dim child As String
		Select True
			Case value Is Map
				child = CRLF & Indent & Indentation & ProcessOrderedXmlFromMap(Tag, value, Indent & Indentation, Indentation) & CRLF & Indent
			Case value Is List
				child = CRLF & Indentation & ProcessOrderedXmlFromList(Tag, value, Indent & Indentation, Indentation) & CRLF '& Indent
			Case value Is String
				child = EscapeXml(value)
			Case Else
				child = value
		End Select
		If First Then
			First = False
		Else
			SB.Append(CRLF)
		End If
		SB.Append(Indent).Append("<").Append(Tag).Append(">")
		SB.Append(child)
		SB.Append("</").Append(Tag).Append(">")
	Next
	Return SB.ToString
End Sub

Public Sub ProcessOrderedXmlFromMap (Tag As String, M As Map, Indent As String, Indentation As String) As String
	Dim SB As StringBuilder
	SB.Initialize
	If M.ContainsKey("__order") Then
		Dim order As List = M.Get("__order")
		Dim First As Boolean = True
		For Each key As String In order
			If key = "__order" Then Continue
			Dim value As Object = M.Get(key)
			Dim child As String
			Select True
				Case value Is Map
					child = CRLF & Indent & Indentation & ProcessOrderedXmlFromMap(Tag, value, Indent & Indentation, Indentation) & CRLF & Indent
				Case value Is List
					child = CRLF & ProcessOrderedXmlFromList(Tag, value, Indent & Indentation, Indentation) & CRLF & Indent
				Case value Is String
					child = EscapeXml(value)
				Case Else
					child = value
			End Select
			If First Then
				First = False
			Else
				SB.Append(CRLF)
			End If
			SB.Append(Indent)
			SB.Append("<").Append(key).Append(">")
			SB.Append(child)
			SB.Append("</").Append(key).Append(">")
		Next
	Else
		For Each key As String In M.Keys
			If key = "__order" Then Continue
			Dim value As Object = M.Get(key)
			Dim child As String
			Select True
				Case value Is Map
					Dim M2 As Map = value
					If M2.ContainsKey("__order") Then
						child = CRLF & Indent & Indentation & ProcessOrderedXmlFromMap(Tag, M2, Indent & Indentation, Indentation) & CRLF & Indent & Indentation
					Else
						Dim m2x As Map2Xml
						m2x.Initialize
						child = m2x.MapToXml(M2)
					End If
				Case value Is List
					child = CRLF & Indent & Indentation & ProcessOrderedXmlFromList(key, value, Indent & Indentation, Indentation) & CRLF & Indent & Indentation
				Case value Is String
					child = EscapeXml(value)
				Case Else
					child = value
			End Select
			SB.Append(Indent).Append("<").Append(key).Append(">")
			SB.Append(child)
			SB.Append("</").Append(key).Append(">")
		Next
	End If
	Return SB.ToString.Trim
End Sub

' To initialize: <code>
' HRM.Initialize
' HRM.VerboseMode = Main.conf.VerboseMode</code>
' ---------------------------------------------------------------
' <em>Output:</em> 
' {
'   "a": 200
'   "s": "ok",
'   "m": "Success",
'   "e": null,
'   "r": {
'     "connect": true
'   }
' }
Public Sub ReturnHttpResponse (mess As HttpResponseMessage, resp As ServletResponse)
	If mess.XmlRoot = "" Then mess.XmlRoot = "root"
	If mess.ContentType = "" Then mess.ContentType = CONTENT_TYPE_JSON
	If mess.PayloadType = "" Then mess.PayloadType = "json"
	If mess.ResponseCode >= 200 And mess.ResponseCode < 300 Then ' SUCCESS
		If mess.ResponseType = "" Then mess.ResponseType = "SUCCESS"
		If mess.ResponseStatus = "" Then mess.ResponseStatus = "ok"
		If mess.ResponseMessage = "" Then mess.ResponseMessage = "Success"
		mess.ResponseError = Null
	Else ' ERROR
		If mess.ResponseCode = 0 Then mess.ResponseCode = 400
		If mess.ResponseType = "" Then mess.ResponseType = "ERROR"
		If mess.ResponseStatus = "" Then mess.ResponseStatus = "error"
		If GetType(mess.ResponseError) = "java.lang.Object" Then
			mess.ResponseError = "Bad Request"
			If mess.ResponseCode = 404 Then mess.ResponseError = "Not Found"
			If mess.ResponseCode = 405 Then mess.ResponseError = "Method Not Allowed"
			If mess.ResponseCode = 422 Then mess.ResponseError = "Unprocessable Entity"
			If mess.ResponseCode = 429 Then mess.ResponseError = "Too Many Requests"
			If mess.ResponseCode = 500 Then mess.ResponseError = "Internal Server Error"
		End If
	End If
	Dim SB As StringBuilder
	SB.Initialize
	If mess.VerboseMode Then
		' Custom Keys
		If mess.ResponseKeys.IsInitialized = False Then
			mess.ResponseKeys.Initialize
		End If
		If mess.ResponseKeys.Size = 0 Then
			mess.ResponseKeys.Add("s")
			mess.ResponseKeys.Add("a")
			mess.ResponseKeys.Add("m")
			mess.ResponseKeys.Add("e")
			mess.ResponseKeys.Add("r")
			'mess.ResponseKeys.Add("t")
		End If
		Dim ResponseElements As Map
		ResponseElements.Initialize
		For Each Key As String In mess.ResponseKeys
			Select Key
				Case RESPONSE_ELEMENT_MESSAGE
					ResponseElements.Put(RESPONSE_ELEMENT_MESSAGE, mess.ResponseMessage)
				Case RESPONSE_ELEMENT_CODE
					ResponseElements.Put(RESPONSE_ELEMENT_CODE, mess.ResponseCode)
				Case RESPONSE_ELEMENT_STATUS
					ResponseElements.Put(RESPONSE_ELEMENT_STATUS, mess.ResponseStatus)
				Case RESPONSE_ELEMENT_TYPE
					ResponseElements.Put(RESPONSE_ELEMENT_TYPE, mess.ResponseType)
				Case RESPONSE_ELEMENT_ERROR
					ResponseElements.Put(RESPONSE_ELEMENT_ERROR, mess.ResponseError)
				Case RESPONSE_ELEMENT_RESULT
					If mess.ResponseData.IsInitialized Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseData)
					Else If mess.ResponseObject.IsInitialized Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseObject)
					Else If mess.ResponseBody Is String Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseBody)
					Else
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, Null)
					End If
			End Select
		Next
		' Override Status Code
		If mess.ResponseCode < 200 Or mess.ResponseCode > 299 Then
			resp.Status = 200
		Else
			resp.Status = mess.ResponseCode
		End If
		
		If mess.ResponseKeysAlias.IsInitialized Then
			Dim ResponseElementsVerbose As Map
			ResponseElementsVerbose.Initialize
			For i = 0 To mess.ResponseKeysAlias.Size - 1
				Dim oldKey As String = mess.ResponseKeys.Get(i)
				Dim Value As Object = ResponseElements.Get(oldKey)
				Dim newKey As String = mess.ResponseKeysAlias.Get(i)
				ResponseElementsVerbose.Put(newKey, Value)
			Next
			If mess.OrderedKeys Then ResponseElementsVerbose.Put("__order", mess.ResponseKeysAlias)
		Else
			ResponseElementsVerbose = ResponseElements
			If mess.OrderedKeys Then ResponseElementsVerbose.Put("__order", mess.ResponseKeys)
		End If
		If mess.OrderedKeys Then
			Select mess.ContentType
				Case CONTENT_TYPE_XML
					SB.Append($"<${mess.XmlRoot}>"$)
					SB.Append(CRLF).Append("  ").Append(ProcessOrderedXmlFromMap(mess.XmlElement, ResponseElementsVerbose, "  ", "  "))
					SB.Append(CRLF).Append($"</${mess.XmlRoot}>"$)
				Case CONTENT_TYPE_JSON
					SB.Append(ProcessOrderedJsonFromMap(ResponseElementsVerbose, "", "  "))
			End Select
		Else
			' order not preserved
			Select mess.ContentType
				Case CONTENT_TYPE_XML
					mess.ResponseObject = CreateMap(mess.XmlRoot: ResponseElementsVerbose)
					Dim m2x As Map2Xml
					m2x.Initialize
					SB.Append(m2x.MapToXml(mess.ResponseObject))
				Case CONTENT_TYPE_JSON
					SB.Append(ResponseElementsVerbose.As(JSON).ToString)
			End Select
		End If
	Else ' VerboseMode = False
		resp.Status = mess.ResponseCode
		If mess.OrderedKeys Then
			Select True
				Case mess.ResponseObject.IsInitialized
					If mess.ContentType = CONTENT_TYPE_XML Then
						SB.Append($"<${mess.XmlRoot}>"$)
						SB.Append(CRLF).Append("  ").Append(ProcessOrderedXmlFromMap(mess.XmlElement, mess.ResponseObject, "  ", "  "))
						SB.Append(CRLF).Append($"</${mess.XmlRoot}>"$)
					Else
						SB.Append(ProcessOrderedJsonFromMap(mess.ResponseObject, "", "  "))
					End If
				Case mess.ResponseData.IsInitialized
					If mess.ContentType = CONTENT_TYPE_XML Then
						If mess.XmlElement = "" Then mess.XmlElement = "item"
						SB.Append($"<${mess.XmlRoot}>"$)
						SB.Append(CRLF).Append(ProcessOrderedXmlFromList(mess.XmlElement, mess.ResponseData, "  ", "  "))
						SB.Append(CRLF).Append($"</${mess.XmlRoot}>"$)
					Else
						SB.Append(ProcessOrderedJsonFromList(mess.ResponseData, "", "  "))
					End If
				Case mess.ResponseBody Is String
					SB.Append(mess.ResponseBody)
				Case Else
					If mess.ContentType = CONTENT_TYPE_XML Then
						mess.ResponseObject = CreateMap("error": mess.ResponseError)
						SB.Append($"<${mess.XmlRoot}>"$)
						SB.Append(CRLF).Append("  ").Append($"<error>${mess.ResponseError}</error>"$)
						SB.Append(CRLF).Append($"</${mess.XmlRoot}>"$)
					Else
						mess.ResponseObject = CreateMap("error": mess.ResponseError)
						SB.Append(mess.ResponseObject.As(JSON).ToString)
					End If
			End Select
		Else
			Select True
				Case mess.ResponseObject.IsInitialized
					If mess.ContentType = CONTENT_TYPE_XML Then
						If mess.XmlElement = "" Then mess.XmlElement = "item"
						mess.ResponseObject = CreateMap(mess.XmlRoot: CreateMap(mess.XmlElement: mess.ResponseObject))
						Dim m2x As Map2Xml
						m2x.Initialize
						SB.Append(m2x.MapToXml(mess.ResponseObject))
					Else
						SB.Append(mess.ResponseObject.As(JSON).ToString)
					End If
				Case mess.ResponseData.IsInitialized
					If mess.ContentType = CONTENT_TYPE_XML Then
						If mess.XmlElement = "" Then mess.XmlElement = "item"
						mess.ResponseObject = CreateMap(mess.XmlRoot: CreateMap(mess.XmlElement: mess.ResponseData))
						Dim m2x As Map2Xml
						m2x.Initialize
						SB.Append(m2x.MapToXml(mess.ResponseObject))
					Else
						SB.Append(mess.ResponseData.As(JSON).ToString)
					End If
				Case mess.ResponseBody Is String
					SB.Append(mess.ResponseBody)
				Case Else
					If mess.ContentType = CONTENT_TYPE_XML Then
						mess.ResponseObject = CreateMap("error": mess.ResponseError)
						SB.Append($"<${mess.XmlRoot}>"$)
						SB.Append(CRLF).Append("  ").Append($"<error>${mess.ResponseError}</error>"$)
						SB.Append(CRLF).Append($"</${mess.XmlRoot}>"$)
					Else
						mess.ResponseObject = CreateMap("error": mess.ResponseError)
						SB.Append(mess.ResponseObject.As(JSON).ToString)
					End If
			End Select
		End If
	End If
	ReturnContent(SB.ToString.Trim, mess.ContentType, resp)
End Sub

Public Sub ReturnContent (Content As Object, ContentType As String, resp As ServletResponse)
	resp.ContentType = ContentType
	resp.Write(Content)
End Sub

Public Sub ReturnHtml (str As String, resp As ServletResponse)
	ReturnContent(str, CONTENT_TYPE_HTML, resp)
End Sub

Public Sub ReturnHtmlBody (cont As HttpResponseContent, resp As ServletResponse)
	ReturnContent(cont.ResponseBody, CONTENT_TYPE_HTML, resp)
End Sub

Public Sub ReturnHtmlPageNotFound (resp As ServletResponse)
	Dim str As String = $"<h1>404 Page Not Found</h1>"$
	ReturnHtml(str, resp)
End Sub

Public Sub ReturnHtmlBadRequest (resp As ServletResponse)
	Dim str As String = $"<h1>400 Bad Request</h1>"$
	ReturnHtml(str, resp)
End Sub

Public Sub ReturnHtmlMethodNotAllowed (resp As ServletResponse)
	Dim str As String = $"<h1>405 Method Not Allowed</h1>"$
	ReturnHtml(str, resp)
End Sub

Public Sub ReturnOutputStream (ins As InputStream, resp As ServletResponse)
	File.Copy2(ins, resp.OutputStream)
	resp.OutputStream.Close
End Sub

' resp.ContentType = "application/pdf"
' resp.SetHeader("Content-Disposition", "inline;filename=temp.pdf")
Public Sub ReturnFileInline (ins As InputStream, filename As String, resp As ServletResponse)
	If filename = "" Then filename = "file"
	resp.SetHeader("Content-Disposition", "inline;filename=" & filename)
	ReturnOutputStream(ins, resp)
End Sub

' resp.ContentType = "application/pdf"
' resp.SetHeader("Content-Disposition", "attachment;filename=temp.pdf")
Public Sub ReturnFileAttachment (ins As InputStream, filename As String, resp As ServletResponse)
	If filename = "" Then filename = "file"
	resp.SetHeader("Content-Disposition", "inline;filename=" & filename)
	ReturnOutputStream(ins, resp)
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
	If req.GetSession.GetAttribute2(session_name, "").As(String).EqualsIgnoreCase(headers.Get(0)) Then
		'Log("matched")
		Return True
	Else
		'Log("unmatched!")
		Return False
	End If
End Sub

' Format: xml, json 
Public Sub ValidateContent (Text As String, Format As String) As Boolean
	Text = Text.Trim
	Select Format.ToLowerCase
		Case "xml"
			Return Text.StartsWith("<")
		Case "json"
			Return Text.StartsWith("{") Or Text.StartsWith("[")
		Case Else
			Return True
	End Select
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

Public Sub ProperCase (Word As String) As String
	If Word.Length = 0 Then Return ""
	If Word.Length = 1 Then Return Word.ToUpperCase
	Return Word.CharAt(0).As(String).ToUpperCase & Word.SubString(1)
End Sub

' ===================================================================
' Taken from WebUtils
' ===================================================================
Public Sub ReplaceMap (Base As String, Replacements As Map) As String
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

Public Sub EscapeHtml (Value As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	For n = 0 To Value.Length - 1
		Dim c As Char = Value.CharAt(n)
		Select c
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
				sb.Append(c)
		End Select
	Next
	Return sb.ToString
End Sub
' ===================================================================

' Reference: https://www.b4x.com/android/forum/threads/escapexml-code-snippet.35720/
Public Sub EscapeXml (Raw As String) As String
	Dim sb As StringBuilder
	sb.Initialize
	For i = 0 To Raw.Length - 1
		Dim c As Char = Raw.CharAt(i)
		Select c
			Case QUOTE
				sb.Append("&quot;")
			Case "'"
				sb.Append("&apos;")
			Case "<"
				sb.Append("&lt;")
			Case ">"
				sb.Append("&gt;")
			Case "&"
				sb.Append("&amp;")
			Case Else
				sb.Append(c)
		End Select
	Next
	Return sb.ToString
End Sub