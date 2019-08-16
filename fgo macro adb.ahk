;fgo macro adb.ahk

#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행

;SetWorkingDir, %A_ScriptDir%	;스크립트의 작업 디렉토리를 변경. vscode autohotkey manager로 작업시 넣어줘야 폴더 인식

;인식 안될 경우에 %A_ScriptDir% 붙이기
#Include Gdip.ahk
#include functions.ahk 
#include adb_functions.ahk
#include messengerPush.ahk

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
global bmpPtrArr := [] ; 이미지서치에 사용할 이미지 비트맵의 포인터를 저장하는 배열
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
Gui, Add, Progress, x12 y9 w140 h20 cGreen Range0-100  vProgress, 0
Gui, Add, Text, x162 y15 w100 h20 +Center vSimpleLog, <대기 중>
;Gui, Add, GroupBox, x12 y39 w250 h330 , 옵션

Gui, Add, Text, x12 y50 , ADB Serial Number: 
Gui, Add, Edit, x140 y45 vEmulSN,

Gui, Add, Text, x12 y90 , 1라 점사:
Gui, Add, Text, x170 y90 , 보구 사용
Gui, Add, DropDownList, x12 y105 Choose1 AltSubmit v점사1, 전|중|후
Gui, Add, checkbox, x170 y105 v보구1라1, 1
Gui, Add, checkbox, x200 y105 v보구1라2, 2
Gui, Add, checkbox, x230 y105 v보구1라3, 3
Gui, Add, Text, x12 y130 , 2라 점사:
Gui, Add, DropDownList, x12 y145 Choose1 AltSubmit v점사2, 전|중|후
Gui, Add, checkbox, x170 y145 v보구2라1, 1
Gui, Add, checkbox, x200 y145 v보구2라2, 2
Gui, Add, checkbox, x230 y145 v보구2라3, 3
Gui, Add, Text, x12 y170 , 3라 점사:
Gui, Add, DropDownList, x12 y185 Choose1 AltSubmit v점사3, 전|중|후
Gui, Add, checkbox, x170 y185 v보구3라1, 1
Gui, Add, checkbox, x200 y185 v보구3라2, 2
Gui, Add, checkbox, x230 y185 v보구3라3, 3
Gui, Add, checkbox, x12 y210 v금사과사용, 금사과 사용

Gui, Add, Button, x12 y240 w70 h30  gOneClick, 실행
Gui, Add, Button, x92 y240 w70 h30  gReset, 재시작
Gui, Add, Button, x200 y240 w50 h30 gMenuInfo, 설명

Gui, Add, ListBox, x12 y290 w330 h180 vLogList,
Gui, 2: +Owner1

Gui, 2: Add, Text, ,해상도: 800 x 450`n`n배틀 메뉴에서 스킬 사용 확인 OFF`n`nCtrl+F6 : 스샷찍기`n`nCtrl+F3 : 무료소환반복`n`nCtrl+F8 : 이미지 재로딩

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

gdipToken := Gdip_Startup()
Gosub, LoadImage

log := "# 동작 대기"
AddLog(log)
return

LoadImage:
	imageNum := 0
	AddLog("# 이미지 로딩 중...")
	;gdipToken := Gdip_Startup()
	Loop, image\*.bmp, , 1  ; Recurse into subfolders.
	{
		imgFileName = %A_LoopFileName%
		StringReplace, imgFileName, imgFileName, .bmp , , All

		if(!bmpPtrArr[(imgFileName)] := Gdip_CreateBitmapFromFile(A_LoopFileFullPath))
			Addlog("  " A_LoopFileName " 로딩 실패")		
		;else
			;Addlog("  " A_LoopFileName )
		imageNum++
	}
	AddLog("# 이미지 " imageNum "장 로딩 완료")
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

showInfo := 0
MenuInfo:
	if(!showInfo)
	{
		RealWinSize(posX, posY, width, height, MacroID)
		ChildX := posX + width + 10
		ChildY := posY
		Gui, 2: Show, x%ChildX% y%ChildY% , 설명
		showInfo := 1
	}
	else
	{
		Gui, 2: Show, hide
		showInfo := 0
	}
