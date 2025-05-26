B4J=true
Group=Classes
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
' Web API Utility
' Version 4.40
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
	Type HttpResponseMessage (ResponseMessage As String, ResponseCode As Int, ResponseStatus As String, ResponseType As String, ResponseError As Object, ResponseData As List, ResponseObject As Map, ResponseBody As Object, ContentType As String, XmlRoot As String, VerboseMode As Boolean, OrderedKeys As Boolean, ResponseKeys As List, ResponseKeysAlias As List)
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

' Same as RequestDataJson
' Tip about POST requests: if you want to get a URL parameter (req.GetParameter)
' then do it only after reading the payload, otherwise the payload will be searched
' for the parameter and will be lost.
Public Sub RequestData (Request As ServletRequest) As Map
	Return RequestDataJson(Request)
End Sub

Public Sub RequestDataJson (Request As ServletRequest) As Map
	Dim data As Map
	Dim inp As InputStream = Request.InputStream
	If inp.BytesAvailable <= 0 Then
		Return data
	End If
	Dim buffer() As Byte = Bit.InputStreamToBytes(inp)
	Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF-8")
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
	Dim str As String = BytesToString(buffer, 0, buffer.Length, "UTF-8")
	str = LinearizeXML(str)
	
	Dim xm As Xml2Map
	xm.Initialize
	xm.StripNamespaces = True
	data = xm.Parse(str)
	Return data
End Sub

' Remove comments, line breaks, tabs and spaces
Public Sub LinearizeXML (Text As String) As String
	Text = Regex.Replace("<!--[\s\S]*?-->", Text, "")
	Return Regex.Replace("\s+", Text, " ").Trim
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
			Dim str As String = BytesToString(ab, 0, ab.Length, "utf8")
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

'Public Sub GenerateVerboseJSON (mess As HttpResponseMessage, L As List, LeftSpaces As String, Identation As String) As String
'	'Dim keys As List
'	'keys.Initialize2(Array As String("s", "a", "r"))
'	If mess.ResponseKeys.IsInitialized = False Then
'		mess.ResponseKeys.Initialize
'	End If
'	If mess.ResponseKeys.Size = 0 Then
'		mess.ResponseKeys.Add("s")
'		mess.ResponseKeys.Add("a")
'		mess.ResponseKeys.Add("m")
'		mess.ResponseKeys.Add("e")
'		mess.ResponseKeys.Add("r")
'		'mess.ResponseKeys.Add("t")
'	End If
'	Dim resmap As Map = CreateMap("r": L, "__order": mess.ResponseKeys)
'	Return ProcessOrderedJsonFromMap(resmap, "", "  ")
'End Sub

Public Sub ProcessOrderedJsonFromList (L As List, LeftSpaces As String, Identation As String) As String
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
				SB.Append(ProcessOrderedJsonFromList(value, LeftSpaces, Identation))
			Case value Is Map
				SB.Append(ProcessOrderedJsonFromMap(value, LeftSpaces & Identation, Identation))
			Case value Is String
				SB.Append(LeftSpaces & QUOTE & value & QUOTE)
			Case Else
				SB.Append(LeftSpaces & value)
		End Select
	Next
	SB.Append(CRLF & LeftSpaces & "]")
	Return SB.ToString
End Sub

