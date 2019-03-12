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
	Dim rv As RemoteViews
	Dim ajdi, ajdiLink, ajdibl, ajdinl As List
'	Dim okr1, okr2, lnk1, lnk2, polaziste1, polaziste2, odrediste1, odrediste2 As List
	Dim lnk1, lnk2, okr1, okr2 As List
	Dim rb As Int
	Dim pos As Int
	Dim detaljiLinije As List
	Dim cMapa As Map
	Dim zMapa As Map
	Dim okretiste1 As Boolean
	Dim okretiste2 As Boolean
	Dim okretiste3 As Boolean
	Dim okretiste4 As Boolean
	Dim okretiste5 As Boolean
	Dim okretiste6 As Boolean
End Sub

Sub Service_Create
	rv = ConfigureHomeWidget("fav_widget", "rv", 0, "", False)
	ajdi.Initialize
	ajdiLink.Initialize
	ajdibl.Initialize
	ajdinl.Initialize
End Sub

Sub Service_Start (StartingIntent As Intent)
'	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
	rv.HandleWidgetEvents(StartingIntent)
	Sleep(0)
	Service.StopAutomaticForeground
End Sub

Sub Service_Destroy

End Sub

Sub rv_RequestUpdate
	DohvatiSveLinijeZaWidget
'	rv.UpdateWidget
End Sub

Sub rv_Disabled
	CancelScheduledService("")
	StopService("")
End Sub

Sub DohvatiSveLinijeZaWidget
	Dim Cursor1 As Cursor
	Cursor1 = Starter.upit.ExecQuery($"SELECT id, dnevna, widget, brojLinije, nazivLinije, link FROM linije WHERE widget = 2 LIMIT 6"$)
	If Cursor1.RowCount > 0 Then
		For i = 0 To Cursor1.RowCount - 1
			Cursor1.Position = i
			Dim tt As Int = Cursor1.GetInt("dnevna")
			ajdi.Add(Cursor1.GetInt("id"))
			ajdiLink.Add(Cursor1.GetString("link"))
			If tt = 1 Then
				ajdibl.Add(Cursor1.GetString("brojLinije"))
			Else
				ajdibl.Add(Cursor1.GetString("brojLinije") & "N")
			End If
			ajdinl.Add(Cursor1.GetString("nazivLinije"))
		Next
		Cursor1.Close
	Else
		ToastMessageShow("Niste odabrili niti jednu liniju za widget unutar aplikacije!", False)
	End If

	For i = 0 To ajdi.Size - 1
		Log(ajdi.Get(i))
		Log(ajdibl.Get(i))
		Log(ajdinl.Get(i))
		Log(ajdiLink.get(i))
	Next

	ProvjeraDatumaNaDatoteci
End Sub

Sub ProvjeraDatumaNaDatoteci
	For i = 0 To ajdi.Size - 1
		If File.Exists(Starter.SourceFolder, ajdi.Get(i) & "lnk1") Then
			rb = ajdi.Get(i)
			DateTime.DateFormat = "dd"
'			Log(DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(i) & "lnk1")))
'			Log(DateTime.Date(DateTime.Now))
			Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(i) & "lnk1"))
			Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
			Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
			If razlika = 0 Then
				Log("današnji datum datoteke!")
				UcitajListe
'				Dim brL As Int = Starter.brojLinije
'				If brL < 99 Then	' tramvaj
'					imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
'				Else	' bus
'					imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
'				End If
'				IspuniTablicu
				iksiks
			Else
				' ako je datoteka sa podacima o današnjem voznom redu od jučer (ili od prije u prošlosti), preuzmi novu sa neta
				Log("datoteka je starija!")
				ToastMessageShow("Trenutno nema podataka odnosno nije napravljen d/l!", False)
'				PripremiDL
			End If
		Else
			' ako ne postoji datoteka sa podacima o današnjem voznom redu, preuzmi ju sa neta
			ToastMessageShow("Trenutno nema podataka odnosno nije napravljen d/l!", False)
'			PripremiDL
		End If
	Next
End Sub

Sub iksiks
	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
'	Dim idxLinijeB As Boolean = False

'	If okretiste Then
		For i = 0 To okr1.Size - 1
'			lblLinija.Text = polaziste1.Get(0) & " - " & odrediste1.Get(0)
			Dim ss As String = okr1.Get(i)
			ss = ss.SubString2(0, ss.LastIndexOf(":"))
			If ss.CompareTo(satMin) > 0 Then
				pos = i	' pozicija za link za detalj linije (uspredba sa trenutnim vremenom)
				Exit
'				idxLinijeB = True
			End If
'			clvD.Add(CreateItem(okr1.Get(i), polaziste1.Get(i), odrediste1.Get(i), clvD.AsView.Width, 62dip), "")
		Next
	Log(lnk1.Get(pos))
	DL_VozniRedDetalj2(lnk1.Get(pos))

	'
	'
	'
	' spremiti za svaki vozni red sa polazišta/odredišta  u određđeno vrijeme, podatke po stanicama u mapu
	' primjer:
	' 13:20:24 je key, a value je stanica1
	' 13:24:45 je key, a value je stanica2
	' ...
	' ...
	'
	'
	'

