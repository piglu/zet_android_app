﻿B4A=true
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
	Private xui As XUI
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
'	Private clvT As CustomListView
	Private clvMejn As CustomListView
	Private lblBrojLinije As Label
	Private lblPolazisteOdrediste As B4XView
	Private imgVozilo As ImageView
	Private btnFavorit As Button
	Private btnDetalj As Button
'	Private t1 As Int
	Private d1 As Int
	Private edtTrazi As EditText
'	Private btnIzbrisi As Button
	Private pojamTrazi As String
	Private btnAddToWidget As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("clv_trazi")
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

#Region trazi
Sub edtTrazi_EnterPressed
	pojamTrazi = ""
	pojamTrazi = edtTrazi.Text

	If pojamTrazi.Length > 0 Then
		TraziPojam
	Else
		Msgbox("Niste unijeli traženi pojam!", "Info")
	End If
	edtTrazi.Text = ""
End Sub

'Sub btnIzbrisi_Click
'	clvT.Clear
'	pojamTrazi = ""
'	edtTrazi.Text = ""
'End Sub
#End Region

Sub TraziPojam
	Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
	Dim img2 As Bitmap = LoadBitmapResize(File.DirAssets, "detalj.png", 40dip, 40dip, True)

	Dim imaTrazenogPojma As Boolean = False
	If IsNumber(pojamTrazi) Then
		Dim Cursor1 As Cursor
		Cursor1 = Starter.upit.ExecQuery($"SELECT id, tip, brojLinije, nazivLinije, dnevna, favorit, widget FROM linije WHERE brojLinije = ${pojamTrazi}"$)
		For i = 0 To Cursor1.RowCount - 1
			imaTrazenogPojma = True
			Cursor1.Position = i
			
			Dim tt As Int = Cursor1.GetInt("dnevna")
			If Cursor1.GetInt("tip") = 1 And Cursor1.GetInt("dnevna") = 1 Or Cursor1.GetInt("dnevna") = 2 Then
				Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "bus1.png", 60dip, 60dip, True)
			Else
				Dim img1 As Bitmap = LoadBitmapResize(File.DirAssets, "tram1.png", 60dip, 60dip, True)
			End If
			If Cursor1.GetInt("widget") = 1 Then
				Dim img3 As Bitmap = LoadBitmapResize(File.DirAssets, "widget_makni.png", 40dip, 40dip, True)
			Else
				Dim img3 As Bitmap = LoadBitmapResize(File.DirAssets, "widget_umetni.png", 40dip, 40dip, True)
			End If
			Dim tp As VoziloData
			tp.Initialize
			tp.id = Cursor1.GetInt("id")
			If tt = 1 Then
				tp.brl = Cursor1.GetInt("brojLinije")
			Else
				tp.brl = Cursor1.GetInt("brojLinije") & "N"
			End If
			tp.i1 = img1
			tp.i2 = img2
			tp.i3 = img3
			tp.nal = Cursor1.GetString("nazivLinije")
			tp.f = Cursor1.GetInt("favorit")
			tp.t = Cursor1.GetInt("tip")
			tp.d = Cursor1.GetInt("dnevna")
			tp.wdg = Cursor1.GetInt("widget")
			Dim p As B4XView = xui.CreatePanel("")
			p.SetColorAndBorder(Colors.Transparent, 2dip, Colors.Black, 10dip)
			p.SetLayoutAnimated(0, 0, 0, clvMejn.AsView.Width, 92dip)
			clvMejn.Add(p, tp)

'			t1 = Cursor1.GetInt("tip")
'			d1 = Cursor1.GetInt("dnevna")
'			If d1 = 1 Then
'				clvT.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije"), img1, img2, img3, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"), clvT.AsView.Width, 88dip), "")
'			Else
'				clvT.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije") & "N", img1, img2, img3, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"), clvT.AsView.Width, 88dip), "")
'			End If
		Next
	Else
		Dim Cursor1 As Cursor
		Cursor1 = Starter.upit.ExecQuery($"SELECT id, tip, brojLinije, nazivLinije, dnevna, favorit FROM linije WHERE nazivLinije LIKE '%${pojamTrazi}%'"$)
		For i = 0 To Cursor1.RowCount - 1
			imaTrazenogPojma = True
			Cursor1.Position = i
'			t1 = Cursor1.GetInt("tip")
			d1 = Cursor1.GetInt("dnevna")
			If d1 = 1 Then
'				clvT.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije"), img1, img2, img3, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"), clvT.AsView.Width, 88dip), "")
			Else
'				clvT.Add(CreateListItem(Cursor1.GetInt("id"), Cursor1.GetInt("brojLinije") & "N", img1, img2, img3, Cursor1.GetString("nazivLinije"), Cursor1.GetInt("favorit"), clvT.AsView.Width, 88dip), "")
			End If
		Next
	End If

	If Not(imaTrazenogPojma) Then
		Msgbox("Nema traženog pojma!", "Info")
		Activity.Finish
	End If
End Sub

