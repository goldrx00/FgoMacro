;fgo macro adb.ahk

#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행

SetWorkingDir, %A_ScriptDir%	;스크립트의 작업 디렉토리를 변경. vscode로 작업시 넣어줘야 폴더 인식

#Include %A_ScriptDir%\Gdip.ahk
#include %A_ScriptDir%\functions.ahk
#include %A_ScriptDir%\adb_functions.ahk

OnExit, Clean_up

global adb := "utility\adb.exe"
global perl := "utility\perl.exe"
global AdbSN ;:= "emulator-5556" ;;그외 에뮬레이터

;global AdbSN := "127.0.0.1:62001" ;;녹스
;127.0.0.1:21503 ;미뮤
;127.0.0.1:7555 ;mumu
global TIME_REFRESH := 250 ;매크로 대기시간 (화면전환 등)
global nLog := 1 ;;기록
global OnRunning := 0
global g_hBitmap ;adb 이미지 서치용 hBitmap
;global 폰모드 := 0 ;매크로 모드
global ConfigFile := "Config.ini"

global SkillButtonPos := [{sX: 23, 	sY: 341,		eX: 63, 	eY: 380}
,{sX: 82, 	sY: 341,		eX: 122, 	eY: 380}
,{sX: 140, 	sY: 341,		eX: 180, 	eY: 380}
,{sX: 221, 	sY: 341,		eX: 261, 	eY: 380}
,{sX: 280, 	sY: 341,		eX: 320, 	eY: 380}
,{sX: 338, 	sY: 341,		eX: 378, 	eY: 380}
,{sX: 421, 	sY: 341,		eX: 461, 	eY: 380}
,{sX: 480, 	sY: 341,		eX: 520, 	eY: 380}
,{sX: 538, 	sY: 341,		eX: 578, 	eY: 380}]

global CmdCardPos := [{sX: 1, 	sY: 240,		eX: 160, 	eY: 400}
,{sX: 160, 	sY: 240,		eX: 320, 	eY: 400}
,{sX: 320, 	sY: 240,		eX: 480, 	eY: 400}
,{sX: 480, 	sY: 240,		eX: 640, 	eY: 400}
,{sX: 640, 	sY: 240,		eX: 800, 	eY: 400}]

global CharacterPos := [{sX: 10, 	sY: 234,		eX: 195, 	eY: 450}
,{sX: 209, 	sY: 234,		eX: 395, 	eY: 450}
,{sX: 409, 	sY: 234,		eX: 594, 	eY: 450}]

global EnemyPos := [{X: 330, 	Y: 25}
,{X: 180, 	Y: 25}
,{X: 30, 	Y: 25}]

global FriendListPos := [{sX: 30, 	sY: 113,		eX: 755, 	eY: 227}
,{sX: 30, 	sY: 238,		eX: 755, 	eY: 351}]

global MacroID := "페그오 매크로"
;Menu, Tray, Icon, Image\Icon1.ico
Gui, Add, Progress, x12 y9 w80 h20 cGreen Range0-100  vProgress, 0
Gui, Add, Text, x182 y15 w80 h20 +Center vSimpleLog, <대기 중>
Gui, Add, GroupBox, x12 y39 w250 h330 , 옵션
;Gui, Add, Text, x22 y59 w140 h150, 모드
;Gui, Add, DropDownList, x22 y80 Choose1 AltSubmit vMacroMode gMacroMode, 1.에뮬모드|2.폰모드

