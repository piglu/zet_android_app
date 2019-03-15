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
'	Dim okr1, okr2, lnk1, lnk2, polaziste1, polaziste2, odrediste1, odrediste2 As List
	Dim lnk1, lnk2, okr1, okr2, polaziste1, polaziste2, odrediste1, odrediste2 As List
	Dim linkovi As List
	Dim rb As Int
	Dim pos As Int
	Dim detaljiLinije As List
	Dim cMapa As Map
	Dim zMapa As Map
	Dim okretiste1 As Boolean = True
	Dim okretiste2 As Boolean = True
	Dim okretiste3 As Boolean = True
	Dim okretiste4 As Boolean = True
	Dim okretiste5 As Boolean = True
	Dim okretiste6 As Boolean = True
	Private imgVozilo1 As ImageView
	Private lblBrojLinije1 As Label
	Private lblPolazisteOdrediste1 As Label
	Private lblPolazisteOdrediste2 As Label
	Private lblBrojLinije2 As Label
	Private imgVozilo2 As ImageView
	Private lblPolazisteOdrediste3 As Label
	Private lblBrojLinije3 As Label
	Private imgVozilo3 As ImageView
	Private lblPolazisteOdrediste4 As Label
	Private lblBrojLinije4 As Label
	Private imgVozilo4 As ImageView
	Private imgVozilo5 As ImageView
	Private lblBrojLinije5 As Label
	Private lblPolazisteOdrediste5 As Label
	Private lblPolazisteOdrediste6 As Label
	Private imgVozilo6 As ImageView
	Private lblBrojLinije6 As Label
	Private Button1 As Button
	Private Button2 As Button
	Private Button3 As Button
	Private Button4 As Button
	Private Button5 As Button
	Private Button6 As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("test")
	ajdi.Initialize
	ajdiLink.Initialize
	ajdibl.Initialize
	ajdinl.Initialize

	linkovi.Initialize

	DohvatiSveLinijeZaWidget
End Sub

Sub DohvatiSveLinijeZaWidget
	Log("DohvatiSveLinijeZaWidget iz rv_RequestUpdate")
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

'	For i = 0 To ajdi.Size - 1
'		Log(ajdi.Get(i))
	Dim j As Int = 0
	For Each link As String In ajdiLink
		ProvjeraDatumaNaDatoteci(ajdi.Get(j), link, ajdinl.Get(j))
		j = j + 1
	Next
	DL_VozniRedDetalj2(linkovi)

'		Sleep(5000)
'		Log(ajdibl.Get(i))
'		Log(ajdinl.Get(i))
'		Log(ajdiLink.Get(i))
'	Next
End Sub

Sub ProvjeraDatumaNaDatoteci(id As Int, link As String, nl As String)
'Sub ProvjeraDatumaNaDatoteci(link As String)
'	File.Delete(Starter.SourceFolder, id & "lnk1")
	If File.Exists(Starter.SourceFolder, id & "lnk1") Then
		DateTime.DateFormat = "dd"'.MM.yyyy"
'		Log(DateTime.Date(File.LastModified(Starter.SourceFolder, id & "lnk1")))
'		Log(DateTime.Date(DateTime.Now))
		Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, id & "lnk1"))
		Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
		Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
		If razlika = 0 Then
			Log("današnji datum datoteke, učitaj listu")
			UcitajListe(id)
			DohvatiIndeksZaDL(nl)
'			UbaciPodatkeWidget
		Else
			' ako je datoteka sa podacima o današnjem voznom redu od jučer (ili od prije u prošlosti), preuzmi novu sa neta
			Log("datoteka je starija, preuzmi nove podatke sa neta")
			DateTime.DateFormat = "dd.MM.yyyy"
			DL_VozniRedTekuciDatum(id, link, DateTime.Date(DateTime.Now))
			DohvatiIndeksZaDL(nl)
'			UbaciPodatkeWidget
		End If
	Else
		' ako ne postoji datoteka sa podacima o današnjem voznom redu, preuzmi ju sa neta
		Log("ne postoji datoteka sa podacima o današnjem voznom redu, preuzmi nove podatke sa neta")
		DateTime.DateFormat = "dd.MM.yyyy"
		DL_VozniRedTekuciDatum(id, link, DateTime.Date(DateTime.Now))
		DohvatiIndeksZaDL(nl)
'		UbaciPodatkeWidget
	End If
End Sub

Sub DohvatiIndeksZaDL(nl As String)
	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
	Dim idxLinijeB As Boolean = False
'	Dim lnkTemp As String

	Dim ss As String = nl'Starter.nazivLinije