Public Sub ProcessOrderedJsonFromMap (M As Map, LeftSpaces As String, Identation As String) As String
	Dim SB As StringBuilder
	SB.Initialize
	SB.Append(LeftSpaces & "{")
	Dim order As List = M.Get("__order")
	Dim alias As List = M.Get("__alias")
	Dim First As Boolean = True
	Dim i As Int
	
	For Each key As String In order
		If First = False Then
			SB.Append(",")
		Else
			First = False
		End If
		SB.Append(CRLF)
		Dim value As Object = m.Get(key)
		If key <> "__order" And key <> "__alias" Then
			'For i = 0 To order.Size - 1
				If alias.IsInitialized And alias.Size > i Then
					key = alias.Get(i)
				End If
			'Next
			Select True
				Case value Is List
					SB.Append(LeftSpaces & Identation & QUOTE & key & QUOTE & ": " & ProcessOrderedJsonFromList(value, LeftSpaces & Identation, Identation))
				Case value Is Map
					SB.Append(LeftSpaces & Identation & QUOTE & key & QUOTE & ": " & ProcessOrderedJsonFromMap(value, LeftSpaces & Identation & Identation, Identation))
				Case value Is String
					SB.Append(LeftSpaces & Identation & QUOTE & key & QUOTE & ": " & QUOTE & value & QUOTE)
				Case Else
					SB.Append(LeftSpaces & Identation & QUOTE & key & QUOTE & ": " & value)
			End Select
		End If
		i = i + 1
	Next
	SB.Append(CRLF & LeftSpaces & "}")
	Return SB.ToString
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
	If mess.ContentType = CONTENT_TYPE_XML Then
		ReturnHttpResponse2(mess, resp)
		Return
		'Else
		'	If mess.ContentType = "" Then mess.ContentType = CONTENT_TYPE_JSON
		'	resp.ContentType = mess.ContentType
	End If
	If mess.VerboseMode Then
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
						'Else If GetType(mess.ResponseBody) = "java.lang.String" Then
					Else If mess.ResponseBody Is String Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseBody)
					Else
						'mess.ResponseObject.Initialize
						'ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseObject)
						'mess.ResponseData.Initialize
						'ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseData)
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
		
		Dim Content As String
		If mess.OrderedKeys Then
'			Dim SB As StringBuilder
'			SB.Initialize
'			SB.Append("{")
'			For i = 0 To mess.ResponseKeys.Size - 1
'				Dim eKey As String = mess.ResponseKeys.Get(i)
'				Dim eValue As Object = ResponseElements.Get(eKey)
'				If mess.KeysAlias.IsInitialized And mess.KeysAlias.Size > i Then
'					eKey = mess.KeysAlias.Get(i)
'				End If
'				If i > 0 Then
'					SB.Append(",")
'				End If
'				SB.Append(CRLF)
'				SB.Append("  ") ' 2 spaces
'				SB.Append(QUOTE)
'				SB.Append(eKey)
'				SB.Append(QUOTE)
'				SB.Append(": ")
'				Select True
'					Case eValue Is List
'						If eValue.As(List).Size = 0 Then
'							SB.Append(eValue)
'						Else
'							Dim gen As JSONGenerator
'							gen.Initialize2(eValue)
'							Dim json As String = gen.ToPrettyString(2)
'							json = json.SubString2(json.IndexOf(CRLF)+1, json.LastIndexOf("]"))
'							SB.Append("[")
'							For Each line As String In Regex.Split(CRLF, json)
'								SB.Append(CRLF).Append("  ").Append(line)
'							Next
'							SB.Append(CRLF).Append("  ]")
'						End If
'					Case eValue Is Map
'						If eValue.As(Map).Size = 0 Then
'							SB.Append(eValue)
'						Else
'							Dim gen As JSONGenerator
'							gen.Initialize(eValue)
'							Dim json As String = gen.ToPrettyString(2)
'							'Log(json)
'							json = json.SubString2(json.IndexOf(CRLF)+1, json.LastIndexOf("}"))
'							SB.Append("{")
'							For Each line As String In Regex.Split(CRLF, json)
'								SB.Append(CRLF).Append("  ").Append(line)
'							Next
'							SB.Append(CRLF).Append("  }")
'						End If
'					Case eValue Is String
'						SB.Append(QUOTE & eValue & QUOTE)
'					Case Else
'						SB.Append(eValue)
'				End Select
'			Next
'			SB.Append(CRLF)
'			SB.Append("}")
'			Content = SB.ToString
			'Dim resmap As Map = CreateMap("r": L, "__order": mess.ResponseKeys)
			If mess.ResponseKeys.IsInitialized Then ResponseElements.Put("__order", mess.ResponseKeys)
			If mess.ResponseKeysAlias.IsInitialized Then ResponseElements.Put("__alias", mess.ResponseKeysAlias)
			'ResponseElements.Put("__order", mess.KeysAlias)
			Content = ProcessOrderedJsonFromMap(ResponseElements, "", "  ")
		Else ' order not preserved
