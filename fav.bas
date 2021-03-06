﻿B4A=true
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
	Dim lnk1, lnk2, okr1, okr2, polaziste1, polaziste2, odrediste1, odrediste2 As List
	Dim cMapa As Map
	Dim zMapa As Map
	Dim detaljiLinije As List
'	Dim pos As Int
End Sub

Sub Service_Create
	Log("fav servis -> Service_Create")
	#if release
	rv = ConfigureHomeWidget("fav_widget", "rv", 0, "", False)
	#end if
	ajdi.Initialize
	ajdiLink.Initialize
	ajdibl.Initialize
	ajdinl.Initialize
End Sub

Sub Service_Start(StartingIntent As Intent)
	Log("fav servis -> Service_Start")
	rv.HandleWidgetEvents(StartingIntent)
	Sleep(0)
	Service.StopAutomaticForeground
	' We have to be sure that we do not start the service
	' again if all widgets are removed from homescreen
	If StartingIntent.Action <> "android.appwidget.action.APPWIDGET_DISABLED" Then
		Dim minuteUPreferences As Int = Main.manager.GetString("edit1")
		Dim slijedecePokretanje As Long = DateTime.Now + (minuteUPreferences * 60) * 1000
		StartServiceAt("", slijedecePokretanje, False)
	End If
End Sub

Sub Service_Destroy
	Log("fav servis -> Service_Destroy")
End Sub

Sub rv_RequestUpdate
	Log("fav servis -> rv_RequestUpdate")
	DohvatiSveLinijeZaWidget
'	rv.UpdateWidget
End Sub

#Region Novi_Kod
Sub DohvatiSveLinijeZaWidget
'	pos = 0
	Log("fav -> DohvatiSveLinijeZaWidget")
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
		Provjera_Lista_I_Datuma_Na_Dat
	Else
		ToastMessageShow("Niste odabrili niti jednu liniju za widget unutar aplikacije!", False)
	End If
End Sub

Sub Provjera_Lista_I_Datuma_Na_Dat
	Log("fav -> Provjera_Lista_I_Datuma_Na_Dat")
	For i = 0 To ajdi.Size - 1
'		File.Delete(Starter.SourceFolder, ajdi.Get(i) & "lnk1")
		If File.Exists(Starter.SourceFolder, ajdi.Get(i) & "lnk1") = False Then
			Wait For (DL_Polaziste_Odrediste_Tekuci_Datum2(Me, ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i), i)) JobDone (j As HttpJob)
			If j.Success Then
'				Log(j.GetString)
				Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, ajdi.Get(i), ajdinl.Get(i), i)
			End If
			j.Release
		Else
			DateTime.DateFormat = "dd"
			Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(i) & "lnk1"))
			Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
			Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
			If razlika = 0 Then
				Log("današnji datum datoteke!")
				UcitajListe(ajdi.Get(i))
				Dohvati_Indeks_Za_DL_Postojece_Liste(ajdi.Get(i), ajdinl.Get(i), i)
			Else
				Wait For (DL_Polaziste_Odrediste_Tekuci_Datum2(Me, ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i), i)) JobDone (j As HttpJob)
				If j.Success Then
'					Log(j.GetString)
					Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, ajdi.Get(i), ajdinl.Get(i), i)
				End If
				j.Release
			End If
		End If
	Next
End Sub

Sub DL_Polaziste_Odrediste_Tekuci_Datum2(Callback As Object, link As String, id As Int, nl As String, bl As String, idx As Int) As HttpJob
	Log("fav -> DL_Polaziste_Odrediste_Tekuci_Datum2")
	Dim j As HttpJob
	j.Initialize("", Callback)
	Dim dat As Long
	dat = DateTime.DateParse(DateTime.Date(DateTime.Now))
	DateTime.DateFormat = "yyyyMMdd"
	Dim s As String = link & "&datum=" & DateTime.Date(dat)
	j.Download(s)

	Return j
End Sub

