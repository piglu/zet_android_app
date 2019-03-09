B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
'	Private rp As RuntimePermissions
	Private awake As PhoneWakeState
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private MapFragment1 As MapFragment
	Private gmap As GoogleMap
	Dim gme As GoogleMapsExtras
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("karta")
End Sub

Sub MapFragment1_Ready
	Log("MapFragment1_Ready")
	Private llat1, llon1, LatLonAdr1, LatLonTip1 As List
	Private llat2, llon2, LatLonAdr2, LatLonTip2 As List
	Private llat3, llon3, LatLonAdr3, LatLonTip3 As List

	gmap = MapFragment1.GetMap
'	If gmap.IsInitialized Then
	Starter.rp.CheckAndRequest(Starter.rp.PERMISSION_ACCESS_FINE_LOCATION)
	Wait For Activity_PermissionResult (Permission As String, Result As Boolean)
	If Result Then
		gmap.MyLocationEnabled = Result
		Dim Cursor1 As Cursor
		Dim x1B As Boolean = Main.Manager.GetBoolean("check1")
		Dim x2B As Boolean = Main.Manager.GetBoolean("check2")
		Dim x3B As Boolean = Main.Manager.GetBoolean("check3")
'		Dim x1V As Int = Main.Manager.GetInt("check1")
'		Dim x2V As Int = Main.Manager.GetInt("check2")
'		Dim x3V As Int = Main.Manager.GetInt("check3")
		Dim y As Int = 0
		llat1.Initialize
		llon1.Initialize
		LatLonAdr1.Initialize
		LatLonTip1.Initialize
		llat2.Initialize
		llon2.Initialize
		LatLonAdr2.Initialize
		LatLonTip2.Initialize
		llat3.Initialize
		llon3.Initialize
		LatLonAdr3.Initialize
		LatLonTip3.Initialize
		If x1B Then
			Cursor1 = Starter.upit.ExecQuery($"SELECT * FROM ostalo WHERE tip = 1 ORDER BY datum DESC LIMIT ${x1V}"$)
			For i = 0 To Cursor1.RowCount - 1
				LatLonTip1.Add(Cursor1.GetInt("tip"))
				llat1.Add(Cursor1.GetDouble("lat"))
				llon1.Add(Cursor1.GetDouble("lon"))
				LatLonAdr1.Add(Cursor1.GetString("adresa"))
			Next
			If i < x1V Then
				y = y + i
			Else
				y = y + x1V
			End If
		End If
		If x2B Then
			Cursor1 = Starter.upit.ExecQuery($"SELECT * FROM ostalo WHERE tip = 2 ORDER BY datum DESC LIMIT ${x2V}"$)
			For i = 0 To Cursor1.RowCount - 1
				LatLonTip2.Add(Cursor1.GetInt("tip"))
				llat2.Add(Cursor1.GetDouble("lat"))
				llon2.Add(Cursor1.GetDouble("lon"))
				LatLonAdr2.Add(Cursor1.GetString("adresa"))
			Next
			If i < x1V Then
				y = y + i
			Else
				y = y + x1V
			End If
		End If
		If x3B Then
			Cursor1 = Starter.upit.ExecQuery($"SELECT * FROM ostalo WHERE tip = 3 ORDER BY datum DESC LIMIT ${x3V}"$)
			For i = 0 To Cursor1.RowCount - 1
				LatLonTip3.Add(Cursor1.GetInt("tip"))
				llat3.Add(Cursor1.GetDouble("lat"))
				llon3.Add(Cursor1.GetDouble("lon"))
				LatLonAdr3.Add(Cursor1.GetString("adresa"))
			Next
			If i < x1V Then
				y = y + i
			Else
				y = y + x1V
			End If
		End If

		Dim markeri(y) As Marker
		Dim LatLngBoundsBuilder1 As LatLngBoundsBuilder
		Dim MarkerOptions1 As MarkerOptions
		LatLngBoundsBuilder1.Initialize
		' prikaz Vaše lokacije
		MarkerOptions1.Initialize
		MarkerOptions1.Position2(kw2.lat, kw2.lon).Title("Vaša lokacija").Visible(True)'.Snippet(adr)
		markeri(0) = gme.AddMarker(gmap, MarkerOptions1)
		LatLngBoundsBuilder1.Include(markeri(0).Position)
		gme.AddMarker(gmap, MarkerOptions1)
		If x1B Then
			For i = 0 To llat1.Size - 1
				MarkerOptions1.Initialize
				MarkerOptions1.Position2(llat1.Get(i), llon1.Get(i)).Title(LatLonAdr1.Get(i)).Visible(True)'.Snippet("Tražena lokacija")
				Dim BitmapDescriptor1 As BitmapDescriptor
				Dim BitmapDescriptorFactory1 As BitmapDescriptorFactory
				BitmapDescriptor1 = BitmapDescriptorFactory1.FromAsset("kontrola.png")
				MarkerOptions1.Icon(BitmapDescriptor1)
				markeri(i+1) = gme.AddMarker(gmap, MarkerOptions1)
				LatLngBoundsBuilder1.Include(markeri(i+1).Position)
				gme.AddMarker(gmap, MarkerOptions1)
			Next
		End If

		If x2B Then
			For j = 0 To llat2.Size - 1
				MarkerOptions1.Initialize
				MarkerOptions1.Position2(llat2.Get(j), llon2.Get(j)).Title(LatLonAdr2.Get(j)).Visible(True)'.Snippet("Tražena lokacija")
				Dim BitmapDescriptor1 As BitmapDescriptor
				Dim BitmapDescriptorFactory1 As BitmapDescriptorFactory
				BitmapDescriptor1 = BitmapDescriptorFactory1.FromAsset("zastoj.png")
				MarkerOptions1.Icon(BitmapDescriptor1)
				markeri(j+i+1) = gme.AddMarker(gmap, MarkerOptions1)
				LatLngBoundsBuilder1.Include(markeri(j+i+1).Position)
				gme.AddMarker(gmap, MarkerOptions1)
			Next
		End If

		If x3B Then
			For k = 0 To llat3.Size - 1
				MarkerOptions1.Initialize
				MarkerOptions1.Position2(llat3.Get(k), llon3.Get(k)).Title(LatLonAdr3.Get(k)).Visible(True)'.Snippet("Tražena lokacija")
				Dim BitmapDescriptor1 As BitmapDescriptor
				Dim BitmapDescriptorFactory1 As BitmapDescriptorFactory
				BitmapDescriptor1 = BitmapDescriptorFactory1.FromAsset("kasni.png")
				MarkerOptions1.Icon(BitmapDescriptor1)
				markeri(k+j+i+1) = gme.AddMarker(gmap, MarkerOptions1)
				LatLngBoundsBuilder1.Include(markeri(k+j+i+1).Position)
				gme.AddMarker(gmap, MarkerOptions1)
			Next
		End If
	
		Dim MarkerBounds As LatLngBounds = LatLngBoundsBuilder1.Build
		gme.AnimateToBounds(gmap, MarkerBounds, 128)


'		Dim cp As CameraPosition
'		cp.Initialize(gmap.MyLocation.latitude,gmap.MyLocation.longitude, 18)
'		gmap.AnimateCamera(cp)
	Else
'		Log("Error initializing GoogleMap")
		ToastMessageShow("Ne mogu inicijalizirati Google karte!", False)
	End If
End Sub

Sub Activity_Resume
	Dim ph As Phone

	ph.SetScreenOrientation(1)

	If Main.Manager.GetBoolean("check1") Then
		awake.KeepAlive(True)
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub