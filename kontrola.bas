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
	Private FusedLocationProvider1 As FusedLocationProvider
	Public LastLocation As Location
	Private adresa As String
End Sub

Sub Service_Create
	rv = ConfigureHomeWidget("k_widget", "rv", 0, "", False)

	FusedLocationProvider1.Initialize("FusedLocationProvider1")
	FusedLocationProvider1.Connect
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
	FusedLocationProvider1.Disconnect
End Sub

Sub rv_RequestUpdate
	rv.UpdateWidget
End Sub

Sub rv_Disabled
	CancelScheduledService("")
	StopService("")
End Sub

Sub btnSend_Click
	Log("gumb")
	If LastLocation.IsInitialized Then
		Wait For (LatLonToPlace(Starter.LastLocation.Latitude, Starter.LastLocation.Longitude)) Complete (adr As String)
		adresa = adr
		Log(adr)
		SendMessage("Kontrolori!", "Lokacija", adresa)
		UpdateUI(adresa)
	End If
End Sub

Sub UpdateUI(adr As String)
	rv.SetText("Label1", LastLocation.Latitude & ":" & LastLocation.Longitude & CRLF & adr)
End Sub

Private Sub SendMessage(Topic As String, Title As String, Body As String)
	Dim Job As HttpJob
	Job.Initialize("fcm", Me)
'	Dim m As Map = CreateMap("to": $"/topics/${Topic}"$)
	Dim m As Map = CreateMap("to": $"/topics/${Topic}"$, "priority": "high")
	Dim data As Map = CreateMap("title": Title, "body": Body)
	If Topic.StartsWith("ios_") Then
		Dim iosalert As Map =  CreateMap("title": Title, "body": Body, "sound": "default")
		m.Put("notification", iosalert)
		m.Put("priority", 10)
	End If
	m.Put("data", data)
	Dim jg As JSONGenerator
	jg.Initialize(m)
	Job.PostString("https://fcm.googleapis.com/fcm/send", jg.ToString)
	Job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Job.GetRequest.SetHeader("Authorization", "key=" & API_KEY)
End Sub

Sub JobDone(job As HttpJob)
	Log(job)
	If job.Success Then
		Log(job.GetString)
	End If
	job.Release
End Sub

Sub LatLonToPlace(lat As Double, lon As Double) As ResumableSub
	Dim res As String
	Dim j As HttpJob

	j.Initialize("", Me)
	j.Download2("https://maps.googleapis.com/maps/api/geocode/json", Array As String("latlng", lat & "," & lon, "key", API_KEY))
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		Dim jp As JSONParser
		jp.Initialize(j.GetString)
		Dim m As Map = jp.NextObject
		If m.Get("status") = "OK" Then
			Dim results As List = m.Get("results")
			If results.Size > 0 Then
				Dim first As Map = results.Get(0)
				res = first.Get("formatted_address")
'				Log(res)
				'res contain address string
			End If
		End If
	End If
	j.Release

	Return res
End Sub

Sub FusedLocationProvider1_ConnectionFailed(ConnectionResult1 As Int)
	Log("FusedLocationProvider1_ConnectionFailed")
	
	'	the FusedLocationProvider ConnectionResult object contains the various CoonectionResult constants
	
	Select ConnectionResult1
		Case FusedLocationProvider1.ConnectionResult.NETWORK_ERROR
			'	a network error has occurred, this is likely to be a recoverable error
			'	so try to connect again
			FusedLocationProvider1.Connect
		Case Else
			'	TODO handle other errors
	End Select
End Sub

Sub FusedLocationProvider1_ConnectionSuccess
	Log("FusedLocationProvider1_ConnectionSuccess")
	Dim LocationRequest1 As LocationRequest
	LocationRequest1.Initialize
	LocationRequest1.SetInterval(1000)	'	1000 milliseconds
	LocationRequest1.SetPriority(LocationRequest1.Priority.PRIORITY_HIGH_ACCURACY)
	LocationRequest1.SetSmallestDisplacement(1)	'	1 meter
	
	Dim LocationSettingsRequestBuilder1 As LocationSettingsRequestBuilder
	LocationSettingsRequestBuilder1.Initialize
	LocationSettingsRequestBuilder1.AddLocationRequest(LocationRequest1)
	FusedLocationProvider1.CheckLocationSettings(LocationSettingsRequestBuilder1.Build)
	
	FusedLocationProvider1.RequestLocationUpdates(LocationRequest1)
End Sub

Sub FusedLocationProvider1_ConnectionSuspended(SuspendedCause1 As Int)
	Log("FusedLocationProvider1_ConnectionSuspended")
	
	'	the FusedLocationProvider SuspendedCause object contains the various SuspendedCause constants
	
	Select SuspendedCause1
		Case FusedLocationProvider1.SuspendedCause.CAUSE_NETWORK_LOST
			'	TODO take action
		Case FusedLocationProvider1.SuspendedCause.CAUSE_SERVICE_DISCONNECTED
			'	TODO take action
	End Select
End Sub

Sub FusedLocationProvider1_LocationChanged(Location1 As Location)
	Log("FusedLocationProvider1_LocationChanged")
	LastLocation = Location1
'	CallSub(Main, "UpdateUI")
End Sub

Sub FusedLocationProvider1_LocationSettingsChecked(LocationSettingsResult1 As LocationSettingsResult)
	Log("FusedLocationProvider1_LocationSettingsChecked")
	Dim LocationSettingsStatus1 As LocationSettingsStatus=LocationSettingsResult1.GetLocationSettingsStatus
	Select LocationSettingsStatus1.GetStatusCode
		Case LocationSettingsStatus1.StatusCodes.RESOLUTION_REQUIRED
			Log("RESOLUTION_REQUIRED")
			'	device settings do not meet the location request requirements
			'	a resolution dialog is available to enable the user to change the settings
			'	the  StartResolutionDialog method cannot be called from a service
			'	so we'll pass the LocationSettingsStatus to the Main activity to be handled
			CallSubDelayed2(kontrola_activity, "HandleLocationSettingsStatus", LocationSettingsStatus1)
		Case LocationSettingsStatus1.StatusCodes.SETTINGS_CHANGE_UNAVAILABLE
			Log("SETTINGS_CHANGE_UNAVAILABLE")
			'	device settings do not meet the location request requirements
			'	a resolution dialog is not available to enable the user to change the settings
			'	we'll pass the LocationSettingsStatus to the Main activity to be handled
			CallSubDelayed2(kontrola_activity, "HandleLocationSettingsStatus", LocationSettingsStatus1)
		Case LocationSettingsStatus1.StatusCodes.SUCCESS
			Log("SUCCESS")
			'	device settings meet the location request requirements
			'	no further action required
	End Select
End Sub