Gui, Add, Text, x22 y59 , 에뮬 ADB Serial Number: 
Gui, Add, Edit, x22 y80 vEmulSN,
;Gui, Add, Text, x22 y210 , 폰 ADB Serial Number:
;Gui, Add, Edit, x22 y230 vPhoneSN,
;Gui, Add, ComboBox, x22 y200 Choose1 vAdbSerial, | |
Gui, Add, Text, x22 y120 , 1라 점사:
Gui, Add, Text, x170 y120 , 보구 사용
Gui, Add, DropDownList, x22 y135 Choose1 AltSubmit v점사1, 전|중|후
Gui, Add, checkbox, x170 y135 v보구1라1, 1
Gui, Add, checkbox, x200 y135 v보구1라2, 2
Gui, Add, checkbox, x230 y135 v보구1라3, 3
Gui, Add, Text, x22 y160 , 2라 점사:
Gui, Add, DropDownList, x22 y175 Choose1 AltSubmit v점사2, 전|중|후
Gui, Add, checkbox, x170 y175 v보구2라1, 1
Gui, Add, checkbox, x200 y175 v보구2라2, 2
Gui, Add, checkbox, x230 y175 v보구2라3, 3
Gui, Add, Text, x22 y200 , 3라 점사:
Gui, Add, DropDownList, x22 y215 Choose1 AltSubmit v점사3, 전|중|후
Gui, Add, checkbox, x170 y215 v보구3라1, 1
Gui, Add, checkbox, x200 y215 v보구3라2, 2
Gui, Add, checkbox, x230 y215 v보구3라3, 3
Gui, Add, checkbox, x22 y240 v금사과사용, 금사과 사용

Gui, Add, Button, x22 y280 w50 h30 gMenuInfo, 설명
Gui, Add, Button, x82 y280 w50 h30 gMenuLog, 기록
Gui, Add, Button, x142 y280 w50 h30 gADB스크린, 화면
Gui, Add, Button, x22 y320 w70 h30  gOneClick, 실행
Gui, Add, Button, x102 y320 w70 h30  gReset, 재시작

Gui, 2: Add, ListBox, x12 y9 w330 h310 vLogList,
Gui, 2: +Owner1

Gui, 3: Add, Text, ,해상도: 800 x 450`n`n배틀 메뉴에서 스킬 사용 확인 OFF`n`nCtrl+F6 : 스샷찍기`n`nCtrl+F5 : 무료소환반복`n`nCtrl+F8 : 이미지 재로딩

;Gui, 4: Add,Picture,x0 y0 w800 h450 0xE vPicADB gClickPic ;;화면
;#include %A_ScriptDir%\guitest2.ahk


IfNotExist, %ConfigFile%
{
	initX := 100
	initY := 100,
}
IfExist, %ConfigFile%
	Gosub, LoadOption

Gosub, Attach

GuiControlGet, EmulSN, 1: ;adb 에뮬 시리얼
AdbSN := EmulSN

Gui, Show,  x%initX% y%initY% , %MacroID% ; h350 w194

Gosub, LoadImage

log := "# 동작 대기"
AddLog(log)
return

LoadImage:
AddLog("# 이미지 로딩 중...")
gdipToken := Gdip_Startup()
Loop, image\*.bmp, , 1  ; Recurse into subfolders.
 {
	 imgFileName = %A_LoopFileName%
	 StringReplace, imgFileName, imgFileName, .bmp , , All	 
	 bmp_%imgFileName% := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
 }
 AddLog("# 이미지 로딩 완료")
;Gdip_Shutdown(gdipToken)
return

LoadOption:
IniRead, initX, %ConfigFile%, Position, X
IniRead, initY, %ConfigFile%, Position, Y
if(initX < 0 || initY < 0)
{
	initX := 100
	initY := 100
}
;재입장
IniRead, IniEmulSN, %ConfigFile%, Option, EmulSN
GuiControl,, EmulSN, %IniEmulSN%
;IniRead, IniPhoneSN, %ConfigFile%, Option, PhoneSN
;GuiControl,, PhoneSN, %IniPhoneSN%

