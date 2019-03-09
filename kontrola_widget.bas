B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.5
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim rv As RemoteViews
	Private const API_KEY As String = "AIzaSyAHPnRfbzzEggfD218kHdYoArcHRhb0ww4"
	Public kojiUpdate As Int
	Private kojiGumbApdejtOK As Boolean
	Public flp As FusedLocationProvider
'	Public LocationSource As Object
'	Private LocationChangedListener As JavaObject
	Private man As ManamIP
	Private lat, lon As Double
End Sub

Sub Service_Create
	rv = ConfigureHomeWidget("k_widget", "rv", 0, "", False)
	man.Initialize("Manam", Me)
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
	If StartingIntent.Action = "android.appwidget.action.APPWIDGET_DELETED" Then Return
	If rv.HandleWidgetEvents(StartingIntent) = False Then
		' If the action is not handled by HandleWidgetEvents() then we
		' probably were called by StartService() or StartServiceAt().
		' So just update the widget.
		rv_RequestUpdate
	End If
End Sub

Sub Service_Destroy
End Sub

Sub rv_RequestUpdate
	rv.UpdateWidget
End Sub

Sub rv_Disabled
	CancelScheduledService("")
	StopService("")
End Sub

Sub img1_Click
	Log("gumb1")
	man.GetIPInfo
'	wait for Manam_Ready
'	Log(lat)
'	Log(lon)
'	If Starter.GPS1.GPSEnabled = False Then
''		ToastMessageShow("Please enable the GPS device.", True)
'		StartActivity(Starter.GPS1.LocationSettingsIntent) 'Will open the relevant settings screen.
'	Else
'		If Starter.rp.Check(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION) = False Then
'			Log("No permission")
'			Return
'		Else
'			StartFLP
''			gpsClient.Start(0, 0)
'			rv.SetText("lblLat", "Esperando localización de GPS")
'		End If
'	End If
'	Starter.rp.CheckAndRequest(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION)
'	Wait For Activity_PermissionResult (Permission As String, Result As Boolean)
'		If Result Then CallSubDelayed(Starter, "StartGPS")
'	End If

'	kojiUpdate = 1
'	kojiGumbApdejtOK = True
'	If Not(kontrola_flp.FusedLocationProvider1.IsInitialized) Then
'		StartActivity(kontrola_activity)
'	Else
'	UpdateUI1
'	kojiGumbApdejtOK = False
'	End If
End Sub

Sub Manam_Ready(result As Map, success As Boolean)
	If success Then
		Log(result)
		lat = result.Get("lat")
		lon = result.Get("lon")
		UpdateUI1
	Else
		Log(LastException)
	End If
End Sub
'Sub StartFLP
'	flp.Initialize("flp")
'	flp.Connect
'	Wait For flp_ConnectionSuccess
'	Log("FLP connected")
'	Dim request As LocationRequest
'	request.Initialize
'	request.SetPriority(request.Priority.PRIORITY_HIGH_ACCURACY)
'	request.SetInterval(2000)
'	request.SetFastestInterval(1000)
'	flp.RequestLocationUpdates(request)
'	Dim jo As JavaObject = flp
'	LocationSource = jo.CreateEventFromUI("com.google.android.gms.maps.LocationSource", "LocationSource", Null)
'	LocationSource_Ready(True)
''	CallSubDelayed2(Main, "LocationSource_Ready", True)
'End Sub
'
'Sub LocationSource_Ready(Result As Boolean)
'	Log("redi!")
'End Sub
'
'Sub LocationSource_Event (MethodName As String, Args() As Object) As Object
'	If MethodName = "activate" Then
'		LocationChangedListener = Args(0)
'		Dim loc As Location = flp.GetLastKnownLocation
'		If loc.IsInitialized Then FLP_LocationChanged(loc)
'	Else if MethodName = "deactivate" Then
'		LocationChangedListener = Null
'	End If
'	Return Null
'End Sub
'
'Sub FLP_ConnectionFailed(ConnectionResult1 As Int)
'	CallSubDelayed2(Main, "LocationSource_Ready", False)
'End Sub
'
'Sub FLP_LocationChanged(Location1 As Location)
'	Log("Location Changed: " & Location1)
'	If LocationChangedListener <> Null And LocationChangedListener.IsInitialized Then
'		LocationChangedListener.RunMethod("onLocationChanged", Array(Location1))
'	End If
'End Sub

Sub img2_Click
	Log("gumb2")
	kojiUpdate = 2
	kojiGumbApdejtOK = True
	If kontrola_flp.FusedLocationProvider1.IsInitialized = False Then
		StartActivity(kontrola_activity)
	Else
		UpdateUI2
		kojiGumbApdejtOK = False
	End If
End Sub

