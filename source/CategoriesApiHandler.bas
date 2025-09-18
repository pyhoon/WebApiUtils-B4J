﻿B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'Api Handler class
'Version 5.30
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
	HRM = App.SetApiMessage(HRM, App.api)
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3) ' 3 For Api handler
	If ElementMatch("") Then
		If App.MethodAvailable2(Method, "/api/categories", Me) Then
			Select Method
				Case "GET"
					GetCategories
					Return
				Case "POST"
					CreateNewCategory
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	Else If ElementMatch("id") Then
		If App.MethodAvailable2(Method, "/api/categories/*", Me) Then
			Select Method
				Case "GET"
					GetCategoryById(ElementId)
					Return
				Case "PUT"
					UpdateCategoryById(ElementId)
					Return
				Case "DELETE"
					DeleteCategoryById(ElementId)
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

Private Sub GetCategories
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub GetCategoryById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Find(id)
	If DB.Found Then
		HRM.ResponseCode = 200
		HRM.ResponseObject = DB.First2
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub CreateNewCategory
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
		Return
	End If
	Dim data As Map = str.As(JSON).ToMap ' JSON payload
	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("category_name") 
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			ReturnApiResponse
			Return
		End If
	Next
	' Check conflict category name
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Where = Array("category_name = ?")
	DB.Parameters = Array(data.Get("category_name"))
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Category already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Insert new row
	DB.Reset
	DB.Columns = Array("category_name", _
	"created_date")
	DB.Parameters = Array(data.Get("category_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Save
	' Retrieve new row
	HRM.ResponseCode = 201
	HRM.ResponseObject = DB.First2
	HRM.ResponseMessage = "Category created successfully"
	ReturnApiResponse
	DB.Close
End Sub

Private Sub UpdateCategoryById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
		Return
	End If
	Dim data As Map = str.As(JSON).ToMap ' JSON payload
	' Check whether required keys are provided
	If data.ContainsKey("category_name") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'category_name' not found"
		ReturnApiResponse
		Return
	End If
	' Check conflict category name
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Where = Array("category_name = ?", "id <> ?")
	DB.Parameters = Array(data.Get("category_name"), id)
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Category already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Find row by id
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Update row by id
	DB.Reset
	DB.Columns = Array("category_name", _
	"modified_date")
	DB.Parameters = Array(data.Get("category_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Id = id
	DB.Save
	' Return updated row
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Category updated successfully"
	HRM.ResponseObject = DB.First2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub DeleteCategoryById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	' Find row by id
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Category not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Delete row
	DB.Reset
	DB.Id = id
	DB.Delete
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Category deleted successfully"
	ReturnApiResponse
	DB.Close
End Sub