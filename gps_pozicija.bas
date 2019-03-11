B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private awake As PhoneWakeState
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private gmap As GoogleMap
	Dim gme As GoogleMapsExtras
	Private MapFragment1 As MapFragment
	Private API_KEY As String = "AIzaSyDcDgSJf0YZKaPnFB3DZpUhM3oLRbzkobM"
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("karta")
	
	If MapFragment1.IsGooglePlayServicesAvailable = False Then
		ToastMessageShow("Instalirajte Google Play servise.", True)
	End If
End Sub

Sub MapFragment1_Ready
	gmap = MapFragment1.GetMap
	Starter.rp.CheckAndRequest(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION)
	Wait For Activity_PermissionResult (Permission As String, Result As Boolean)
	If Result Then
		gmap.MyLocationEnabled = Result
		Dim markeri(2) As Marker
		Dim LatLngBoundsBuilder1 As LatLngBoundsBuilder
		Dim MarkerOptions1 As MarkerOptions
		LatLngBoundsBuilder1.Initialize
		Do Until Starter.LastLocation.IsInitialized
			Sleep(100)
		Loop
		Log("Starter.LastLocation.Latitude: " & Starter.LastLocation.Latitude)
		Wait For (LatLonToPlace(Starter.LastLocation.Latitude, Starter.LastLocation.Longitude)) Complete (adr As String)
		MarkerOptions1.Initialize
		MarkerOptions1.Position2(Starter.LastLocation.Latitude, Starter.LastLocation.Longitude).Title("Vaša lokacija").Visible(True).Snippet(adr)
		markeri(0) = gme.AddMarker(gmap, MarkerOptions1)
		LatLngBoundsBuilder1.Include(markeri(0).Position)
		gme.AddMarker(gmap, MarkerOptions1)
		MarkerOptions1.Initialize
		MarkerOptions1.Position2(detalj_stanice.lat, detalj_stanice.lon).Title(detalj_stanice.nl).Visible(True).Snippet("Tražena lokacija")
		Dim BitmapDescriptor1 As BitmapDescriptor
		Dim BitmapDescriptorFactory1 As BitmapDescriptorFactory
		BitmapDescriptor1 = BitmapDescriptorFactory1.DefaultMarker2(BitmapDescriptorFactory1.HUE_AZURE)
		MarkerOptions1.Icon(BitmapDescriptor1)
'		MarkerOptions1.visible(True)

		markeri(1) = gme.AddMarker(gmap, MarkerOptions1)
		LatLngBoundsBuilder1.Include(markeri(1).Position)
		gme.AddMarker(gmap, MarkerOptions1)

		Dim MarkerBounds As LatLngBounds = LatLngBoundsBuilder1.Build
		gme.AnimateToBounds(gmap, MarkerBounds, 128)
	End If
End Sub

Sub MapFragment1_MarkerClick (SelectedMarker As Marker) As Boolean
	Log(SelectedMarker.Snippet)

	Return False
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	awake.ReleaseKeepAlive
End Sub

Sub Activity_Resume
	Dim ph As Phone

	ph.SetScreenOrientation(1)

	If Main.Manager.GetBoolean("check1") Then
		awake.KeepAlive(True)
	End If

	Do Until MapFragment1.GetMap.IsInitialized
		Sleep(100)
	Loop

	If Starter.GPS1.GPSEnabled = False Then
		Msgbox2Async("Informacija", "Omogućiti GPS za prikaz lokacija na karti?", "Da", "", "Ne", Null, False)
		Wait For Msgbox_Result (res As Int)
		If res = DialogResponse.POSITIVE Then
			StartActivity(Starter.GPS1.LocationSettingsIntent) 'Will open the relevant settings screen.
		Else
			Msgbox("Niste omogućili GPS za prikaz na karti!", "Problem")
			Activity.Finish
		End If
	Else
		Starter.rp.CheckAndRequest(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION)
		Wait For Activity_PermissionResult (Permission As String, Result As Boolean)
		If Result Then
'			Log($"CallSubDelayed(Starter, "StartGPS")"$)
			CallSubDelayed(Starter, "StartGPS")
		End If
	End If
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

Sub HandleLocationSettingsStatus(LocationSettingsStatus1 As LocationSettingsStatus)
	Select LocationSettingsStatus1.GetStatusCode
		Case LocationSettingsStatus1.StatusCodes.RESOLUTION_REQUIRED
			Log("RESOLUTION_REQUIRED")
			'	device settings do not meet the location request requirements
			'	a resolution dialog is available to enable the user to change the settings
			LocationSettingsStatus1.StartResolutionDialog("LocationSettingsResult1")
		Case LocationSettingsStatus1.StatusCodes.SETTINGS_CHANGE_UNAVAILABLE
			Log("SETTINGS_CHANGE_UNAVAILABLE")
			'	device settings do not meet the location request requirements
			'	a resolution dialog is not available to enable the user to change the settings
			Msgbox("Uređaj nema potrebne zahtjeve za lokacijom!", "Problem")
			Activity.Finish
	End Select
End Sub

Sub LocationSettingsResult1_ResolutionDialogDismissed(LocationSettingsUpdated As Boolean)
	Log("LocationSettingsResult1_ResolutionDialogDismissed")
	If Not(LocationSettingsUpdated) Then
		'	the user failed to update the device settings to meet the location request requirements
		Msgbox("Niste omogućili lokaciju na uređaju!", "Problem")
		Activity.Finish
	End If
End Sub