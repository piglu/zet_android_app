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
	Dim lnk1, lnk2, okr1, okr2, polaziste1, polaziste2, odrediste1, odrediste2 As List
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
	#if release
	rv = ConfigureHomeWidget("fav_widget", "rv", 0, "", False)
	#end if
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
				PripremiDL
			End If
		Else
			' ako ne postoji datoteka sa podacima o današnjem voznom redu, preuzmi ju sa neta
			ToastMessageShow("Trenutno nema podataka odnosno nije napravljen d/l!", False)
			PripremiDL
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
'	Log(lnk1.Get(pos))
'	DL_VozniRedDetalj2(lnk1.Get(pos))

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
	lnk1 = File.ReadList(Starter.SourceFolder, rb & "lnk1")
'	Log(lnk1)
	lnk2 = File.ReadList(Starter.SourceFolder, rb & "lnk2")
'	Log(lnk2)
	okr1 = File.ReadList(Starter.SourceFolder, rb & "okr1")
	okr2 = File.ReadList(Starter.SourceFolder, rb & "okr2")
	polaziste1 = File.ReadList(Starter.SourceFolder, rb & "p1")
	polaziste2 = File.ReadList(Starter.SourceFolder, rb & "p2")
	odrediste1 = File.ReadList(Starter.SourceFolder, rb & "o1")
	odrediste2 = File.ReadList(Starter.SourceFolder, rb & "o2")
End Sub

Sub PripremiDL
	Dim Cursor1 As Cursor

	DateTime.DateFormat = "dd.MM.yyyy"

	Cursor1 = Starter.upit.ExecQuery("SELECT id, tip, brojLinije, nazivLinije, dnevna, favorit, link FROM linije WHERE id = " & Starter.indeks)
	For i = 0 To Cursor1.RowCount - 1
		Cursor1.Position = i
		Log(Cursor1.GetInt("tip"))
		Log(Cursor1.GetInt("dnevna"))
		Log(Cursor1.GetString("brojLinije"))
		Log(Cursor1.GetString("nazivLinije"))
		If Cursor1.GetInt("tip") = 1 And Cursor1.GetInt("dnevna") = 1 Then
'			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
'			lblLinija.Text = Starter.nazivLinije
		else if Cursor1.GetInt("tip") = 1 And Cursor1.GetInt("dnevna") = 2 Then
'			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
'			lblLinija.Text = Starter.nazivLinije
		Else if Cursor1.GetInt("tip") = 2 And Cursor1.GetInt("dnevna") = 1 Then
'			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
'			lblLinija.Text = Starter.nazivLinije
		Else if Cursor1.GetInt("tip") = 2 And Cursor1.GetInt("dnevna") = 2 Then
'			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
'			lblLinija.Text = Starter.nazivLinije
		End If
'		idLinije = Cursor1.GetInt("id")
	Next
	Cursor1.Close

	' ako link sadrži pdf datoteku onda prikazujemo PDF korisniku
	If link.Contains("pdf") Then
		' prikazi pdf
		Dim ss As String = link
		ss = ss.SubString2(ss.LastIndexOf("/")+1, ss.Length)
		' provjeriti podržava li uređaj PDF datoteke
		Dim intent1 As Intent
'		intent1.Initialize(intent1.ACTION_VIEW, "file://" & ss)
		intent1.Initialize2(link, 0)
		intent1.SetType("application/pdf")
		Dim pdfAppsList As List
		pdfAppsList = QueryIntent(intent1)
		If pdfAppsList.size > 0 Then
			' pdf viewer(s) exists
			StartActivity(intent1)
		Else
			Msgbox("Vaš uređaj ne podražava pregled PDF dokumenata!", "Greška")
		End If
	Else
		' d/l sa linka stranice za liniju i parsanje vremena za odabranu liniju
		DL_VozniRedTekuciDatum(link, DateTime.Date(DateTime.Now))
	End If
End Sub

Sub QueryIntent(Intent1 As Intent) As List
	Dim r As Reflector
	r.Target = r.GetContext
	r.Target = r.RunMethod("getPackageManager")
	Dim list1 As List
	list1 = r.RunMethod4("queryIntentActivities", Array As Object(Intent1, 0), Array As String("android.content.Intent", "java.lang.int"))
	Dim listRes As List
	listRes.Initialize
	For i = 0 To list1.Size - 1
		r.Target = list1.Get(i)
		r.Target = r.GetField("activityInfo")
		'listRes.Add(r.GetField("name")) 'return the activity full name
		listRes.Add(r.GetField("packageName"))
	Next
	Return listRes
End Sub

Sub DL_VozniRedTekuciDatum(lnk As String, datum As String)
	ProgressDialogShow2("Preuzimam podatke...", False)

	Dim j As HttpJob
	j.Initialize("", Me) 'name is empty as it is no longer needed
	DateTime.DateFormat = "dd.MM.yyyy"
	Dim dat As Long
	dat = DateTime.DateParse(datum)
	DateTime.DateFormat = "yyyyMMdd"
	Dim s As String = lnk & "&datum=" & DateTime.Date(dat)
	j.Download(s) 'link
	Wait For (j) JobDone(j As HttpJob)
	If j.Success And j.getstring.Contains("<table class='table raspored table-striped'>") Then
		ParsajVozniRed(j.GetString)
	Else
		DateTime.DateFormat = "dd.MM.yyyy"
		ToastMessageShow("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & Starter.brojLinije, False)
'		Msgbox("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & Starter.brojLinije, "Informacija")
	End If

	j.Release
End Sub

Sub ParsajVozniRed(strim As String)
	Dim matcher1 As Matcher

	lnk1.Initialize
	lnk2.Initialize
	okr1.Initialize
	okr2.Initialize
	polaziste1.Initialize
	polaziste2.Initialize
	odrediste1.Initialize
	odrediste2.Initialize

	' 1. okretište -> 2. okretište
	matcher1 = Regex.Matcher($"<a href='(.*?&direction_id=(\d))'>([0-5][0-9]:[0-5][0-9]:[0-5][0-9])</a></td><td>(.*?)</td><td>&nbsp;</td><td>(.*?)</td>"$, strim)
	Do While matcher1.Find = True
		If matcher1.Group(2) = "0" Then
			lnk1.Add(matcher1.Group(1))
			okr1.Add(matcher1.Group(3))' = okr1 & matcher1.Group(2) & ";"
			polaziste1.Add(matcher1.Group(4))
			odrediste1.Add(matcher1.Group(5))
		Else
			lnk2.Add(matcher1.Group(1))
			okr2.Add(matcher1.Group(3))' = okr2 & matcher1.Group(2) & ";"
			polaziste2.Add(matcher1.Group(4))
			odrediste2.Add(matcher1.Group(5))
		End If
	Loop

	UsnimiListe

'	IspuniTablicu
End Sub

Sub UsnimiListe
	File.WriteList(Starter.SourceFolder, Starter.indeks & "lnk1", lnk1)
'	Log(lnk1)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "lnk2", lnk2)
'	Log(lnk2)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "okr1", okr1)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "okr2", okr2)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "p1", polaziste1)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "p2", polaziste2)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "o1", odrediste1)
	File.WriteList(Starter.SourceFolder, Starter.indeks & "o2", odrediste2)
End Sub