'	Log("test -> DohvatiIndeksZaDL -> starter.nazivLinije -> " & ss)
'	Dim ss1, ss2 As String
'	ss1 = ss.SubString2(0, ss.IndexOf(" -"))
'	ss2 = ss.SubString2(ss.IndexOf(" -") + 2, ss.Length)
'	Log(ss1)
'	Log(ss2)
	If okretiste1 Then
		For i = 0 To okr1.Size - 1
			Dim ss As String = okr1.Get(i)
			ss = ss.SubString2(0, ss.LastIndexOf(":"))
			If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
				pos = i
				idxLinijeB = True
			End If
'			clvD.Add(CreateItem(okr1.Get(i), polaziste1.Get(i), odrediste1.Get(i), clvD.AsView.Width, 62dip), "")
		Next
'		lblLinija.Text = ss1 & " - " & ss2
'		Log(pos)
'		Log(lnk1.Get(pos))
		linkovi.Add(lnk1.Get(pos))
'		lnkTemp = lnk1.Get(pos)
	Else
		For i = 0 To okr2.Size - 1
			Dim ss As String = okr2.Get(i)
			ss = ss.SubString2(0, ss.LastIndexOf(":"))
			If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
				pos = i
				idxLinijeB = True
			End If
'			clvD.Add(CreateItem(okr2.Get(i), polaziste2.Get(i), odrediste2.Get(i), clvD.AsView.Width, 62dip), "")
		Next
'		lblLinija.Text = ss2 & " - " & ss1
'		Log(pos)
'		Log(lnk2.Get(pos))
		linkovi.Add(lnk2.Get(pos))
'		lnkTemp = lnk2.Get(pos)
	End If
	Log(linkovi)
End Sub

Sub DL_VozniRedDetalj2(lnks As List)'(lnk As String)
	For Each link As String In lnks
		Dim j As HttpJob
		j.Initialize("", Me) 'name is empty as it is no longer needed
		j.Download(link)
		Wait For (j) JobDone(j As HttpJob)
		If j.Success Then
			ParsajDetaljeLinije2(j.GetString)
'			Log("Current link: " & link)
'			Log(j.GetString)
		End If
		j.Release
	Next
'	Dim j As HttpJob
'	j.Initialize("", Me) 'name is empty as it is no longer needed
'	j.Download(lnk)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
''		Log(j.GetString)
'		ParsajDetaljeLinije2(j.GetString)
'	End If
'	j.Release
''	PrikaziDetaljeLinijeZaSat
End Sub

Sub ParsajDetaljeLinije2(strim As String)
	Dim matcher1 As Matcher

	cMapa.Initialize
	zMapa.Initialize
	detaljiLinije.Initialize

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

	Log(zMapa)
	Log(cMapa)
'	UbaciPodatkeWidget
End Sub

Sub UcitajListe(id As Int)
	lnk1 = File.ReadList(Starter.SourceFolder, id & "lnk1")
'	Log(lnk1)
	lnk2 = File.ReadList(Starter.SourceFolder, id & "lnk2")
'	Log(lnk2)
	okr1 = File.ReadList(Starter.SourceFolder, id & "okr1")
'	Log(okr1)
	okr2 = File.ReadList(Starter.SourceFolder, id & "okr2")
'	Log(okr2)
	polaziste1 = File.ReadList(Starter.SourceFolder, id & "p1")
	polaziste2 = File.ReadList(Starter.SourceFolder, id & "p2")
	odrediste1 = File.ReadList(Starter.SourceFolder, id & "o1")
	odrediste2 = File.ReadList(Starter.SourceFolder, id & "o2")
End Sub

Sub DL_VozniRedTekuciDatum(id As Int, lnk As String, datum As String)
'	ProgressDialogShow2("Preuzimam podatke...", False)

	Log(datum)
	Dim j As HttpJob
	j.Initialize("", Me) 'name is empty as it is no longer needed
'	DateTime.DateFormat = DateTime.DeviceDefaultDateFormat' "dd.MM.yyyy"
	Dim dat As Long
	dat = DateTime.DateParse(datum)
	DateTime.DateFormat = "yyyyMMdd"
	Dim s As String = lnk & "&datum=" & DateTime.Date(dat)
	j.Download(s) 'link
	Wait For (j) JobDone(j As HttpJob)
	If j.Success And j.getstring.Contains("<table class='table raspored table-striped'>") Then
		ParsajVozniRed(id, j.GetString)
	Else
		DateTime.DateFormat = "dd.MM.yyyy"
		ToastMessageShow("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & Starter.brojLinije, False)
	End If

	j.Release
End Sub

Sub ParsajVozniRed(id As Int, strim As String)
	Dim matcher1 As Matcher

	lnk1.Initialize
	lnk1.Initialize
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

	UsnimiListe(id)

'	UbaciPodatkeWidget
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

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub Button6_Click
	
End Sub

Sub Button5_Click
	
End Sub

Sub Button4_Click
	
End Sub

Sub Button3_Click
	
End Sub

Sub Button2_Click
	
End Sub

Sub Button1_Click
	
End Sub