B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: true
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private awake As PhoneWakeState
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private clvF As CustomListView
	Private btnFavorit As Button
	Private lblBrojLinije As B4XView
	Private lblPolazisteOdrediste As B4XView
	Private btnDetalj As Button
	Private imgVozilo As ImageView
	Private btnAddToWidget As Button
	Private ukupnoZaWidget As Int = 0
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("favoriti")

	DodajStavke
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

#Region clv
Sub DodajStavke
	Dim img2 As Bitmap = LoadBitmapResize(File.DirAssets, "detalj.png", 40dip, 40dip, True)

	Dim Cursor1 As Cursor
	Cursor1 = Starter.upit.ExecQuery("SELECT id, tip, brojLinije, nazivLinije, dnevna, favorit, widget FROM linije WHERE favorit = 2 ORDER by brojLinije")
	For i = 0 To Cursor1.RowCount - 1
		Cursor1.Position = i
		If Cursor1.GetInt("tip") = 1 And Cursor1.GetInt("dnevna") = 1 Then
			Starter.nocna = False
			Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			clvF.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije"), img1, img2, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"),  Cursor1.GetInt("widget"), clvF.AsView.Width, 84dip), "")
		else if Cursor1.GetInt("tip") = 1 And Cursor1.GetInt("dnevna") = 2 Then
			Starter.nocna = True
			Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			clvF.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije") & "N", img1, img2, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"),  Cursor1.GetInt("widget"), clvF.AsView.Width, 84dip), "")
		Else if Cursor1.GetInt("tip") = 2 And Cursor1.GetInt("dnevna") = 1 Then
			Starter.nocna = False
			Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			clvF.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije"), img1, img2, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"),  Cursor1.GetInt("widget"), clvF.AsView.Width, 84dip), "")
		Else if Cursor1.GetInt("tip") = 2 And Cursor1.GetInt("dnevna") = 2 Then
			Starter.nocna = True
			Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			clvF.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije") & "N", img1, img2, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"), Cursor1.GetInt("widget"), clvF.AsView.Width, 84dip), "")
		End If
	Next
	Cursor1.Close
End Sub

'Sub clv_ItemClick (Index As Int, Value As Object)
'	Log(Index)
'End Sub

Sub CreateListItem(rb As Int, brLinije As String, slikaAutobusaILITramvaja As Bitmap, slikaDetalj As Bitmap, trasaLinije As String, fav1 As Int, widget1 As Int, Width As Int, Height As Int) As Panel
	Dim p As Panel

	p.Initialize("")
	p.SetLayout(0, 0, Width, Height)
	p.LoadLayout("clv_stavka_f")
	p.Color = Colors.white

	imgVozilo.Bitmap = slikaAutobusaILITramvaja
	lblBrojLinije.Text = brLinije' & "/" & rb'.Replace(" - ", " smjer ")
	btnDetalj.SetBackgroundImage(slikaDetalj)
	btnFavorit.Tag = rb
	trasaLinije = trasaLinije.Replace(" - ", " smjer ")
	lblPolazisteOdrediste.Text = trasaLinije

	If fav1 = 1 Then
		Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorit_oduzmi.png", 40dip, 40dip, True)
		lblPolazisteOdrediste.Color = Colors.white
	Else
		Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorite_dodaj.png", 40dip, 40dip, True)
		lblPolazisteOdrediste.Color = Colors.Green
	End If
	btnFavorit.SetBackgroundImage(bmpFavorit)

	If widget1 = 1 Then
		Dim bmpWidget As Bitmap = LoadBitmapResize(File.DirAssets, "widget_makni.png", 40dip, 40dip, True)
	Else
		Dim bmpWidget As Bitmap = LoadBitmapResize(File.DirAssets, "widget_umetni.png", 40dip, 40dip, True)
	End If
	Log("prije btnAddToWidget")
	btnAddToWidget.SetBackgroundImage(bmpWidget)
	Log("poslije btnAddToWidget")

	Dim cd As ColorDrawable
	cd.Initialize(Colors.Black, 10dip)
	p.Background = cd

	Return p
End Sub
#End Region