'			If GetType(ResponseElements.Get(RESPONSE_ELEMENT_ERROR)) = "java.lang.Object" Then ResponseElements.Put(RESPONSE_ELEMENT_ERROR, Null)
			
			Content = ResponseElements.As(JSON).ToString
'			Dim DB As MiniORM
'			DB.Initialize("", Null)
'			Dim keys As List
'			keys.Initialize2(Array As String("s", "a", "r"))
'		Dim resmap As Map = CreateMap("a": 200, "s": "ok", "r": mess.ResponseBody, "__order": keys)
'			'Content = DB.GenerateResults2JSON(DB.Results2, "       ", "  ")
'		Content = ProcessOrderedJsonFromMap(resmap, "", "  ")
		End If
	Else ' VerboseMode = False
		resp.Status = mess.ResponseCode
		
		Dim Content As String
		If mess.OrderedKeys Then
			If mess.ResponseData.IsInitialized Then
				Content = ProcessOrderedJsonFromList(mess.ResponseData, "", "  ")
			Else If mess.ResponseObject.IsInitialized Then
				Content = ProcessOrderedJsonFromMap(mess.ResponseObject, "", "  ")
			Else If mess.ResponseBody Is String Then
				Content = mess.ResponseBody
			Else
				Content = Null
			End If
		Else
			If mess.ResponseData.IsInitialized Then
				Content = mess.ResponseData.As(JSON).ToString
			Else If mess.ResponseObject.IsInitialized Then
				Content = mess.ResponseObject.As(JSON).ToString
			Else If mess.ResponseBody Is String Then
				Content = mess.ResponseBody
			Else
				Content = Null
			End If
		End If
	End If
	'Log(Content)
	'resp.Write(Content)
	ReturnContent(Content, CONTENT_TYPE_JSON, resp)
End Sub

