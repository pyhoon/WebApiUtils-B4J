B4J=true
Group=App
ModulesStructureVersion=1
Type=StaticCode
Version=10.2
@EndOfDesignText@
'Utility code module
'Version 3.60
Sub Process_Globals
	
End Sub

Public Sub MD5 (str As String) As String
	Dim data() As Byte
	Dim MD As MessageDigest
	Dim BC As ByteConverter

	data = BC.StringToBytes(str, "UTF8")
	data = MD.GetMessageDigest(data, "MD5")
	Return BC.HexFromBytes(data).ToLowerCase
End Sub

Public Sub SHA1 (str As String) As String
	Dim data() As Byte
	Dim MD As MessageDigest
	Dim BC As ByteConverter

	data = BC.StringToBytes(str, "UTF8")
	data = MD.GetMessageDigest(data, "SHA-1")
	Return BC.HexFromBytes(data).ToLowerCase
End Sub

Public Sub ReMapKey (map As Map, key1 As String, key2 As String)
	If map.ContainsKey(key1) Then
		map.Put(key2, map.Get(key1))
		map.Remove(key1)
	End If
End Sub

Public Sub CurrentTimeStamp As String
	Select Main.DBType.ToUpperCase
		Case "MYSQL"
			Return "NOW()"
		Case "SQLITE"
			Return "datetime('Now')"
		Case Else
			Return ""
	End Select
End Sub

Public Sub CurrentTimeStampAddMinute (Value As Int) As String
	Select Main.DBType.ToUpperCase
		Case "MYSQL"
			Return $"DATE_ADD(NOW(), INTERVAL ${Value} MINUTE)"$
		Case "SQLITE"
			Return $"datetime('Now', '+${Value} minute')"$
		Case Else
			Return ""
	End Select
End Sub

Private Sub ReturnAlertScript (JSON As Boolean, VerboseMode As Boolean, AlertMessage As String, SuccessCode As Int) As String
	If VerboseMode Then
		If JSON Then
			Return $"
			var code = response.a
			var error = response.e
			if (code == ${SuccessCode}) {
  alert("${AlertMessage}")
  location.reload()
}
else {
  alert(code + " " + error)
}"$
		Else
			Return $"
			var code = $(response).find("code")
			var error = $(response).find("error")
			if (code == ${SuccessCode}) {
  alert("${AlertMessage}")
  location.reload()
}
else {
  alert(code + " " + error)
}"$
		End If
	Else
		Return $"alert("${AlertMessage}")
          location.reload()"$
	End If
End Sub

' align for update category and add product
Private Sub ReturnAlertScript2 (JSON As Boolean, VerboseMode As Boolean, AlertMessage As String, SuccessCode As Int) As String
	If VerboseMode Then
		If JSON Then
			Return $"	  if (response.a == ${SuccessCode}) {
	    alert("${AlertMessage}")
	    location.reload()
	  }
	  else {
	    alert(response.a + " " + response.e)
	  }"$
		Else
			Return $"
	  var code = $(response).find("code")
	  var error = $(response).find("error")
	  if (code == ${SuccessCode}) {
	    alert("${AlertMessage}")
	    location.reload()
	  }
	  else {
	    alert(code + " " + error)
	  }"$
		End If
	Else
		Return $"    alert("${AlertMessage}")
          location.reload()"$
	End If
End Sub

' align for delete category
Private Sub ReturnAlertScript3 (JSON As Boolean, VerboseMode As Boolean, AlertMessage As String, SuccessCode As Int) As String
	If VerboseMode Then
		If JSON Then
			Return $"	if (response.a == ${SuccessCode}) {
	  alert("${AlertMessage}")
	  location.reload()
	}
	else {
	  alert(response.a + " " + response.e)
	}"$
		Else
			Return $"
	var code = $(response).find("code")
	var error = $(response).find("error")
	if (code == ${SuccessCode}) {
	  alert("${AlertMessage}")
	  location.reload()
	}
	else {
	  alert(code + " " + error)
	}"$
		End If
	Else
		Return $"	alert("${AlertMessage}")
      location.reload()"$
	End If
End Sub

