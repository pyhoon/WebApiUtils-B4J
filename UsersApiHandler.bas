B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
'Api Handler class
'Version 3.10
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private DB As MiniORM
	Private Method As String
	Private Elements() As String
	Private ElementId As Int
	Private ElementCode As String
	Type UserData (UserName As String, UserEmail As String, UserPassword As String, UserFlag As String, UserApiKey As String, UserToken As String, UserTokenExpiry As String, UserActive As Int)
	Type EmailData (RecipientName As String, RecipientEmail As String, Action As String, ActivateCode As String, ResetCode As String, TempPassword As String)
End Sub

Public Sub Initialize
	HRM.Initialize
	HRM.VerboseMode = Main.conf.VerboseMode
	HRM.ContentType = WebApiUtils.CONTENT_TYPE_XML
	'HRM.SimpleResponse = Main.conf.SimpleResponse
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3) ' 3 For Api handler
	Select Method
		Case "GET"
			'If ElementMatch("") Then
			'	GetUsers
			'	Return
			'End If
			If ElementMatch("id") Then
				GetUserById(ElementId)
				Return
			End If
			If ElementMatch("list") Then
				GetShowUserList
				Return
			End If
			If ElementMatch("activate/code") Then
				GetActivateUser(ElementCode)
				Return
			End If
			If ElementMatch("confirm-reset/code") Then
				GetConfirmResetPassword(ElementCode)
				Return
			End If
		Case "POST"
			'If ElementMatch("") Then
			'	PostUser
			'	Return
			'End If
			If ElementMatch("register") Then
				PostRegisterUser
				Return
			End If
			If ElementMatch("login") Then
				PostUserLogin
				Return
			End If
			If ElementMatch("token") Then
				PostUserToken
				Return
			End If
			If ElementMatch("profile") Then
				PostReadUserProfile
				Return
			End If
			If ElementMatch("reset-password") Then
				PostResetUserPassword
				Return
			End If
		Case "PUT"
			'If ElementMatch("id") Then
			'	PutUserById(ElementId)
			'	Return
			'End If
			If ElementMatch("change-password") Then
				PutChangeUserPassword
				Return
			End If
			If ElementMatch("update-profile") Then
				PutUpdateUserProfile
				Return
			End If
			'Case "DELETE"
			'	If ElementMatch("id") Then
			'		DeleteUserById(ElementId)
			'		Return
			'	End If
		Case Else
			Log("Unsupported method: " & Method)
			ReturnMethodNotAllow
			Return
	End Select
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
		Case "list", "register", "login", "token", "profile", "reset-password", "change-password", "update-profile"
			If Elements.Length = 1 Then
				If Elements(0).EqualsIgnoreCase(Pattern) Then
					Return True
				End If
			End If
		Case "activate/code"
			If Elements.Length = 2 Then
				If Elements(0).EqualsIgnoreCase("activate") Then
					ElementCode = Elements(1)
					Return True
				End If
			End If
		Case "confirm-reset/code"
			If Elements.Length = 2 Then
				If Elements(0).EqualsIgnoreCase("confirm-reset") Then
					ElementCode = Elements(1)
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

Private Sub ValidateToken (Token As UserData) As Boolean
	Try
		'If Token = Null Or Token.IsInitialized = False Then
		If NotInitialized(Token) Then 'B4J v10.20
			HRM.ResponseCode = 401
			HRM.ResponseError = "Undefine User Token"
			ReturnApiResponse
			Return False
		End If
		
		If Token.UserToken = "" Then
			HRM.ResponseCode = 401
			HRM.ResponseError = "Invalid User Token"
			ReturnApiResponse
			Return False
		End If
		
		Dim CurrentDateFormat As String = DateTime.DateFormat
		DateTime.DateFormat = "yyyy-MM-dd"
		DateTime.TimeFormat = "HH:mm:ss"
		Dim date1() As String = Regex.Split(" ", Main.conn.GetDateTime)
		Dim date2() As String = Regex.Split(" ", Token.UserTokenExpiry)
		Dim DateNow As String = date1(0)
		Dim TimeNow As String = date1(1)
		Dim DateExp As String = date2(0)
		Dim TimeExp As String = date2(1)
		Dim DateTime1 As Long = DateTime.DateTimeParse(DateNow, TimeNow)
		Dim DateTime2 As Long = DateTime.DateTimeParse(DateExp, TimeExp)
		DateTime.DateFormat = CurrentDateFormat
	Catch
		Log(LastException)
		HRM.ResponseCode = 401
		HRM.ResponseError = "Invalid User Token"
		ReturnApiResponse
		Return False
	End Try

	If DateTime1 > DateTime2 Then
		HRM.ResponseCode = 401
		HRM.ResponseError = "User Token Expired"
		ReturnApiResponse
		Return False
	End If
	Return True
