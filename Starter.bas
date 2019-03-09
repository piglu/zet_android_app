B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
'	Dim linijeT, linijeTNoćne As List
'	Dim linijeTLinkovi, linijeTLinkoviNoćne As List
'	Dim linijeTBrojevi, linijeTBrojeviNoćne As List
'	Dim linijeA, linijeANoćne As List
'	Dim linijeALinkovi, linijeALinkoviNoćne As List
'	Dim linijeABrojevi, linijeABrojeviNoćne As List
'	Public iz As Int'As Boolean
	Public indeks As Int
	Public nazivLinije As String
	Public brojLinije As String
	Public adresaZaGPS As String
	Public upit As SQL
	'
	Public FusedLocationProvider1 As FusedLocationProvider
	Public LastLocation As Location
	Public rp As RuntimePermissions
	Public GPS1 As GPS
	Public gpsStarted As Boolean
	Public lastLoc As Boolean = False
	Public SourceFolder As String
	Dim nocna As Boolean = False
'	Private su As StringUtils
'	Public flp As FusedLocationProvider
	Public LocationSource As Object
'	Private LocationChangedListener As JavaObject
End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	SourceFolder = rp.GetSafeDirDefaultExternal("")
	GPS1.Initialize("GPS")
	FusedLocationProvider1.Initialize("FusedLocationProvider1")
'	StartService(kontrola)
	CallSubDelayed(FirebaseMessaging, "SubscribeToTopics")
