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
	Public timer1 As Timer
	Public lat, lon As Double
	Public nl As String
'	Private korZeliGPS As Boolean = False
	Private awake As PhoneWakeState
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Dim cMapa As Map
	Dim zMapa As Map
	Dim detaljiLinije As List
	Private lblDStanica As Label
	Private lblDVrijeme As Label
	Dim cs As CSBuilder
	Dim pos As Int
	Private clvD As CustomListView
	Private ImageView1 As ImageView
	Private lblLinija As Label
	Private imgLinija As ImageView
	Private imgGeoLociranje As ImageView
	Private lblBr As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("detalj")

	detaljiLinije.Initialize
	timer1.Initialize("timer1", 1000)

	lblLinija.Text = Starter.nazivLinije
	imgLinija.Bitmap = detalj.ikona
	lblBr.Text = Starter.brojLinije

	DL_VozniRedDetalj2
End Sub

Sub Activity_Resume
	Dim ph As Phone

	timer1.Enabled = True

	ph.SetScreenOrientation(1)

	If Main.manager.GetBoolean("check1") Then
		awake.KeepAlive(True)
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	Log("detalj_stanice -> UserClosed: " & UserClosed)
	CallSubDelayed(Starter,"StopGps")
	awake.ReleaseKeepAlive
	timer1.Enabled = False
End Sub

Sub timer1_Tick
	Dim panel As B4XView = clvD.GetPanel(pos)
	panel.SetVisibleAnimated(500, False)
	panel.SetVisibleAnimated(500, True)
End Sub

Sub DL_VozniRedDetalj2'(l As List)
	Dim j As HttpJob
	j.Initialize("", Me) 'name is empty as it is no longer needed
	j.Download(detalj.linkZaDetaljPoStanicama)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
'		Log(j.GetString)
		ParsajDetaljeLinije2(j.GetString)
	End If
	j.Release
	PrikaziDetaljeLinijeZaSat
End Sub

Sub PrikaziDetaljeLinijeZaSat
	DodajStavke
'	Log(pos)
	Sleep(100)
	clvD.ScrollToItem(pos)
	timer1.Enabled = True
End Sub

Sub ParsajDetaljeLinije2(strim As String)
	Dim matcher1 As Matcher

	cMapa.Initialize
	zMapa.Initialize

	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))

	matcher1 = Regex.Matcher($"<li>(\d+:\d+:\d+\s+-\s+.*)</li>"$, strim)
	Do While matcher1.Find = True
		detaljiLinije.Add(matcher1.Group(1))
	Loop

'	Log(detaljiLinije)
	For i = 0 To detaljiLinije.Size - 1
		Dim s1 As String = detaljiLinije.Get(i)
		Dim s3 As String = s1
		s3 = s1.SubString2(0, s1.IndexOf(" - "))
		'
		'
		' prikazati od trenutnog vremena koje je malo veće od lokalnog vremena ili sve
		' ako maknemo komentar sa IF onda je od trenutnog inače sve
		'
		'
		If satMin.CompareTo(s3) >= 0 Then
			Dim s4 As String = s1
			' stanica
			s4 = s1.SubString2(s1.IndexOf(" - ") + 3, s1.Length)
			cMapa.Put(s3, s4)
		Else
			Dim s4 As String = s1
			' stanica
			s4 = s1.SubString2(s1.IndexOf(" - ") + 3, s1.Length)
			zMapa.Put(s3, s4)
		End If
	Next

'	Log("detaljiLinije: " & detaljiLinije)
End Sub

Sub IzvuciLokaciju(stanica As String)' As Boolean
	Dim Cursor1 As Cursor

	Cursor1 = Starter.upit.ExecQuery("SELECT stop_name, stop_lat, stop_lon FROM lokacije WHERE stop_name = '" & stanica & "'")
	If Cursor1.RowCount > 0 Then
		For i = 0 To Cursor1.RowCount - 1
			Cursor1.Position = i
			nl = Cursor1.GetString("stop_name")
			lat = Cursor1.GetDouble("stop_lat")
			lon = Cursor1.GetDouble("stop_lon")
		Next
	End If
End Sub

Sub DodajStavke
'	Log(detaljiLinije)
'	Log(cMapa)
'	Log(zMapa)
	Dim imgC As Bitmap = LoadBitmap(File.DirAssets, "crvena.png")

	If cMapa.Size > 0 Then
		For i = 0 To cMapa.Size - 1
			clvD.Add(CreateListItemDDC(i, imgC, cMapa.GetKeyAt(i), cMapa.GetValueAt(i), clvD.AsView.Width, 64dip), "")
		Next
		pos = clvD.GetSize
	Else
		pos = 0
	End If

	If zMapa.Size > 0 Then
		For i = 0 To zMapa.Size - 1
			If i = 0 Then
				Dim imgNZ As Bitmap = LoadBitmap(File.DirAssets, "narancasta.png")
			Else
				Dim imgNZ As Bitmap = LoadBitmap(File.DirAssets, "zelena.png")
			End If
			clvD.Add(CreateListItemDDZ(i, imgNZ, zMapa.GetKeyAt(i), zMapa.GetValueAt(i), clvD.AsView.Width, 64dip), "")
		Next
	Else
		pos = 0
	End If

	ProgressDialogHide
