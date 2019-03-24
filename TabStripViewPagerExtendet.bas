B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'***************TabStripViewPagerExtendet**********************
'Author: Alexander Stolte
'Createt on 12.01.2018
'For the TabStripViewPager 
'https://www.b4x.com/android/forum/threads/tabstripviewpager-better-viewpager.63975/#content

'Version 1.01
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

'change the color of the Indicator
Public Sub IndicatorColor(tabstrip As TabStrip, color As Int)
	
	Dim jo As JavaObject = tabstrip
	jo.GetFieldJO("tabStrip").RunMethod("setIndicatorColor", Array(color))
	
End Sub

'change the Indicator Height
Public Sub IndicatorHeight(tabstrip As TabStrip, height As Int)
	
	Dim jo As JavaObject = tabstrip
	jo.GetFieldJO("tabStrip").RunMethod("setIndicatorHeight", Array(height))
	
End Sub

'change the Underline Color
Public Sub UnderlineColor(tabstrip As TabStrip, color As Int)
	
	Dim jo As JavaObject = tabstrip
	jo.GetFieldJO("tabStrip").RunMethod("setUnderlineColor", Array(color))
	
End Sub

'change the Underline Height
Public Sub UnderlineHeight(tabstrip As TabStrip, height As Int)
	
	Dim jo As JavaObject = tabstrip
	jo.GetFieldJO("tabStrip").RunMethod("setUnderlineHeight", Array(height))
	
End Sub

'change the Divider Color
Public Sub DividerColor(tabstrip As TabStrip, color As Int)
	
	Dim jo As JavaObject = tabstrip
	jo.GetFieldJO("tabStrip").RunMethod("setDividerColor", Array(color))
	
End Sub

'Get all Tabs in the Tabstrip and put it to a list
Public Sub GetAllTabLabels (tabstrip As TabStrip) As List
	Dim jo As JavaObject = tabstrip
	Dim r As Reflector
	r.Target = jo.GetField("tabStrip")
	Dim tc As Panel = r.GetField("tabsContainer")
	Dim res As List
	res.Initialize
	For Each v As View In tc
		If v Is Label Then res.Add(v)
	Next
	Return res
   
End Sub