'	linijeT.Initialize2(Array As String("ZAPADNI KOLODVOR - BORONGAJ", "ČRNOMEREC - SAVIŠĆE", "LJUBLJANICA - SAVIŠĆE", "SAVSKI MOST - DUBEC", "PREČKO - DUBRAVA", _
'					   "ČRNOMEREC - SOPOT", "SAVSKI MOST - DUBEC", "MIHALJEVAC - ZAPRUĐE", "LJUBLJANICA - BORONGAJ", "ČRNOMEREC - DUBEC", "LJUBLJANICA - DUBRAVA", _
'					   "ŽITNJAK - KVATERNIKOV TRG", "MIHALJEVAC - ZAPRUĐE", "MIHALJEVAC - DOLJE", "PREČKO - BORONGAJ"))
'	linijeTNoćne.Initialize2(Array As String("ČRNOMEREC - SAVSKI MOST", "PREČKO - BORONGAJ", "DOLJE - SAVIŠĆE", "LJUBLJANICA - DUBEC"))
'	linijeTLinkovi.Initialize2(Array As String("http://www.zet.hr/raspored-voznji/325?route_id=1", "http://www.zet.hr/raspored-voznji/325?route_id=2", "http://www.zet.hr/raspored-voznji/325?route_id=3", _
'							  "http://www.zet.hr/raspored-voznji/325?route_id=4", "http://www.zet.hr/raspored-voznji/325?route_id=5", "http://www.zet.hr/raspored-voznji/325?route_id=6", _
'							  "http://www.zet.hr/raspored-voznji/325?route_id=7", "http://www.zet.hr/raspored-voznji/325?route_id=8", "http://www.zet.hr/raspored-voznji/325?route_id=9", _
'							  "http://www.zet.hr/raspored-voznji/325?route_id=11", "http://www.zet.hr/raspored-voznji/325?route_id=12", "http://www.zet.hr/raspored-voznji/325?route_id=13", _
'							  "http://www.zet.hr/raspored-voznji/325?route_id=14", "http://www.zet.hr/raspored-voznji/325?route_id=15", "http://www.zet.hr/raspored-voznji/325?route_id=17"))
'	linijeTLinkoviNoćne.Initialize2(Array As String("http://www.zet.hr/raspored-voznji/325?route_id=31", "http://www.zet.hr/raspored-voznji/325?route_id=32", _
'													"http://www.zet.hr/raspored-voznji/325?route_id=33", "http://www.zet.hr/raspored-voznji/325?route_id=34"))
'	linijeTBrojevi.Initialize2(Array As Int(1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 17))
'	linijeTBrojeviNoćne.Initialize2(Array As Int("31", "32", "33", "34"))
'
'	linijeA.Initialize2(Array As String("BORONGAJ - DUBEC", "BORONGAJ - SESVETSKI KRALJEVEC", "BRITANSKI TRG - GORNJE PREKRIŽJE", "BRITANSKI TRG - MIHALJEVAC", "BRITANSKI TRG - KRALJEVEC", _
'						"BRITANSKI TRG - KAPTOL", "BRITANSKI TRG - ZELENGAJ - BRITANSKI TRG", "ČRNOMEREC - DUGAVE", "ČRNOMEREC - PODSUSED MOST", "ČRNOMEREC - GAJNICE", "ČRNOMEREC - KARAŽNIK - GAJNICE", _
'						"ČRNOMEREC - PODSUSED-CENTAR", "ČRNOMEREC - PODSUSEDSKO DOLJE", "ČRNOMEREC - GORNJI STENJEVEC", "ČRNOMEREC - GORNJE VRAPČE", "ČRNOMEREC - GORNJA KUSTOŠIJA - KRVARIĆ", _
'						"ČRNOMEREC - MIKULIĆI", "ČRNOMEREC - LUKŠIĆI", "ČRNOMEREC - BORČEC", "ČRNOMEREC - BIZEK", "ČRNOMEREC - PREČKO", "ČRNOMEREC - GRABERJE", "ČRNOMEREC - ŠPANSKO", "ČRNOMEREC - PERJAVICA - BORČEC", _
'						"ČRNOMEREC - ZAPREŠIĆ", "ČRNOMEREC - GORNJA BISTRA", "ČRNOMEREC - POLJANICA - GORNJA BISTRA", "DUBEC - SESVETE", "DUBRAVA - TRNOVČICA - DUBEC", "DUBEC - NOVOSELEC", _
'						"DUBEC - BORONGAJ", "DUBEC - SESVETE - GORANEC", "DUBEC - SESVETE - PLANINA DONJA", "DUBEC - SESVETE - KAŠINA - PLANINA GORNJA", "DUBEC - SESVETE - JESENOVEC", "DUBEC - MARKOVO POLJE", _
'						"DUBEC - SESVETE - BLAGUŠA", "DUBEC - SESVETE - GLAVNICA DONJA", "DUBEC - SESVETE - MORAVČE", "DUBEC - SESVETE - LUŽAN", "DUBEC - SESVETE - LAKTEC", "DUBEC - NOVI JELKOVEC", _
'						"DUBEC - SESVETE - ŠIMUNČEVEC", "DUBRAVA - MARKUŠEVEC - BIDROVEC", "DUBRAVA - MIROŠEVEC", "DUBRAVA - VIDOVEC", "DUBRAVA - ČUČERJE", "DUBRAVA - STUDENTSKI GRAD - KLIN", "DUBRAVA - JALŠEVEC", _
'						"DUBRAVA - TRNOVČICA - DUBEC", "DUBRAVA - GRANEŠINSKI NOVAKI", "DUBRAVA - ČRET", "GLAVNI KOLODVOR - SAVSKI MOST", "GLAVNI KOLODVOR - DONJI DRAGONOŽEC", "GLAVNI KOLODVOR - SAVICA - BOROVJE", _
'						"GLAVNI KOLODVOR - SLOBOŠTINA", "GLAVNI KOLODVOR - DUGAVE", "GLAVNI KOLODVOR - TRAVNO", "GLAVNI KOLODVOR - ODRA - MALA MLAKA", "GLAVNI KOLODVOR - KAJZERICA - LANIŠTE", "GLAVNI KOLODVOR - VELIKA GORICA", _
'						"GLAVNI KOLODVOR - NOVI JELKOVEC", "GLAVNI KOLODVOR - PETROVINA", "GLAVNI KOLODVOR - CEROVSKI VRH", "GLAVNI KOLODVOR - VUKOMERIĆ", "GLAVNI KOLODVOR - VELIKA GORICA (BRZA)", _
'						"JANDRIĆEVA - DOM UMIROVLJENIKA", "JANKOMIR - ŽITNJAK", "JANKOMIR - ŠPANSKO - LJUBLJANICA", "JANKOMIR - MALEŠNICA - RELJKOVIĆEVA", "KAMPUS - ČAVIĆEVA", "KAPTOL - BRITANSKI TRG", "KAPTOL - MIROGOJ - KREMATORIJ", _
'						"KAPTOL - KVATERNIKOV TRG", "KAPTOL - REMETE - SVETICE", "KAPTOL - KOZJAK", "KOLEDINEČKA - TRNAVA - KOZARI BOK", "KVATERNIKOV TRG - KAPTOL", "KVATERNIKOV TRG - KOZJAK", "KVATERNIKOV TRG - HORVATOVAC - VOĆARSKA - KVATERNIKOV TRG", _
'						"KVATERNIKOV TRG - TRNAVA", "KVATERNIKOV TRG - RESNIK - IVANJA REKA", "KVATERNIKOV TRG - STRUGE - PETRUŠEVEČKO NASELJE", "KVATERNIKOV TRG - KOZARI PUTEVI", "KVATERNIKOV TRG - IVANJA REKA - DUMOVEC", _
'						"KVATERNIKOV TRG - ZRAČNA LUKA - VELIKA GORICA", "LJUBLJANICA - JARUN", "LJUBLJANICA - PREČKO", "LJUBLJANICA - ŠPANSKO - JANKOMIR", "LJUBLJANICA - PODSUSED MOST", "KUNIŠČAK - ŠESTINSKI DOL, MANDALIČINA - VRHOVEC", "MIHALJEVAC - BRITANSKI TRG", _
'						"MIHALJEVAC - MARKUŠEVEC", "MIHALJEVAC - SLJEME", "NOVI JELKOVEC - DUBEC", "GLAVNI KOLODVOR - NOVI JELKOVEC", "SESVETE - NOVI JELKOVEC", "PREČKO - LJUBLJANICA", "PREČKO - ČRNOMEREC", "PREČKO - JEŽDOVEC - SAVSKI MOST", _
'						"RELJKOVIĆEVA - JELENOVAC - RELJKOVIĆEVA", "RELJKOVIĆEVA - VINOGRADI - RELJKOVIĆEVA", "RELJKOVIĆEVA - MALEŠNICA - JANKOMIR", "RELJKOVIĆEVA - HERCEGOVAČKA - BOSANSKA - RELJKOVIĆEVA", "SAVSKI MOST - GLAVNI KOLODVOR", _
'						"SAVSKI MOST - BOTINEC", "SAVSKI MOST - DONJI STUPNIK - STUPNIČKI OBREŽ", "SAVSKI MOST - LUČKO", "SAVSKI MOST - GOLI BREG - BREZOVICA", "SAVSKI MOST - SVETA KLARA - ČEHI", "SAVSKI MOST - STRMEC ODRANSKI", _
'						"SAVSKI MOST - LIPNICA - HAVIDIĆ SELO", "SAVSKI MOST - KUPINEČKI KRALJEVEC - ŠTRPET", "SAVSKI MOST - AŠPERGERI - KUPINEC", "SAVSKI MOST - DONJI TRPUCI - GORNJI TRPUCI", "SAVSKI MOST - HORVATI", _
'						"SAVSKI MOST - KLINČA SELA", "SAVSKI MOST - JEŽDOVEC - PREČKO", "SAVSKI MOST - KUPINEC", "SAVSKI MOST - BLATO", "SAVSKI MOST - LUKAVEC", "DUBEC - SESVETE", "SESVETE - KOZARI BOK", _
'						"SESVETE - SESVETSKA SOPNICA", "SESVETE - SESVETSKA SELNICA", "SESVETE - SESVETSKA SELA - KRALJEVEČKI NOVAKI", "SESVETE - NOVI JELKOVEC", "SESVETE - BADELOV BRIJEG", "SESVETE - IVANJA REKA", "SREBRNJAK - RIM - SREBRNJAK", _
'						"SVETICE - VINEC - KREMATORIJ", "SVETICE - REMETE - KAPTOL", "SVETICE - GORNJI BUKOVAC - JAZBINA - BLIZNEC", "SVETICE - REBRO - SVETICE", "TUŠKANAC GARAŽA - GORNJI GRAD - TRG BANA JOSIPA JELAČIĆA", "TRG MAŽURANIĆA - VOLTINO", _
'						"VELIKA GORICA - GLAVNI KOLODVOR", "ZRAČNA LUKA - VELIKA GORICA - KVATERNIKOV TRG", "VELIKA GORICA - VELIKA BUNA", "VELIKA GORICA - KOZJAČA", "VELIKA GORICA - MRACLIN", "VELIKA GORICA - TUROPOLJE", _
'						"VELIKA GORICA - SASI", "VELIKA GORICA - LUKAVEC", "VELIKA GORICA - STRMEC BUKEVSKI", "VELIKA GORICA - CEROVSKI VRH", "VELIKA GORICA - RIBNICA - LAZINA", "VELIKA GORICA - ČIČKA POLJANA", "VELIKA GORICA - VUKOJEVAC", _
'						"VELIKA GORICA - GLAVNI KOLODVOR (BRZA)", "VELIKA GORICA - PLESO - DONJA LOMNICA", "VRAPČANSKA ALEJA - JAČKOVINA - VRAPČANSKA ALEJA", "VRAPČANSKA ALEJA - OREŠJE", "VRAPČANSKA ALEJA - ORANICE", _
'						"ZAPREŠIĆ - ČRNOMEREC", "ZAPREŠIĆ - ŽEJINCI", "ZAPREŠIĆ - POJATNO - GORNJA BISTRA", "TRG MLADOSTI - GROBLJE ZAPREŠIĆ - ŠIBICE", "ZAPRUĐE - JAKUŠEVEC - ZAPRUĐE", "ZAPRUĐE - STRMEC BUKEVSKI", _
'						"ZAPRUĐE - SASI", "ŽITNJAK - JANKOMIR", "REMETINEC - ŽITNJAK"))
'
'	linijeANoćne.Initialize2(Array As String("LJUBLJANICA - PODSUSED MOST", "ČRNOMEREC - ZAPREŠIĆ", "DUBEC - SESVETE", "GLAVNI KOLODVOR - VELIKA GORICA"))
'	linijeALinkovi.Initialize2(Array As String("http://www.zet.hr/raspored-voznji/325?route_id=231", "http://www.zet.hr/raspored-voznji/325?route_id=269", "http://www.zet.hr/raspored-voznji/325?route_id=101", "http://www.zet.hr/raspored-voznji/325?route_id=102", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=103", "http://www.zet.hr/raspored-voznji/325?route_id=105", "http://www.zet.hr/raspored-voznji/325?route_id=138", "http://www.zet.hr/raspored-voznji/325?route_id=109", "http://www.zet.hr/raspored-voznji/325?route_id=119", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=120", "http://www.zet.hr/raspored-voznji/325?route_id=121", "http://www.zet.hr/raspored-voznji/325?route_id=122", "http://www.zet.hr/raspored-voznji/325?route_id=123", "http://www.zet.hr/raspored-voznji/325?route_id=124", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=125", "http://www.zet.hr/raspored-voznji/325?route_id=126", "http://www.zet.hr/raspored-voznji/325?route_id=127", "http://www.zet.hr/raspored-voznji/325?route_id=128", "http://www.zet.hr/raspored-voznji/325?route_id=130", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=131", "http://www.zet.hr/raspored-voznji/325?route_id=134", "http://www.zet.hr/raspored-voznji/325?route_id=135", "http://www.zet.hr/raspored-voznji/325?route_id=136", "http://www.zet.hr/raspored-voznji/325?route_id=137", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=172", "http://www.zet.hr/raspored-voznji/325?route_id=176", "http://www.zet.hr/raspored-voznji/325?route_id=177", "http://www.zet.hr/raspored-voznji/325?route_id=212", "http://www.zet.hr/raspored-voznji/325?route_id=223", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=224", "http://www.zet.hr/raspored-voznji/325?route_id=231", "http://www.zet.hr/raspored-voznji/325?route_id=261", "http://www.zet.hr/raspored-voznji/325?route_id=262", "http://www.zet.hr/raspored-voznji/325?route_id=263", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=264", "http://www.zet.hr/raspored-voznji/325?route_id=267", "http://www.zet.hr/raspored-voznji/325?route_id=270", "http://www.zet.hr/raspored-voznji/325?route_id=271", "http://www.zet.hr/raspored-voznji/325?route_id=272", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=273", "http://www.zet.hr/raspored-voznji/325?route_id=274", "http://www.zet.hr/raspored-voznji/325?route_id=279", "http://www.zet.hr/raspored-voznji/325?route_id=280", "http://www.zet.hr/raspored-voznji/325?route_id=205", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=206", "http://www.zet.hr/raspored-voznji/325?route_id=208", "http://www.zet.hr/raspored-voznji/325?route_id=209", "http://www.zet.hr/raspored-voznji/325?route_id=210", "http://www.zet.hr/raspored-voznji/325?route_id=213", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=223", "http://www.zet.hr/raspored-voznji/325?route_id=230", "http://www.zet.hr/raspored-voznji/325?route_id=232", "http://www.zet.hr/raspored-voznji/325?route_id=108", "http://www.zet.hr/raspored-voznji/325?route_id=166", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=218", "http://www.zet.hr/raspored-voznji/325?route_id=219", "http://www.zet.hr/raspored-voznji/325?route_id=220", "http://www.zet.hr/raspored-voznji/325?route_id=221", "http://www.zet.hr/raspored-voznji/325?route_id=229", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=234", "http://www.zet.hr/raspored-voznji/325?route_id=268", "http://www.zet.hr/raspored-voznji/325?route_id=281", "http://www.zet.hr/raspored-voznji/325?route_id=310", "http://www.zet.hr/raspored-voznji/325?route_id=311", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=313", "http://www.zet.hr/raspored-voznji/325?route_id=330", "http://www.zet.hr/raspored-voznji/325?route_id=104", "http://www.zet.hr/raspored-voznji/325?route_id=107", "http://www.zet.hr/raspored-voznji/325?route_id=115", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=146", "http://www.zet.hr/raspored-voznji/325?route_id=236", "http://www.zet.hr/raspored-voznji/325?route_id=105", "http://www.zet.hr/raspored-voznji/325?route_id=106", "http://www.zet.hr/raspored-voznji/325?route_id=201", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=226", "http://www.zet.hr/raspored-voznji/325?route_id=238", "http://www.zet.hr/raspored-voznji/325?route_id=214", "http://www.zet.hr/raspored-voznji/325?route_id=201", "http://www.zet.hr/raspored-voznji/325?route_id=202", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=204", "http://www.zet.hr/raspored-voznji/325?route_id=215", "http://www.zet.hr/raspored-voznji/325?route_id=216", "http://www.zet.hr/raspored-voznji/325?route_id=217", "http://www.zet.hr/raspored-voznji/325?route_id=237", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=276", "http://www.zet.hr/raspored-voznji/325?route_id=290", "http://www.zet.hr/raspored-voznji/325?route_id=113", "http://www.zet.hr/raspored-voznji/325?route_id=114", "http://www.zet.hr/raspored-voznji/325?route_id=115", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=116", "http://www.zet.hr/raspored-voznji/325?route_id=129", "http://www.zet.hr/raspored-voznji/325?route_id=102", "http://www.zet.hr/raspored-voznji/325?route_id=233", "http://www.zet.hr/raspored-voznji/325?route_id=140", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=279", "http://www.zet.hr/raspored-voznji/325?route_id=281", "http://www.zet.hr/raspored-voznji/325?route_id=282", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=114", "http://www.zet.hr/raspored-voznji/325?route_id=134", "http://www.zet.hr/raspored-voznji/325?route_id=168", "http://www.zet.hr/raspored-voznji/325?route_id=139", "http://www.zet.hr/raspored-voznji/325?route_id=141", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=146", "http://www.zet.hr/raspored-voznji/325?route_id=148", "http://www.zet.hr/raspored-voznji/325?route_id=108", "http://www.zet.hr/raspored-voznji/325?route_id=110", "http://www.zet.hr/raspored-voznji/325?route_id=111", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=112", "http://www.zet.hr/UserDocsImages/Voznired/132.pdf", "http://www.zet.hr/raspored-voznji/325?route_id=133", "http://www.zet.hr/raspored-voznji/325?route_id=159", "http://www.zet.hr/raspored-voznji/325?route_id=160", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=161", "http://www.zet.hr/raspored-voznji/325?route_id=162", "http://www.zet.hr/raspored-voznji/325?route_id=163", "http://www.zet.hr/raspored-voznji/325?route_id=164", "http://www.zet.hr/raspored-voznji/325?route_id=165", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=168", "http://www.zet.hr/raspored-voznji/325?route_id=169", "http://www.zet.hr/UserDocsImages/Voznired/izvanredne/195 A4.pdf", "http://www.zet.hr/raspored-voznji/325?route_id=315", "http://www.zet.hr/raspored-voznji/325?route_id=212", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=225", "http://www.zet.hr/raspored-voznji/325?route_id=275", "http://www.zet.hr/raspored-voznji/325?route_id=277", "http://www.zet.hr/raspored-voznji/325?route_id=278", "http://www.zet.hr/raspored-voznji/325?route_id=282", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=283", "http://www.zet.hr/raspored-voznji/325?route_id=284", "http://www.zet.hr/raspored-voznji/325?route_id=207", "http://www.zet.hr/raspored-voznji/325?route_id=203", "http://www.zet.hr/raspored-voznji/325?route_id=226", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=227", "http://www.zet.hr/raspored-voznji/325?route_id=228", "http://www.zet.hr/raspored-voznji/325?route_id=150", "http://www.zet.hr/raspored-voznji/325?route_id=118", "http://www.zet.hr/raspored-voznji/325?route_id=268", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=290", "http://www.zet.hr/raspored-voznji/325?route_id=302", "http://www.zet.hr/raspored-voznji/325?route_id=303", "http://www.zet.hr/raspored-voznji/325?route_id=304", "http://www.zet.hr/raspored-voznji/325?route_id=305", _
'							   "http://www.zet.hr/UserDocsImages/Voznired/309.pdf", "http://www.zet.hr/raspored-voznji/325?route_id=319", "http://www.zet.hr/raspored-voznji/325?route_id=321", "http://www.zet.hr/raspored-voznji/325?route_id=322", "http://www.zet.hr/raspored-voznji/325?route_id=323", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=324", "http://www.zet.hr/raspored-voznji/325?route_id=325", "http://www.zet.hr/raspored-voznji/325?route_id=330", "http://www.zet.hr/raspored-voznji/325?route_id=335", "http://www.zet.hr/raspored-voznji/325?route_id=142", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=143", "http://www.zet.hr/raspored-voznji/325?route_id=145", "http://www.zet.hr/raspored-voznji/325?route_id=172", "http://www.zet.hr/raspored-voznji/325?route_id=174", "http://www.zet.hr/raspored-voznji/325?route_id=175", _
'							   "http://www.zet.hr/raspored-voznji/325?route_id=182", "http://www.zet.hr/raspored-voznji/325?route_id=295", "http://www.zet.hr/raspored-voznji/325?route_id=307", "http://www.zet.hr/raspored-voznji/325?route_id=308", "http://www.zet.hr/raspored-voznji/325?route_id=107", "http://www.zet.hr/raspored-voznji/325?route_id=222"))
'	linijeALinkoviNoćne.Initialize2(Array As String("http://www.zet.hr/raspored-voznji/325?route_id=116", "http://www.zet.hr/raspored-voznji/325?route_id=172", "http://www.zet.hr/raspored-voznji/325?route_id=212", "http://www.zet.hr/raspored-voznji/325?route_id=268"))
'	linijeABrojevi.Initialize2(Array As Int(231, 269, 101, 102, 103, 105, 138, 109, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 130, 131, 134, 135, 136, 137, 172, 176, 177, 212, 223, 224, 231, 261, 262, 263, 264, 267, 270, 271, 272, 273, 274, 279, 280, 205, 206, 208, 209, 210, 213, 223, 230, 232, 108, _
'							   166, 218, 219, 220, 221, 229, 234, 268, 281, 310, 311, 313, 330, 104, 107, 115, 146, 236, 105, 106, 201, 226, 238, 214, 201, 202, 204, 215, 216, 217, 237, 276, 290, 113, 114, 115, 116, 129, 102, 233, 140, 279, 281, 282, 114, 134, 168, 139, 141, 146, 148, 108, 110, 111, 112, 132, _
'							   133, 159, 160, 161, 162, 163, 164, 165, 168, 169, 195, 315, 212, 225, 275, 277, 278, 282, 283, 284, 207, 203, 226, 227, 228, 150, 118, 268, 290, 302, 303, 304, 305, 309, 319, 321, 322, 323, 324, 325, 330, 335, 142, 143, 145, 172, 174, 175, 182, 295, 307, 308, 107, 222))
'	linijeABrojeviNoćne.Initialize2(Array As Int(116, 172, 212, 268))

