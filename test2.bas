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

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Dim ajdi, ajdiLink, ajdibl, ajdinl As List
	Dim lnk1, lnk2, okr1, okr2, polaziste1, polaziste2, odrediste1, odrediste2 As List
	Dim cMapa As Map
	Dim zMapa As Map
	Dim detaljiLinije As List
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("test")

	ajdi.Initialize
	ajdiLink.Initialize
	ajdibl.Initialize
	ajdinl.Initialize

	DohvatiSveLinijeZaWidget
	'
	'
	' ovo radi ali se previše toga preuzme. za svaki link bi se trebalo preuzeti samo jednom a ne više puta
	' provjeriti gdje je problem i ispraviti ga.
	'
	'
	For i = 0 To ajdi.Size - 1
'		File.Delete(Starter.SourceFolder, ajdi.Get(i) & "lnk1")
		If File.Exists(Starter.SourceFolder, ajdi.Get(i) & "lnk1") = False Then
'			DL_Polaziste_Odrediste_Tekuci_Datum(ajdiLink, ajdi)
			DL_Polaziste_Odrediste_Tekuci_Datum2(ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i))
		Else
			DateTime.DateFormat = "dd"'.MM.yyyy"
			Log(DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(i) & "lnk1")))
			Log(DateTime.Date(DateTime.Now))
			Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(i) & "lnk1"))
			Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
			Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
			If razlika = 0 Then
				Log("današnji datum datoteke!")
				UcitajListe(ajdi.Get(i))
				Dohvati_Indeks_Za_DL_Postojece_Liste(ajdi.Get(i), ajdinl.Get(i))
			Else
				DL_Polaziste_Odrediste_Tekuci_Datum2(ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i))
			End If
		End If
	Next
'	If File.Exists(Starter.SourceFolder, ajdi.Get(0) & "lnk1") = False Then
'		DL_Polaziste_Odrediste_Tekuci_Datum(ajdiLink, ajdi)
'	Else
		' učitaj iz već usnimljenih lista polazišta/odredišta
		'
		'
		' ovo se treba urediti!!!!!!!!!!!
		'
		'
		' 
'		Dim k As Int = 0
'		For Each id As Int In ajdi
'			DateTime.DateFormat = "dd"'.MM.yyyy"
'			Log(DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(k) & "lnk1")))
'			Log(DateTime.Date(DateTime.Now))
'			Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, ajdi.Get(k) & "lnk1"))
'			Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
'			Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
'			If razlika = 0 Then
'				Log("današnji datum datoteke!")
'				UcitajListe(id)
'			Else
'				
'			End If
'		Next
'	End If
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub DohvatiSveLinijeZaWidget
	Log("DohvatiSveLinijeZaWidget iz test2 aktivnosti")
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
End Sub

Sub DL_Polaziste_Odrediste_Tekuci_Datum2(link As String, id As Int, nl As String, bl As String)
	Dim j As HttpJob
	j.Initialize("", Me) 'name is empty as it is no longer needed
	Dim dat As Long
	dat = DateTime.DateParse(DateTime.Date(DateTime.Now))
	DateTime.DateFormat = "yyyyMMdd"
	Dim s As String = link & "&datum=" & DateTime.Date(dat)
	j.Download(s)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success  And j.getstring.Contains("<table class='table raspored table-striped'>") Then
		Log("Current link: " & link)
'		Log(j.GetString)
		Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, id, nl)
	Else
		DateTime.DateFormat = "dd.MM.yyyy"
		ToastMessageShow("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & bl, False)
	End If
	j.Release
End Sub

'Sub DL_Polaziste_Odrediste_Tekuci_Datum(links As List, id As List)
'	Dim k As Int = 0
'	For Each link As String In links
'		Dim j As HttpJob
'		j.Initialize("", Me) 'name is empty as it is no longer needed
'		Dim dat As Long
'		dat = DateTime.DateParse(DateTime.Date(DateTime.Now))
'		DateTime.DateFormat = "yyyyMMdd"
'		Dim s As String = link & "&datum=" & DateTime.Date(dat)
'		j.Download(s)
'		Wait For (j) JobDone(j As HttpJob)
'		If j.Success  And j.getstring.Contains("<table class='table raspored table-striped'>") Then
'			Log("Current link: " & link)
''			Log(j.GetString)
'			Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, ajdi.Get(k), ajdinl.Get(k))
'			k = k + 1
'		Else
'			DateTime.DateFormat = "dd.MM.yyyy"
'			ToastMessageShow("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & ajdibl.Get(k), False)
'			k = k + 1
'		End If
'		j.Release
'	Next
'End Sub

Sub Parsaj_Polaziste_Odrediste_Tekuci_Datum(stranica As String, ide As Int, nl As String)
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

	DL_VozniRedDetalj2(lnk1.Get(pos), ide)
End Sub

Sub Dohvati_Indeks_Za_DL_Postojece_Liste(ide As Int, nl As String)
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
	DL_VozniRedDetalj2(lnk1.Get(pos), ide)
End Sub

Sub DL_VozniRedDetalj2(link As String, ide As Int)
	Dim j As HttpJob
	j.Initialize("", Me) 'name is empty as it is no longer needed
	j.Download(link)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		ParsajDetaljeLinije2(j.GetString, ide)
	End If
	j.Release
End Sub

Sub ParsajDetaljeLinije2(stranica As String, ide As Int)
	Dim matcher1 As Matcher

	cMapa.Initialize
	zMapa.Initialize
	detaljiLinije.Initialize

	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))

	matcher1 = Regex.Matcher($"<li>(\d+:\d+:\d+\s+-\s+.*)</li>"$, stranica)
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

	Log(ajdi.IndexOf(ide))
	Log(ajdibl.Get(ajdi.IndexOf(ide)))
	Log(ajdinl.Get(ajdi.IndexOf(ide)))
	Log(ajdiLink.Get(ajdi.IndexOf(ide)))
	Log(zMapa)
	Log(zMapa.GetKeyAt(0))
'	Log(cMapa)
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