Sub Parsaj_Polaziste_Odrediste_Tekuci_Datum(stranica As String, ide As Int, nl As String, idx As Int)
	Log("fav -> Parsaj_Polaziste_Odrediste_Tekuci_Datum")
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
	matcher1 = Regex.Matcher($"<a href='(.*?&direction_id=(\d))'>([0-5][0-9]:[0-5][0-9]:[0-5][0-9])</a></td><td>(.*?)</td><td>&nbsp;</td><td>(.*?)</td>"$, stranica)
	Do While matcher1.Find = True
		If matcher1.Group(2) = "0" Then
			lnk1.Add(matcher1.Group(1))
			okr1.Add(matcher1.Group(3))
			polaziste1.Add(matcher1.Group(4))
			odrediste1.Add(matcher1.Group(5))
		Else
			lnk2.Add(matcher1.Group(1))
			okr2.Add(matcher1.Group(3))
			polaziste2.Add(matcher1.Group(4))
			odrediste2.Add(matcher1.Group(5))
		End If
	Loop

	'
	' dohvat indeksa za prikaz detaljnijeg voznog reda
	'
	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
	Dim idxLinijeB As Boolean = False
	Dim ss As String = nl
	Dim pos As Int
	For i = 0 To okr1.Size - 1
		Dim ss As String = okr1.Get(i)
		ss = ss.SubString2(0, ss.LastIndexOf(":"))
		If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
			pos = i
			idxLinijeB = True
			Exit
		End If
	Next
	UsnimiListe(ide)

	Wait For (DL_VozniRedDetalj2(Me, lnk1.Get(pos), ide, idx)) JobDone (j As HttpJob)
	If j.Success Then
'		Log(j.GetString)
		ParsajDetaljeLinije2(j.GetString, ide, idx)
	End If
	j.Release
End Sub

Sub Dohvati_Indeks_Za_DL_Postojece_Liste(ide As Int, nl As String, idx As Int)
	Log("fav -> Dohvati_Indeks_Za_DL_Postojece_Liste")
	'
	' dohvat indeksa za prikaz detaljnijeg voznog reda
	'
	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
	Dim idxLinijeB As Boolean = False
	Dim ss As String = nl
	Dim pos As Int
	For i = 0 To okr1.Size - 1
		Dim ss As String = okr1.Get(i)
		ss = ss.SubString2(0, ss.LastIndexOf(":"))
		If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
			pos = i
			idxLinijeB = True
			Exit
		End If
	Next

	Wait For (DL_VozniRedDetalj2(Me, lnk1.Get(pos), ide, idx)) JobDone (j As HttpJob)
	If j.Success Then
'		Log(j.GetString)
		ParsajDetaljeLinije2(j.GetString, ide, idx)
	End If
	j.Release
End Sub

Sub DL_VozniRedDetalj2(Callback As Object, link As String, ide As Int, idx As Int) As HttpJob
	Log("fav -> DL_VozniRedDetalj2")
	Dim j As HttpJob
	j.Initialize("", Callback)
	j.Download(link)

	Return j
End Sub

Sub ParsajDetaljeLinije2(stranica As String, ide As Int, idx As Int)
	Log("fav -> ParsajDetaljeLinije2")
	Dim matcher1 As Matcher
'	Dim pos As Int

	cMapa.Initialize
	zMapa.Initialize
	detaljiLinije.Initialize

	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
	matcher1 = Regex.Matcher($"<li>(\d+:\d+:\d+\s+-\s+.*)</li>"$, stranica)
	Do While matcher1.Find = True
		detaljiLinije.Add(matcher1.Group(1))
	Loop

'	Log("detaljiLinije: " & detaljiLinije)
	For i = 0 To detaljiLinije.Size - 1
		Dim s1 As String = detaljiLinije.Get(i)
		Dim s3 As String = s1
		s3 = s1.SubString2(0, s1.IndexOf(" - "))
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