'	File.Delete(SourceFolder, "linije.db")
'	File.Copy(SourceFolder, "linije.db.orig", SourceFolder, "linije.db")
	If File.Exists(SourceFolder, "linije.db") = False Then
		File.Copy(File.DirAssets, "linije.db", SourceFolder, "linije.db")
	End If
	upit.Initialize(SourceFolder, "linije.db", True)
	'
	' tablica lokacija kontrolora, zastoja i kašnjenja
	'
'	upit.ExecNonQuery("DROP TABLE IF EXISTS ostalo")
	upit.ExecNonQuery("CREATE TABLE IF NOT EXISTS ostalo (id INTEGER PRIMARY KEY AUTOINCREMENT, tip INTEGER, lat REAL, lon REAL, adresa TEXT, datum TEXT)")
	'
	' tablica brojeva i naziva linija
	'
'	upit.ExecNonQuery("CREATE TABLE IF NOT EXISTS linije (id INTEGER PRIMARY KEY AUTOINCREMENT, tip INTEGER, brojLinije INTEGER, nazivLinije TEXT, dnevna INTEGER, link TEXT, favorit INTEGER)")
'	Dim brzapisa As Int = upit.ExecQuerySingleResult("SELECT COUNT(*) FROM linije")
'	If brzapisa <= 0 Then
'		For i = 0 To linijeTBrojevi.Size - 1
'			Dim brzapisa As Int = upit.ExecQuerySingleResult("SELECT COUNT(*) FROM linije")
'			upit.ExecNonQuery($"INSERT INTO linije VALUES (${brzapisa}, 2, ${linijeTBrojevi.Get(i)}, '${linijeT.Get(i)}', 1, '${linijeTLinkovi.Get(i)}', 1)"$)
'		Next
'		
'		For i = 0 To linijeTBrojeviNoćne.Size - 1
'			Dim brzapisa As Int = upit.ExecQuerySingleResult("SELECT COUNT(*) FROM linije")
'			upit.ExecNonQuery($"INSERT INTO linije VALUES (${brzapisa}, 2, ${linijeTBrojeviNoćne.Get(i)}, '${linijeTNoćne.Get(i)}', 2, '${linijeTLinkoviNoćne.Get(i)}', 1)"$)
'		Next
'		
'		For i = 0 To linijeABrojevi.Size - 1
'			Dim brzapisa As Int = upit.ExecQuerySingleResult("SELECT COUNT(*) FROM linije")
'			upit.ExecNonQuery($"INSERT INTO linije VALUES (${brzapisa}, 1, ${linijeABrojevi.Get(i)}, '${linijeA.Get(i)}', 1, '${linijeALinkovi.Get(i)}', 1)"$)
'		Next
'		
'		For i = 0 To linijeABrojeviNoćne.Size - 1
'			Dim brzapisa As Int = upit.ExecQuerySingleResult("SELECT COUNT(*) FROM linije")
'			upit.ExecNonQuery($"INSERT INTO linije VALUES (${brzapisa}, 1, ${linijeABrojeviNoćne.Get(i)}, '${linijeANoćne.Get(i)}', 2, '${linijeALinkoviNoćne.Get(i)}', 1)"$)
'		Next
'	Else
'		Log(brzapisa)
'	End If

	'
	' tablica lokacija
	'
