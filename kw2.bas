B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.8
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public rp As RuntimePermissions
	Public flp As FusedLocationProvider
	Dim rv As RemoteViews
	Private const API_KEY As String = "AIzaSyAHPnRfbzzEggfD218kHdYoArcHRhb0ww4"
	Public lat, lon As Double
	Private gps1 As GPS
	Private lm As ESLocation2
	Public kojiUpdate As Int
	Private apdejtOK As Boolean
End Sub

Sub Service_Create
'	#if release
	rv = ConfigureHomeWidget("k_widget", "rv", 0, "", False)
'	#end if
	lm.Initialize("Location")
	gps1.Initialize("gps1")
End Sub

Sub Service_Start (StartingIntent As Intent)
'	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
'	If StartingIntent.Action = "android.appwidget.action.APPWIDGET_DELETED" Then Return
'	If rv.HandleWidgetEvents(StartingIntent) = False Then
'		' If the action is not handled by HandleWidgetEvents() then we
'		' probably were called by StartService() or StartServiceAt().
'		' So just update the widget.
'		rv_RequestUpdate
'	End If
	rv.HandleWidgetEvents(StartingIntent)
	Sleep(0)
	Service.StopAutomaticForeground
End Sub

Sub rv_RequestUpdate
	rv.UpdateWidget
End Sub

Sub rv_Disabled
	CancelScheduledService("")
	StopService("")
End Sub

Sub Service_Destroy

End Sub

Sub img1_Click
	Log("gumb1")
	rv.SetText("Label1", "Dohvaćam podatke...")
	kojiUpdate = 1
	If Starter.GPS1.GPSEnabled = False Then
		StartActivity(Starter.GPS1.LocationSettingsIntent) 'Will open the relevant settings screen.
	Else
		If Starter.rp.Check(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION) = False Then
			Log("No permission")
			Return
		Else
			apdejtOK = True
			lm.requestNetworkLocation(0,0)
		End If
	End If
End Sub

Sub img2_Click
	Log("gumb2")
	rv.SetText("Label1", "Dohvaćam podatke...")
	kojiUpdate = 2
	If Starter.GPS1.GPSEnabled = False Then
		StartActivity(Starter.GPS1.LocationSettingsIntent) 'Will open the relevant settings screen.
	Else
		If Starter.rp.Check(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION) = False Then
			Log("No permission")
			Return
		Else
			apdejtOK = True
			lm.requestNetworkLocation(0,0)
		End If
	End If
End Sub

Sub img3_Click
	Log("gumb3")
	rv.SetText("Label1", "Dohvaćam podatke...")
	kojiUpdate = 3
	If Starter.GPS1.GPSEnabled = False Then
		StartActivity(Starter.GPS1.LocationSettingsIntent) 'Will open the relevant settings screen.
	Else
		If Starter.rp.Check(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION) = False Then
			Log("No permission")
			Return
		Else
			apdejtOK = True
			lm.requestNetworkLocation(0,0)
		End If
	End If
End Sub

Sub img4_Click
	If Not(Main.manager.GetBoolean("check2")) And Not(Main.manager.GetBoolean("check3")) And Not(Main.manager.GetBoolean("check4")) Then
'		Msgbox("Omogućite prikaz barem jedne lokacije pod postavkama!", "Info")
		ToastMessageShow("Omogućite prikaz barem jedne lokacije pod postavkama!", False)
	Else
		StartActivity(lok_123_karta2)
	End If
End Sub

Sub Location_LocationChanged (Longitude As Double, Latitude As Double, Altitude As Double, Accuracy As Float, Bearing As Float, Provider As String, Speed As Float, time As Long)
'	DateTime.DateFormat = "yyyy-MM-dd"
'	DateTime.TimeFormat = "HH:mm:ss"
	
'	Dim netdate As String = DateTime.Date(time)
'	Dim netTime As String = DateTime.Time(time)
	Log(Latitude)
	Log(Longitude)
	lat = Latitude
	lon = Longitude
	If kojiUpdate = 1 And apdejtOK Then
		UpdateUI1
	else if kojiUpdate = 2 And apdejtOK Then
		UpdateUI2
	Else if kojiUpdate = 3 And apdejtOK Then
		UpdateUI3
	End If
'	Msgbox("Longitude: " & Longitude & CRLF & "Latitude: " & Latitude & CRLF & "Altitude: " & Altitude & CRLF & "Accuracy: " & Accuracy & CRLF & "Bearing: " & Bearing & CRLF & "Speed: " & Speed & CRLF & "Time: " & netdate & " " & netTime, "Location")
End Sub

Sub Location_ProviderDisabled (Provider As String)
'	Msgbox("Provider","Provider Disabled")
	Log("Provider: " & "Provider Disabled")
End Sub

Sub Location_ProviderEnabled (Provider As String)
'	Msgbox("Provider","Provider Enabled")
	Log("Provider: " & "Provider Enabled")
End Sub

Sub Location_StatusChanged (Provider As String, Status As Int)
'	Msgbox("Provider: " & Provider & CRLF & "Status: " & Status,"Status Changed")
	Log("Provider: " & Provider & CRLF & "Status: " & Status & " Status Changed")
End Sub

Sub UpdateUI1
	Wait For (LatLonToPlace(lat, lon)) complete (adr As String)
	Log(adr)
	SendMessage("kontrola", "Kontrola!", "Lokacija: " & adr)

	DateTime.DateFormat = "dd.MM.yyyy"
	DateTime.TimeFormat = "HH:mm"
	
	Starter.upit.ExecNonQuery($"INSERT INTO ostalo VALUES (?, 1, ${lat}, ${lon}, '${adr}', '$DateTime{DateTime.Now}')"$)

	rv.SetText("Label1", "Kontrola!" & CRLF & adr)

	rv.UpdateWidget

	lm.stopNetworkListening
	apdejtOK = False
End Sub

Sub UpdateUI2
	Wait For (LatLonToPlace(lat, lon)) complete (adr As String)
	Log(adr)
	SendMessage("zastoj", "Zastoj u prometu!", "Lokacija: " & adr)

	DateTime.DateFormat = "dd.MM.yyyy"
	DateTime.TimeFormat = "HH:mm"
	
	Starter.upit.ExecNonQuery($"INSERT INTO ostalo VALUES (?, 2, ${lat}, ${lon}, '${adr}', '$DateTime{DateTime.Now}')"$)

	rv.SetText("Label1", "Zastoj u prometu!" & CRLF & adr)

	rv.UpdateWidget

	lm.stopNetworkListening
	apdejtOK = False
End Sub

Sub UpdateUI3
	Wait For (LatLonToPlace(lat, lon)) complete (adr As String)
	Log(adr)
	SendMessage("kasni", "Kašnjenje!", "Lokacija: " & adr)

	DateTime.DateFormat = "dd.MM.yyyy"
	DateTime.TimeFormat = "HH:mm"
	
	Starter.upit.ExecNonQuery($"INSERT INTO ostalo VALUES (?, 3, ${lat}, ${lon}, '${adr}', '$DateTime{DateTime.Now}')"$)

	rv.SetText("Label1", "Kašnjenje!" & CRLF & adr)

	rv.UpdateWidget

	lm.stopNetworkListening
	apdejtOK = False
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