'	Log(ajdi.IndexOf(ide))
'	Log(ajdibl.Get(ajdi.IndexOf(ide)))
'	Log(ajdinl.Get(ajdi.IndexOf(ide)))
'	Log(ajdiLink.Get(ajdi.IndexOf(ide)))
	Dim tv As String = DateTime.Time(DateTime.Now)
	Log("trenutno vrijeme: " & tv)
	For i = 0 To zMapa.Size - 1
		Dim ki As String = zMapa.GetKeyAt(i)
		Log("prvo vrijeme u zMapa: " & ki)
		If ki.CompareTo(tv) < 0 Then	' trenutno vrijeme je veće
			Log("trenutno vrijeme je veće")
			Log(zMapa.GetKeyAt(i))
			Log(zMapa.GetValueAt(i))
			Exit
		Else
			Log("trenutno vrijeme je manje")
			Log(zMapa.GetKeyAt(i))
			Log(zMapa.GetValueAt(i))
			Exit
		End If
	Next
	Log(detaljiLinije.Size)
'	Log(pos)
	Log(zMapa)
'	Log(cMapa)
	Log(zMapa.GetKeyAt(0))
	Log(zMapa.GetKeyAt(1))
'	Log(detaljiLinije.Get(pos))
'	Log(zMapa.GetValueAt(pos))
	'
	'
	' sa donje dvije LOG linije app se ruši
	'
	'
'	Log(pos)
'	Log(zMapa.GetKeyAt(pos))
''	Log(cMapa)
'	Log("imgVozilo" & idx)
'	Log("lblBrojLinije" & idx)
'	Log("lblPolazisteOdrediste" & idx)
	Dim bl As String = ajdibl.Get(ajdi.IndexOf(ide))
	If bl < 100 Then ' tramvaji
		rv.SetImage("imgVozilo" & (idx+1), LoadBitmap(File.DirAssets, "tram1.png"))
		rv.SetText("lblBrojLinije" & (idx+1), zMapa.GetKeyAt(0))
	Else
		rv.SetImage("imgVozilo" & (idx+1), LoadBitmap(File.DirAssets, "bus1.png"))
		rv.SetText("lblBrojLinije" & (idx+1), zMapa.GetKeyAt(0))
	End If
	Dim nl As String = ajdinl.Get(ajdi.IndexOf(ide))
	rv.SetText("lblPolazisteOdrediste" & (idx+1), nl)
	
	rv.UpdateWidget
End Sub

Sub UsnimiListe(id As Int)
	File.WriteList(Starter.SourceFolder, id & "lnk1", lnk1)
	File.WriteList(Starter.SourceFolder, id & "lnk2", lnk2)
	File.WriteList(Starter.SourceFolder, id & "okr1", okr1)
	File.WriteList(Starter.SourceFolder, id & "okr2", okr2)
	File.WriteList(Starter.SourceFolder, id & "p1", polaziste1)
	File.WriteList(Starter.SourceFolder, id & "p2", polaziste2)
	File.WriteList(Starter.SourceFolder, id & "o1", odrediste1)
	File.WriteList(Starter.SourceFolder, id & "o2", odrediste2)
End Sub

Sub UcitajListe(id As Int)
	lnk1 = File.ReadList(Starter.SourceFolder, id & "lnk1")
	lnk2 = File.ReadList(Starter.SourceFolder, id & "lnk2")
	okr1 = File.ReadList(Starter.SourceFolder, id & "okr1")
	okr2 = File.ReadList(Starter.SourceFolder, id & "okr2")
	polaziste1 = File.ReadList(Starter.SourceFolder, id & "p1")
	polaziste2 = File.ReadList(Starter.SourceFolder, id & "p2")
	odrediste1 = File.ReadList(Starter.SourceFolder, id & "o1")
	odrediste2 = File.ReadList(Starter.SourceFolder, id & "o2")
End Sub
#End Region