'	Else
'		For i = 0 To okr2.Size - 1
'			lblLinija.Text = polaziste2.Get(0) & " - " & odrediste2.Get(0)
'			Dim ss As String = okr2.Get(i)
'			ss = ss.SubString2(0, ss.LastIndexOf(":"))
'			If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
'				pos = i
'				idxLinijeB = True
'			End If
'			clvD.Add(CreateItem(okr2.Get(i), polaziste2.Get(i), odrediste2.Get(i), clvD.AsView.Width, 62dip), "")
'		Next
'	End If
End Sub

Sub lblPolazisteOdrediste1_Click
	If okretiste1 Then
		okretiste1 = False
'		IspuniTablicu
'		iksiks
	Else
		okretiste1 = True
'		IspuniTablicu
'		iksiks
	End If
End Sub

Sub lblPolazisteOdredist2_Click
	If okretiste2 Then
		okretiste2 = False
'		IspuniTablicu
'		iksiks
	Else
		okretiste2 = True
'		IspuniTablicu
'		iksiks
	End If
End Sub

Sub lblPolazisteOdrediste3_Click
	If okretiste3 Then
		okretiste3 = False
'		IspuniTablicu
'		iksiks
	Else
		okretiste3 = True
'		IspuniTablicu
'		iksiks
	End If
End Sub

Sub lblPolazisteOdrediste4_Click
	If okretiste4 Then
		okretiste4 = False
'		IspuniTablicu
'		iksiks
	Else
		okretiste4 = True
'		IspuniTablicu
'		iksiks
	End If
End Sub

Sub lblPolazisteOdrediste5_Click
	If okretiste5 Then
		okretiste5 = False
'		IspuniTablicu
'		iksiks
	Else
		okretiste5 = True
'		IspuniTablicu
'		iksiks
	End If
End Sub

Sub lblPolazisteOdrediste6_Click
	If okretiste6 Then
		okretiste6 = False
'		IspuniTablicu
'		iksiks
	Else
		okretiste6 = True
'		IspuniTablicu
'		iksiks
	End If
End Sub

Sub DL_VozniRedDetalj2(lnk As String)
	Dim j As HttpJob
	j.Initialize("", Me) 'name is empty as it is no longer needed
	j.Download(lnk)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
'		Log(j.GetString)
		ParsajDetaljeLinije2(j.GetString)
	End If
	j.Release
End Sub

Sub ParsajDetaljeLinije2(strim As String)
	Dim matcher1 As Matcher

	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))

	detaljiLinije.Initialize
	cMapa.Initialize
	zMapa.Initialize

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

	Log(cMapa)
	Log(zMapa)
	UbaciPodatkeWidget
'	Log("detaljiLinije: " & detaljiLinije)
End Sub

Sub UbaciPodatkeWidget
	For i = 0 To ajdi.Size - 1
		rv.SetVisible("imgVozilo" & (i+1), True)
		rv.SetVisible("lblBrojLinije" & (i+1), True)
		rv.SetVisible("lblPolazisteOdrediste" & (i+1), True)
		Dim br As Int = ajdibl.Get(i)
		If br < 100 Then	' slika tramvaja
			rv.SetImage("imgVozilo" & (i+1), LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True))
		Else	' inače autobusa
			rv.SetImage("imgVozilo" & (i+1), LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True))
		End If
		rv.SetText("lblBrojLinije" & (i+1), ajdibl.Get(i))
'		Log(bl.Get(i))
		rv.SetText("lblPolazisteOdrediste" & (i+1), zMapa.GetKeyAt(0) & CRLF & zMapa.GetValueAt(0))
		Log(zMapa.GetKeyAt(0) & CRLF & zMapa.GetValueAt(0))
	Next

	rv.UpdateWidget
End Sub

Sub UcitajListe
	lnk1.Initialize
	lnk2.Initialize
	okr1.Initialize
	okr2.Initialize

	lnk1 = File.ReadList(Starter.SourceFolder, rb & "lnk1")
'	Log(lnk1)
	lnk2 = File.ReadList(Starter.SourceFolder, rb & "lnk2")
	okr1 = File.ReadList(Starter.SourceFolder, rb & "okr1")' - vrijeme sa okretišta
'	Log(okr1)
	okr2 = File.ReadList(Starter.SourceFolder, rb & "okr2")
'	polaziste1 = File.ReadList(Starter.SourceFolder, rb & "p1")
'	Log(polaziste1)
'	polaziste2 = File.ReadList(Starter.SourceFolder, rb & "p2")
'	odrediste1 = File.ReadList(Starter.SourceFolder, rb & "o1")
'	odrediste2 = File.ReadList(Starter.SourceFolder, rb & "o2")
End Sub