' Return XML format response
' <em>To initialize:</em> <code>
' HRM.Initialize
' HRM.ContentType = WebApiUtils.CONTENT_TYPE_XML</code>
' ---------------------------------------------------------------
' <em>Output:</em>
' &lt;content&gt;
'   &lt;message&gt;Success&lt;/message&gt;
'   &lt;error&gt;Null&lt;/error&gt;
'   &lt;status&gt;ok&lt;/status&gt;
'   &lt;result&gt;
'     &lt;connect&gt;true&lt;connect&gt;
'   &lt;/result&gt;
'   &lt;code&gt;200&lt;code&gt;
' &lt;/content&gt;
Private Sub ReturnHttpResponse2 (mess As HttpResponseMessage, resp As ServletResponse)
	'If mess.ContentType = "" Then mess.ContentType = CONTENT_TYPE_XML
	'resp.ContentType = mess.ContentType
	If mess.XmlRoot = "" Then mess.XmlRoot = "root"
	'If mess.XmlElement = "" Then mess.XmlElement = "result"
	
	Dim ResponseElements As Map
	ResponseElements.Initialize
	If mess.VerboseMode Then
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
			mess.ResponseKeysAlias.Initialize
			mess.ResponseKeysAlias.Add("status")
			mess.ResponseKeysAlias.Add("code")
			mess.ResponseKeysAlias.Add("message")
			mess.ResponseKeysAlias.Add("error")
			mess.ResponseKeysAlias.Add("result")
			mess.ResponseKeysAlias.Add("type")
		End If
		'Dim ResponseElements As Map
		'ResponseElements.Initialize
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
					'If GetType(mess.ResponseError) = "java.lang.String" Then
					ResponseElements.Put(RESPONSE_ELEMENT_ERROR, mess.ResponseError)
					'Else
					'	ResponseElements.Put(RESPONSE_ELEMENT_ERROR, Null)
					'End If
				Case RESPONSE_ELEMENT_RESULT
					If mess.ResponseData.IsInitialized Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseData)
					Else If mess.ResponseObject.IsInitialized Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseObject)
					Else If mess.ResponseBody Is String Then
						ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseBody)
					Else
						'mess.ResponseObject.Initialize
						'ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseObject)
						'mess.ResponseData.Initialize
						'ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseData)
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

		Dim Content As String
		If mess.OrderedKeys Then
			Dim SB As StringBuilder
			SB.Initialize
			SB.Append($"<${mess.XmlRoot}>"$)
			For i = 0 To mess.ResponseKeys.Size - 1
				Dim eKey As String = mess.ResponseKeys.Get(i)
				Dim eValue As Object = ResponseElements.Get(eKey)
				If mess.ResponseKeysAlias.IsInitialized And mess.ResponseKeysAlias.Size > 0 Then
					eKey = mess.ResponseKeysAlias.Get(i)
				End If
				If mess.ResponseKeys.Get(i) = RESPONSE_ELEMENT_RESULT Then
					Select True
						Case eValue Is List
							If eValue.As(List).Size = 0 Then
								SB.Append(CRLF)
								SB.Append("  ")
								SB.Append($"<${eKey}/>"$)
							Else
								Dim List1 As List = eValue
								For m = 0 To List1.Size - 1
									Dim Map1 As Map = List1.Get(m)
									SB.Append(CRLF)
									SB.Append("  ")
									SB.Append($"<${eKey}>"$)
									For Each Key1 As String In Map1.keys
										SB.Append(CRLF)
										SB.Append("  ") ' 2 spaces
										SB.Append("  ")
										SB.Append($"<${Key1}>${Map1.Get(Key1)}</${Key1}>"$)
									Next
									SB.Append(CRLF)
									SB.Append("  ")
									SB.Append($"</${eKey}>"$)
								Next
							End If
						Case eValue Is Map
							'Dim m2x As Map2Xml
							'm2x.Initialize
							'SB.Append(m2x.MapToXml(CreateMap(eKey: eValue)))
							If eValue.As(Map).Size = 0 Then
								SB.Append(CRLF)
								SB.Append("  ")
								SB.Append($"<${eKey}/>"$)
							Else
								SB.Append(CRLF)
								SB.Append("  ")
								SB.Append($"<${eKey}>"$)
								Dim Map1 As Map = eValue
								For Each Key1 As String In Map1.Keys
									'Log(Key1) 'category
									Dim Child1 As Object = Map1.Get(Key1)
									Select True
										Case Child1 Is List
											Dim List1 As List = Child1
											For Each Child2 As Object In List1
												'Log(Child2)
												SB.Append(CRLF)
												SB.Append("  ")
												SB.Append("  ")
												SB.Append($"<${Key1}>"$) 'category
												Select True
													Case Child2 Is List
														Dim List2 As List = Child2
														For Each Child3 As Object In List2
															Log(Child3)
														Next
													Case Child2 Is Map
														Dim Map2 As Map = Child2
														'For Each Grand2Child As Object In Map2.Values
														'	Log(Grand2Child)
														'Next
														For Each Key2 As String In Map2.Keys
															'Log(Key2) 'products
															Dim Child3 As Object = Map2.Get(Key2)
															Select True
																Case Child3 Is List
																	Dim List3 As List = Child3
																	If List3.Size = 0 Then
																		SB.Append(CRLF)
																		SB.Append("  ") ' 2 spaces
																		SB.Append("  ") ' 2 spaces
																		SB.Append("  ") ' 2 spaces
																		SB.Append($"<${Key2}/>"$)
																	Else
																	
																		For Each Child3 As Object In List3
																			Log(Child3)
																			SB.Append(CRLF)
																			SB.Append("  ") ' 2 spaces
																			SB.Append("  ") ' 2 spaces
																			SB.Append("  ") ' 2 spaces
																			SB.Append($"<${Key2}>"$)
																			'SB.Append($"${Map2.Get(Key2)}"$)
																			SB.Append($"${Child3}"$)
																			SB.Append(CRLF)
																			SB.Append("  ") ' 2 spaces
																			SB.Append("  ") ' 2 spaces
																			SB.Append("  ") ' 2 spaces
																			SB.Append($"</${Key2}>"$)
																		Next
																	End If
																Case Child3 Is Map
																	Dim Map3 As Map = Child3
																	SB.Append(CRLF)
																	SB.Append("  ") ' 2 spaces
																	SB.Append("  ") ' 2 spaces
																	SB.Append("  ") ' 2 spaces
																	SB.Append($"<${Key2}>"$)
																	' todo: Check size of children
																	'Log(Map3.Size)
																	For Each Key3 As String In Map3.Keys
																		'Log(Key3) 'product
																		Dim Child4 As Object = Map3.Get(Key3)
																		Select True
																			Case Child4 Is List
																				'Log(Child4)
																				Dim List4 As List = Child4
																				If List4.Size = 0 Then
																					SB.Append(CRLF)
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append($"<${Key3}/>"$)
																				Else
																					'SB.Append($"<${Key3}>"$)
																					For Each Child5 As Object In List4
																						'Log(Child4)
																						'SB.Append($"<${Key3}>"$)
																						'SB.Append($"${Child4}"$)
																						Select True
																							Case Child5 Is List
																								Dim List5 As List = Child5
																								If List5.Size = 0 Then
																									'SB.Append($"${Child5}"$)
																									SB.Append(CRLF)
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append($"<${Key3}/>"$)
																								Else
																									For Each Child5 As Object In List4
																										SB.Append(CRLF)
																										SB.Append("  ") ' 2 spaces
																										SB.Append("  ") ' 2 spaces
																										SB.Append("  ") ' 2 spaces
																										SB.Append("  ") ' 2 spaces
																										SB.Append($"<${Key3}>"$)
																										SB.Append($"${Child5}"$)
																										SB.Append($"</${Key3}>"$)
																									Next
																								End If
																							Case Child5 Is Map
																								SB.Append(CRLF)
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append($"<${Key3}>"$) 'product
																								Dim Map5 As Map = Child5
																								For Each Key5 As String In Map5.Keys
																									SB.Append(CRLF)
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append("  ") ' 2 spaces
																									SB.Append($"<${Key5}>"$) 'id, name
																									SB.Append($"${Map5.Get(Key5)}"$)
																									SB.Append($"</${Key5}>"$)
																								Next
																								SB.Append(CRLF)
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append($"</${Key3}>"$)
																							Case Else
																								SB.Append(CRLF)
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								SB.Append("  ") ' 2 spaces
																								'SB.Append("  ") ' 2 spaces
																								SB.Append($"${Child5}"$)
																						End Select
																						
																					Next
																				End If
																			Case Child4 Is Map
																				'Log(Child4)
																				Dim Map4 As Map = Child4
																				For Each Key4 As String In Map4.Keys
																					SB.Append(CRLF)
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append("  ") ' 2 spaces
																					SB.Append($"<${Key4}>"$)
																					SB.Append($"${Map4.Get(Key4)}"$)
																					SB.Append($"</${Key4}>"$)
																				Next
																			Case Else
																				'Log(Child4)
																				'SB.Append($"<${Key3}>"$)
																				SB.Append($"${Child4}"$)
																				'SB.Append($"</${Key3}>"$)
																		End Select
																	Next
																	SB.Append(CRLF)
																	SB.Append("  ") ' 2 spaces
																	SB.Append("  ") ' 2 spaces
																	SB.Append("  ") ' 2 spaces
																	SB.Append($"</${Key2}>"$)
																	
																Case Else
																	SB.Append(CRLF)
																	SB.Append("  ") ' 2 spaces
																	SB.Append("  ") ' 2 spaces
																	SB.Append("  ") ' 2 spaces
																	SB.Append($"<${Key2}>"$)
																	'SB.Append($"${Map2.Get(Key2)}"$)
																	SB.Append($"${Child3}"$)
																	SB.Append($"</${Key2}>"$)
															End Select
														Next
													Case Else
														'For Each Grand2Child As Object In GrandChild
														'	Log(Grand2Child)
														'Next
														Log(Child2)
												End Select
												SB.Append(CRLF)
												SB.Append("  ")
												SB.Append("  ")
												SB.Append($"</${Key1}>"$)
											Next
										Case Child1 Is Map
											Log(Child1)
											SB.Append(CRLF)
											SB.Append("  ")
											SB.Append("  ")
											SB.Append($"<${Key1}>"$)
											
											'
											
											SB.Append(CRLF)
											SB.Append("  ")
											SB.Append("  ")
											SB.Append($"</${Key1}>"$)
										Case Else
											'Log(GetType(Child1))
											'Log(Child1)
											SB.Append(CRLF)
											SB.Append("  ")
											SB.Append("  ")
											SB.Append($"<${Key1}>"$)
											SB.Append($"<${Child1}>"$)
											SB.Append($"</${Key1}>"$)
									End Select

								Next
								SB.Append(CRLF)
								SB.Append("  ")
								SB.Append($"</${eKey}>"$)
							End If
						Case Else
							SB.Append(CRLF)
							SB.Append("  ") ' 2 spaces
							SB.Append($"<${eKey}>${eValue}</${eKey}>"$)
					End Select
				Else
					SB.Append(CRLF)
					SB.Append("  ") ' 2 spaces
					SB.Append($"<${eKey}>${eValue}</${eKey}>"$)
				End If
			Next
			SB.Append(CRLF)
			SB.Append($"</${mess.XmlRoot}>"$)
			Content = SB.ToString
		Else ' order not preserved
			'Log(GetType(ResponseElements.Get(RESPONSE_ELEMENT_ERROR)))
			'If GetType(ResponseElements.Get(RESPONSE_ELEMENT_ERROR)) = "java.lang.Object" Then ResponseElements.Put(RESPONSE_ELEMENT_ERROR, Null)
			Dim Map1 As Map
			Map1.Initialize
			For i = 0 To mess.ResponseKeys.Size - 1
				Dim eKey As String = mess.ResponseKeys.Get(i)
				Dim eValue As Object = ResponseElements.Get(eKey)
				If mess.ResponseKeysAlias.IsInitialized And mess.ResponseKeysAlias.Size > i Then
					eKey = mess.ResponseKeysAlias.Get(i)
				End If
				Map1.Put(eKey, eValue)
			Next
			Dim m2x As Map2Xml
			m2x.Initialize
			Content = m2x.MapToXml(CreateMap(mess.XmlRoot: Map1))
		End If
	Else ' VerboseMode = False
		resp.Status = mess.ResponseCode
		If mess.ResponseData.IsInitialized Then
			ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseData)
		Else If mess.ResponseObject.IsInitialized Then
			ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseObject)
		Else If mess.ResponseBody Is String Then
			ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseBody)
		Else
			'mess.ResponseObject.Initialize
			'ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseObject)
			'mess.ResponseData.Initialize
			'ResponseElements.Put(RESPONSE_ELEMENT_RESULT, mess.ResponseData)
			ResponseElements.Put(RESPONSE_ELEMENT_RESULT, Null)
		End If
		
		Dim eKey As String = "result"
		If mess.ResponseKeysAlias.IsInitialized And mess.ResponseKeysAlias.Size > 0 Then
			eKey = mess.ResponseKeysAlias.Get(0)
		End If
		Dim eValue As Object = ResponseElements.Get(RESPONSE_ELEMENT_RESULT)
		Dim Map1 As Map
		Map1.Initialize
		Map1.Put(eKey, eValue)
		Dim m2x As Map2Xml
		m2x.Initialize
		Content = m2x.MapToXml(CreateMap(mess.XmlRoot: Map1))
	End If
	'Log(Content)
	'resp.Write(Content)
	ReturnContent(Content, CONTENT_TYPE_XML, resp)
End Sub

Public Sub ReturnContent (Content As Object, ContentType As String, resp As ServletResponse)
	resp.ContentType = ContentType
	resp.Write(Content)
End Sub

Public Sub ReturnHtml (str As String, resp As ServletResponse)
	'resp.ContentType = CONTENT_TYPE_HTML
	'resp.Write(str)
	ReturnContent(str, CONTENT_TYPE_HTML, resp)
End Sub

Public Sub ReturnHtmlBody (cont As HttpResponseContent, resp As ServletResponse)
	'resp.ContentType = CONTENT_TYPE_HTML
	'resp.Write(cont.ResponseBody)
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