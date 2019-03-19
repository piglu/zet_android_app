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
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub DohvatiSveLinijeZaWidget
	Log("test2 -> DohvatiSveLinijeZaWidget")
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
	Log("test2 -> Provjera_Lista_I_Datuma_Na_Dat")
	For i = 0 To ajdi.Size - 1
		File.Delete(Starter.SourceFolder, ajdi.Get(i) & "lnk1")
		If File.Exists(Starter.SourceFolder, ajdi.Get(i) & "lnk1") = False Then
			Wait For (DL_Polaziste_Odrediste_Tekuci_Datum2(Me, ajdiLink.Get(i), ajdi.Get(i), ajdinl.Get(i), ajdibl.Get(i), i)) JobDone (j As HttpJob)
			If j.Success Then
				Log(j.GetString)
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
					Log(j.GetString)
					Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, ajdi.Get(i), ajdinl.Get(i), i)
				End If
				j.Release
			End If
		End If
	Next
End Sub

Sub DL_Polaziste_Odrediste_Tekuci_Datum2(Callback As Object, link As String, id As Int, nl As String, bl As String, idx As Int) As HttpJob
	Log("test2 -> DL_Polaziste_Odrediste_Tekuci_Datum2")
	Dim j As HttpJob
	j.Initialize("", Callback)
	Dim dat As Long
	dat = DateTime.DateParse(DateTime.Date(DateTime.Now))
	DateTime.DateFormat = "yyyyMMdd"
	Dim s As String = link & "&datum=" & DateTime.Date(dat)
	j.Download(s)

	Return j
End Sub


'Sub DL_Polaziste_Odrediste_Tekuci_Datum2(link As String, id As Int, nl As String, bl As String, idx As Int)
'	Log("test2 -> DL_Polaziste_Odrediste_Tekuci_Datum2")
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
''		Parsaj_Polaziste_Odrediste_Tekuci_Datum(j.GetString, id, nl, idx)
'	Else
'		DateTime.DateFormat = "dd.MM.yyyy"
'		ToastMessageShow("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & bl, False)
'	End If
'	j.Release
'End Sub

Sub Parsaj_Polaziste_Odrediste_Tekuci_Datum(stranica As String, ide As Int, nl As String, idx As Int)
	Log("test2 -> Parsaj_Polaziste_Odrediste_Tekuci_Datum")
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
		Log(j.GetString)
		ParsajDetaljeLinije2(j.GetString, ide, idx)
	End If
	j.Release
End Sub

Sub Dohvati_Indeks_Za_DL_Postojece_Liste(ide As Int, nl As String, idx As Int)
	Log("test2 -> Dohvati_Indeks_Za_DL_Postojece_Liste")
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
		Log(j.GetString)
		ParsajDetaljeLinije2(j.GetString, ide, idx)
	End If
	j.Release
End Sub

Sub DL_VozniRedDetalj2(Callback As Object, link As String, ide As Int, idx As Int) As HttpJob
	Log("test2 -> DL_VozniRedDetalj2")
	Dim j As HttpJob
	j.Initialize("", Callback)
	j.Download(link)

	Return j
End Sub

'Sub DL_VozniRedDetalj2(link As String, ide As Int, idx As Int)
'	Log("test2 -> DL_VozniRedDetalj2")
'	Dim j As HttpJob
'	j.Initialize("", Me)
'	j.Download(link)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		ParsajDetaljeLinije2(j.GetString, ide, idx)
'	End If
'	j.Release
'End Sub

Sub ParsajDetaljeLinije2(stranica As String, ide As Int, idx As Int)
	Log("test2 -> ParsajDetaljeLinije2")
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

	Log(ajdi.IndexOf(ide))
	Log(ajdibl.Get(ajdi.IndexOf(ide)))
	Log(ajdinl.Get(ajdi.IndexOf(ide)))
	Log(ajdiLink.Get(ajdi.IndexOf(ide)))
	Log(zMapa)
	Log(zMapa.GetKeyAt(0))
'	Log(cMapa)
'	Dim bl As String = ajdibl.Get(ajdi.IndexOf(ide))
	Log("imgVozilo" & idx)
	Log("lblBrojLinije" & idx)
	Log("lblPolazisteOdrediste" & idx)
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