Private Sub ReturnSuccessScript (Verbose As Boolean, JSON As Boolean, ExpectAccessToken As Boolean) As String
	If JSON Then
		If Verbose Then
			Return $"success: function (data) {
					if (data.s == "ok" || data.s == "success") {
						var content = JSON.stringify(data.r, undefined, 2)
						$("#alert" + id).fadeOut("fast", function () {
							$("#response" + id).val(content)
							$("#alert" + id).html(data.a + " " + data.m)
							$("#alert" + id).removeClass("alert-danger")
							$("#alert" + id).addClass("alert-success")
							$("#alert" + id).fadeIn()
						})${IIf(ExpectAccessToken, $"
						// Json Web Token specific
						if (data.r.length > 0) {
							if ("access_token" in data.r[0]) {
								localStorage.setItem("access_token", data.r[0]["access_token"])
								console.log("access token stored!")
							}
						}"$, "")}
					}
					else {
						var content = JSON.stringify(data.r, undefined, 2)
						$("#alert" + id).fadeOut("fast", function () {
							$("#response" + id).val(content)
							$("#alert" + id).html(data.a + " " + data.e)
							$("#alert" + id).removeClass("alert-success")
							$("#alert" + id).addClass("alert-danger")
							$("#alert" + id).fadeIn()
						})
					}
				},"$
		Else
			Return $"success: function (data, textStatus, xhr) {
					var content = JSON.stringify(data, undefined, 2)
					$("#alert" + id).fadeOut("fast", function () {
						$("#response" + id).val(content)
						$("#alert" + id).html(xhr.status + " " + textStatus)
						$("#alert" + id).removeClass("alert-danger")
						$("#alert" + id).addClass("alert-success")
						$("#alert" + id).fadeIn()
					})${IIf(ExpectAccessToken, $"
					// Json Web Token specific
					if (data) {
						if ("access_token" in data) {
							localStorage.setItem("access_token", data["access_token"])
							console.log("access token stored!")
						}
					}"$, "")}
				},"$
		End If
	Else
		If Verbose Then
			Return $"success: function (data, textStatus, xhr) {
					var status = $(data).find("status").text()
					var code = $(data).find("code").text()
					var error = $(data).find("error").text()
					var message = $(data).find("message").text()
					var result = $(data).find("result")
					if (status == "ok" || status == "success") {
						$("#alert" + id).fadeOut("fast", function () {
							$("#response" + id).val(xhr.responseText)
							$("#alert" + id).html(code + " " + message)
							$("#alert" + id).removeClass("alert-danger")
							$("#alert" + id).addClass("alert-success")
							$("#alert" + id).fadeIn()
						})${IIf(ExpectAccessToken, $"
						// Access Token specific
						var access_token = $(result).find("token").text()
						if (access_token.length > 0) {
							localStorage.setItem("access_token", access_token)
							console.log("access token stored!")							
						}
						else {
							console.log("access token not found")	
						}"$, "")}
					}
					else {
						$("#alert" + id).fadeOut("fast", function () {
							$("#response" + id).val(xhr.responseText)
							$("#alert" + id).html(code + " " + error)
							$("#alert" + id).removeClass("alert-success")
							$("#alert" + id).addClass("alert-danger")
							$("#alert" + id).fadeIn()
						})
					}
				},"$
		Else
			Return $"success: function (data, textStatus, xhr) {
					$("#alert" + id).fadeOut("fast", function () {
						$("#response" + id).val(xhr.responseText)
						$("#alert" + id).html(xhr.status + " " + textStatus)
						$("#alert" + id).removeClass("alert-danger")
						$("#alert" + id).addClass("alert-success")
						$("#alert" + id).fadeIn()
					})${IIf(ExpectAccessToken, $"
					// Access Token specific
					var result = $(data).find("result")
					var access_token = $(result).find("token").text()
					if (access_token.length > 0) {
						localStorage.setItem("access_token", access_token)
						console.log("access token stored!")
					}
					else {
						console.log("access token not found")
					}"$, "")}
				},"$
		End If
	End If
End Sub

Private Sub ReturnSuccessTableScript (Verbose As Boolean, jsonResponse As String) As String
	If Verbose Then
		Return $"    success: function (response) {
      if (response.s == "ok") {
        var tbl_head = ""
        var tbl_body = ""
        if (${jsonResponse}.length) {
          tbl_head = "<thead class=\"bg-light\"><th style=\"text-align: right; width: 60px\">#</th><th>Code</th><th>Category</th><th>Name</th><th style=\"text-align: right\">Price</th><th style=\"width: 90px\">Actions</th></thead>"
          tbl_body += "<tbody>"
          $.each(${jsonResponse}, function () {
            var col_id = ""
            var col_code = ""
            var col_category = ""
            var col_name = ""
            var col_price = ""
            var col_edit = ""
            var id
            var code
            var name
            var price
            var catid
            $.each(this, function (key, value) {
              if (key == "id") {
                col_id = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
                id = value
              }
              else if (key == "product_code") {
                col_code = "<td class=\"align-middle\">" + value + "</td>"
                code = value
              }
              else if (key == "category_name") {
                col_category = "<td class=\"align-middle\">" + value + "</td>"
              }
              else if (key == "product_name") {
                col_name = "<td class=\"align-middle\">" + value + "</td>"
                name = value
              }
              else if (key == "product_price") {
                col_price = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
                price = value
              }
              else if (key == "category_id") {
                catid = value
              }
            })
            col_edit = "<td><a href=\"#edit\" class=\"text-primary mx-2\" data-toggle=\"modal\"><i class=\"edit fa fa-pen\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-code=\"" + code + "\" data-category=\"" + catid + "\" data-name=\"" + name + "\"  data-price=\"" + price + "\" title=\"Edit\"></i></a> <a href=\"#delete\" class=\"text-danger mx-2\" data-toggle=\"modal\"><i class=\"delete fa fa-trash\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-code=\"" + code + "\" data-category=\"" + catid + "\" data-name=\"" + name + "\" title=\"Delete\"></i></a></td>"
            tbl_body += "<tr>" + col_id + col_code + col_category + col_name + col_price + col_edit + "</tr>"
          })
          tbl_body += "</tbody>"
        }
        else {
          tbl_body = "<tr><td>No results</td></tr>"
        }
        $("#results table").html(tbl_head + tbl_body)
      }
      else {
        $(".alert").html(response.e)
        $(".alert").fadeIn()
      }
    },"$
	Else
		Return $"    success: function (response) {
      //console.log(response)
      var tbl_head = ""
      var tbl_body = ""
      if (${jsonResponse}.length) {
        tbl_head = "<thead class=\"bg-light\"><th style=\"text-align: right; width: 60px\">#</th><th>Code</th><th>Category</th><th>Name</th><th style=\"text-align: right\">Price</th><th style=\"width: 90px\">Actions</th></thead>"
        tbl_body += "<tbody>"
        $.each(${jsonResponse}, function () {
          var col_id = ""
          var col_code = ""
          var col_category = ""
          var col_name = ""
          var col_price = ""
          var col_edit = ""
          var id
          var code
          var name
          var price
          var catid
          $.each(this, function (key, value) {
            if (key == "id") {
              col_id = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
              id = value
            }
            else if (key == "product_code") {
              col_code = "<td class=\"align-middle\">" + value + "</td>"
              code = value
            }
            else if (key == "category_name") {
              col_category = "<td class=\"align-middle\">" + value + "</td>"
            }
            else if (key == "product_name") {
              col_name = "<td class=\"align-middle\">" + value + "</td>"
              name = value
            }
            else if (key == "product_price") {
              col_price = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
              price = value
            }
            else if (key == "category_id") {
              catid = value
            }
          })
          col_edit = "<td><a href=\"#edit\" class=\"text-primary mx-2\" data-toggle=\"modal\"><i class=\"edit fa fa-pen\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-code=\"" + code + "\" data-category=\"" + catid + "\" data-name=\"" + name + "\" data-price=\"" + price + "\" title=\"Edit\"></i></a> <a href=\"#delete\" class=\"text-danger mx-2\" data-toggle=\"modal\"><i class=\"delete fa fa-trash\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-code=\"" + code + "\" data-category=\"" + catid + "\" data-name=\"" + name + "\" title=\"Delete\"></i></a></td>"
          tbl_body += "<tr>" + col_id + col_code + col_category + col_name + col_price + col_edit + "</tr>"
        })
        tbl_body += "</tbody>"
      }
      else {
        tbl_body = "<tr><td>No results</td></tr>"
      }
      $("#results table").html(tbl_head + tbl_body)
    },"$
	End If
End Sub

Public Sub GenerateJSFileForHelp (DirName As String, FileName As String, JSON As Boolean, Verbose As Boolean)
	Dim script1 As String = $"// Button click event for all verbs
$(".get, .post, .put, .delete").click(function (e) {
	e.preventDefault()
	const element = $(this)
	const id = element.attr("id").substring(3)
	makeApiRequest(id)
})"$
	Dim script2 As String = $"// Function to set options
function setOptions(id) {
	const element = $("#btn" + id)
	const headers = setHeaders(element)
	switch (true) {
		case element.hasClass("get"):
			return {
				type: "GET",
				headers: headers,
				dataType: "${IIf(JSON, "json", "xml")}",
				${ReturnSuccessScript(Verbose, JSON, False)}
				error: function (xhr, textStatus, errorThrown) {
					var content = xhr.responseText
					$("#alert" + id).fadeOut("fast", function () {
						$("#response" + id).val(content)
						$("#alert" + id).html(xhr.status + " " + errorThrown)
						$("#alert" + id).removeClass("alert-success")
						$("#alert" + id).addClass("alert-danger")
						$("#alert" + id).fadeIn()
					})
				}
			}
			break
		case element.hasClass("post"):
			return {
				type: "POST",
				data: $("#body" + id).val(),
				dataType: "${IIf(JSON, "json", "xml")}",
				headers: headers,
				${ReturnSuccessScript(Verbose, JSON, True)}
				error: function (xhr, textStatus, thrownError) {
					var content = xhr.responseText			
					$("#alert" + id).fadeOut("fast", function () {
						$("#response" + id).val(content)
						$("#alert" + id).html(xhr.status + " " + thrownError)
						$("#alert" + id).removeClass("alert-success")
						$("#alert" + id).addClass("alert-danger")
						$("#alert" + id).fadeIn()
					})
				}
			}
			break
		case element.hasClass("put"):
			return {
				type: "PUT",
				data: $("#body" + id).val(),
				dataType: "${IIf(JSON, "json", "xml")}",
				headers: headers,
				${ReturnSuccessScript(Verbose, JSON, False)}
				error: function (xhr, textStatus, thrownError) {
					var content = xhr.responseText
					$("#alert" + id).fadeOut("fast", function () {
						$("#response" + id).val(content)
						$("#alert" + id).html(xhr.status + " " + thrownError)
						$("#alert" + id).removeClass("alert-success")
						$("#alert" + id).addClass("alert-danger")
						$("#alert" + id).fadeIn()
					})
				}
			}
			break
		case element.hasClass("delete"):
			return {
				type: "DELETE",
				dataType: "${IIf(JSON, "json", "xml")}",
				headers: headers,
				${ReturnSuccessScript(Verbose, JSON, False)}
				error: function (xhr, textStatus, thrownError) {
					var content = xhr.responseText
					$("#alert" + id).fadeOut("fast", function () {
						$("#response" + id).val(content)
						$("#alert" + id).html(xhr.status + " " + thrownError)
						$("#alert" + id).removeClass("alert-success")
						$("#alert" + id).addClass("alert-danger")
						$("#alert" + id).fadeIn()
					})
				}
			}
			break
		default: // unsupported verbs
			return {}
	}
}"$
	Dim script3 As String = $"// Function to return headers base on button class
function setHeaders(element) {
	// Using switch case for readibility
	switch (true) {
		case element.hasClass("basic"):
			return {
				"Accept": "application/json",
				"Authorization": "Basic " + btoa(localStorage.getItem("client_id") + ":" + localStorage.getItem("client_secret"))
			}
			break
		case element.hasClass("token"):
			return {
				"Accept": "application/json",
				"Authorization": "Bearer " + localStorage.getItem("access_token")
			}
			break
		default:
			return {
				"Accept": "application/json"
			}
	}
}"$
	Dim script4 As String = $"// Function to make API call using Ajax
function makeApiRequest(id) {
	const url = $("#path" + id).val()
	const options = setOptions(id)
	$.ajax(url, options)
}"$
	
	Dim HelpFile As String = $"${script1}
${script2}
${script3}
${script4}"$
	File.WriteString(DirName, FileName, HelpFile)
End Sub

Public Sub GenerateJSFileForCategory (DirName As String, FileName As String, JSON As Boolean, Verbose As Boolean)
	If JSON Then
		Dim jsonResponse As String
		If Verbose Then
			jsonResponse = "response.r"
		Else
			jsonResponse = "response"
		End If
		Dim script1 As String = $"
  var tbl_head = ""
  var tbl_body = ""
  $.getJSON("/${Main.conf.ApiName}/categories", function (response) {
    if (${jsonResponse}.length) {
      tbl_head = "<thead class=\"bg-light\"><th style=\"text-align: right; width: 60px\">#</th><th>Name</th><th style=\"width: 90px\">Actions</th></thead>"
      tbl_body += "<tbody>"
      $.each(${jsonResponse}, function () {
        var tbl_row = ""
        var col_id = ""
        var col_name = ""
        var id
        var name
        $.each(this, function (key, value) {
          if (key == "id") {
            col_id = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
            id = value
          }
          else if (key == "category_name") {
            col_name = "<td class=\"align-middle\">" + value + "</td>"
            name = value
          }
        })
        tbl_row = col_id + col_name + "<td><a href=\"#edit\" class=\"text-primary mx-2\" data-toggle=\"modal\"><i class=\"edit fa fa-pen\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-name=\"" + name + "\" title=\"Edit\"></i></a> <a href=\"#delete\" class=\"text-danger mx-2\" data-toggle=\"modal\"><i class=\"delete fa fa-trash\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-name=\"" + name + "\" title=\"Delete\"></i></a></td>"
        tbl_body += "<tr>" + tbl_row + "</tr>"
      })
      tbl_body += "</tbody>"
    }
    else {
      tbl_body = "<tr><td>No results</td></tr>"
    }
    $("#results table").html(tbl_head + tbl_body)
  })"$
		Dim script2 As String = $"$(document).on("click", ".edit", function (e) {
  var id = $(this).attr("data-id")
  var name = $(this).attr("data-name")
  $("#id1").val(id)
  $("#name1").val(name)
})"$
		Dim script3 As String = $"$(document).on("click", ".delete", function (e) {
  var id = $(this).attr("data-id")
  var name = $(this).attr("data-name")
  $("#id2").val(id)
  $("#name2").text(name)
})"$
		Dim script4 As String = $"$(document).on("click", "#add", function (e) {
  var form = $("#add_form")
  form.validate({
    rules: {
      name: {
        required: true
      },
      action: "required"
    },
    messages: {
      name: {
        required: "Please enter Category Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      e.preventDefault()
      var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "post",
        url: "/${Main.conf.ApiName}/categories",
        data: data,
        dataType: "${IIf(JSON, "json", "xml")}",
        success: function (response) {
          $("#new").modal("hide")
          ${ReturnAlertScript(JSON, Verbose, "New category added !", 201)}
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert(thrownError)
        }
      })
      // return false // required to block normal submit since you used ajax
    }
  })
})"$
		Dim script5 As String = $"$(document).on("click", "#update", function (e) {
  var form = $("#update_form")
  form.validate({
    rules: {
      name: {
        required: true
      },
      action: "required"
    },
    messages: {
      name: {
        required: "Please enter Category Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      e.preventDefault()
      var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "put",
        url: "/${Main.conf.ApiName}/categories/" + $("#id1").val(),
        data: data,
        dataType: "${IIf(JSON, "json", "xml")}",
        success: function (response) {
          $("#edit").modal("hide")
		  ${ReturnAlertScript2(JSON, Verbose, "Category updated successfully !", 200)}
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert(thrownError)
        }
      })
      // return false // required to block normal submit since you used ajax
    }
  })
})"$
		Dim script6 As String = $"$(document).on("click", "#remove", function (e) {
  e.preventDefault()
  var form = $("#delete_form")
  var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
  $.ajax({
    data: data,
    dataType: "json",
    type: "delete",
    url: "/${Main.conf.ApiName}/categories/" + $("#id2").val(),
    success: function (response) {
      $("#delete").modal("hide")
	  ${ReturnAlertScript3(JSON, Verbose, "Category deleted successfully !", 200)}
    },
    error: function (xhr, ajaxOptions, thrownError) {
      alert(thrownError)
    }
  })
})"$
		Dim script7 As String = $"function convertFormToJSON(form) {
  const array = $(form).serializeArray() // Encodes the set of form elements as an array of names and values.
  const json = {}
  $.each(array, function () {
    json[this.name] = this.value || ""
  })
  return json
}"$
	Else ' XML
		'Dim xmlResponse As String
		If Verbose Then
			Dim script1 As String = $"
  var tbl_head = ""
  var tbl_body = ""
  $.ajax({
    type: "get",
    url: "/${Main.conf.ApiName}/categories",
    dataType: "xml",
    success: function (response) {
	  if (response.length) {
	    tbl_head = "<thead class=\"bg-light\"><th style=\"text-align: right; width: 60px\">#</th><th>Name</th><th style=\"width: 90px\">Actions</th></thead>"
	    tbl_body += "<tbody>"
	    $.each(response, function () {
	      var tbl_row = ""
	      var col_id = ""
	      var col_name = ""
	      var id
	      var name
	      $.each(this, function (key, value) {
	        if (key == "id") {
	          col_id = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
	          id = value
	        }
	        else if (key == "category_name") {
	          col_name = "<td class=\"align-middle\">" + value + "</td>"
	          name = value
	        }
	      })
	      tbl_row = col_id + col_name + "<td><a href=\"#edit\" class=\"text-primary mx-2\" data-toggle=\"modal\"><i class=\"edit fa fa-pen\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-name=\"" + name + "\" title=\"Edit\"></i></a> <a href=\"#delete\" class=\"text-danger mx-2\" data-toggle=\"modal\"><i class=\"delete fa fa-trash\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-name=\"" + name + "\" title=\"Delete\"></i></a></td>"
	      tbl_body += "<tr>" + tbl_row + "</tr>"
	    })
	    tbl_body += "</tbody>"
	  }
	  else {
	    tbl_body = "<tr><td>No results</td></tr>"
	  }
	},
    error: function (xhr, ajaxOptions, thrownError) {
      alert(thrownError)
    }
  })
  $("#results table").html(tbl_head + tbl_body)"$
	
			Dim script2 As String = $"$(document).on("click", ".edit", function (e) {
  var id = $(this).attr("data-id")
  var name = $(this).attr("data-name")
  $("#id1").val(id)
  $("#name1").val(name)
})"$
			Dim script3 As String = $"$(document).on("click", ".delete", function (e) {
  var id = $(this).attr("data-id")
  var name = $(this).attr("data-name")
  $("#id2").val(id)
  $("#name2").text(name)
})"$
			Dim script4 As String = $"$(document).on("click", "#add", function (e) {
  var form = $("#add_form")
  form.validate({
    rules: {
      name: {
        required: true
      },
      action: "required"
    },
    messages: {
      name: {
        required: "Please enter Category Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      e.preventDefault()
      var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "post",
        url: "/${Main.conf.ApiName}/categories",
        data: data,
        dataType: "${IIf(JSON, "json", "xml")}",
        success: function (response) {
          $("#new").modal("hide")
          ${ReturnAlertScript(JSON, Verbose, "New category added !", 201)}
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert(thrownError)
        }
      })
      // return false // required to block normal submit since you used ajax
    }
  })
})"$
			Dim script5 As String = $"$(document).on("click", "#update", function (e) {
  var form = $("#update_form")
  form.validate({
    rules: {
      name: {
        required: true
      },
      action: "required"
    },
    messages: {
      name: {
        required: "Please enter Category Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      e.preventDefault()
      var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "put",
        url: "/${Main.conf.ApiName}/categories/" + $("#id1").val(),
        data: data,
        dataType: "${IIf(JSON, "json", "xml")}",
        success: function (response) {
          $("#edit").modal("hide")
		  ${ReturnAlertScript2(JSON, Verbose, "Category updated successfully !", 200)}
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert(thrownError)
        }
      })
      // return false // required to block normal submit since you used ajax
    }
  })
})"$
			Dim script6 As String = $"$(document).on("click", "#remove", function (e) {
  e.preventDefault()
  var form = $("#delete_form")
  var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
  $.ajax({
    data: data,
    dataType: "json",
    type: "delete",
    url: "/${Main.conf.ApiName}/categories/" + $("#id2").val(),
    success: function (response) {
      $("#delete").modal("hide")
	  ${ReturnAlertScript3(JSON, Verbose, "Category deleted successfully !", 200)}
    },
    error: function (xhr, ajaxOptions, thrownError) {
      alert(thrownError)
    }
  })
})"$
			Dim script7 As String = $"function convertFormToJSON(form) {
  const array = $(form).serializeArray() // Encodes the set of form elements as an array of names and values.
  const json = {}
  $.each(array, function () {
    json[this.name] = this.value || ""
  })
  return json
}"$
		Else
			' Verbose = False
		
		End If
	End If
		
	Dim CategoryFile As String = $"$(document).ready(function () {