#Region stavka
Sub btnDetalj_Click
	Dim index As Int = clvF.GetItemFromView(Sender)
	Dim pnl As B4XView = clvF.GetPanel(index)
	Dim lblN As B4XView = pnl.GetView(2)
	Dim btn As Button = pnl.getview(3)
	Dim lblB As B4XView = pnl.GetView(4)

	Starter.nazivLinije = lblN.Text.Replace(CRLF & "smjer" & CRLF, " - ")'lblB.Text & " - " & lblN.Text
	Starter.indeks = btn.Tag'index
	Starter.brojLinije = lblB.Text

	StartActivity(detalj)
End Sub

Sub btnFavorit_Click
	Dim index As Int = clvF.GetItemFromView(Sender)
	Dim pnl As B4XView = clvF.GetPanel(index)
	Dim btn As Button = pnl.GetView(3)
	Dim lblN As B4XView = pnl.GetView(2)
	Dim nS As String = lblN.Text

	Dim tp As VoziloData = clvF.GetValue(index)
	Dim t1, d1 As Int
	t1 = tp.t
	d1 = tp.d
	nS = nS.Replace(" smjer ", " - ")
	Dim Cursor1 As Cursor
	Cursor1 = Starter.upit.ExecQuery($"SELECT id, favorit, brojLinije, nazivLinije FROM linije WHERE tip = ${t1} AND dnevna = ${d1} AND id = ${btn.Tag}"$)
	For i = 0 To Cursor1.RowCount - 1
		Cursor1.Position = i
		Log(Cursor1.GetInt("brojLinije"))
		Log(Cursor1.GetString("nazivLinije"))
		Dim favorit As Int = Cursor1.GetInt("favorit")
		If favorit = 1 Then	' nije favorit
			Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorite_dodaj.png", 40dip, 40dip, True)
			lblN.Color = Colors.Green
			Starter.upit.ExecNonQuery($"UPDATE linije SET favorit = 2 WHERE id = ${btn.Tag}"$)
		Else
			Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorit_oduzmi.png", 40dip, 40dip, True)
			lblN.Color = Colors.white
			Starter.upit.ExecNonQuery($"UPDATE linije SET favorit = 1 WHERE id = ${btn.Tag}"$)
		End If
	Next
	Cursor1.Close
	btn.SetBackgroundImage(bmpFavorit)
End Sub

Sub btnAddToWidget_Click
	Dim index As Int = clvF.GetItemFromView(Sender)
	Dim pnl As B4XView = clvF.GetPanel(index)
	Dim btn As Button = pnl.GetView(5)
	
	Dim tp As VoziloData = clvF.GetValue(index)
	Dim t1, d1 As Int
	t1 = tp.t
	d1 = tp.d
	Dim Cursor1 As Cursor
	Cursor1 = Starter.upit.ExecQuery($"SELECT id, widget, brojLinije, nazivLinije FROM linije WHERE tip = ${t1} AND dnevna = ${d1} AND id = ${btn.Tag}"$)
	For i = 0 To Cursor1.RowCount - 1
		Cursor1.Position = i
		Dim w1 As Int = Cursor1.GetInt("widget")
		If w1 = 1 Then	' nije favorit
			Dim bmpWidget As Bitmap = LoadBitmapResize(File.DirAssets, "widget_umetni.png", 40dip, 40dip, True)
			Starter.upit.ExecNonQuery($"UPDATE linije SET widget = 2 WHERE id = ${btn.Tag}"$)
			ukupnoZaWidget = ukupnoZaWidget + 1
			If ukupnoZaWidget > 5 Then
				Msgbox("Widget podržava samo 5 linija!", "Info")
			End If
		Else
			Dim bmpWidget As Bitmap = LoadBitmapResize(File.DirAssets, "widget_makni.png", 40dip, 40dip, True)
			Starter.upit.ExecNonQuery($"UPDATE linije SET widget = 1 WHERE id = ${btn.Tag}"$)
			ukupnoZaWidget = ukupnoZaWidget - 1
		End If
	Next
	Cursor1.Close
	btn.SetBackgroundImage(bmpWidget)
End Sub
#End Region
