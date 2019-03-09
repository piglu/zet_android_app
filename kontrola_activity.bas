B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	Public rp As RuntimePermissions
End Sub

Sub Globals
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'	**	IMPORTANT see manifest for required entries	**
'	Activity.LoadLayout("Main")
	If kontrola_flp.FusedLocationProvider1.IsInitialized = False Then
		StartService(kontrola_flp)
	Else
		Activity.Finish
	End If
End Sub

Sub Activity_Resume
	If rp.Check(rp.PERMISSION_ACCESS_FINE_LOCATION) Then
		If kontrola_flp.LastLocation.IsInitialized Then
			Activity.Finish
		Else
			StartService(kontrola_flp)
		End If
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
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
			Msgbox("Unable to listen for location updates, device does not meet the requirements.", "Problem")
			Activity.Finish
	End Select
End Sub

Sub LocationSettingsResult1_ResolutionDialogDismissed(LocationSettingsUpdated As Boolean)
	Log("LocationSettingsResult1_ResolutionDialogDismissed")
	If Not(LocationSettingsUpdated) Then
		'	the user failed to update the device settings to meet the location request requirements
		Msgbox("Unable to listen for location updates, you failed to enable the required device settings.", "Problem")
	End If
	Activity.Finish
End Sub