${script1}
})

${script2}

${script3}

${script4}

${script5}

${script6}

${script7}"$
	File.WriteString(DirName, FileName, CategoryFile)
End Sub

Public Sub GenerateJSFileForSearch (DirName As String, FileName As String, JSON As Boolean, Verbose As Boolean)
	If JSON Then
		Dim jsonResponse As String
		If Verbose Then
			jsonResponse = "response.r"
		Else
			jsonResponse = "response"
		End If

		Dim script1 As String = $"  $.getJSON("/${Main.conf.ApiName}/categories", function (response) {
    var item = ${jsonResponse}
    var $category1 = $("#category1")
    var $category2 = $("#category2")
    $.each(item, function (i, category) {
      $category1.append($("<option />").val(category.id).text(category.category_name))
      $category2.append($("<option />").val(category.id).text(category.category_name))
    })
  })"$
		Dim script2 As String = $"  $.getJSON("/${Main.conf.ApiName}/find", function (response) {
    var tbl_head = ""
    var tbl_body = ""
    if (${jsonResponse}.length) {
      tbl_head = "<thead class=\"bg-light\"><th style=\"text-align: right; width: 60px\">#</th><th>Code</th><th>Category</th><th>Name</th><th style=\"text-align: right\">Price</th><th style=\"width: 90px\">Actions</th></thead>"
      tbl_body += "<tbody>"
      $.each(${jsonResponse}, function () {
        var col_id = ""
        var col_code = ""
        var col_category = ""
        var col_name = ""
        var col_price = ""
        var col_edit = ""
        var id
        var code
        var name
        var price
        var catid
        $.each(this, function (key, value) {
          if (key == "id") {
            col_id = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
            id = value
          }
          else if (key == "product_code") {
            col_code = "<td class=\"align-middle\">" + value + "</td>"
            code = value
          }
          else if (key == "category_name") {
            col_category = "<td class=\"align-middle\">" + value + "</td>"
          }
          else if (key == "product_name") {
            col_name = "<td class=\"align-middle\">" + value + "</td>"
            name = value
          }
          else if (key == "product_price") {
            col_price = "<td class=\"align-middle\" style=\"text-align: right\">" + value + "</td>"
            price = value
          }
          else if (key == "category_id") {
            catid = value
          }
        })
        col_edit = "<td><a href=\"#edit\" class=\"text-primary mx-2\" data-toggle=\"modal\"><i class=\"edit fa fa-pen\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-code=\"" + code + "\" data-category=\"" + catid + "\" data-name=\"" + name + "\" data-price=\"" + price + "\" title=\"Edit\"></i></a> <a href=\"#delete\" class=\"text-danger mx-2\" data-toggle=\"modal\"><i class=\"delete fa fa-trash\" data-toggle=\"tooltip\" data-id=\"" + id + "\" data-code=\"" + code + "\" data-category=\"" + catid + "\" data-name=\"" + name + "\" title=\"Delete\"></i></a></td>"
        tbl_body += "<tr>" + col_id + col_code + col_category + col_name + col_price + col_edit + "</tr>"
      })
      tbl_body += "</tbody>"
    }
    else {
      tbl_body = "<tr><td>No results</td></tr>"
    }
    $("#results table").html(tbl_head + tbl_body)
  })"$
		Dim script3 As String = $"$("#btnsearch").click(function (e) {
  e.preventDefault()
  var form = $("#search_form")
  var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
  $.ajax({
    type: "post",
    url: "/${Main.conf.ApiName}/find",
    data: data,
    dataType: "json",
	${ReturnSuccessTableScript(Verbose, jsonResponse)}
    error: function (xhr, ajaxOptions, thrownError) {
      $(".alert").html(thrownError)
      $(".alert").fadeIn()
    }
  })
})"$
		Dim script4 As String = $"$(document).on("click", ".edit", function (e) {
  var id = $(this).attr("data-id")
  var category = $(this).attr("data-category")
  var code = $(this).attr("data-code")
  var name = $(this).attr("data-name")
  var price = $(this).attr("data-price").replace(",", "")
  $("#id1").val(id)
  $("#category2").val(category)
  $("#code1").val(code)
  $("#name1").val(name)
  $("#price1").val(price)
})"$
		Dim script5 As String = $"$(document).on("click", ".delete", function (e) {
  var id = $(this).attr("data-id")
  var code = $(this).attr("data-code")
  var name = $(this).attr("data-name")
  $("#id2").val(id)
  $("#code_name").text("(" + code + ") " + name)
})"$
		Dim script6 As String = $"$(document).on("click", "#add", function (e) {
  var form = $("#add_form")
  form.validate({
    rules: {
      product_code: {
        required: true,
        minlength: 3
      },
      product_name: {
        required: true
      },
      action: "required"
    },
    messages: {
      product_code: {
        required: "Please enter Product Code",
        minlength: "Value must be at least 3 characters"
      },
      product_name: {
        required: "Please enter Product Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      e.preventDefault()
      var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        type: "POST",
        url: "/${Main.conf.ApiName}/products",
        data: data,
        dataType: "json",
        success: function (response) {
          $("#new").modal("hide")
		  ${ReturnAlertScript2(JSON, Verbose, "New product added !", 201)}
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert(thrownError)
        }
      })
    }
  })
})"$
		Dim script7 As String = $"$(document).on("click", "#update", function (e) {
  var form = $("#update_form")
  form.validate({
    rules: {
      product_code: {
        required: true,
        minlength: 3
      },
      product_name: {
        required: true
      },
      action: "required"
    },
    messages: {
      product_code: {
        required: "Please enter Product Code",
        minlength: "Value must be at least 3 characters"
      },
      product_name: {
        required: "Please enter Product Name"
      },
      action: "Please provide some data"
    },
    submitHandler: function (form) {
      e.preventDefault()
      var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
      $.ajax({
        data: data,
        dataType: "json",
        type: "put",
        url: "/${Main.conf.ApiName}/products/" + $("#id1").val(),
        success: function (response) {
          $("#edit").modal("hide")
		  ${ReturnAlertScript2(JSON, Verbose, "Product updated successfully !", 200)}
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert(thrownError)
        }
      })
    }
  })
})"$
		Dim script8 As String = $"$(document).on("click", "#remove", function (e) {
  e.preventDefault()
  var form = $("#delete_form")
  var data = JSON.stringify(convertFormToJSON(form), undefined, 2)
  $.ajax({
    data: data,
    dataType: "json",
    type: "delete",
    url: "/${Main.conf.ApiName}/products/" + $("#id2").val(),
    success: function (response) {
      $("#delete").modal("hide")
	  ${ReturnAlertScript3(JSON, Verbose, "Product deleted successfully !", 200)}
    },
    error: function (xhr, ajaxOptions, thrownError) {
      alert(thrownError)
    }
  })
})"$
		Dim script9 As String = $"function convertFormToJSON(form) {
  const array = $(form).serializeArray() // Encodes the set of form elements as an array of names and values.
  const json = {}
  $.each(array, function () {
    json[this.name] = this.value || ""
  })
  return json
}"$
	Else ' XML
		'Dim xmlResponse As String
		If Verbose Then
			
		Else
			
		End If
	End If

	Dim SearchFile As String = $"$(document).ready(function () {
${script1}

${script2}
})

${script3}

${script4}

${script5}

${script6}

${script7}

${script8}

${script9}"$
	File.WriteString(DirName, FileName, SearchFile)
End Sub