'	upit.ExecNonQuery("DROP TABLE IF EXISTS lokacije")
'	upit.ExecNonQuery("CREATE TABLE IF NOT EXISTS lokacije (id INTEGER PRIMARY KEY AUTOINCREMENT, stop_id INTEGER, stop_name TEXT, stop_lat REAL, stop_lon REAL)")
'	Dim ll1 As List = su.LoadCSV(File.DirAssets, "stops.txt", ",")
'	Dim stavke() As String
'	For i = 1 To ll1.Size - 1
'		stavke = ll1.Get(i)
'		Log(stavke(0))
'		Log(stavke(2))
'		Log(stavke(4))
'		Log(stavke(5))
'		Dim brzapisa As Int = upit.ExecQuerySingleResult("SELECT COUNT(*) FROM lokacije")
'		upit.ExecNonQuery($"INSERT INTO lokacije VALUES (${brzapisa}, ${stavke(0)}, '${stavke(2)}', ${stavke(4)}, ${stavke(5)})"$)
''		Dim m As Map
''		m.Initialize
''		m.Put("stop_id", stavke(0))
'''		m.Put("stop_code", stavke(1))
''		m.Put("stop_name", stavke(2))
'''		m.Put("stop_desc", stavke(3))
''		m.Put("stop_lat", stavke(4))
''		m.Put("stop_lon", stavke(5))
'''		m.Put("zone_id", stavke(6))
'''		m.Put("stop_url", stavke(7))
'''		m.Put("location_type", stavke(8))
'''		m.Put("parent_station", stavke(9))
'''		ll2.Add(m)
'	Next
'	Dim cursor1 As Cursor
'	cursor1 = upit.ExecQuery("SELECT * FROM lokacije")
'	If cursor1.RowCount > 0 Then
'		For i = 0 To cursor1.RowCount - 1
'			cursor1.Position = i
'			Log(cursor1.GetInt("id"))
'			Log(cursor1.GetInt("stop_id"))
'			Log(cursor1.GetString("stop_name"))
'			Log(cursor1.GetDouble("stop_lat"))
'			Log(cursor1.GetDouble("stop_lon"))
'		Next
'	End If
End Sub


Sub Service_Start (StartingIntent As Intent)

End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
'	Log(Error)
'	Log(StackTrace)
	Return True
End Sub

Sub Service_Destroy
	StopGps
End Sub

Sub FusedLocationProvider1_ConnectionFailed(ConnectionResult1 As Int)
	Log("FusedLocationProvider1_ConnectionFailed")
	
	'	the FusedLocationProvider ConnectionResult object contains the various CoonectionResult constants
	
	Select ConnectionResult1
		Case FusedLocationProvider1.ConnectionResult.NETWORK_ERROR
			'	a network error has occurred, this is likely to be a recoverable error
			'	so try to connect again
			FusedLocationProvider1.Connect
		Case Else
			'	TODO handle other errors
	End Select
End Sub

Sub FusedLocationProvider1_ConnectionSuccess
	Log("FusedLocationProvider1_ConnectionSuccess")
	Dim LocationRequest1 As LocationRequest
	LocationRequest1.Initialize
	LocationRequest1.SetInterval(1000)	'	1000 milliseconds
	LocationRequest1.SetPriority(LocationRequest1.Priority.PRIORITY_HIGH_ACCURACY)
	LocationRequest1.SetSmallestDisplacement(1)	'	1 meter
	
	Dim LocationSettingsRequestBuilder1 As LocationSettingsRequestBuilder
	LocationSettingsRequestBuilder1.Initialize
	LocationSettingsRequestBuilder1.AddLocationRequest(LocationRequest1)
	FusedLocationProvider1.CheckLocationSettings(LocationSettingsRequestBuilder1.Build)
	
	FusedLocationProvider1.RequestLocationUpdates(LocationRequest1)
End Sub

Sub FusedLocationProvider1_ConnectionSuspended(SuspendedCause1 As Int)
	Log("FusedLocationProvider1_ConnectionSuspended")
	
	'	the FusedLocationProvider SuspendedCause object contains the various SuspendedCause constants
	
	Select SuspendedCause1
		Case FusedLocationProvider1.SuspendedCause.CAUSE_NETWORK_LOST
			'	TODO take action
		Case FusedLocationProvider1.SuspendedCause.CAUSE_SERVICE_DISCONNECTED
			'	TODO take action
	End Select
End Sub

Sub FusedLocationProvider1_LocationChanged(Location1 As Location)
	Log("FusedLocationProvider1_LocationChanged")
	LastLocation = Location1
	lastLoc = True
'	CallSub(Main, "UpdateUI")
End Sub

Sub FusedLocationProvider1_LocationSettingsChecked(LocationSettingsResult1 As LocationSettingsResult)
	Log("FusedLocationProvider1_LocationSettingsChecked")
	Dim LocationSettingsStatus1 As LocationSettingsStatus=LocationSettingsResult1.GetLocationSettingsStatus
	Select LocationSettingsStatus1.GetStatusCode
		Case LocationSettingsStatus1.StatusCodes.RESOLUTION_REQUIRED
			Log("RESOLUTION_REQUIRED")
			'	device settings do not meet the location request requirements
			'	a resolution dialog is available to enable the user to change the settings
			'	the  StartResolutionDialog method cannot be called from a service
			'	so we'll pass the LocationSettingsStatus to the Main activity to be handled
			CallSubDelayed2(detalj_stanice, "HandleLocationSettingsStatus", LocationSettingsStatus1)
		Case LocationSettingsStatus1.StatusCodes.SETTINGS_CHANGE_UNAVAILABLE
			Log("SETTINGS_CHANGE_UNAVAILABLE")
			'	device settings do not meet the location request requirements
			'	a resolution dialog is not available to enable the user to change the settings
			'	we'll pass the LocationSettingsStatus to the Main activity to be handled
			CallSubDelayed2(detalj_stanice, "HandleLocationSettingsStatus", LocationSettingsStatus1)
		Case LocationSettingsStatus1.StatusCodes.SUCCESS
			Log("SUCCESS")
			'	device settings meet the location request requirements
			'	no further action required
	End Select
End Sub

Public Sub StartGps
	If gpsStarted = False Then
		GPS1.Start(0, 0)
		gpsStarted = True
		FusedLocationProvider1.Connect
	End If
End Sub

Public Sub StopGps
	If gpsStarted Then
		GPS1.Stop
		gpsStarted = False
		FusedLocationProvider1.Disconnect
	End If
End Sub
