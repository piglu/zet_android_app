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

'Always extend Preference Activities from this Class!
'#Extends: de.amberhome.preferences.AppCompatPreferenceActivity

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private awake As PhoneWakeState
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
'	Private ToolBar As ACToolBarDark
'	Private PView As PreferenceView
'	Private AC As AppCompat
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	'Activity.LoadLayout("Layout1")
	Activity.LoadLayout("postavke")

'	ToolBar.Color = AC.GetThemeAttribute("colorPrimary")
'	Dim AB As ACActionBar
'	AB.Initialize
'	AB.ShowUpIndicator = True
'	AB.HomeVisible = True
'	ToolBar.InitMenuListener
End Sub

Sub Activity_Resume
	Dim ph As Phone

	ph.SetScreenOrientation(1)

	If Main.Manager.GetBoolean("check1") Then
		awake.KeepAlive(True)
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

'Sub Activity_ActionBarHomeClick
'	Activity.Finish
'End Sub
'
'Sub ToolBar_NavigationItemClick
'	Activity.Finish
'End Sub

Sub PView_Ready (PrefsView As PreferenceView)
	Dim cat1 As PreferenceCategory
	cat1 = PrefsView.AddCategory("", "", "Postavke ekrana")
	cat1.AddCheckBoxPreference("", "check1", "Čuvar ekrana", "Ekran uvijek upaljen", "Ekran se gasi", False)

	Dim cat2 As PreferenceCategory
	cat2 = PrefsView.AddCategory("", "", "Prijavljene lokacije")

'	PrefsView.AddCheckBoxPreference("", "dcheck1", "Prikaz zadnjih lokacija kontrola", "Uključena opcija nudi upis broja prikaza lokacija na karti", "Nema prikaza lokacija na karti", False)
	cat2.AddCheckBoxPreference("", "dcheck1", "Prikaz zadnjih lokacija kontrola", "Uključena opcija nudi upis broja prikaza lokacija na karti", "Nema prikaza lokacija na karti", False)
	Dim etp As EditTextPreference
	etp = cat2.AddEditTextPreference("Edit1", "edittext1", "Broja lokacija na karti", "", "3")
	etp.Dependency = "dcheck1"

	cat2.AddCheckBoxPreference("", "dcheck2", "Prikaz zadnjih lokacija zastoja", "Uključena opcija nudi upis broja prikaza lokacija na karti", "Nema prikaza lokacija na karti", False)
	Dim etp As EditTextPreference
	etp = cat2.AddEditTextPreference("Edit2", "edittext2", "Broja lokacija na karti", "", "3")
	etp.Dependency = "dcheck2"

	cat2.AddCheckBoxPreference("", "dcheck3", "Prikaz zadnjih lokacija kašnjenja", "Uključena opcija nudi upis broja prikaza lokacija na karti", "Nema prikaza lokacija na karti", False)
	Dim etp As EditTextPreference
	etp = cat2.AddEditTextPreference("Edit3", "edittext3", "Broja lokacija na karti", "", "3")
	etp.Dependency = "dcheck3"
End Sub

Sub Edit1_PreferenceChanged (Preference As Preference, NewValue As Object)
	Log("Preference Changed")
	Preference.Summary = NewValue
End Sub

'The EditTextPreference object has a EditTextCreated event. This is called when the EditText object is
'created so you can modify some settings. Here we set the InputType to only numbers. 
Sub Edit1_EditTextCreated (Edit As EditText)
	Edit.InputType = Edit.INPUT_TYPE_NUMBERS
End Sub

Sub Edit2_PreferenceChanged (Preference As Preference, NewValue As Object)
	Log("Preference Changed")
	Preference.Summary = NewValue
End Sub

'The EditTextPreference object has a EditTextCreated event. This is called when the EditText object is
'created so you can modify some settings. Here we set the InputType to only numbers. 
Sub Edit2_EditTextCreated (Edit As EditText)
	Edit.InputType = Edit.INPUT_TYPE_NUMBERS
End Sub

Sub Edit3_PreferenceChanged (Preference As Preference, NewValue As Object)
	Log("Preference Changed")
	Preference.Summary = NewValue
End Sub

'The EditTextPreference object has a EditTextCreated event. This is called when the EditText object is
'created so you can modify some settings. Here we set the InputType to only numbers. 
Sub Edit3_EditTextCreated (Edit As EditText)
	Edit.InputType = Edit.INPUT_TYPE_NUMBERS
End Sub
