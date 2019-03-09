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
	Private fm As FirebaseMessaging
End Sub

Sub Service_Create
	fm.Initialize("fm")
End Sub

Public Sub SubscribeToTopics
	fm.SubscribeToTopic("kontrola") 'you can subscribe to more topics
	fm.SubscribeToTopic("zastoj")
	fm.SubscribeToTopic("kasni")
End Sub

Sub Service_Start (StartingIntent As Intent)
	If StartingIntent.IsInitialized Then fm.HandleIntent(StartingIntent)
	Sleep(0)
	Service.StopAutomaticForeground 'remove if not using B4A v8+.
End Sub

Sub fm_MessageArrived (Message As RemoteMessage)
	Log("Message arrived")
	Log($"Message data: ${Message.GetData}"$)
	Dim n As Notification
	n.Initialize
	If kw2.kojiUpdate = 1 Then
		n.Icon = "kontrola"
		n.SetInfo(Message.GetData.Get("title"), Message.GetData.Get("body"), Main)
		n.Notify(1)
	else if kw2.kojiUpdate = 2 Then
		n.Icon = "zastoj"
		n.SetInfo(Message.GetData.Get("title"), Message.GetData.Get("body"), Main)
		n.Notify(2)
	Else
		n.Icon = "kasni"
		n.SetInfo(Message.GetData.Get("title"), Message.GetData.Get("body"), Main)
		n.Notify(3)
	End If
End Sub

Sub Service_Destroy

End Sub

