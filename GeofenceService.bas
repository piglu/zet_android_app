B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	Private client As JavaObject
	Private context As JavaObject
	Private PendingIntent As Object
	Type Geofence (Id As String, Center As Location, RadiusMeters As Float, ExpirationMs As Long)
End Sub

Sub Service_Create
	context.InitializeContext
	Dim LocationServices As JavaObject
	LocationServices.InitializeStatic("com.google.android.gms.location.LocationServices")
	client = LocationServices.RunMethod("getGeofencingClient", Array(context))
	PendingIntent = CreatePendingIntent
End Sub

Sub Service_Start (StartingIntent As Intent)
	Dim GeofencingEvent As JavaObject
	GeofencingEvent.InitializeStatic("com.google.android.gms.location.GeofencingEvent")
	GeofencingEvent = GeofencingEvent.RunMethod("fromIntent", Array(StartingIntent))
	Dim transtion As Int = GeofencingEvent.RunMethod("getGeofenceTransition", Null)
	If transtion > 0 Then
		Dim geofences As List = GeofencingEvent.RunMethod("getTriggeringGeofences", Null)
		If geofences.Size > 0 Then
			Dim geofence As JavaObject = geofences.Get(0)
			Dim id As String = geofence.RunMethod("getRequestId", Null)
			If transtion = 1 Then
				CallSubDelayed2(lok_123_karta, "Geofence_Enter", id)
			Else If transtion = 2 Then
				CallSubDelayed2(lok_123_karta, "Geofence_Exit", id)
			End If
		End If
		
	End If
End Sub

Public Sub AddGeofence(Callback As Object, geo As Geofence)
	Dim gb As JavaObject = CreateGeofenceBuilder(geo)
	Dim req As JavaObject = CreateGeofenceRequest(gb)
	Dim task As JavaObject = client.RunMethod("addGeofences", Array(req, PendingIntent))
	Do While task.RunMethod("isComplete", Null) = False
		Sleep(50)
	Loop
	CallSubDelayed2(Callback, "Geofence_Added", task.RunMethod("isSuccessful", Null))
End Sub

Private Sub CreateGeofenceBuilder (geo As Geofence) As JavaObject
	Dim builder As JavaObject
	builder.InitializeNewInstance("com.google.android.gms.location.Geofence$Builder", Null)
	builder.RunMethod("setRequestId", Array(geo.Id))
	builder.RunMethod("setExpirationDuration", Array(geo.ExpirationMs))
	builder.RunMethod("setCircularRegion", Array(geo.Center.Latitude, geo.Center.Longitude, geo.RadiusMeters))
	builder.RunMethod("setTransitionTypes", Array(3)) 'GEOFENCE_TRANSITION_ENTER | GEOFENCE_TRANSITION_EXIT
	Return builder
End Sub

Private Sub CreateGeofenceRequest (GeofenceBuilder As JavaObject) As JavaObject
	Dim builder As JavaObject
	builder.InitializeNewInstance("com.google.android.gms.location.GeofencingRequest$Builder", Null)
	builder.RunMethod("setInitialTrigger", Array(1)) 'INITIAL_TRIGGER_ENTER
	builder.RunMethod("addGeofence", Array(GeofenceBuilder.RunMethod("build", Null)))
	Return builder.RunMethod("build", Null)
End Sub

Private Sub CreatePendingIntent As Object
	Dim in As JavaObject
	in.InitializeNewInstance("android.content.Intent", Array(context, Me))
	Dim pi As JavaObject
	pi = pi.InitializeStatic("android.app.PendingIntent").RunMethod("getService", _
  		Array(context, 1, in, 134217728))
	Return pi
End Sub



Sub Service_Destroy

End Sub