''
'' dohvaćanje svih linija koje je korisnik dodao za widget
'' linija za prikaz u widgetu može biti najviše 6
''
'Sub DohvatiSveLinijeZaWidget
'	Log("fav servis -> DohvatiSveLinijeZaWidget")
'	Dim Cursor1 As Cursor
'	Cursor1 = Starter.upit.ExecQuery($"SELECT id, dnevna, widget, brojLinije, nazivLinije, link FROM linije WHERE widget = 2 LIMIT 6"$)
'	If Cursor1.RowCount > 0 Then
'		For i = 0 To Cursor1.RowCount - 1
'			Cursor1.Position = i
'			Dim tt As Int = Cursor1.GetInt("dnevna")
'			ajdi.Add(Cursor1.GetInt("id"))
'			ajdiLink.Add(Cursor1.GetString("link"))
'			If tt = 1 Then
'				ajdibl.Add(Cursor1.GetString("brojLinije"))
'			Else
'				ajdibl.Add(Cursor1.GetString("brojLinije") & "N")
'			End If
'			ajdinl.Add(Cursor1.GetString("nazivLinije"))
'		Next
'		Cursor1.Close
'		Provjera_Lista_I_Datuma_Na_Dat
'	Else
'		ToastMessageShow("Niste odabrili niti jednu liniju za widget unutar aplikacije!", False)
'	End If
'End Sub
'
''
'' provjera postoje li liste
'' ako postoje provjeri jesu li od tekućeg datuma
'' ako nisu DL novih od tekućeg datuma
''
'Sub Provjera_Lista_I_Datuma_Na_Dat
'	Log("fav servis -> Provjera_Lista_I_Datuma_Na_Dat")
'	For i = 0 To ajdi.Size - 1
'		If File.Exists(Starter.SourceFolder, ajdi.Get(i) & "lnk1") = False Then
'			Wait For (DL_Polaziste_Odrediste_Tekuci_Datum2(ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i), i)) Complete (Success As Boolean)
'			If Success Then
'				Log("prvi DL OK!")
'			End If
'		Else
'			DateTime.DateFormat = "dd"
'			Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(i) & "lnk1"))
'			Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
'			Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
'			If razlika = 0 Then
'				Log("današnji datum datoteke!")
'				UcitajListe(ajdi.Get(i))
'				Dohvati_Indeks_Za_DL_Postojece_Liste(ajdi.Get(i), ajdinl.Get(i), i)
'			Else
'				Wait For (DL_Polaziste_Odrediste_Tekuci_Datum2(ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i), i)) Complete (Success As Boolean)				
'			End If
'		End If
'	Next
'End Sub
'
''
'' DL tekućih podataka za polazište/odredište
''
'Sub DL_Polaziste_Odrediste_Tekuci_Datum2(link As String, id As Int, nl As String, bl As String, idx As Int) As ResumableSub
'	Log("fav servis -> DL_Polaziste_Odrediste_Tekuci_Datum2")
'	Dim j As HttpJob
'	j.Initialize("", Me)
'	Dim dat As Long
'	dat = DateTime.DateParse(DateTime.Date(DateTime.Now))
'	DateTime.DateFormat = "yyyyMMdd"
'	Dim s As String = link & "&datum=" & DateTime.Date(dat)
'	j.Download(s)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success  And j.getstring.Contains("<table class='table raspored table-striped'>") Then
'		Log("Current link: " & link)
'		Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, id, nl, idx)
'	Else
'		DateTime.DateFormat = "dd.MM.yyyy"
'		ToastMessageShow("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & bl, False)
'	End If
'	j.Release
'
'	Return j.Success
'End Sub
'
''
'' parsanje datoteke za polazište/odredište za tekući datum
''
'Sub Parsaj_Polaziste_Odrediste_Tekuci_Datum(stranica As String, ide As Int, nl As String, idx As Int)
'	Log("fav servis -> Parsaj_Polaziste_Odrediste_Tekuci_Datum")
'	Dim matcher1 As Matcher
'
'	lnk1.Initialize
'	lnk2.Initialize
'	okr1.Initialize
'	okr2.Initialize
'	polaziste1.Initialize
'	polaziste2.Initialize
'	odrediste1.Initialize
'	odrediste2.Initialize
'
'	' 1. okretište -> 2. okretište
'	matcher1 = Regex.Matcher($"<a href='(.*?&direction_id=(\d))'>([0-5][0-9]:[0-5][0-9]:[0-5][0-9])</a></td><td>(.*?)</td><td>&nbsp;</td><td>(.*?)</td>"$, stranica)
'	Do While matcher1.Find = True
'		If matcher1.Group(2) = "0" Then
'			lnk1.Add(matcher1.Group(1))
'			okr1.Add(matcher1.Group(3))
'			polaziste1.Add(matcher1.Group(4))
'			odrediste1.Add(matcher1.Group(5))
'		Else
'			lnk2.Add(matcher1.Group(1))
'			okr2.Add(matcher1.Group(3))
'			polaziste2.Add(matcher1.Group(4))
'			odrediste2.Add(matcher1.Group(5))
'		End If
'	Loop
'
'	'
'	' dohvat indeksa za prikaz detaljnijeg voznog reda
'	'
'	Dim satMin As String = DateTime.Time(DateTime.Now)
'	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
'	Dim idxLinijeB As Boolean = False
'	Dim ss As String = nl
'	Dim pos As Int
'	For i = 0 To okr1.Size - 1
'		Dim ss As String = okr1.Get(i)
'		ss = ss.SubString2(0, ss.LastIndexOf(":"))
'		If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
'			pos = i
'			idxLinijeB = True
'			Exit
'		End If
'	Next
'	UsnimiListe(ide)
'
'	DL_VozniRedDetalj2(lnk1.Get(pos), ide, idx)
'End Sub
'
''
'' dohvaćanje indeksa za vrijeme (od kojeg vremena ćemo prikazati podatke unutar widgeta)
'' prvo najbliže vrijeme do tekućeg vremena
''
'Sub Dohvati_Indeks_Za_DL_Postojece_Liste(ide As Int, nl As String, idx As Int)
'	Log("fav servis -> Dohvati_Indeks_Za_DL_Postojece_Liste")
'	'
'	' dohvat indeksa za prikaz detaljnijeg voznog reda
'	'
'	Dim satMin As String = DateTime.Time(DateTime.Now)
'	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
'	Dim idxLinijeB As Boolean = False
'	Dim ss As String = nl
'	Dim pos As Int
'	For i = 0 To okr1.Size - 1
'		Dim ss As String = okr1.Get(i)
'		ss = ss.SubString2(0, ss.LastIndexOf(":"))
'		If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
'			pos = i
'			idxLinijeB = True
'			Exit
'		End If
'	Next
'	DL_VozniRedDetalj2(lnk1.Get(pos), ide, idx)
'End Sub
'
''
'' DL detalja voznog reda (za indeks gore)
''
'Sub DL_VozniRedDetalj2(link As String, ide As Int, idx As Int)
'	Log("fav servis -> DL_VozniRedDetalj2")
'	Dim j As HttpJob
'	j.Initialize("", Me)
'	j.Download(link)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		ParsajDetaljeLinije2(j.GetString, ide, idx)
'	End If
'	j.Release
'End Sub
'
''
'' parsanje detalja voznog reda
''
'Sub ParsajDetaljeLinije2(stranica As String, ide As Int, idx As Int)
'	Log("fav servis -> ParsajDetaljeLinije2")
'	Dim matcher1 As Matcher
'
'	cMapa.Initialize
'	zMapa.Initialize
'	detaljiLinije.Initialize
'
'	Dim satMin As String = DateTime.Time(DateTime.Now)
'	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
'
'	matcher1 = Regex.Matcher($"<li>(\d+:\d+:\d+\s+-\s+.*)</li>"$, stranica)
'	Do While matcher1.Find = True
'		detaljiLinije.Add(matcher1.Group(1))
'	Loop
'
'	For i = 0 To detaljiLinije.Size - 1
'		Dim s1 As String = detaljiLinije.Get(i)
'		Dim s3 As String = s1
'		s3 = s1.SubString2(0, s1.IndexOf(" - "))
'		If satMin.CompareTo(s3) >= 0 Then
'			Dim s4 As String = s1
'			' stanica
'			s4 = s1.SubString2(s1.IndexOf(" - ") + 3, s1.Length)
'			cMapa.Put(s3, s4)
'		Else
'			Dim s4 As String = s1
'			' stanica
'			s4 = s1.SubString2(s1.IndexOf(" - ") + 3, s1.Length)
'			zMapa.Put(s3, s4)
'		End If
'	Next
'
'	Log(ajdi.IndexOf(ide))
'	Log(ajdibl.Get(ajdi.IndexOf(ide)))
'	Log(ajdinl.Get(ajdi.IndexOf(ide)))
'	Log(ajdiLink.Get(ajdi.IndexOf(ide)))
'	Log(zMapa)
'	Log(zMapa.GetKeyAt(0))
''	Log(cMapa)
'	Dim bl As String = ajdibl.Get(ajdi.IndexOf(ide))
'	Log("imgVozilo" & idx)
'	Log("lblBrojLinije" & idx)
'	Log("lblPolazisteOdrediste" & idx)
'	If bl < 100 Then ' tramvaji
'		rv.SetImage("imgVozilo" & idx, LoadBitmap(File.DirAssets, "tram1.png"))
'		rv.SetText("lblBrojLinije" & idx, zMapa.GetKeyAt(0))
'	Else
'		rv.SetImage("imgVozilo" & idx, LoadBitmap(File.DirAssets, "bus1.png"))
'		rv.SetText("lblBrojLinije" & idx, zMapa.GetKeyAt(0))
'	End If
'	Dim nl As String = ajdinl.Get(ajdi.IndexOf(ide))
'	rv.SetText("lblPolazisteOdrediste" & idx, nl)
'
'	rv.UpdateWidget
'End Sub
'
'' usnimavanje liste za tekući dan, da se ista ne mora svaki puta preuzimati sa neta
''
'Sub UsnimiListe(id As Int)
'	Log("fav servis -> UsnimiListe")
'	File.WriteList(Starter.SourceFolder, id & "lnk1", lnk1)
'	File.WriteList(Starter.SourceFolder, id & "lnk2", lnk2)
'	File.WriteList(Starter.SourceFolder, id & "okr1", okr1)
'	File.WriteList(Starter.SourceFolder, id & "okr2", okr2)
'	File.WriteList(Starter.SourceFolder, id & "p1", polaziste1)
'	File.WriteList(Starter.SourceFolder, id & "p2", polaziste2)
'	File.WriteList(Starter.SourceFolder, id & "o1", odrediste1)
'	File.WriteList(Starter.SourceFolder, id & "o2", odrediste2)
'End Sub
'
''
'' učitavanje tekuće liste
''
'Sub UcitajListe(id As Int)
'	Log("fav servis -> UcitajListe")
'	lnk1 = File.ReadList(Starter.SourceFolder, id & "lnk1")
'	lnk2 = File.ReadList(Starter.SourceFolder, id & "lnk2")
'	okr1 = File.ReadList(Starter.SourceFolder, id & "okr1")
'	okr2 = File.ReadList(Starter.SourceFolder, id & "okr2")
'	polaziste1 = File.ReadList(Starter.SourceFolder, id & "p1")
'	polaziste2 = File.ReadList(Starter.SourceFolder, id & "p2")
'	odrediste1 = File.ReadList(Starter.SourceFolder, id & "o1")
'	odrediste2 = File.ReadList(Starter.SourceFolder, id & "o2")
'End Sub

Sub rv_Disabled
	Log("fav servis -> rv_Disabled")
	CancelScheduledService("")
	StopService("")
End Sub