'Text Color of the Tab
'Example code:
'<code>Dim tse as TabStripExtendet
'tse.Initialize
'InactiveTabTextColor(TabStrip1,Colors.Blue,Colors.Red,TabStrip1.CurrentPage)</code>
Public Sub TabTextColor(tabstrip As TabStrip, colorSelected As Int , colorInactive As Int, Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			lbl.TextColor = colorSelected
			Else	
			lbl.TextColor = colorInactive
		End If
		i = i + 1
	Next
	
End Sub

'Tab Background-Color
'Example code:
'<code>Dim tse as TabStripExtendet
'tse.Initialize
'TabBackgroundColor(TabStrip1,Colors.Blue,Colors.Red,TabStrip1.CurrentPage)</code>
Public Sub TabBackgroundColor(tabstrip As TabStrip, colorSelected As Int , colorInactive As Int, Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			lbl.Color = colorSelected
		Else
			lbl.Color = colorInactive
		End If
		i = i + 1
	Next
	
End Sub

'change the text of the given Tab
Public Sub ChangeTabText(tabstrip As TabStrip, text As String, Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Text = text

		End If
		i = i + 1
	Next
	
End Sub

'Possible is:
'NONE
'START
'MIDDLE
'END
'<code>ChangeTabTextEllipsize(Tabstrip1,"END",0</code>
Public Sub ChangeTabTextEllipsize(tabstrip As TabStrip, Ellipsize As String, Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Ellipsize = Ellipsize

		End If
		i = i + 1
	Next
	
End Sub

'Sets different typefaces for Tabs
'If TypeFaces() is an array with only one TypeFace this one is applied to all columns.
'This method must be called before filling the table
'Example code:
'<code>Dim tf() As TypeFace
'tf = Array As Typeface(Typeface.DEFAULT, Typeface.DEFAULT_BOLD, , Typeface.DEFAULT, Typeface.DEFAULT_BOLD)
'Table1.SetTypeFaces(tf)</code>
Public Sub SetTypeFaces(tabstrip As TabStrip,TypeFaces As Typeface,Position As Int)
	
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Typeface = TypeFaces

		End If
		i = i + 1
	Next
	
	
End Sub

'Set the Gravity of a Text in a specify Tab
Public Sub SetTextGravity(tabstrip As TabStrip,gravitys As Int,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Gravity = gravitys

		End If
		i = i + 1
	Next
	
End Sub

'Set the Height of a Tab in a specify Tab
Public Sub SetTabHeight(tabstrip As TabStrip,height As Int,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Height = height

		End If
		i = i + 1
	Next
	
End Sub

'Set the Left of a Tab
Public Sub SetTabLeft(tabstrip As TabStrip,left As Int,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Left = left

		End If
		i = i + 1
	Next
	
End Sub

'Set the Padding of a Tab
Public Sub SetTabPadding(tabstrip As TabStrip,padding() As Int,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Padding = padding

		End If
		i = i + 1
	Next
	
End Sub

Public Sub SetTabSingleline(tabstrip As TabStrip,singleline As Boolean,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.SingleLine = singleline

		End If
		i = i + 1
	Next
	
End Sub

'Here you can set a Tag of a specify Tab
Public Sub SetTabTag(tabstrip As TabStrip,Tag As Object,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Tag = Tag

		End If
		i = i + 1
	Next
	
End Sub

'Get the Tag of a Tag
Public Sub GetTabTag(tabstrip As TabStrip, position As Int) As Object

	Dim tag As Object
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = position Then
			
			lbl.Tag = tag

		End If
		i = i + 1
	Next

	Return tag
End Sub

'Set the Tab Top
Public Sub TabTop(tabstrip As TabStrip,Top As Int,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Top = Top

		End If
		i = i + 1
	Next
	
	
End Sub

'Set the Tab width
Public Sub TabWidth(tabstrip As TabStrip,Width As Int,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Width = Width

		End If
		i = i + 1
	Next
	
End Sub

'Make a Tab Visible or not
Public Sub TabVisible(tabstrip As TabStrip,Visible As Boolean,Position As Int)
	
	Dim i As Int
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		If i = Position Then
			
			lbl.Visible = Visible

		End If
		i = i + 1
	Next
	
End Sub


Public Sub InsertPage (tabstrip As TabStrip, Index As Int, Page As Panel, Title As String)
	Dim jo As JavaObject = tabstrip
	jo.GetFieldJO("pages").RunMethod("add", Array(Index, Page))
	jo.GetFieldJO("titles").RunMethod("add", Array(Index, Title))
	RefreshTabStrip(tabstrip)
End Sub

'Return the removed page
Public Sub RemovePage (tabstrip As TabStrip, Index As Int) As Panel
	If tabstrip.CurrentPage >= Index Then tabstrip.ScrollTo(0, False)
	Dim jo As JavaObject = tabstrip
	Dim p As Panel = jo.GetFieldJO("pages").RunMethod("remove", Array(Index))
	jo.GetFieldJO("titles").RunMethod("remove", Array(Index))
	RefreshTabStrip (tabstrip)
	Return p
End Sub

Public Sub RefreshTabStrip(tabstrip As TabStrip)
	Dim jo As JavaObject = tabstrip
	jo.RunMethod("resetAdapter", Null)
	jo.GetFieldJO("vp").RunMethodJO("getAdapter", Null).RunMethod("notifyDataSetChanged", Null)
	jo.GetFieldJO("tabStrip").RunMethod("notifyDataSetChanged", Null)
End Sub


Public Sub CenterAllTabs(tabstrip As TabStrip, tabstripwidth As Int)
	
	For Each lbl As Label In GetAllTabLabels(tabstrip)
		lbl.Width = Round(tabstripwidth/GetAllTabLabels(tabstrip).Size) 
	Next
	
End Sub
