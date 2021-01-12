;fgo macro adb.ahk ;테스트

#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행
#NoEnv ;변수명을 해석할 때, 환경 변수를 무시한다 (속도 상승)
SetBatchLines, -1 ; 스크립트 최고속도로

SetWorkingDir, %A_ScriptDir%	;스크립트의 작업 디렉토리를 변경. vscode autohotkey manager로 작업시 넣어줘야 폴더 인식

CoordMode,ToolTip,Screen ;ToolTip

;인식 안될 경우에 %A_ScriptDir% 붙이기
#Include Gdip.ahk
#include functions.ahk 
#include adb_functions.ahk
#Include CreateFormData.ahk

OnExit, Clean_up

global adb := "utility\adb.exe"
global AdbSN ;:= "emulator-5556" ;;그외 에뮬레이터
;"127.0.0.1:62001" ;;녹스
;127.0.0.1:21503 ;미뮤
;127.0.0.1:7555 ;mumu

global bmpPtrArr := [] ; 이미지서치에 사용할 이미지 비트맵의 포인터를 저장하는 배열
global ConfigFile := "Config.ini"
global rCount ;
global 메인종료 := 0 ; 1이되면 메인함수 종료

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

Gui, Add, Tab2, x10 w350 h240, 퀘스트|기타|텔레그램|설명
Gui, Tab, 퀘스트

Gui, Add, Text, xp+5 yp+30, Android Serial Number:
Gui, Add, Edit, x+10 vAdbSN,

Gui, Add, Text, x15 y71 , 1라 점사: ;;점사 기준점
Gui, Add, DropDownList,  Choose1 AltSubmit v점사1, 전|중|후
Gui, Add, Text, , 2라 점사:
Gui, Add, DropDownList, Choose1 AltSubmit v점사2, 전|중|후
Gui, Add, Text, , 3라 점사:
Gui, Add, DropDownList, Choose1 AltSubmit v점사3, 전|중|후

Gui, Add, Text, x+10 y71 , 보구 사용  ;;보구 사용 기준점
Gui, Add, checkbox, xp yp+20 v보구1라1, 1
Gui, Add, checkbox, xp+30 v보구1라2, 2
Gui, Add, checkbox, xp+30  v보구1라3, 3
Gui, Add, checkbox, xp-60 yp+45 v보구2라1, 1
Gui, Add, checkbox, xp+30 v보구2라2, 2
Gui, Add, checkbox, xp+30  v보구2라3, 3
Gui, Add, checkbox, xp-60 yp+45 v보구3라1, 1
Gui, Add, checkbox, xp+30 v보구3라2, 2
Gui, Add, checkbox, xp+30 v보구3라3, 3

Gui, Add, Text, x+8 y71  w100, 공슼 차지 사용 ;;공멀 기술 기준점
Gui, Add, checkbox, xp+10 yp+20 v공명1, 1
Gui, Add, checkbox, xp+30  v공명2, 2
Gui, Add, checkbox, xp+30   v공명3, 3

Gui, Add, Text, xp-70 yp+20  w100, 멀린 버프 사용 ;;공멀 기술 기준점
Gui, Add, checkbox, xp+10 yp+20 v멀린1, 1
Gui, Add, checkbox, xp+30  v멀린2, 2
Gui, Add, checkbox, xp+30   v멀린3, 3

Gui, Add, Text, xp-70 yp+20  w100, 스카디 버프 사용 ;;공멀 기술 기준점
Gui, Add, checkbox, xp+10 yp+20 v스카디1, 1
Gui, Add, checkbox, xp+30  v스카디2, 2
Gui, Add, checkbox, xp+30   v스카디3, 3

Gui, Add, checkbox, x12 y220 v금사과사용, 금사과 사용

Gui, Tab, 텔레그램
Gui, Add, Text, ,텔레그램 Chat ID :
Gui, Add, Edit, vChatID,
Gui, Add, Text, ,텔레그램 BOT api Token :
Gui, Add, Edit, w320 vbotToken,

Gui, Tab, 설명
Gui, Add, Text, ,앱플레이어 해상도: 800 x 450
Gui, Add, Text, ,배틀 메뉴에서 스킬 사용 확인 OFF
Gui, Add, Text, ,공멀슼 스킬은 항상 첫번째 자리에만 사용
Gui, Add, Text, ,Ctrl+F6 : 스샷찍기

Gui, Tab, 기타
Gui, Add, Button, h30 gLoadImage, 이미지 파일 로드
Gui, Add, Button, h30 g스크린샷, 스크린샷
Gui, Add, Button, h30 g무료소환, 무료소환
Gui, Add, Button, h30 g룰렛돌리기, 룰렛돌리기

