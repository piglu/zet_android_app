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
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private awake As PhoneWakeState
'	Public izLokacije123Sve As Boolean
	Public spnOdbaraniTip As Int
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private spn123 As Spinner
	Private clv123 As CustomListView
	Private lblAdresa As Label
	Private lblDatum As Label
	Private imgLok123 As ImageView
'	Private const STREET_API As String = "AIzaSyAC0JS6AX9sXcN_cEALLWjzA9VpqoHzuHU"
'	Private imgStreetViewStatic As ImageView
'	Private imgKarta As ImageView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("lokacije123")

	spn123.AddAll(Array As String("Kontrolori", "Zastoji", "Kašnjenja"))

	Activity.AddMenuItem3("Prikaz na karti", "karta", LoadBitmap(File.DirAssets, "karta2.png"), True)
	Activity.AddMenuItem3("Obriši podatke", "obrisi", LoadBitmap(File.DirAssets, "db_obrisi1.png"), True)
End Sub

Sub Activity_Resume
	Dim ph As Phone

	ph.SetScreenOrientation(1)

	If Main.Manager.GetBoolean("check1") Then
		awake.KeepAlive(True)
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	awake.ReleaseKeepAlive
End Sub

'Sub imgKarta_Click
'	izLokacije123Sve = True
'	StartActivity(lok_123_karta2)
'End Sub
'
'Sub imgKarta_LongClick
'	Msgbox("Odabirom se otvaraju sve lokacija na karti ovisno o tipu (kontrola, ...)!", "Info")
'End Sub

Sub obrisi_Click
	Dim res As Int = Msgbox2("Brisanje kojih podataka?", "Upit", "Sve", "", "Odabrano", Null)
	If res = DialogResponse.POSITIVE Then	' briši sve
		Starter.upit.ExecNonQuery($"DELETE FROM ostalo"$)
		MsgboxAsync("Podatci obrisani!", "Upozorenje")
		clv123.Clear
	else if res = DialogResponse.NEGATIVE Then	' samo odabrano iz spinnera
		Dim x As Int = spn123.SelectedIndex
		x = x + 1
		Starter.upit.ExecNonQuery($"DELETE FROM ostalo WHERE tip = ${x} "$)
		Select x
			Case 1
				MsgboxAsync("Podatci o kontrolama obrisani!", "Upozorenje")
			Case 2
				MsgboxAsync("Podatci o zastojima obrisani!", "Upozorenje")
			Case 3
				MsgboxAsync("Podatci o kašnjenju obrisani!", "Upozorenje")
		End Select
		clv123.Clear
	End If
End Sub

Sub PovuciIzBaze(tip As Int)
	Dim Cursor1 As Cursor

	If tip = 1 Then
		Dim bmp As Bitmap = LoadBitmap(File.DirAssets, "kontrola.png")
	else if tip = 2 Then
		Dim bmp As Bitmap = LoadBitmap(File.DirAssets, "zastoj.png")
	Else
		Dim bmp As Bitmap = LoadBitmap(File.DirAssets, "kasni.png")
	End If

	Cursor1 = Starter.upit.ExecQuery($"SELECT tip, adresa, datum FROM ostalo WHERE tip = ${tip}"$)
	If Cursor1.RowCount > 0 Then
		For i = 0 To Cursor1.RowCount - 1
			Cursor1.Position = i
			clv123.Add(CreateListItem(bmp, Cursor1.GetString("adresa"), Cursor1.GetString("datum"), clv123.AsView.Width, 42dip), "")
		Next
	Else
		Msgbox("Nema podataka!", "Info")
	End If
	Cursor1.Close
End Sub

Sub CreateListItem(sl As Bitmap, adr As String, dat As String, Width As Int, Height As Int) As Panel
	Dim p As Panel

	p.Initialize("")
	p.SetLayout(0, 0, Width, Height)
	p.LoadLayout("lok123_stavka")
	p.Color = Colors.white

	imgLok123.Bitmap = sl
	lblAdresa.Text = adr
	lblDatum.Text = dat

	Return p
End Sub

Sub spn123_ItemClick (Position As Int, Value As Object)
	clv123.Clear
	PovuciIzBaze(Position+1)
End Sub

'Sub isStreetViewAvailable(latSA As Float, lonSA As Float)
'	Dim j As HttpJob
'
'	j.Initialize("", Me)
'	j.Download("https://maps.googleapis.com/maps/api/streetview/metadata?location=" & latSA & "," & lonSA & "&key=" & STREET_API)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		Dim jp As JSONParser
'		jp.Initialize(j.GetString)
'		Dim status As String = jp.NextObject.GetDefault("status", 0)
'		If  status.Contains("OK") Then
'			Log("Streetview is available!")
'			'
'			'
'			'
'			'
'			' sliku otvoriti u dijalog prozoru sa imageview viewvom
'			'
'			'
'			'
'			'
'			getStreetViewPicture(200, 200, latSA, lonSA)
'		Else
'			Log("Streetview is not available!")
'		End If
'	End If
'
'	j.Release
'End Sub
'
'Sub getStreetViewPicture(width As Int, height As Int, lat As Float, lon As Float)
'	Dim j As HttpJob
'
'	j.Initialize("", Me)
'	j.Download("https://maps.googleapis.com/maps/api/streetview?size=" & width & "x" & height & "&location=" & lat & "," & lon)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		imgStreetViewStatic.Bitmap = j.GetBitmap
'	End If
'
'	j.Release
'End Sub
'
'Sub imgStreetViewStatic_Click
'	Dim Cursor1 As Cursor
'
'	Dim x As Int = spn123.SelectedIndex
'	x = x + 1
'	Cursor1 = Starter.upit.ExecQuery($"SELECT tip, adresa, datum, lat, lon FROM ostalo WHERE tip = ${x}"$)
'	If Cursor1.RowCount > 0 Then
'		For i = 0 To Cursor1.RowCount - 1
'			Cursor1.Position = i
'			Dim la1 As Double = Cursor1.GetDouble("lat")
'			Dim lo1 As Double = Cursor1.GetDouble("lon")
''			clv123.Add(CreateListItem(bmp, Cursor1.GetString("adresa"), Cursor1.GetString("datum"), clv123.AsView.Width, 42dip), "")
'		Next
'	End If
'	Cursor1.Close
'	isStreetViewAvailable(la1, lo1)
'End Sub

Sub karta_Click
'	spnOdbaraniTip = spn123.SelectedIndex + 1
'	izLokacije123Sve = True
	If Not(Main.manager.GetBoolean("check2")) And Not(Main.manager.GetBoolean("check3")) And Not(Main.manager.GetBoolean("check4")) Then
		Msgbox("Omogućite prikaz barem jedne lokacije pod postavkama!", "Info")
		Activity.Finish
	Else
		StartActivity(lok_123_karta2)
	End If
End Sub

'Sub imgKarta_LongClick
'	Msgbox("Odabirom se otvara odabrana lokacija na karti!", "Info")
'End Sub