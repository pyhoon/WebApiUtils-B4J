B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Handler class
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Method As String
	Private Elements() As String
	Private ElementId As Int
End Sub

Public Sub Initialize
	App = Main.app
	HRM.Initialize
	HRM = WebApiUtils.SetApiMessage(HRM, App.api)
	'HRM.ContentType = Api.ContentType
	'HRM.VerboseMode = Api.VerboseMode
	'HRM.OrderedKeys = Api.OrderedKeys
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3) ' 3 For Api handler
	If ElementMatch("") Then
		If App.MethodAvailable2(Method, "/api/users", Me) Then
			Select Method
				Case "GET"
					GetUsers
					Return
				Case "POST"
					PostUser
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	Else If ElementMatch("id") Then
		If App.MethodAvailable2(Method, "/api/users/*", Me) Then
			Select Method
				Case "GET"
					GetUserById(ElementId)
					Return
				Case "PUT"
					PutUserById(ElementId)
					Return
				Case "DELETE"
					DeleteUserById(ElementId)
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	End If
	ReturnBadRequest
End Sub

Private Sub ElementMatch (Pattern As String) As Boolean
	Select Pattern
		Case ""
			If Elements.Length = 0 Then
				Return True
			End If
		Case "id"
			If Elements.Length = 1 Then
				If IsNumber(Elements(0)) Then
					ElementId = Elements(0)
					Return True
				End If
			End If
	End Select
	Return False
End Sub

Private Sub ReturnApiResponse
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub ReturnBadRequest
	WebApiUtils.ReturnBadRequest(HRM, Response)
End Sub

Private Sub ReturnMethodNotAllow
	WebApiUtils.ReturnMethodNotAllow(HRM, Response)
End Sub

Private Sub GetUsers
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Query
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = DB.Results2
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub GetUserById (Id As Int)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Find(Id)
	If DB.Found Then
		HRM.ResponseCode = 200
		HRM.ResponseObject = DB.First2
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "User not found"
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub PostUser
	Dim data As Map
	If HRM.ContentType = WebApiUtils.MIME_TYPE_XML Then
		data = WebApiUtils.RequestDataXml(Request)
		data = data.Get("root")
	Else
		data = WebApiUtils.RequestDataJson(Request)
	End If
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("user_name")
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			ReturnApiResponse
			Return
		End If
	Next
	
	' Check conflict User name
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Where = Array("user_name = ?")
	DB.Parameters = Array As String(data.Get("user_name"))
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "User already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	
	' Insert new row
	DB.Reset
	DB.Columns = Array("user_name", "created_date")
	DB.Parameters = Array(data.Get("user_name"), data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Save
	
	' Retrieve new row
	If DB.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = DB.Error.Message
	Else
		HRM.ResponseCode = 201
		HRM.ResponseObject = DB.First2 'DB.Results2.Get(0)
		HRM.ResponseMessage = "User created successfully"
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub PutUserById (Id As Int)
	Dim data As Map
	If HRM.ContentType = WebApiUtils.MIME_TYPE_XML Then
		data = WebApiUtils.RequestDataXml(Request)
		data = data.Get("root")
	Else
		data = WebApiUtils.RequestDataJson(Request)
	End If
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If
	
	' Check whether required keys are provided
	If data.ContainsKey("user_name") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'user_name' not found"
		ReturnApiResponse
		Return
	End If
	
	' Check conflict User name
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Where = Array("user_name = ?", "id <> ?")
	DB.Parameters = Array As String(data.Get("user_name"), Id)
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "User already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	
	DB.Find(Id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "User not found"
		ReturnApiResponse
		DB.Close
		Return
	End If

	DB.Reset
	DB.Columns = Array("user_name", _
	"modified_date")
	DB.Parameters = Array(data.Get("user_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Id = Id
	DB.Save

	HRM.ResponseCode = 200
	HRM.ResponseMessage = "User updated successfully"
	HRM.ResponseObject = DB.First2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub DeleteUserById (Id As Int)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Find(Id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "User not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	
	DB.Reset
	DB.Id = Id
	DB.Delete
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "User deleted successfully"
	ReturnApiResponse
	DB.Close
End Sub