;IniRead, MacroMode, %ConfigFile%, Option, MacroMode
;GuiControl, Choose, MacroMode, %MacroMode%
loop, 3
{
	IniRead, 점사%a_index%, %ConfigFile%, Option, 점사%a_index%
	temp := 점사%a_index%
	GuiControl, Choose, 점사%a_index%, %temp%
}
loop,3
{
	ii := a_index
	loop, 3
	{
		IniRead, 보구%ii%라%a_index%, %ConfigFile%, Option, 보구%ii%라%a_index%
		temp := 보구%ii%라%a_index%
		GuiControl,, 보구%ii%라%a_index%, %temp%
	}	
}
log := "# 설정 불러오기 완료"
AddLog(log)
return

SaveOption: ;세이브옵션
WinGetPos, posX, posY, width, height,  %MacroID%
IniWrite, %posX%, %ConfigFile%, Position, X
IniWrite, %posY%, %ConfigFile%, Position, Y
;ADB 시리얼
GuiControlGet, EmulSN, 1:
IniWrite, %EmulSN%, %ConfigFile%,  Option, EmulSN
;GuiControlGet, PhoneSN, 1:
;IniWrite, %PhoneSN%, %ConfigFile%,  Option, PhoneSN
;매크로모드
;GuiControlGet, MacroMode, 1:
;IniWrite, %MacroMode%, %ConfigFile%,  Option, MacroMode
loop, 3
{
	GuiControlGet, 점사%a_index%, 1:
	temp := 점사%a_index%
	IniWrite, %temp%, %ConfigFile%,  Option, 점사%a_index%
}
loop, 3
{
	ii := a_index
	loop, 3
	{
		GuiControlGet, 보구%ii%라%a_index%, 1:
		temp := 보구%ii%라%a_index%
		IniWrite, %temp%, %ConfigFile%,  Option, 보구%ii%라%a_index%
	}
}
return

MenuLog:
RealWinSize(posX, posY, width, height, MacroID)
ChildX := posX + width + 10
ChildY := posY
Gui, 2: Show, x%ChildX% y%ChildY%  h320 , 기록 ;
Return

MenuInfo:
RealWinSize(posX, posY, width, height, MacroID)
ChildX := posX + width + 10
ChildY := posY
Gui, 3: Show, x%ChildX% y%ChildY% , 설명
Return

ADB스크린:
RealWinSize(posX, posY, width, height, MacroID)
ChildX := posX + width + 10
ChildY := posY
;Gui, 4: Add,Picture,x0 y0 0xE vPic
Gui, 4: Show, x%ChildX% y%ChildY%  , ADB Screen
Return

ClickPic:
	SysGet, wCaption, 4
	SysGet, wFrame, 7
	MouseGetPos, MouseX, MouseY	
	x := MouseX - wFrame
	y := MouseY - wFrame - wCaption
	;addlog("마우스클릭" MouseX " " MouseY)
	ClickAdb(x, y)
	sleep, 500
	getAdbToGui()
	getAdbToGui()
	;getAdbToGui()
return

GuiClose:
Clean_up: ;매크로 끌때
Gosub, SaveOption
;DllCall("DeleteObject", Ptr,g_hBitmap) ;파일쓰기 없이 adb서치용 hBitmap 비움.
DllCall("CloseHandle", "uint", hCon)
DllCall("FreeConsole")
Process, Close, %cPid%
ExitApp
return

OneClick: ;;원클릭
GuiControl,, Progress, 100
log := "# 한방 클릭"
AddLog(log)
if(OnRunning = 1)
{
	log := "# 중복 동작 : 매크로가 동작 중입니다."
	AddLog(log)
	Return
}
/*
Process, Exist, dnplayer.exe
if(!ErrorLevel)
{
	Addlog("# 에뮬레이터 감지 못함")
	OnRunning := 0
	return
}
*/
메인함수()
OnRunning := 0
GuiControl,, Progress, 0
GuiControl,, SimpleLog, <동작 종료>
Return

Reset:
Reload
Return