Sub clvMejn_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 20
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvMejn.Size - 1)
		Dim p As B4XView = clvMejn.GetPanel(i)
		If p.NumberOfViews = 0 Then
			Dim tp As VoziloData = clvMejn.GetValue(i)
			p.LoadLayout("clv_stavka")
			p.Color = Colors.White
			p.SetColorAndBorder(Colors.Transparent, 2dip, Colors.Black, 10dip)
			imgVozilo.Bitmap = tp.i1
			lblBrojLinije.Text = tp.brl
			btnDetalj.SetBackgroundImage(tp.i2)
			btnFavorit.Tag = tp.id
			btnDetalj.Tag = tp.id
			btnAddToWidget.Tag = tp.id
			Dim ss As String = tp.nal
			ss = ss.Replace(" - ", " smjer ")
			lblPolazisteOdrediste.Text = ss
			If tp.f = 1 Then
				Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorit_oduzmi.png", 40dip, 40dip, True)
				lblPolazisteOdrediste.Color = Colors.white
			Else
				Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorite_dodaj.png", 40dip, 40dip, True)
				lblPolazisteOdrediste.Color = Colors.Green
			End If
			btnFavorit.SetBackgroundImage(bmpFavorit)
			If tp.wdg = 1 Then
				Dim bmpWidget As Bitmap = LoadBitmapResize(File.DirAssets, "widget_makni.png", 40dip, 40dip, True)
			Else
				Dim bmpWidget As Bitmap = LoadBitmapResize(File.DirAssets, "widget_umetni.png", 40dip, 40dip, True)
			End If
			btnAddToWidget.SetBackgroundImage(bmpWidget)
		End If
	Next
End Sub

Sub CreateListItem(rb As Int, brLinije As String, slikaAutobusaILITramvaja As Bitmap, slikaDetalj As Bitmap, wdg As Bitmap, trasaLinije As String, fav1 As Int, Width As Int, Height As Int) As Panel
	Dim p As Panel

	p.Initialize("")
	p.SetLayout(0, 0, Width, Height)
	p.LoadLayout("clv_stavka")
	p.Color = Colors.white

	imgVozilo.Bitmap = slikaAutobusaILITramvaja
	lblBrojLinije.Text = brLinije
	lblPolazisteOdrediste.Text = trasaLinije
	btnFavorit.Tag = rb'brLinije
	btnDetalj.SetBackgroundImage(slikaDetalj)
	btnAddToWidget.SetBackgroundImage(wdg)

	If fav1 = 1 Then
		Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorit_oduzmi.png", 40dip, 40dip, True)
		lblPolazisteOdrediste.Color = Colors.white
	Else
		Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorite_dodaj.png", 40dip, 40dip, True)
		lblPolazisteOdrediste.Color = Colors.Green
	End If
	btnFavorit.SetBackgroundImage(bmpFavorit)

	Dim cd As ColorDrawable
	cd.Initialize(Colors.Black, 10dip)
	p.Background = cd

	Return p
End Sub

#Region stavka
Sub btnDetalj_Click
'	Dim index As Int = clvT.GetItemFromView(Sender)
'	Dim pnl As B4XView = clvT.GetPanel(index)
	Dim index As Int = clvMejn.GetItemFromView(Sender)
	Dim pnl As B4XView = clvMejn.GetPanel(index)
	Dim lblN As B4XView = pnl.GetView(2)
	Dim btn As Button = pnl.GetView(3)
	Dim lblB As B4XView = pnl.GetView(4)

	Starter.nazivLinije = lblN.Text.Replace(" smjer ", " - ")'lblB.Text & " - " & lblN.Text
	Starter.indeks = btn.Tag'index
	Starter.brojLinije = lblB.Text

	StartActivity(detalj)
End Sub

Sub btnFavorit_Click
	Dim index As Int = clvMejn.GetItemFromView(Sender)
	Dim pnl As B4XView = clvMejn.GetPanel(index)
	Dim btn As Button = pnl.GetView(3)
	Dim lblN As B4XView = pnl.GetView(2)
	Dim nS As String = lblN.Text
	
	nS = nS.Replace(" smjer ", " - ")
	Dim Cursor1 As Cursor
'	Cursor1 = Starter.upit.ExecQuery($"SELECT id, favorit, brojLinije, nazivLinije FROM linije WHERE tip = ${t1} AND dnevna = ${d1} AND id = ${btn.Tag}"$)
	Cursor1 = Starter.upit.ExecQuery($"SELECT id, favorit, brojLinije, nazivLinije FROM linije WHERE id = ${btn.Tag}"$)
	For i = 0 To Cursor1.RowCount - 1
		Cursor1.Position = i
		Log(Cursor1.GetInt("brojLinije"))
		Log(Cursor1.GetString("nazivLinije"))
		Dim favorit As Int = Cursor1.GetInt("favorit")
		If favorit = 1 Then	' nije favorit
			Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorite_dodaj.png", 40dip, 40dip, True)
			lblN.Color = Colors.Green
			Starter.upit.ExecNonQuery($"UPDATE linije SET favorit = ${2} WHERE id = ${btn.Tag}"$)
			btn.SetBackgroundImage(bmpFavorit)
		Else
			Dim bmpFavorit As Bitmap = LoadBitmapResize(File.DirAssets, "favorit_oduzmi.png", 40dip, 40dip, True)
			lblN.Color = Colors.white
			Starter.upit.ExecNonQuery($"UPDATE linije SET favorit = ${1} WHERE id = ${btn.Tag}"$)
			btn.SetBackgroundImage(bmpFavorit)
		End If
	Next
	Cursor1.Close
End Sub
#End Region