Gui, Tab

Gui, Add, Button, x10 y250 w70 h30  gOneClick, 실행
Gui, Add, Button, x+10 w70 h30  gReset, 재시작
;Gui, Add, Button, x+10 w50 h30 gMenuInfo, 설명

Gui, Add, ListBox, x10 y+10 w350 h200 vLogList,

; Gui, 2: +Owner1
; Gui, 2: Add, Text, ,앱플레이어 해상도: 800 x 450`n`

GuiControl, Focus, LogList 

IfNotExist, %ConfigFile%
{
	initX := 100
	initY := 100,
}
IfExist, %ConfigFile%
	Gosub, LoadOption

Gosub, Attach

GuiControlGet, AdbSN, 1: ;adb 에뮬 시리얼
GuiControlGet, chatID, 1: ;텔레그램
GuiControlGet, botToken, 1:

Gui, Show,  x%initX% y%initY% , %MacroID% ; h350 w194

gdipToken := Gdip_Startup()
Gosub, LoadImage

log := "# 동작 대기"
AddLog(log)
return

LoadImage:
	For Key , in bmpPtrArr
		Gdip_DisposeImage(bmpPtrArr[(Key)]) ;기존에 로딩되어있던 이미지 메모리에서 지움

	imageNum := 0
	AddLog("# 이미지 로딩 중...")
	;gdipTokenA := Gdip_Startup()
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
	
	; 이미지 비트맵을 복사해서 새로운 비트맵 만들기 (이미지 파일 수정하기 위함)
	For Key , in bmpPtrArr 
	{	
		Gdip_GetImageDimensions(bmpPtrArr[(Key)], Width, Height)
		newBitmap := Gdip_CreateBitmap(Width, Height)
		G := Gdip_GraphicsFromImage(newBitmap)
		Gdip_DrawImage(G, bmpPtrArr[(Key)], 0, 0, Width, Height)
		Gdip_DeleteGraphics(G)
		Gdip_DisposeImage(bmpPtrArr[(Key)])
		bmpPtrArr[(Key)] := newBitmap
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
	IniRead, IniAdbSN, %ConfigFile%, Option, AdbSN
	GuiControl,, AdbSN, %IniAdbSN%
	IniRead, InibotToken, %ConfigFile%, Option, botToken
	GuiControl,, botToken, %InibotToken%
	IniRead, InichatID, %ConfigFile%, Option, chatID
	GuiControl,, chatID, %InichatID%
	
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
	loop, 3
	{
		IniRead, 공명%a_index%, %ConfigFile%, Option, 공명%a_index%
		temp := 공명%a_index%
		GuiControl,, 공명%a_index%, %temp%
	}
	loop, 3
	{
		IniRead, 멀린%a_index%, %ConfigFile%, Option, 멀린%a_index%
		temp := 멀린%a_index%
		GuiControl,, 멀린%a_index%, %temp%
	}
	loop, 3
	{
		IniRead, 스카디%a_index%, %ConfigFile%, Option, 스카디%a_index%
		temp := 스카디%a_index%
		GuiControl,, 스카디%a_index%, %temp%
	}
	log := "# 설정 불러오기 완료"
	AddLog(log)
return

SaveOption: ;세이브옵션
	WinGetPos, posX, posY, width, height,  %MacroID%
	IniWrite, %posX%, %ConfigFile%, Position, X
	IniWrite, %posY%, %ConfigFile%, Position, Y
	;ADB 시리얼
	GuiControlGet, AdbSN, 1:
	IniWrite, %AdbSN%, %ConfigFile%,  Option, AdbSN
	GuiControlGet, chatID,
	IniWrite, %chatID%, %ConfigFile%,  Option, chatID
	GuiControlGet, botToken, 
	IniWrite, %botToken%, %ConfigFile%,  Option, botToken
	
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
	loop, 3
	{
		GuiControlGet, 공명%a_index%, 
		temp := 공명%a_index%
		IniWrite, %temp%, %ConfigFile%,  Option, 공명%a_index%
	}
	loop, 3
	{
		GuiControlGet, 멀린%a_index%, 
		temp := 멀린%a_index%
		IniWrite, %temp%, %ConfigFile%,  Option, 멀린%a_index%
	}
	loop, 3
	{
		GuiControlGet, 스카디%a_index%, 
		temp := 스카디%a_index%
		IniWrite, %temp%, %ConfigFile%,  Option, 스카디%a_index%
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
	DllCall("CloseHandle", "uint", hCon) ;;cmd 생성
	DllCall("FreeConsole") ;cmd 생성
	Process, Close, %cPid% ;cmd 생성
	Gdip_Shutdown(gdipToken) ;gdip 끄기
	ExitApp
return

OneClick: ;;원클릭
	if(!메인함수())
	{
		addlog("# 에러 발생")
	}	
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
	AddLog("# 페그오 매크로 시작 ")
	메인종료 := 0
	
	GuiControlGet, chatID ,
	GuiControlGet, botToken , 
	if(chatID)
		SetTimer, TelegramGetUpdates, 10000 ; 10초마다 텔레그램 메시지 읽어오기
	
	GuiControlGet, AdbSN,  ;adb 에뮬 시리얼
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
			addlog("# " AdbSN " 에 연결")
			objExec := objShell.Exec(adb " connect " AdbSN)
			while(!objExec.status)
				sleep, 10
		}
		
		if(!퀘스트준비())
		{
			return false
		}
		if(!퀘스트배틀())
		{
			return false
		}
		if(!배틀피니쉬())
		{
			return false
		}
	}
}

