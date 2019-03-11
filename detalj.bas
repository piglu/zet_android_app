B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.3
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public linkZaDetaljPoStanicama As String
	Public ikona As Bitmap
	Public idLinije As Int
	Public pos As Int
	Public timer1 As Timer
	Private awake As PhoneWakeState
'	Public korZeliGPS As Boolean = False
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private imgLinija As ImageView
	Private lblLinija As B4XView
	Dim vozniRed As List
	Private clvD As CustomListView
	Private lblV As Label
	Private lblP As Label
	Private lblO As Label
	Private Panel1 As Panel
	Dim okr1, okr2, lnk1, lnk2, polaziste1, polaziste2, odrediste1, odrediste2 As List
	Dim okretiste As Boolean' = True
	Private ImageView1 As ImageView
	Private lblBr As Label
End Sub

#Region aktivnost
Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("detalj")

	vozniRed.Initialize
	If Not(Starter.nocna) Then
		timer1.Initialize("timer1", 1000)
	End If

	lblBr.Text = Starter.brojLinije
	lblLinija.Text = Starter.nazivLinije

	ProvjeraDatumaNaDatoteci
End Sub

Sub Activity_Resume
	Dim ph As Phone

	ph.SetScreenOrientation(1)

	If Main.manager.GetBoolean("check1") Then
		awake.KeepAlive(True)
	End If

	If Not(Starter.nocna) Then
		timer1.Enabled = True
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	Log("detalj -> UserClosed: " & UserClosed)
	awake.ReleaseKeepAlive
	If Not(Starter.nocna) Then
		timer1.Enabled = False
	End If
End Sub
#End Region

Sub timer1_Tick
	Dim panel As B4XView = clvD.GetPanel(pos)
	Dim iv As B4XView = panel.GetView(0) 'assuming that the ImageView is child number 1
	iv.SetVisibleAnimated(500, False)
	iv.SetVisibleAnimated(500, True)
End Sub

#Region DLs
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
		Msgbox("Nema voznog reda za " & DateTime.Date(DateTime.Now) & " linije broj " & Starter.brojLinije, "Informacija")
		Activity.Finish
	End If

	j.Release
End Sub
#End Region

#Region parseri
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

	IspuniTablicu
End Sub

Sub IspuniTablicu
	Dim satMin As String = DateTime.Time(DateTime.Now)
	satMin = satMin.SubString2(0, satMin.LastIndexOf(":"))
	Dim idxLinijeB As Boolean = False

	Dim ss As String = Starter.nazivLinije
	Log("detalj -> IspuniTablicu -> starter.nazivLinije -> " & ss)
	Dim ss1, ss2 As String
	ss1 = ss.SubString2(0, ss.IndexOf(" -"))
	ss2 = ss.SubString2(ss.IndexOf(" -") + 2, ss.Length)
	Log(ss1)
	Log(ss2)
	If okretiste Then
		For i = 0 To okr1.Size - 1
'			lblLinija.Text = polaziste1.Get(0) & " - " & odrediste1.Get(0)
			Dim ss As String = okr1.Get(i)
			ss = ss.SubString2(0, ss.LastIndexOf(":"))
			If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
				pos = i
				idxLinijeB = True
			End If
			clvD.Add(CreateItem(okr1.Get(i), polaziste1.Get(i), odrediste1.Get(i), clvD.AsView.Width, 62dip), "")
		Next
	Else
		For i = 0 To okr2.Size - 1
'			lblLinija.Text = polaziste2.Get(0) & " - " & odrediste2.Get(0)
			Dim ss As String = okr2.Get(i)
			ss = ss.SubString2(0, ss.LastIndexOf(":"))
			If ss.CompareTo(satMin) > 0 And idxLinijeB = False Then	' nemamo još indeks koji treba označiti
				pos = i
				idxLinijeB = True
			End If
			clvD.Add(CreateItem(okr2.Get(i), polaziste2.Get(i), odrediste2.Get(i), clvD.AsView.Width, 62dip), "")
		Next
	End If

	'
	'
	'
	'
	' dodati obrnuti naziv linije u naslov linije (lblLinija.Text) !!!!!!!
	'
	'
	'
	'
	ProgressDialogHide

	Sleep(100)
	clvD.ScrollToItem(pos)
	If Not(Starter.nocna) Then
		timer1.Enabled = True
	End If
End Sub

Sub CreateItem(okret As String, polaz As String, odred As String, Width As Int, Height As Int) As Panel
	Dim p As Panel

	p.Initialize("")
	p.SetLayout(0, 0, Width, Height)
	p.LoadLayout("clv_stavkad")
	p.Color = Colors.white

	lblV.Text = okret
	lblP.Text = polaz
	lblO.Text = odred

	Return p