Attach: ;;adb방식 컨트롤 하는 cmd 생성
;DetectHiddenWindows, on ;숨겨진 윈도우 조작 가능
Run, %comspec% /k ,, UseErrorLevel, cPid ;;hide 추가하면 숨겨짐
WinWait, ahk_pid %cPid%,, 10
WinHide, ahk_pid %cPid% ;나중에 숨기기
DllCall("AttachConsole","uint",cPid)
hCon:=DllCall("CreateFile","str","CONOUT$","uint",0xC0000000,"uint",7,"uint",0,"uint",3,"uint",0,"uint",0)
global objShell := ComObjCreate("WScript.Shell")
return

메인함수()
{
	GuiControl,, SimpleLog, <매크로 작동중>
	AddLog("# 페그오 매크로 시작 ")
	
	GuiControlGet, EmulSN, 1: ;adb 에뮬 시리얼
	AdbSN := EmulSN
	/*
	objExec := objShell.Exec(adb " connect " AdbSN)
	while(!objExec.status) ; objExec.status가 1이면 프로세스 완료된 상태
		sleep, 10
	*/
	loop
	{
		rCount := a_index ; 반복 회차

		objExec := objShell.Exec(adb " devices")
		strStdOut:=strStdErr:=""
		while, !objExec.StdOut.AtEndOfStream
		strStdOut := objExec.StdOut.ReadAll()
		IfNotInString, strStdOut, %AdbSN%
		{
			addlog("# " AdbSN " 에 재연결")
			objExec := objShell.Exec(adb " connect " AdbSN)
			while(!objExec.status)
				sleep, 10
		}

		if(IsImgPlusAdb(clickX, clickY, "Image\돌아가기.bmp", 60, 0))
		{
			clickX := 400
			clickY := 200
			ClickToImgAdb(clickX, clickY, "Image\퀘스트개시.bmp")
			sleep, 5000
			ClickAdb(clickX, clickY)
			sleep, 1500
			if(IsImgPlusAdb(clickX, clickY, "Image\아이템을사용하지않고.bmp", 60, 0)) ;퀘스트개시를 눌러도 뭐가 뜰때 여기 이미지 변경
			{
				ClickAdb(clickX, clickY)
			}
			addlog("# 반복 " rCount "회차 시작")
			sleep, 10000 ; 10초 대기
			ii = 0
			loop
			{
				if(IsImgPlusAdb(clickX, clickY, "Image\attack.bmp", 60, 0))
					break

				if(ii > 60 && IsImgPlusAdb(clickX, clickY, "Image\퀘스트개시.bmp", 60, 0))
				{
					ClickAdb(clickX, clickY)
					ii := 0
				}

				ii++
				sleep, 1000
			}
			;sleep, 1000
			라운드 := 1
			라운드시작 := true
			Loop
			{
				;;attack.bmp가 발견되면 배틀 시작한 것
				if(IsImgPlusAdb(clickX, clickY, "Image\attack.bmp", 60, 0))
				{
					sleep, 500
					getAdbScreen()				

					;;라운드 알아내기
					if(IsImageWithoutCap(clickX, clickY, "Image\Battle2.bmp", 120, "black", 541, 9, 551, 22))
					{
						if(라운드 = 1)
							라운드시작 := true	
						라운드 := 2											
					}
					else if(IsImageWithoutCap(clickX, clickY, "Image\Battle3.bmp", 120, "black", 541, 9, 551, 22))
					{
						if(라운드 = 2)
							라운드시작 := true
						라운드 := 3										
					}
					
					;; 점사 대상 선택
					if(라운드 = 1 && 라운드시작 = 1)
					{
						addlog("# 1라 시작")
						라운드시작 := false
						GuiControlGet, 점사1, 1:
						if(점사1 != 1)
							ClickAdb(EnemyPos[점사1].X, EnemyPos[점사1].Y)
						sleep, 300
					}
					else if(라운드 = 2 && 라운드시작 = 1)
					{
						addlog("# 2라 시작")
						라운드시작 := false
						GuiControlGet, 점사2, 1:
						if(점사2 != 1)							
							ClickAdb(EnemyPos[점사2].X, EnemyPos[점사2].Y)
						sleep, 300
					}
					else if(라운드 = 3 && 라운드시작 = 1)
					{
						addlog("# 3라 시작")
						라운드시작 := false
						GuiControlGet, 점사3, 1:
						if(점사3 != 1)
							ClickAdb(EnemyPos[점사3].X, EnemyPos[점사3].Y)
						sleep, 300
					}

					;;;;;;;;;;;;;;;;;;;;;;;;;; 스킬 사용 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					loop, 9
					{
						if(IsImageWithoutCap(clickX, clickY, "Image\방업1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImageWithoutCap(clickX, clickY, "Image\방업2.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 방업 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					loop, 9
					{
						if(IsImageWithoutCap(clickX, clickY, "Image\공업1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImageWithoutCap(clickX, clickY, "Image\공업2.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImageWithoutCap(clickX, clickY, "Image\공업2.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 공업 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					loop, 9
					{
						if(IsImageWithoutCap(clickX, clickY, "Image\np획득량1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImageWithoutCap(clickX, clickY, "Image\np획득량1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 엔피 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					loop, 9
					{
						if(IsImageWithoutCap(clickX, clickY, "Image\np업1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImageWithoutCap(clickX, clickY, "Image\np업2.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 엔피 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					loop, 9
					{
						if(IsImageWithoutCap(clickX, clickY, "Image\스타1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImageWithoutCap(clickX, clickY, "Image\스타2.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 스타 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					
					ClickAdb(710, 410) ;어택 클릭					
					sleep, 2000

					;;;;;;;;;;;;;;;;;;;커맨드 카드 사용;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					Loop
					{
						getAdbScreen() ;한번 가져온 스샷으로 여러번 이미지 서치
						if(!IsImageWithoutCap(clickX, clickY, "Image\attack.bmp", 60, 0))
						{
							break
						}
						ClickAdb(710, 410) ;어택클릭
						sleep, 2000
					}
					
					
					;;;보구 사용
					loop,3
					{
						ii := A_Index
						loop, 3
						{
							GuiControlGet, 보구%ii%라%a_index%, 1:
						}
					}

					if((라운드 = 1 && 보구1라1) || 라운드 = 2 && 보구2라1) || (라운드 = 3 && 보구3라1)
					{
						ClickAdb(260, 80)
						sleep, 100
					}
					if((라운드 = 1 && 보구1라2) || 라운드 = 2 && 보구2라2) || (라운드 = 3 && 보구3라2)
					{
						ClickAdb(405, 80)
						sleep, 100
					}
					if((라운드 = 1 && 보구1라3) || 라운드 = 2 && 보구2라3) || (라운드 = 3 && 보구3라3)
					{
						ClickAdb(550, 80)
						sleep, 100
					}

					loop, 5
						card%a_index% := 0 ;skill 배열: 사용한 카드는 1

					loop, 5 ;이펙티브 버스터 우선 사용
					{
						if(IsImageWithoutCap(clickX, clickY, "Image\effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							card%a_index% := 1
							sleep, 300
						}
					}
					loop, 5 ;이펙티브 아츠 사용
					{
						if(card%a_index% = 1)
							continue
						if(IsImageWithoutCap(clickX, clickY, "Image\effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							card%a_index% := 1
							sleep, 300
						}
					}
					/*
					loop, 5 ;남은 이펙티브 사용 (이펙티브 퀵)
					{
						if(card%a_index% = 1)
							continue
						if(IsImageWithoutCap(clickX, clickY, "Image\effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 ))
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							card%a_index% := 1
						}
					}
					*/
					loop, 5 ;레지스트 아닌 버스터 사용
					{
						if(card%a_index% = 1)
							continue
						if(!IsImageWithoutCap(clickX, clickY, "Image\resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							card%a_index% := 1
							sleep, 300
						}
					}
					loop, 5 ;레지스트 아닌 아츠 사용
					{
						if(card%a_index% = 1)
							continue
						if(!IsImageWithoutCap(clickX, clickY, "Image\resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "Image\arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							card%a_index% := 1
							sleep, 300
						}
					}
					loop, 5 ;남은 레지스트 아닌 기술 사용
					{
						if(card%a_index% = 1)
							continue
						if(!IsImageWithoutCap(clickX, clickY, "Image\resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 ))
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							card%a_index% := 1
							sleep, 300
						}
					}
					loop, 5 ;;남은 기술들 순서대로 사용
					{
						if(card%a_index% = 0)
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
							sleep, 300
						}
						;sleep, 10
					}
		
				}

				;;전멸했을 시

				;;전투가 끝났을 시
				getAdbScreen()
				if(IsImageWithoutCap(clickX, clickY, "Image\전투x.bmp", 60, 0))
				{
					ClickAdb(clickX, clickY)
					sleep, 2000
				}
				/*
				if(IsImageWithoutCap(clickX, clickY, "Image\보구렉.bmp", 60, 0))
				{					
					sleeplog(7000)
				} 
				*/
				if(IsImageWithoutCap(clickX, clickY, "Image\result.bmp", 45, "black", 462, 20, 492, 55))
				;|| IsImageWithoutCap(clickX, clickY, "Image\인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
				{
					ClickAdb(clickX, clickY)
					sleep, 3000
					loop
					{
						getAdbScreen()
						if(IsImageWithoutCap(clickX, clickY, "Image\result.bmp", 60, "black", 462, 20, 492, 55))
						;|| IsImageWithoutCap(clickX, clickY, "Image\인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImageWithoutCap(clickX, clickY, "Image\다음.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
							break
						}
						if(mod(a_index , 5) = 0)
							ClickAdb(100, 100)
					}
					loop
					{
						getAdbScreen()
						if(IsImageWithoutCap(clickX, clickY, "Image\다음.bmp", 60, 0)) ;이벤트 포인트 받기용 다음
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
							;break
						}
						if(IsImageWithoutCap(clickX, clickY, "Image\신청안함.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImageWithoutCap(clickX, clickY, "Image\퀘스트보상.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImageWithoutCap(clickX, clickY, "Image\닫기.bmp", 60, 0))
						{
							;ClickAdb(clickX, clickY)
							sleep, 5000
							break
						}
					}
					;ClickToImgAdb(clickX, clickY, "Image\닫기.bmp")
					;sleep, 3000
					loop, 5
					{
						if(IsImgPlusAdb(clickX, clickY, "Image\팝업닫기.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						sleep, 500
					}
					/*
					if(IsImgPlusAdb(clickX, clickY, "Image\이벤트배너.bmp", 60, 0))
					{
						ClickAdb(clickX, clickY)
						sleep, 3000
					}
					*/
					;;ap없으면 ap찰때까지 반복
					loop
					{
						ClickAdb(650, 120) ;;첫번째 퀘스트 다시 누르기
						sleep, 3000
						getAdbScreen()
						if(IsImageWithoutCap(clickX, clickY, "Image\ap회복.bmp", 60, 0)
						|| IsImageWithoutCap(clickX, clickY, "Image\bp회복.bmp", 60, 0))
						{
							GuiControlGet, 금사과사용, 1:

							if(금사과사용 = 1)
							{
								;사과 사용코드
								if(IsImgPlusAdb(clickX, clickY, "Image\황금색과일.bmp", 60, 0))
								;if(IsImgPlusAdb(clickX, clickY, "Image\골든경단.bmp", 60, 0))
								{								
									ClickToImgAdb(clickX, clickY, "Image\과일사용.bmp")
									ClickAdb(clickX, clickY)
									sleep, 3000
								}
								continue
							}
							else
							{
								;사과 사용안할때 코드
								ClickAdb(clickX, clickY)
								addlog("ap 없음")
								sleeplog(300000) ;;ap찰때까지 5분대기
								continue
							}	

						}
						else if(IsImgPlusAdb(clickX, clickY, "Image\팝업닫기.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						break
					}
					break
				}
				sleep, 1000
			} ;;loop

		}

	}
}

^f6::
	fileName := A_DD "_" A_HOUR "_" A_MIN "_" A_SEC "_capture.png"
	CaptureAdb(fileName)
	;CaptureAdb2("adbCapture\" filename)
return



/*
^f4::
addlog("스샷")
;objExec := objShell.Exec(comspec " /c " adb " -s " AdbSN " shell screencap -p | " perl " -pe ""binmode(STDOUT); s/\r\n/\n/g"" > test.png")
objExec := objShell.Exec(comspec " /c " adb " -s " AdbSN " shell screencap -p | " perl " -pe ""binmode(STDOUT); s/\r\n/\n/g""")
;objExec := objShell.Exec(adb " -s " AdbSN " shell screencap -p | perl.exe -pe ""binmode STDOUT; s/\r\n/\n/g"" > test.png")
;Runwait, %ComSpec% /c %adb% -s %AdbSN% shell screencap -p | %perl% -pe "binmode(STDOUT);s/\r\n/\n/g" > test.png, ,
strStdOut:=strStdErr:=""
while, !objExec.StdErr.AtEndOfStream
	strStdErr := objExec.StdErr.ReadAll()
addlog(strStdOut)
addlog(strStdErr)
return
*/


^f5:: ;; 무료 소환 반복 핫키
objExec := objShell.Exec(adb " devices")
strStdOut:=strStdErr:=""
while, !objExec.StdOut.AtEndOfStream
strStdOut := objExec.StdOut.ReadAll()
IfNotInString, strStdOut, %AdbSN%
{
	addlog("# " AdbSN " 에 재연결")
	objExec := objShell.Exec(adb " connect " AdbSN)
	while(!objExec.status)
		sleep, 10
}

loop
{
	getAdbScreen()
	if(IsImageWithoutCap(clickX, clickY, "Image\친구10회소환.bmp", 60, 0)
	|| IsImageWithoutCap(clickX, clickY, "Image\무료10회소환.bmp", 60, 0))
	{
		ClickToImgAdb(clickX, clickY, "Image\무료소환확인.bmp")
		ClickAdb(clickX, clickY)
		sleep, 1000
	}
	
	ClickAdb(520, 430)
	sleep, 1000
}
return


^f8:: ;이미지 재로딩
	Gosub, LoadImage
return



/*
^f4::
 getAdbScreen()
 if(IsImageWithoutCap2(clickX, clickY, hbm_ap회복, 60, 0))
	ClickAdb(clickX, clickY)

return

^f2::
gdipToken := Gdip_Startup()
Loop, image\*.bmp, , 1  ; Recurse into subfolders.
 {
	 aaa = %A_LoopFileName%
	 StringReplace, aaa, aaa, .bmp , , All
	 ;hbm%aaa% := 0
	bmp_%aaa% := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
	;addlog(A_LoopFileFullPath)
 }
 addlog(hbm_ap회복)


 getAdbScreen()
 if(IsImageWithoutCap2(clickX, clickY, bmp_ap회복, 60, 0))
	ClickAdb(clickX, clickY)
;msgbox, %aaa%
;Gdip_Shutdown(gdipToken)
return

;그런데 이렇게만 하면 명령만 보내고 작업이 끝났는지 알수가 없습니다. 따라서 아래의 코드를 추가합니다

/*
strStdOut:=strStdErr:=""
while, !objExec.StdOut.AtEndOfStream
	strStdOut := objExec.StdOut.ReadAll()
while, !objExec.StdErr.AtEndOfStream
	strStdErr := objExec.StdErr.ReadAll()



;결과를 모니터링 하려면 아래 코드도 써줍니다

MSGBOX,4096,, OUT:`n[`n%strStdOut%]`n`nERROR:`n[`n%strStdErr%]



;참고로 adb pull 명령의 실행 결과는 error 값으로 리턴되기때문에 strStdErr에 저장됩니다