Sub img3_Click
	Log("gumb3")
	kojiUpdate = 3
	kojiGumbApdejtOK = True
	If kontrola_flp.FusedLocationProvider1.IsInitialized = False Then
		StartActivity(kontrola_activity)
	Else
		UpdateUI3
		kojiGumbApdejtOK = False
	End If
End Sub

Sub UpdateUI1
'	If kojiGumbApdejtOK Then
'		Wait For (LatLonToPlace(kontrola_flp.LastLocation.Latitude, kontrola_flp.LastLocation.Longitude)) Complete (adr As String)
		Wait For (LatLonToPlace(lat, lon)) complete (adr As String)
		Log(adr)
		SendMessage("kontrola", "Kontrola!", "Lokacija: " & adr)

		DateTime.DateFormat = "dd.MM.yyyy"
		DateTime.TimeFormat = "HH:mm"
	
'		Starter.upit.ExecNonQuery($"INSERT INTO ostalo VALUES (?, 1, ${kontrola_flp.LastLocation.Latitude}, ${kontrola_flp.LastLocation.Longitude}, '${adr}', '$DateTime{DateTime.Now}')"$)

		rv.SetText("Label1", "Kontrola!" & CRLF & adr)

		rv.UpdateWidget
'	End If
End Sub

Sub UpdateUI2
	If kojiGumbApdejtOK Then
		Wait For (LatLonToPlace(kontrola_flp.LastLocation.Latitude, kontrola_flp.LastLocation.Longitude)) Complete (adr As String)
		SendMessage("zastoj", "Zastoj u prometu!", "Lokacija: " & adr)

		DateTime.DateFormat = "dd.MM.yyyy"
		DateTime.TimeFormat = "HH:mm"

		Starter.upit.ExecNonQuery($"INSERT INTO ostalo VALUES (?, 2, ${kontrola_flp.LastLocation.Latitude}, ${kontrola_flp.LastLocation.Longitude}, '${adr}', '$DateTime{DateTime.Now}')"$)

		rv.SetText("Label1", "Zastoj u prometu!" & CRLF & adr)

		rv.UpdateWidget
	End If
End Sub

Sub UpdateUI3
	If kojiGumbApdejtOK Then
		Wait For (LatLonToPlace(kontrola_flp.LastLocation.Latitude, kontrola_flp.LastLocation.Longitude)) Complete (adr As String)
		SendMessage("kasni", "Kašnjenje!", "Lokacija: " & adr)

		DateTime.DateFormat = "dd.MM.yyyy"
		DateTime.TimeFormat = "HH:mm"

		Starter.upit.ExecNonQuery($"INSERT INTO ostalo VALUES (?, 3, ${kontrola_flp.LastLocation.Latitude}, ${kontrola_flp.LastLocation.Longitude}, '${adr}', '$DateTime{DateTime.Now}')"$)

		rv.SetText("Label1", "Kašnjenje!" & CRLF & adr)

		rv.UpdateWidget
	End If
End Sub

Private Sub SendMessage(Topic As String, Title As String, Body As String)
	Dim Job As HttpJob

	Job.Initialize("fcm", Me)
	Dim m As Map = CreateMap("to": $"/topics/${Topic}"$, "priority": "high")
	Dim data As Map = CreateMap("title": Title, "body": Body)
	m.Put("data", data)
	Dim jg As JSONGenerator
	jg.Initialize(m)
	Job.PostString("https://fcm.googleapis.com/fcm/send", jg.ToString)
	Job.GetRequest.SetContentType("application/json")';charset=UTF-8")
	Job.GetRequest.SetHeader("Authorization", "key=" & API_KEY)
End Sub

Sub JobDone(job As HttpJob)
	Log(job.GetString)
	If job.Success Then
		Log("kontrola_widget -> džob dan!")
'		Log(job.GetString)
	End If
	job.Release
End Sub

Sub LatLonToPlace(latP As Double, lonP As Double) As ResumableSub
	Dim res As String
	Dim j As HttpJob

	j.Initialize("", Me)
	j.Download2("https://maps.googleapis.com/maps/api/geocode/json", Array As String("latlng", latP & "," & lonP, "key", API_KEY))
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		Dim jp As JSONParser
		jp.Initialize(j.GetString)
		Dim m As Map = jp.NextObject
		If m.Get("status") = "OK" Then
			Dim results As List = m.Get("results")
			If results.Size > 0 Then
				Dim colresults As Map = results.Get(0)
				Dim address_components As List = colresults.Get("address_components")
				Dim coladdress_components As Map = address_components.Get(0)
				Dim resKB As String = coladdress_components.Get("short_name")
				Dim coladdress_components As Map = address_components.Get(1)
'				Log(coladdress_components.Get("short_name"))
				res = coladdress_components.Get("short_name") & " " & resKB
			End If
		End If
	End If
	j.Release

	Return res
End Sub