퀘스트준비()
{
	getAdbScreen()
	if(IsImgWithoutCap(clickX, clickY, "돌아가기.bmp", 60, 0))
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
				return true

			if(ii > 60 && IsImgPlusAdb(clickX, clickY, "퀘스트개시.bmp", 60, 0))
			{
				ClickAdb(clickX, clickY)
				ii := 0
			}

			ii++
			sleep, 1000
		}
	}
	else if(IsImgWithoutCap(clickX, clickY, "attack.bmp", 60, 0))
	{
		addlog("# 반복 " rCount "회차 시작")
		return true
	}
	else
	{
		addlog("매크로 시작 실패")
		return false
	}
}

퀘스트배틀()
{
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
			loop, 3
			{
				if(라운드 = a_index && 라운드시작 = 1)
				{
					addlog("# " a_index "라 시작")
					라운드시작 := false
					GuiControlGet, 점사%a_index%, 1:
					if(점사%a_index% != 1)							
						ClickAdb(EnemyPos[점사%a_index%].X, EnemyPos[점사%a_index%].Y)
					sleep, 500
					ClickAdb(663,93)
					sleep, 1000
				}
			}

			;;;;공멀 스킬사용
			loop, 3
			{
				GuiControlGet, 공명%a_index%,
				if(라운드 = a_index && 공명%a_index%)
				{					
					if(IsImgWithoutCap(clickX, clickY, "s_크리1.bmp", 60, 0, SkillButtonPos[7].sX, SkillButtonPos[7].sY, SkillButtonPos[7].eX, SkillButtonPos[7].eY)
					&& IsImgWithoutCap(clickX, clickY, "공명.bmp", 120, "black", 500, 433, 550, 448))
					{
						ClickAdb(440, 360)
						sleep, 500
						ClickAdb(220, 260)
						sleep, 3000
						getAdbScreen()
					}
					if(IsImgWithoutCap(clickX, clickY, "s_np업1.bmp", 60, 0, SkillButtonPos[9].sX, SkillButtonPos[9].sY, SkillButtonPos[9].eX, SkillButtonPos[9].eY))
					&& IsImgWithoutCap(clickX, clickY, "스카디.bmp", 120, "black", 500, 433, 550, 448)
					{
						ClickAdb(560, 360)
						sleep, 500
						ClickAdb(220, 260)
						sleep, 3000
						getAdbScreen()
					}
				}
				GuiControlGet, 멀린%a_index%,
				if(라운드 = a_index && 멀린%a_index%)
				{			
					if(IsImgWithoutCap(clickX, clickY, "s_버스터1.bmp", 60, 0, SkillButtonPos[9].sX, SkillButtonPos[9].sY, SkillButtonPos[9].eX, SkillButtonPos[9].eY))
					&& IsImgWithoutCap(clickX, clickY, "멀린.bmp", 120, "black", 500, 433, 550, 448)
					{
						ClickAdb(560, 360)
						sleep, 500
						ClickAdb(220, 260)
						sleep, 3000
						getAdbScreen()
					}
				}				
				GuiControlGet, 스카디%a_index%,
				if(라운드 = a_index && 스카디%a_index%)
				{			
					if(IsImgWithoutCap(clickX, clickY, "s_퀵1.bmp", 60, 0, SkillButtonPos[7].sX, SkillButtonPos[7].sY, SkillButtonPos[7].eX, SkillButtonPos[7].eY))
					&& IsImgWithoutCap(clickX, clickY, "스카디.bmp", 120, "black", 500, 433, 550, 448)
					{
						ClickAdb(440, 360)
						sleep, 500
						ClickAdb(220, 260)
						sleep, 3000
						getAdbScreen()
					}
				}
			}

			;;;;;;;;;;;;;;;;;;;;;;;;;; 스킬 사용 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			loop, 3
			{
				if(IsImgWithoutCap(clickX, clickY, "적풀차지.bmp", 90, 0, EnemyPos[a_index].X, EnemyPos[a_index].Y, EnemyPos[a_index].X+90, EnemyPos[a_index].Y+40)
				&& IsImgWithoutCap(clickX, clickY, "적금테.bmp", 90, 0, EnemyPos[a_index].X+10, EnemyPos[a_index].Y-5, EnemyPos[a_index].X+25, EnemyPos[a_index].Y+5))
				{
					;적이 금테이고 풀차지일 때만 무적 사용
					;addlog(a_index " 번 적 보구 준비")
					스킬사용("s_무적")
				}
			}
			스킬사용("s_방업")
			스킬사용("s_공업")
			스킬사용("s_방깎")
			스킬사용("s_공깎")
			스킬사용("s_np획득량")
			스킬사용("s_np업")
			스킬사용("s_스타")
			스킬사용("s_버스터", 110)
			스킬사용("s_아츠")
			스킬사용("s_퀵")
			스킬사용("s_스집", 110)
			스킬사용("s_거츠")
			스킬사용("s_회피")

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
				sleep, 1500
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
				sleep, 300
			}
			if((라운드 = 1 && 보구1라2) || 라운드 = 2 && 보구2라2) || (라운드 = 3 && 보구3라2)
			{
				ClickAdb(405, 80)
				sleep, 300
			}
			if((라운드 = 1 && 보구1라3) || 라운드 = 2 && 보구2라3) || (라운드 = 3 && 보구3라3)
			{
				ClickAdb(550, 80)
				sleep, 300
			}					

			loop, 5
				card%a_index% := 0 ;skill 배열: 사용한 카드는 1

			loop, 5 ;이펙티브 버스터 우선 사용
			{
				if(IsImgWithoutCapLog(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
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
				if(IsImgWithoutCapLog(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
				&& IsImgWithoutCapLog(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
				&& IsImgWithoutCapLog(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
				{
					ClickAdb(CmdCardPos[a_index].sX + 80, 320)
					card%a_index% := 1
					sleep, 300
				}
			}
			
			loop, 5 ;레지스트 아닌 버스터 사용
			{
				if(card%a_index% = 1)
					continue
				if(!IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
				&& IsImgWithoutCapLog(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
				&& IsImgWithoutCapLog(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
				{
					ClickAdb(CmdCardPos[a_index].sX + 80, 320)
					card%a_index% := 1
					sleep, 300
				}
			}

			loop, 5 ;남은 이펙티브 사용 (이펙티브 퀵)
			{
				if(card%a_index% = 1)
					continue
				if(IsImgWithoutCap(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-20, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 ))
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
				if(!IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
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
				if(!IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-5, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 ))
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
		sleep, 1000

		getAdbScreen()
		if(IsImgWithoutCap(clickX, clickY, "어택돌아가기.bmp", 60, 0))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		if(IsImgWithoutCap(clickX, clickY, "전투x.bmp", 60, 0))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		if(IsImgWithoutCap(clickX, clickY, "스킬사용불가.bmp", 60, 0))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}

		;;전멸했을 시
		if(IsImgWithoutCap(clickX, clickY, "영주사용.bmp", 60, 0)
		|| IsImgWithoutCap(clickX, clickY, "철수하기.bmp", 60, 0))
		{
			fileName := "파티전멸.png"
			CaptureAdb(fileName)
			SendTelegramImg("adbCapture/" fileName)
			addlog("# 파티 전멸, 텔레그램 전송")
			return false
		}

		;;전투가 끝났을 시
		if(IsImgWithoutCap(clickX, clickY, "result.bmp", 60, "black", 462, 20, 492, 55))		
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
			return true				
		}

		if(메인종료 = 1)
			return false
		sleep, 1000
	} ;loop
}

배틀피니쉬()
{
	loop
	{
		getAdbScreen()
		if(IsImgWithoutCap(clickX, clickY, "result.bmp", 60, "black", 462, 20, 492, 55))
		;|| IsImgWithoutCap(clickX, clickY, "인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		if(IsImgWithoutCap(clickX, clickY, "다음.bmp", 60, 0))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
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
			sleep, 1000
			;break
		}
		if(IsImgWithoutCap(clickX, clickY, "친구신청종료.bmp", 60, 0)) ;친구신청 뜰때
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		if(IsImgWithoutCap(clickX, clickY, "퀘스트보상.bmp", 60, 0, 500, 250, 800, 450))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		if(IsImgWithoutCap(clickX, clickY, "연속출격닫기.bmp", 60, 0))
		{
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		if(IsImgWithoutCap(clickX, clickY, "닫기.bmp", 60, 0))
		{
			;ClickAdb(clickX, clickY)
			sleep, 1000
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
		if(IsImgWithoutCap(clickX, clickY, "ap회복.bmp", 60, 0))
		;|| IsImgWithoutCap(clickX, clickY, "bp회복.bmp", 60, 0))
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
				addlog("# ap 없음")
				sleeplog(300000) ;;ap찰때까지 5분대기
				continue
			}	

		}
		else if(IsImgPlusAdb(clickX, clickY, "팝업닫기.bmp", 60, 0))
		{
			ClickAdb(clickX, clickY)
			sleep, 3000
		}
		else if(IsImgWithoutCap(clickX, clickY, "돌아가기.bmp", 60, 0))	
			return true
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
				sleep, 2000
				;breakLoop := 1
				;break
				return
			}			
		}		
		;if(breakLoop)
		;	break		
	}
}

TelegramGetUpdates:
	if(!msg := getTelegramMsg())
		return
	
	Addlog("# 텔레그램 커맨드")
	switch msg
	{
		case "스샷":
			fileName := A_yyyy a_mm A_DD "_" A_HOUR  A_MIN  A_SEC ".png"
			CaptureAdb(fileName)		
			SendTelegramImg("adbCapture/" fileName)	
				
		case "정보":
			SendTelegram("반복 횟수: " rCount)

		case "철수하기":	
			ClickAdb(200, 200)
			메인종료 := 1

		case "영주사용":
			ClickAdb(400, 200)
			sleep, 5000
			fileName := "영주사용.png"
			CaptureAdb(fileName)		
			SendTelegramImg("adbCapture/" fileName)
	}
return

좌표툴팁(x, y, str)
{
	RealWinSize(posX, posY, width, height, "페이트/그랜드오더")
	tipX := posX 
	tipY := posY + 36 ;뮤뮤 제목 높이
	tipX+= x
	tipY+= y
	ToolTip, %str%, %tipX%,%tipY%
}

룰렛돌리기:
	loop
	{
		ClickAdb(270, 270)
		sleep, 200
	}

return

^f6::
스크린샷:	
	fileName := A_yyyy a_mm A_DD "_" A_HOUR  A_MIN  A_SEC ".png"
	CaptureAdb(fileName)
return

무료소환: ;; 무료 소환 반복 핫키
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

	getAdbScreen()
	if(IsImgWithoutCap(clickX, clickY, "친구10회소환.bmp", 60, 0)
	|| IsImgWithoutCap(clickX, clickY, "무료10회소환.bmp", 60, 0))
	{
		ClickToImgAdb(clickX, clickY, "무료소환확인.bmp")
		ClickAdb(clickX, clickY)
		sleep, 1000
	}
	loop
	{
		getAdbScreen()
		if(IsImgWithoutCap(clickX, clickY, "무료소환확인.bmp", 60, 0))		
		{			
			ClickAdb(clickX, clickY)
			sleep, 1000
		}
		
		ClickAdb(520, 430)
		sleep, 1000
	}
return

; ^f3::
; ;addlog(getTelegramMsg())
; SendLine("asdfas하하하", "adbCapture/파티전멸.png")
; return

; ^f4::
; addlog("하하")
; getAdbScreen()
; loop, 3
; {	
; 	if(IsImgWithoutCap(clickX, clickY, "적풀차지.bmp", 90, 0, EnemyPos[a_index].X, EnemyPos[a_index].Y, EnemyPos[a_index].X+90, EnemyPos[a_index].Y+40))
; 	{
; 		addlog(a_index "번 적 풀차지")
; 	}
; 	if(IsImgWithoutCap(clickX, clickY, "적금테.bmp", 90, 0, EnemyPos[a_index].X+10, EnemyPos[a_index].Y-5, EnemyPos[a_index].X+25, EnemyPos[a_index].Y+5))
; 	{
; 		addlog(a_index "번 적 금테")
; 	}
; }
; return

/*
 ^F2::
;fileName := A_DD "d_" A_HOUR "h_" A_MIN "m_" A_SEC "s.png"
;		CaptureAdb(fileName)
		addlog("zz")
		SendTelegramImg2("adbCapture/party.png")
 return


; ^f4::
; 	array := [[1,2,3],[4,5,6]]
; 	addlog(array[2,1])
; return
;*/

;/*

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
