B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.8
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

' TODO
' ----
'
' u fav servis dodati sličan kod slijedećem kodu: (d/l liste voznih redova za max. 6 linija koje su u fav widgetu)
'Sub Activity_Create(FirstTime As Boolean)
'	DownloadMany(Array("http://www.google.com", "http://duckduckgo.com", "http://bing.com"))
'End Sub
'
'Sub DownloadMany (links As List)
'	For Each link As String In links
'		Dim j As HttpJob
'		j.Initialize("", Me) 'name is empty as it is no longer needed
'		j.Download(link)
'		Wait For (j) JobDone(j As HttpJob)
'		If j.Success Then
'			Log("Current link: " & link)
'			Log(j.GetString)
'		End If
'		j.Release
'	Next
'End Sub
' u widget dodati 2 gumba čiji tekst je "1" i "2"
' 1 je vozni red za polazište -> odredište
' 2 je vozni red za odredište -> polazište