Return

GuiClose:
Clean_up: ;매크로 끌때
	Gosub, SaveOption
	;DllCall("DeleteObject", Ptr,g_hBitmap) ;파일쓰기 없이 adb서치용 hBitmap 비움.
	DllCall("CloseHandle", "uint", hCon)
	DllCall("FreeConsole")
	Process, Close, %cPid%
	Gdip_Shutdown(gdipToken)
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

		if(IsImgPlusAdb(clickX, clickY, "돌아가기.bmp", 60, 0))
		{
			clickX := 400
			clickY := 200
			ClickToImgAdb(clickX, clickY, "퀘스트개시.bmp")
			sleep, 5000
			ClickAdb(clickX, clickY)
			sleep, 1500
			if(IsImgPlusAdb(clickX, clickY, "아이템을사용하지않고.bmp", 60, 0)) ;퀘스트개시를 눌러도 뭐가 뜰때 여기 이미지 변경
			{
				ClickAdb(clickX, clickY)
			}
			addlog("# 반복 " rCount "회차 시작")
			sleep, 10000 ; 10초 대기
			ii = 0
			loop
			{
				if(IsImgPlusAdb(clickX, clickY, "attack.bmp", 60, 0))
					break

				if(ii > 60 && IsImgPlusAdb(clickX, clickY, "퀘스트개시.bmp", 60, 0))
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
				if(IsImgPlusAdb(clickX, clickY, "attack.bmp", 60, 0))
				{
					sleep, 500
					getAdbScreen()				

					;;라운드 알아내기
					if(IsImgWithoutCap(clickX, clickY, "Battle2.bmp", 120, "black", 541, 9, 551, 22))
					{
						if(라운드 = 1)
							라운드시작 := true	
						라운드 := 2											
					}
					else if(IsImgWithoutCap(clickX, clickY, "Battle3.bmp", 120, "black", 541, 9, 551, 22))
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
					스킬사용("s_방업")
					스킬사용("s_공업")
					스킬사용("s_np획득량")
					스킬사용("s_np업")
					스킬사용("s_스타")
					스킬사용("s_버스터", 110)
					스킬사용("s_스집", 110)
					스킬사용("s_거츠")

					/*
					loop, 9
					{
						if(IsImgWithoutCap(clickX, clickY, "s_방업1.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						|| IsImgWithoutCap(clickX, clickY, "s_방업2.bmp", 150, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 방업 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 1000
							ClickAdb(690, 110) ; 선택창 떴을 때 끄기
							sleep, 2000
							break
						}
					}		
					*/

					ClickAdb(710, 410) ;어택 클릭					
					sleep, 2000

					;;;;;;;;;;;;;;;;;;;커맨드 카드 사용;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					Loop
					{
						getAdbScreen() ;한번 가져온 스샷으로 여러번 이미지 서치
						if(!IsImgWithoutCap(clickX, clickY, "attack.bmp", 60, 0))
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
						if(IsImgWithoutCap(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
						&& IsImgWithoutCapLog(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
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
						if(IsImgWithoutCap(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
						&& IsImgWithoutCapLog(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
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
						if(IsImgWithoutCap(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 ))
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
						if(!IsImgWithoutCap(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
						&& IsImgWithoutCapLog(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
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
						if(!IsImgWithoutCap(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
						&& IsImgWithoutCapLog(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
						&& IsImgWithoutCapLog(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
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
						if(!IsImgWithoutCap(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 ))
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
				if(IsImgWithoutCap(clickX, clickY, "전투x.bmp", 60, 0))
				{
					ClickAdb(clickX, clickY)
					sleep, 2000
				}
		
				if(IsImgWithoutCap(clickX, clickY, "result.bmp", 45, "black", 462, 20, 492, 55))
				;|| IsImgWithoutCap(clickX, clickY, "인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
				{
					ClickAdb(clickX, clickY)
					sleep, 3000
					loop
					{
						getAdbScreen()
						if(IsImgWithoutCap(clickX, clickY, "result.bmp", 60, "black", 462, 20, 492, 55))
						;|| IsImgWithoutCap(clickX, clickY, "인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImgWithoutCap(clickX, clickY, "다음.bmp", 60, 0))
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
						if(IsImgWithoutCap(clickX, clickY, "다음.bmp", 60, 0)) ;이벤트 포인트 받기용 다음
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
							;break
						}
						if(IsImgWithoutCap(clickX, clickY, "신청안함.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImgWithoutCap(clickX, clickY, "퀘스트보상.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImgWithoutCap(clickX, clickY, "닫기.bmp", 60, 0))
						{
							;ClickAdb(clickX, clickY)
							sleep, 5000
							break
						}
					}
					;ClickToImgAdb(clickX, clickY, "닫기.bmp")
					;sleep, 3000
					loop, 5
					{
						if(IsImgPlusAdb(clickX, clickY, "팝업닫기.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						sleep, 500
					}
					/*
					if(IsImgPlusAdb(clickX, clickY, "이벤트배너.bmp", 60, 0))
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
						if(IsImgWithoutCap(clickX, clickY, "ap회복.bmp", 60, 0)
						|| IsImgWithoutCap(clickX, clickY, "bp회복.bmp", 60, 0))
						{
							GuiControlGet, 금사과사용, 1:

							if(금사과사용 = 1)
							{
								;사과 사용코드
								if(IsImgPlusAdb(clickX, clickY, "황금색과일.bmp", 60, 0))
								;if(IsImgPlusAdb(clickX, clickY, "골든경단.bmp", 60, 0))
								{								
									ClickToImgAdb(clickX, clickY, "과일사용.bmp")
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
						else if(IsImgPlusAdb(clickX, clickY, "팝업닫기.bmp", 60, 0))
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

스킬사용(skillName, errorRange = 150) ;스킬이미지이름에서 숫자뺀거, 이미지 갯수
{
	loop ;;스킬이미지가 몇개 인지 확인하는 루프
	{
		if(!bmpPtrArr[(skillName) a_index])
		{
			imageNum := a_index - 1
			break
		}		
	}

	;breakLoop := 0
	loop, 9
	{
		buttonNum := a_index
		loop, %imageNum%
		{			
			if(IsImgWithoutCap(clickX, clickY, skillName a_index ".bmp", errorRange, 0, SkillButtonPos[buttonNum].sX, SkillButtonPos[buttonNum].sY, SkillButtonPos[buttonNum].eX, SkillButtonPos[buttonNum].eY))
			{
				addlog("# " buttonNum " 번 칸 " skillName " 스킬 사용")
				ClickAdb(SkillButtonPos[buttonNum].sX+20, SkillButtonPos[buttonNum].sY+20)
				sleep, 500
				ClickAdb(690, 110) ; 선택창 떴을 때 끄기
				sleep, 2500
				;breakLoop := 1
				;break
				return
			}			
		}		
		;if(breakLoop)
		;	break		
	}
}

^f6::
	fileName := A_DD "_" A_HOUR "_" A_MIN "_" A_SEC "_capture.png"
	CaptureAdb(fileName)
	;CaptureAdb2("adbCapture\" filename)
return



^f3:: ;; 무료 소환 반복 핫키
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
	if(IsImgWithoutCap(clickX, clickY, "친구10회소환.bmp", 60, 0)
	|| IsImgWithoutCap(clickX, clickY, "무료10회소환.bmp", 60, 0))
	{
		ClickToImgAdb(clickX, clickY, "무료소환확인.bmp")
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




^f4::
	;PushLine("English 한글")
	;PushLine("English 한글","utility/17_02_16_29_capture.png")
	;PushTelegram("English 한글")
	PushTelegram("English 한글","adbCapture/17_02_16_00_capture.png")
return

/*
^f2::
getAdbScreen()
if(IsImgWithoutCap(clickX, clickY, "ap회복.bmp", 60, 0))
	ClickAdb(clickX, clickY)

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