End Sub

Private Sub FindUserByAccessToken (Token As String) As UserData
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Where = Array("user_token = ?")
	DB.Parameters = Array(Token)
	DB.Query
	
	If DB.Found Then
		Dim user As Map = DB.First
		Dim TokenUser As UserData
		TokenUser.Initialize
		'TokenUser.UserName = user.Get("user_name")
		TokenUser.UserEmail = user.Get("user_email")
		'TokenUser.UserActive = user.Get("user_active")
		'TokenUser.UserFlag = user.Get("user_activation_flag")
		TokenUser.UserToken = user.Get("user_token")
		TokenUser.UserTokenExpiry = user.Get("user_token_expiry")
	End If
	DB.Close
	Return TokenUser
End Sub

Sub SendEmail (NewEmail As EmailData)
	Try
		Dim ROOT_URL As String = Main.conf.RootUrl
		Dim ROOT_PATH As String = Main.conf.RootPath
		Dim APP_TRADEMARK As String = Main.ctx.Get("APP_TRADEMARK")
		Dim SMTP_USERNAME As String = Main.conf.SmtpUserName
		Dim SMTP_PASSWORD As String = Main.conf.SmtpPassword
		Dim SMTP_SERVER As String = Main.conf.SmtpServer
		Dim SMTP_USESSL As String = Main.conf.SmtpUseSsl
		Dim SMTP_PORT As Int = Main.conf.SmtpPort
		Dim EmailSubject As String
		Dim EmailBody As String
		
		Select True
			Case SMTP_USERNAME.EqualsIgnoreCase(""), _
				SMTP_PASSWORD.EqualsIgnoreCase(""), _
				SMTP_SERVER.EqualsIgnoreCase("")
				Log("Invalid SMTP Settings")
				Return
		End Select
		
		Select NewEmail.Action
			Case "send activation code"
				EmailSubject = APP_TRADEMARK
				EmailBody = $"Hi ${NewEmail.RecipientName},<br />
				Please click on this link to finish the registration process:<br />
				<a href="${ROOT_URL}/${ROOT_PATH}/users/activate/${NewEmail.ActivateCode}" id="user-activation-link" title="activate"
				target="_blank">${ROOT_URL}/${ROOT_PATH}/users/activate/${NewEmail.ActivateCode}</a><br />
				<br />
				If the link is not working, please copy the url to your browser.<br />
				<br />
				Regards,<br />
				<em>${APP_TRADEMARK}</em>"$					
			Case "send change password notification"
				EmailSubject = "Your password has been changed"
				EmailBody = $"Hi ${NewEmail.RecipientName},<br />
				We have noticed that you have changed your password recently.<br />
				<br />
				If this action is not initiated by you, please contact us immediately.<br />
				Otherwise, please ignore this email.<br />
				<br />
				Regards,<br />
				<em>${APP_TRADEMARK}</em>"$							
			Case "send reset code"
				EmailSubject = "Request to reset your password"
				EmailBody = $"Hi ${NewEmail.RecipientName},<br />
				We have received a request from you to reset your password.<br />
				<br />
				If this action is not initiated by you, please contact us immediately.<br />
				Otherwise, click the following link to confirm:<br />
				<br />
				<a href="${ROOT_URL}${ROOT_PATH}client/confirm-reset-password/${NewEmail.ResetCode}" id="reset-link" title="reset"
				target="_blank">${ROOT_URL}${ROOT_PATH}client/confirm-reset-password/${NewEmail.ResetCode}</a><br />
				<br />
				If the link is not working, please copy the url to your browser.<br />
				If you have changed your mind, just ignore this email.<br />				
				<br />
				Regards,<br />
				<em>${APP_TRADEMARK}</em>"$
			Case "send temp password"
				EmailSubject = "Your password has been reset"
				EmailBody = $"Hi ${NewEmail.RecipientName},<br />
				Your password has been reset.<br />
				Please use the following temporary password to log in.<br />
				Password: ${NewEmail.TempPassword}<br />
				<br />
				Once you are able to log in, please change to a new password.<br />
				<br />
				Regards,<br />
				<em>${APP_TRADEMARK}</em>"$
			Case Else
				Log("Wrong parameter")
				Return
		End Select

		Dim smtp As SMTP
		smtp.Initialize(SMTP_SERVER, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, "SMTP")
		smtp.UseSSL = IIf(SMTP_USESSL.EqualsIgnoreCase("True"), True, False)
		smtp.Sender = SMTP_USERNAME
		smtp.To.Add(NewEmail.RecipientEmail)
		smtp.AuthMethod = smtp.AUTH_LOGIN
		smtp.HtmlBody = True
		smtp.Subject = EmailSubject
		smtp.Body = EmailBody
		LogDebug("Sending email...")
		Wait For (smtp.Send) SMTP_MessageSent (Success As Boolean)
		If Success Then
			LogDebug("Message sent successfully")
		Else
			LogDebug("Error sending message")
			LogDebug(LastException)
		End If
	Catch
		LogDebug(LastException)
		WebApiUtils.ReturnError(HRM, Response, 400, "Error Send Email")
	End Try
