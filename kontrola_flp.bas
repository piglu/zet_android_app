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
	Public FusedLocationProvider1 As FusedLocationProvider
	Public LastLocation As Location
End Sub

Sub Service_Create
	FusedLocationProvider1.Initialize("FusedLocationProvider1")
'	CallSubDelayed(Starter, "StartGPS")

	FusedLocationProvider1.Connect
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
End Sub

Sub Service_Destroy
'	FusedLocationProvider1.Disconnect
'	CallSubDelayed(Starter, "StopGps")
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
	If kontrola_widget.kojiUpdate = 1 Then
		CallSubDelayed(kontrola_widget, "UpdateUI1")
	Else If kontrola_widget.kojiUpdate = 2 Then
		CallSubDelayed(kontrola_widget, "UpdateUI2")
	Else
		CallSubDelayed(kontrola_widget, "UpdateUI3")
	End If
	FusedLocationProvider1.Disconnect
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