End Sub

Sub CreateListItemDDC(rb As String, slikaC As Bitmap, vrijeme As String, stanica As String, Width As Int, Height As Int) As Panel
	Dim p As Panel

	p.Initialize("")
	p.SetLayout(0, 0, Width, Height)
	p.LoadLayout("clv_stavka_d")
	p.Color = Colors.white

	ImageView1.Bitmap = slikaC

	Dim rbI As Int = rb
	If rbI = cMapa.Size - 1 Then	' Or rbI = pocSIndex Then
		lblDStanica.TextSize = 18.0
		lblDStanica.Text = cs.Initialize.Color(Colors.RGB(255, 0, 0)).Underline.Append(stanica).PopAll
		lblDVrijeme.TextSize = 18.0
		lblDVrijeme.Text = cs.Initialize.Color(Colors.RGB(255, 0, 0)).Strikethrough.Append(vrijeme).PopAll
	Else
		lblDStanica.TextSize = 14.0
		lblDStanica.Text = cs.Initialize.Color(Colors.RGB(255, 0, 0)).Underline.Append(stanica).PopAll
		lblDVrijeme.TextSize = 14.0
		lblDVrijeme.Text = cs.Initialize.Color(Colors.RGB(255, 0, 0)).Strikethrough.Append(vrijeme).PopAll
	End If
	
	Return p
End Sub

Sub CreateListItemDDZ(rb As String, slikaNZ As Bitmap, vrijeme As String, stanica As String, Width As Int, Height As Int) As Panel
	Dim p As Panel

	p.Initialize("")
	p.SetLayout(0, 0, Width, Height)
	p.LoadLayout("clv_stavka_d")
	p.Color = Colors.white

	ImageView1.Bitmap = slikaNZ

	Dim rbI As Int = rb
	If rbI = 0 Then	'Or rbI = pocSIndex Then
		lblDStanica.TextSize = 18.0
		lblDStanica.Text = cs.Initialize.Color(Colors.RGB(255, 165, 0)).Underline.Append(stanica).PopAll
		lblDVrijeme.TextSize = 18.0
		lblDVrijeme.Text = cs.Initialize.Color(Colors.RGB(255, 165, 0)).Underline.Append(vrijeme).PopAll
	Else
		lblDStanica.TextSize = 14.0
		lblDStanica.Text = cs.Initialize.Color(Colors.RGB(0, 100, 0)).Underline.Append(stanica).PopAll
		lblDVrijeme.TextSize = 14.0
		lblDVrijeme.Text = cs.Initialize.Color(Colors.RGB(0, 100, 0)).Underline.Append(vrijeme).PopAll
	End If
	
	Return p
End Sub
#End Region

Sub imgGeoLociranje_Click
	Log("klik imgGeoLociranje_Click")

	Dim index As Int = clvD.GetItemFromView(Sender)
	Dim pnl As Panel = clvD.GetPanel(index)
	Dim lblA As Label = pnl.GetView(1)

'	Log(lblA.Text)
	IzvuciLokaciju(lblA.Text)
	Starter.adresaZaGPS = lblA.Text

	StartActivity(gps_pozicija)
End Sub

Sub lblDStanica_Click
	Dim cp As BClipboard
	Dim index As Int = clvD.GetItemFromView(Sender)
	Dim pnl As Panel = clvD.GetPanel(index)
	Dim lblA As Label = pnl.GetView(1) ' stanica
	Dim lblB As Label = pnl.GetView(0) ' vrijeme

	Log(lblA.Text)
	Log(lblB.Text)

	Log(cp.hasText)
	cp.clrText
	cp.setText(lblBr.Text & " - " & lblLinija.Text & CRLF & lblA.Text & " - " & lblB.Text)
	Log(cp.hasText)
	Log(cp.getText)
End Sub

Sub lblDVrijeme_Click
	Dim cp As BClipboard
	Dim index As Int = clvD.GetItemFromView(Sender)
	Dim pnl As Panel = clvD.GetPanel(index)
	Dim lblA As Label = pnl.GetView(1) ' stanica
	Dim lblB As Label = pnl.GetView(0) ' vrijeme

	Log(lblA.Text)
	Log(lblB.Text)

	Log(cp.hasText)
	cp.clrText
	cp.setText(lblBr.Text & " - " & lblLinija.Text & CRLF & lblA.Text & " - " & lblB.Text)
	Log(cp.hasText)
	Log(cp.getText)
End Sub