End Sub

Private Sub GetShowUserList
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim access_token As String = WebApiUtils.RequestBearerToken(Request)
	Dim user As UserData = FindUserByAccessToken(access_token)
	If ValidateToken(user) = False Then
		Return
	End If
	
	Select Main.DBType
		Case DB.MYSQL
			Dim online As String = $"CASE WHEN (TIME_TO_SEC(TIMEDIFF(now(), user_last_login)) < 600)
			THEN 'Y' ELSE 'N' END AS online,
			TIME_TO_SEC(TIMEDIFF(now(), user_last_login)) AS last_online"$
		Case DB.SQLITE
			Dim online As String = $"CASE WHEN (((strftime('%s', 'now') - strftime('%s', user_last_login)) / 60) < 10)
			THEN 'Y' ELSE 'N' END AS online,
			(strftime('%s', 'now') - strftime('%s', user_last_login)) AS last_online"$
	End Select

	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Select = Array("user_email AS email", "user_name AS name", DB.IfNull("user_location", "", "location"), online)
	DB.ShowExtraLogs = True
	DB.Query
	
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results
	DB.Close
	ReturnApiResponse
End Sub

Private Sub GetUserById (Id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim access_token As String = WebApiUtils.RequestBearerToken(Request)
	Dim user As UserData = FindUserByAccessToken(access_token)
	If ValidateToken(user) = False Then
		Return
	End If
	
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_Users"
	DB.Find2("user_id = ?", Id)
	If DB.Found Then
		HRM.ResponseCode = 200
		HRM.ResponseObject = DB.First
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "User not found"
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub GetActivateUser (ActivationCode As String)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Select = Array("user_email", "user_hash", "user_salt", "user_activation_code")
	DB.Where = Array("user_activation_code = ?")
	DB.Parameters = Array(ActivationCode)
	DB.Query
	
	If DB.Found Then
		Dim api_key As String = Utility.SHA1(DB.First.Get("user_hash"))
		Dim new_code As String = Utility.MD5(Rnd(100001, 999999))
		
		DB.Reset
		DB.Columns = Array("user_api_key", "user_activation_code", "user_activation_flag", "user_active", "user_activated_date")
		DB.Where = Array("user_activation_code = ?")
		DB.Parameters = Array(api_key, new_code, "A", 1, Main.conn.GetDateTime, ActivationCode)
		DB.Save
		
		Dim user1 As Map = DB.First
		Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
		"activated_date": user1.Get("user_activated_date"))

		HRM.ResponseCode = 200
		HRM.ResponseObject = user2
		HRM.ResponseMessage = "User activated successfully"
	Else
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid activation code"
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub GetConfirmResetPassword (ResetCode As String)
	' #Version = v1
	' #Desc = Confirm reset User password by Reset Code
	' #Elements = ["confirm-reset", ":code"]
	
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Select = Array("user_email", "user_hash", "user_salt", "user_activation_code")
	DB.Where = Array("user_activation_code = ?")
	DB.Parameters = Array(ResetCode)
	DB.Query
	
	If DB.Found Then
		Dim salt As String = Utility.MD5(Rnd(100001, 999999))
		Dim temp As String = Utility.MD5(Rnd(100001, 999999))
		temp = temp.SubString(temp.Length - 8) ' get last 8 letters
		Dim hash As String = Utility.MD5(temp & salt)	' random password
		Dim code As String = Utility.MD5(Rnd(100001, 999999))
		Dim apikey As String = Utility.SHA1(hash)
		Dim token As String = Utility.SHA1(Rnd(100001, 999999))

		DB.Reset
		DB.Columns = Array("user_hash", "user_salt", "user_apikey", "user_token", "user_activation_code")
		DB.Where = Array("user_activation_code = ?")
		DB.Parameters = Array(hash, salt, apikey, token, code, ResetCode)
		DB.Save

		Dim user1 As Map = DB.First
		If Main.CONFIRMATION_REQUIRED Then
			Dim ResetPasswordEmail As EmailData
			ResetPasswordEmail.Initialize
			ResetPasswordEmail.RecipientName = user1.Get("user_name")
			ResetPasswordEmail.RecipientEmail = user1.Get("user_email")
			ResetPasswordEmail.Action = "send temp password"
			ResetPasswordEmail.TempPassword = temp
			SendEmail(ResetPasswordEmail)
		End If
		
		Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
		"api_key": user1.Get("user_api_key"), _
		"token": user1.Get("user_token"), _
		"token_expiry": user1.Get("user_token_expiry"), _
		"modified_date": user1.Get("modified_date"))

		HRM.ResponseCode = 200
		HRM.ResponseObject = user2
		HRM.ResponseMessage = "Password updated successfully"
	Else
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid reset code"
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PostRegisterUser
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If
	
	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("name", "email", "password")
	For Each requiredkey As String In RequiredKeys
		If Not(data.ContainsKey(requiredkey)) Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"'${requiredkey}' key not found"$
			ReturnApiResponse
			Return
		End If
	Next

	' Remap keys to table column names
	Utility.ReMapKey(data, "name", "user_name")
	Utility.ReMapKey(data, "email", "user_email")
	Utility.ReMapKey(data, "password", "user_password")

	' Check conflict user account
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Where = Array("user_email = ?")
	DB.Parameters = Array(data.Get("user_email"))
	DB.Query
	
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "User already exist"
		DB.Close
		ReturnApiResponse
		Return
	End If

	Dim Columns As List
	Columns.Initialize
	Dim Values As List
	Values.Initialize
	For Each key As String In data.Keys
		Select key
			Case "user_name"
				Dim user_name As String = data.Get(key)
				Columns.Add(key)
				Values.Add(user_name)
			Case "user_email"
				Dim user_email As String = data.Get(key)
				Columns.Add(key)
				Values.Add(user_email)
			Case "user_password"
				Dim salt As String = Utility.MD5(Rnd(100001, 999999))
				Dim hash As String = Utility.MD5(data.Get("user_password") & salt)
				Columns.Add("user_salt")
				Values.Add(salt)
				Columns.Add("user_hash")
				Values.Add(hash)
		End Select
	Next
	
	' Additional columns
	If Main.ACTIVATION_REQUIRED Then
		Dim activation_flag As String = "R"
		Columns.Add("user_activation_flag")
		Values.Add(activation_flag)
		Dim activation_code As String = Utility.MD5(salt & user_email)
		Columns.Add("user_activation_code")
		Values.Add(activation_code)
	Else
		Dim activation_flag As String = "A"
		Columns.Add("user_activation_flag")
		Values.Add(activation_flag)
		Dim api_key As String = Utility.SHA1(hash)
		Columns.Add("user_api_key")
		Values.Add(api_key)
	End If
	
	' Insert new row
	DB.Reset
	DB.Columns = Columns
	DB.Parameters = Values
	DB.Insert
	DB.Execute

	Dim NewID As Int = DB.LastInsertID
	DB.Reset
	DB.Where = Array("user_id = ?")
	DB.Parameters = Array(NewID)
	DB.Query

	Dim user1 As Map = DB.First
	Dim msg_text As String = $"New user registered (${user_email})"$
	Main.WriteUserLog("user/register", "success", msg_text, user1.Get("user_id"))
	
	' If activation required and email configured
	If Main.ACTIVATION_REQUIRED Then
		Dim NewUserEmail As EmailData
		NewUserEmail.Initialize
		NewUserEmail.RecipientName = user_name
		NewUserEmail.RecipientEmail = user_email
		NewUserEmail.Action = "send activation code"
		NewUserEmail.ActivateCode = activation_code
		SendEmail(NewUserEmail)
	End If
	
	' Return new user
	Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
	"name": user1.Get("user_name"), _
	"location": user1.Get("user_location"), _
	"user_activation_flag": user1.Get("user_activation_flag"), _
	"created_date": user1.Get("created_date"))

	HRM.ResponseCode = 201
	HRM.ResponseObject = user2
	HRM.ResponseMessage = "User created successfully"
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PostUserLogin
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("email", "password")
	For Each requiredkey As String In RequiredKeys
		If Not(data.ContainsKey(requiredkey)) Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"'${requiredkey}' key not found"$
			ReturnApiResponse
			Return
		End If
	Next

	' Remap keys to table column names
	Utility.ReMapKey(data, "email", "user_email")
	Utility.ReMapKey(data, "password", "user_password")
	Dim user_email As String = data.Get("user_email")
	Dim user_password As String = data.Get("user_password")

	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Select = Array("user_salt")
	DB.Where = Array("user_email = ?")
	DB.Parameters = Array(user_email)
	Dim user_salt As String = DB.Scalar
	Dim user_hash As String = Utility.MD5(user_password & user_salt)

	' Check user exist
	DB.Table = "tbl_users"
	DB.Select = Array("user_email AS 'email'", _
	"user_name AS 'name'", _
	DB.IfNull("user_location", "", "location"), _
	DB.IfNull("user_api_key", "", "api_key"), _
	"user_activation_flag AS 'flag'")
	DB.Where = Array("user_email = ?", "user_hash = ?")
	DB.Parameters = Array As String(user_email, user_hash)
	DB.Query
	
	If DB.Found = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Password is incorrect"
		DB.Close
		ReturnApiResponse
		Return
	End If
	
	Dim user1 As Map = DB.First
	If user1.Get("flag") = "R" Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Email Not Activated"
		DB.Close
		ReturnApiResponse
		Return
	End If

	Dim user2 As Map = CreateMap("email": user1.Get("email"), _
	"name": user1.Get("name"), _
	"location": user1.Get("location"), _
	"api_key": user1.Get("api_key"))
	
	' Retrieve updated row
	HRM.ResponseCode = 200
	HRM.ResponseObject = user2
	HRM.ResponseMessage = "Api key retrieved successfully"
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PostUserToken
	' #Version = v1
	' #Desc = Get User token
	' #Body = {<br>&nbsp;"email": "user_email",<br>&nbsp;"apikey": "api_key"<br>}
	' #Elements = ["token"]
	
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("email", "apikey")
	For Each requiredkey As String In RequiredKeys
		If Not(data.ContainsKey(requiredkey)) Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"'${requiredkey}' key not found"$
			ReturnApiResponse
			Return
		End If
	Next

	' Remap keys to table column names
	Utility.ReMapKey(data, "email", "user_email")
	Utility.ReMapKey(data, "apikey", "user_api_key")
	Dim user_email As String = data.Get("user_email")
	Dim api_key As String = data.Get("user_api_key")

	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Where = Array("user_email = ?", "user_api_key = ?")
	DB.Parameters = Array(user_email, api_key)
	DB.Query
	
	If DB.Found Then
		' Update user token
		Dim token As String = Utility.SHA1(Rnd(100001, 999999))
		DB.Reset
		DB.Columns = Array("user_token", _
		"user_token_expiry = " & Utility.CurrentTimeStampAddMinute(10), _
		"user_last_login = " & Utility.CurrentTimeStamp, _
		"user_login_count++")
		DB.Where = Array("user_email = ?", "user_api_key = ?")
		DB.Parameters = Array(token, user_email, api_key)
		DB.Save
		
		Dim user1 As Map = DB.First
		Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
		"token": user1.Get("user_token"), _
		"token_expiry": user1.Get("user_token_expiry"))

		HRM.ResponseCode = 200
		HRM.ResponseObject = user2
	Else
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid Api Key"
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PostReadUserProfile
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim access_token As String = WebApiUtils.RequestBearerToken(Request)
	Dim user As UserData = FindUserByAccessToken(access_token)
	If ValidateToken(user) = False Then
		Return
	End If

	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Remap keys to table column names
	Utility.ReMapKey(data, "email", "user_email")
	Dim user_email As String = data.Get("user_email")
	
	Select Main.DBType
		Case DB.MYSQL
			Dim online As String = $"CASE WHEN (TIME_TO_SEC(TIMEDIFF(now(), user_last_login)) < 600)
			THEN 'Y' ELSE 'N' END AS online,
			now() - user_last_login AS last_online"$
		Case DB.SQLITE
			Dim online As String = $"CASE WHEN (((strftime('%s', 'now') - strftime('%s', user_last_login)) / 60) < 10)
			THEN 'Y' ELSE 'N' END AS online,
			(strftime('%s', 'now') - strftime('%s', user_last_login)) AS last_online"$
	End Select
	
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Select = Array("user_name", _
	"user_email", _
	"user_location", _
	DB.IfNull("user_location", "", ""), _
	"user_last_login", _
	online)
	DB.Where = Array("user_email = ?")
	DB.Parameters = Array(user_email)
	DB.Query
	
	If DB.Found Then
		Dim user1 As Map = DB.First
		Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
		"name": user1.Get("user_name"), _
		"location": user1.Get("user_location"), _
		"last_login": user1.Get("user_last_login"), _
		"online": user1.Get("online"), _
		"last_online": user1.Get("last_online"))

		HRM.ResponseCode = 200
		HRM.ResponseObject = user2
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "User Not Found"
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PostResetUserPassword
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("email")
	For Each requiredkey As String In RequiredKeys
		If Not(data.ContainsKey(requiredkey)) Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"'${requiredkey}' key not found"$
			ReturnApiResponse
			Return
		End If
	Next

	' Remap keys to table column names
	Utility.ReMapKey(data, "email", "user_email")
	Dim user_email As String = data.Get("user_email")
	
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Where = Array("user_email = ?")
	DB.Parameters = Array(user_email)
	DB.Query
	If DB.Found Then
		Dim user1 As Map = DB.First
		If Main.CONFIRMATION_REQUIRED Then
			' Update activation code column with reset code
			Dim resetcode As String = Utility.MD5(Rnd(100001, 999999))
			DB.Reset
			DB.Columns = Array("user_activation_code")
			DB.Where = Array("user_email = ?")
			DB.Parameters = Array(resetcode, user_email)
			DB.Save
		
			Dim ResetPasswordEmail As EmailData
			ResetPasswordEmail.Initialize
			ResetPasswordEmail.RecipientName = user1.Get("user_name")
			ResetPasswordEmail.RecipientEmail = user1.Get("user_email")
			ResetPasswordEmail.Action = "send reset code"
			ResetPasswordEmail.ResetCode = resetcode
			SendEmail(ResetPasswordEmail)
		Else
			' if email confirmation not required
			' Update user api key and token
			Dim salt As String = Utility.MD5(Rnd(100001, 999999))
			Dim hash As String = Utility.MD5("password" & salt) ' default password
			Dim apikey As String = Utility.SHA1(hash)
			Dim token As String = Utility.SHA1(Rnd(100001, 999999))
			
			DB.Reset
			DB.Columns = Array("user_hash", "user_salt", "user_api_key", "user_token", "user_token_expiry = " & Utility.CurrentTimeStampAddMinute(10))
			DB.Where = Array("user_email = ?")
			DB.Parameters = Array(hash, salt, apikey, token, user_email)
			DB.Save
		End If
		Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
		"token": user1.Get("user_token"))

		HRM.ResponseCode = 200
		HRM.ResponseObject = user2
		HRM.ResponseMessage = "Password set to default (password)"
	Else
		HRM.ResponseCode = 400
		HRM.ResponseError = "Email not found"
	End If
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PutUpdateUserProfile
	' #Authenticate = Token
	' #Version = v1
	' #Desc = Update User name and location data
	' #Body = {<br>&nbsp;"name": "name",<br>&nbsp;"location": "location"<br>}
	' #Elements = ["update-profile"]

	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim access_token As String = WebApiUtils.RequestBearerToken(Request)
	Dim user As UserData = FindUserByAccessToken(access_token)
	If ValidateToken(user) = False Then
		Return
	End If

	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Remap keys to table column names
	Utility.ReMapKey(data, "name", "user_name")
	Utility.ReMapKey(data, "location", "user_location")
	Dim user_name As String = data.Get("user_name")
	Dim user_location As String = data.Get("user_location")
						
	Dim Columns As List
	Columns.Initialize
	Dim Values As List
	Values.Initialize
	Columns.Add("user_name")
	Values.Add(user_name)
	Columns.Add("user_location")
	Values.Add(user_location)
	
	' Condition
	Values.Add(user.UserEmail)
	Values.Add(user.UserToken)
	
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.UpdateModifiedDate = True
	DB.Columns = Columns
	DB.Parameters = Values
	DB.Where = Array("user_email = ?", "user_token = ?")
	DB.Save
	
	Dim user1 As Map = DB.First
	Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
	"name": user1.Get("user_name"), _
	"location": user1.Get("user_location"), _
	"modified_date": user1.Get("modified_date"))

	HRM.ResponseCode = 200
	HRM.ResponseMessage = "User updated successfully"
	HRM.ResponseObject = user2
	DB.Close
	ReturnApiResponse