End Sub

'Sub AnimatedArrow(index As Int, From As Int, ToDegree As Int)
'	Panel1 = clvD.GetPanel(index).GetView(0) 'Panel1 is the first item
'	Dim iv As B4XView = Panel1.GetView(1) 'ImageView1 is the second item
'	iv.SetRotationAnimated(0, From)
'	iv.SetRotationAnimated(clvD.AnimationDuration, ToDegree)
'End Sub

Sub clvD_ItemClick (Index As Int, Value As Object)
	If Starter.brojLinije > 99 Then
		ikona = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
	Else
		ikona = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
	End If
	If okretiste Then
		Log(lnk1.Get(Index))
		linkZaDetaljPoStanicama = lnk1.Get(Index)
	Else
		Log(lnk2.Get(Index))
		linkZaDetaljPoStanicama = lnk2.Get(Index)
	End If

	Starter.nazivLinije = lblLinija.Text

	StartActivity(detalj_stanice)
End Sub
#End Region

Sub lblLinija_Click
	clvD.Clear
	If okretiste Then
		okretiste = False
		IspuniTablicu
	Else
		okretiste = True
		IspuniTablicu
	End If
End Sub

Sub ProvjeraDatumaNaDatoteci
	File.Delete(Starter.SourceFolder, Starter.indeks & "lnk1")
	If File.Exists(Starter.SourceFolder, Starter.indeks & "lnk1") Then
		DateTime.DateFormat = "dd"'.MM.yyyy"
		Log(DateTime.Date(File.LastModified(Starter.SourceFolder, Starter.indeks & "lnk1")))
'		Dim datumDat As Long = File.LastModified(Starter.SourceFolder, Starter.indeks & "lnk1")
'		Dim trenutniDatum As Long = DateTime.Now
		Log(DateTime.Date(DateTime.Now))
		Dim danNaDatoteciKaoBroj As Int = DateTime.Date(File.LastModified(Starter.SourceFolder, Starter.indeks & "lnk1"))
		Dim danasnjiDanKaoBroj As Int = DateTime.Date(DateTime.Now)
		Dim razlika As Int = danasnjiDanKaoBroj - danNaDatoteciKaoBroj
'		Dim pp As Period = DateUtils.PeriodBetweenInDays(trenutniDatum, datumDat)
'		Log(pp.Hours)
'		Log(pp.Days)
'		If pp.Days = 0 Then
		If razlika = 0 Then
			Log("današnji datum datoteke!")
			UcitajListe
			Dim brL As Int = Starter.brojLinije
			If brL < 99 Then	' tramvaj
				imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			Else	' bus
				imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			End If
			IspuniTablicu
		Else
			' ako je datoteka sa podacima o današnjem voznom redu od jučer (ili od prije u prošlosti), preuzmi novu sa neta
			Log("datoteka je starija!")
			PripremiDL
		End If
	Else
		' ako ne postoji datoteka sa podacima o današnjem voznom redu, preuzmi ju sa neta
		PripremiDL
	End If
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

Sub UcitajListe
	lnk1 = File.ReadList(Starter.SourceFolder, Starter.indeks & "lnk1")
'	Log(lnk1)
	lnk2 = File.ReadList(Starter.SourceFolder, Starter.indeks & "lnk2")
'	Log(lnk2)
	okr1 = File.ReadList(Starter.SourceFolder, Starter.indeks & "okr1")
	okr2 = File.ReadList(Starter.SourceFolder, Starter.indeks & "okr2")
	polaziste1 = File.ReadList(Starter.SourceFolder, Starter.indeks & "p1")
	polaziste2 = File.ReadList(Starter.SourceFolder, Starter.indeks & "p2")
	odrediste1 = File.ReadList(Starter.SourceFolder, Starter.indeks & "o1")
	odrediste2 = File.ReadList(Starter.SourceFolder, Starter.indeks & "o2")
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
			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
			lblLinija.Text = Starter.nazivLinije
		else if Cursor1.GetInt("tip") = 1 And Cursor1.GetInt("dnevna") = 2 Then
			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
			lblLinija.Text = Starter.nazivLinije
		Else if Cursor1.GetInt("tip") = 2 And Cursor1.GetInt("dnevna") = 1 Then
			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
			lblLinija.Text = Starter.nazivLinije
		Else if Cursor1.GetInt("tip") = 2 And Cursor1.GetInt("dnevna") = 2 Then
			imgLinija.Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			Dim link As String = Cursor1.GetString("link")
			lblLinija.Text = Starter.nazivLinije
		End If
		idLinije = Cursor1.GetInt("id")
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
		If pdfAppsList.size>0 Then
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