End Sub

Private Sub PutChangeUserPassword
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim access_token As String = WebApiUtils.RequestBearerToken(Request)
	Dim user As UserData = FindUserByAccessToken(access_token)
	If ValidateToken(user) = False Then
		Return
	End If

	Dim data As Map = WebApiUtils.RequestData(Request)
	If Not(data.IsInitialized) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid json object"
		ReturnApiResponse
		Return
	End If

	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("old", "new")
	For Each requiredkey As String In RequiredKeys
		If Not(data.ContainsKey(requiredkey)) Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"'${requiredkey}' key not found"$
			ReturnApiResponse
			Return
		End If
	Next

	Dim user_email As String = user.UserEmail
	Dim current_password As String = data.Get("old")
	Dim change_password As String = data.Get("new")
	
	DB.Initialize(Main.DBType, Main.DBOpen)
	DB.Table = "tbl_users"
	DB.Select = Array("user_salt")
	DB.Where = Array("user_email = ?")
	DB.Parameters = Array(user_email)
	Dim user_salt As String = DB.Scalar
	Dim user_hash As String = Utility.MD5(current_password & user_salt)

	' Check user exist
	DB.Table = "tbl_users"
	DB.Select = Array("user_id AS 'id'", _
	"user_name AS 'name'", _
	"user_email AS 'email'", _
	"user_hash AS 'hash'", _
	"user_activation_flag AS 'flag'")
	DB.Where = Array("user_email = ?", "user_hash = ?")
	DB.Parameters = Array As String(user_email, user_hash)
	DB.Query
	
	If DB.Found = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Current password incorrect"
		DB.Close
		ReturnApiResponse
		Return
	End If

	If DB.First.Get("flag") = "R" Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Email Not Activated"
		DB.Close
		ReturnApiResponse
		Return
	End If

	If DB.First.Get("hash") = Utility.MD5(change_password & user_salt) Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "New password cannot be same"
		DB.Close
		ReturnApiResponse
		Return
	End If

	Dim salt As String = Utility.MD5(Rnd(100001, 999999))
	Dim hash As String = Utility.MD5(change_password & salt)
	Dim apikey As String = Utility.SHA1(hash)
	Dim token As String = Utility.SHA1(Rnd(100001, 999999))
	
	DB.Reset
	DB.UpdateModifiedDate = True
	DB.Columns = Array("user_hash", "user_salt", "user_api_key", "user_token", "user_token_expiry = " & Utility.CurrentTimeStampAddMinute(10))
	DB.Where = Array("user_email = ?")
	DB.Parameters = Array(hash, salt, apikey, token, user_email)
	DB.Save
	
	Dim user1 As Map = DB.First
	' Notify User of password change (optional)
	If Main.NOTIFICATION_ENABLED Then
		Dim NotifyEmail As EmailData
		NotifyEmail.Initialize
		NotifyEmail.RecipientName = user1.Get("user_name")
		NotifyEmail.RecipientEmail = user1.Get("user_email")
		NotifyEmail.Action = "send change password notification"
		SendEmail(NotifyEmail)
	End If
	
	Dim user2 As Map = CreateMap("email": user1.Get("user_email"), _
	"api_key": user1.Get("user_api_key"), _
	"token": user1.Get("user_token"), _
	"token_expiry": user1.Get("user_token_expiry"), _
	"modified_date": user1.Get("modified_date"))

	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Password updated successfully"
	HRM.ResponseObject = user2
	DB.Close
	ReturnApiResponse
End Sub