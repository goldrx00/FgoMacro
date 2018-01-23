;;;;UTF-8로 인코딩
;;새가지
#Include Gdip.ahk
#include functions.ahk
#include adb_functions.ahk

#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행

OnExit, Clean_up

global adb := "utility\adb.exe"
;global adb := "C:\Users\goldr\Desktop\platform-tools\adb.exe"
global perl := "utility\perl.exe"
global AdbSN ;:= "emulator-5556" ;;그외 에뮬레이터

;global AdbSN := "127.0.0.1:21503" ;;녹스, 미뮤 등

global TIME_REFRESH := 250 ;매크로 대기시간 (화면전환 등)
global nLog := 1 ;;기록
global OnRunning := 0
global hBitmap ;adb 이미지 서치용 hBitmap
global 옵지모드 := 0 ;매크로 모드
global OptionFile := "Option.ini"

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

global CharacterPosition := [{sX: 10, 	sY: 234,		eX: 195, 	eY: 450}
,{sX: 209, 	sY: 234,		eX: 395, 	eY: 450}
,{sX: 409, 	sY: 234,		eX: 594, 	eY: 450}]

global MacroID := "페그오 매크로"
;Menu, Tray, Icon, Image\Icon1.ico
Gui, Add, Progress, x12 y9 w80 h20 cGreen Range0-100  vProgress, 0
Gui, Add, Text, x182 y15 w80 h20 +Center vSimpleLog, <대기 중>
Gui, Add, GroupBox, x12 y39 w250 h330 , 옵션
Gui, Add, Text, x22 y59 w140 h150, 모드
Gui, Add, DropDownList, x22 y80 Choose1 AltSubmit vMacroMode gMacroMode, 1.에뮬모드|2.옵지모드

Gui, Add, Text, x22 y160 , 에뮬 ADB Serial Number:
Gui, Add, Edit, x22 y180 vEmulSN,
Gui, Add, Text, x22 y210 , 폰 ADB Serial Number:
Gui, Add, Edit, x22 y230 vPhoneSN,
;Gui, Add, ComboBox, x22 y200 Choose1 vAdbSerial, | |

Gui, Add, Button, x22 y280 w50 h30 gMenuInfo, 설명
Gui, Add, Button, x82 y280 w50 h30 gMenuLog, 기록
Gui, Add, Button, x22 y320 w70 h30  gOneClick, 실행
Gui, Add, Button, x102 y320 w70 h30  gReset, 재시작

Gui, 3: Add, ListBox, x12 y9 w330 h310 vLogList,
Gui, 3: +Owner1

Gui, 5: Add, Text, ,해상도: 800 x 450`n`n배틀 메뉴에서 스킬 사용 확인 OFF`n`nCtrl+F6 : 스샷찍기

IfNotExist, %OptionFile%
{
	initX := 100
	initY := 100,
}
IfExist, %OptionFile%
	Gosub, LoadOption

Gosub, Attach

GuiControlGet, MacroMode, 1:
if(MacroMode = 1)
{
	GuiControlGet, EmulSN, 1: ;adb 에뮬 시리얼
	AdbSN := EmulSN
}
else
{
	옵지모드 := 1
	GuiControlGet, PhoneSN, 1:
	AdbSN := PhoneSN
}

Gui, Show,  x%initX% y%initY% , %MacroID% ; h350 w194
log := "# 동작 대기"
AddLog(log)
return

LoadOption:
IniRead, initX, %OptionFile%, Position, X
IniRead, initY, %OptionFile%, Position, Y
if(initX < 0 || initY < 0)
{
	initX := 100
	initY := 100
}
;재입장
IniRead, IniEmulSN, %OptionFile%, Option, EmulSN
GuiControl,, EmulSN, %IniEmulSN%
IniRead, IniPhoneSN, %OptionFile%, Option, PhoneSN
GuiControl,, PhoneSN, %IniPhoneSN%

IniRead, MacroMode, %OptionFile%, Option, MacroMode
GuiControl, Choose, MacroMode, %MacroMode%
log := "# 설정 불러오기 완료"
AddLog(log)
return

SaveOption: ;세이브옵션
IfExist, %OptionFile%
	FileDelete, %OptionFile%
WinGetPos, posX, posY, width, height,  %MacroID%
IniWrite, %posX%, %OptionFile%, Position, X
IniWrite, %posY%, %OptionFile%, Position, Y
;ADB 시리얼
GuiControlGet, EmulSN, 1:
IniWrite, %EmulSN%, %OptionFile%,  Option, EmulSN
GuiControlGet, PhoneSN, 1:
IniWrite, %PhoneSN%, %OptionFile%,  Option, PhoneSN
;매크로모드
GuiControlGet, MacroMode, 1:
IniWrite, %MacroMode%, %OptionFile%,  Option, MacroMode
return

MenuLog:
RealWinSize(posX, posY, width, height, MacroID)
ChildX := posX + width + 10
ChildY := posY
Gui, 3: Show, x%ChildX% y%ChildY%  h320 , 기록 ;
Return

MenuInfo:
RealWinSize(posX, posY, width, height, MacroID)
ChildX := posX + width + 10
ChildY := posY
Gui, 5: Show, x%ChildX% y%ChildY% , 설명
Return

GuiClose:
Clean_up: ;매크로 끌때
Gosub, SaveOption
;DllCall("DeleteObject", Ptr,hBitmap) ;파일쓰기 없이 adb서치용 hBitmap 비움.
DllCall("CloseHandle", "uint", hCon)
DllCall("FreeConsole")
Process, Close, %cPid%
ExitApp
return

MacroMode:
GuiControlGet, MacroMode, 1:
if(MacroMode = 1)
{
	GuiControlGet, EmulSN, 1: ;adb 에뮬 시리얼
	AdbSN := EmulSN
}
else
{
	옵지모드 := 1
	GuiControlGet, PhoneSN, 1:
	AdbSN := PhoneSN
}
Addlog("에이디비 변경")
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

	;GuiControlGet, EmulSN, 1: ;adb 시리얼 받기
	GuiControlGet, MacroMode, 1:
	if(MacroMode = 1)
	{
		GuiControlGet, EmulSN, 1: ;adb 에뮬 시리얼
		AdbSN := EmulSN
	}
	else
	{
		옵지모드 := 1
		GuiControlGet, PhoneSN, 1:
		AdbSN := PhoneSN
	}
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
			라운드3 := 0
			Loop
			{
				;;attack.bmp가 발견되면 배틀 시작한 것
				if(IsImgPlusAdb(clickX, clickY, "Image\attack.bmp", 60, 0))
				{
					sleep, 500
					getAdbScreen()

					;;3라운드에는 먼저 보구부터 사용한다.
					if(라운드3 = 0 && IsImageWithoutCap(clickX, clickY, "Image\Battle3.bmp", 120, "black", 535, 9, 545, 22))
						라운드3 := 1

					;;;;;;;;;;;;;;;;;;;;;;;;;; 스킬 사용 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					loop, 9
					{
						if(IsImgWithoutCapLog(clickX, clickY, "Image\방업1.bmp", 10, 0, SkillButtonPos[a_index].sX+15, SkillButtonPos[a_index].sY+20, SkillButtonPos[a_index].eX-15, SkillButtonPos[a_index].eY-10)
						&& IsImgWithoutCapLog(clickX, clickY, "Image\방업2.bmp", 10, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 방업 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					loop, 9
					{
						if(IsImgWithoutCapLog(clickX, clickY, "Image\공업1.bmp", 10, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
						&& IsImgWithoutCapLog(clickX, clickY, "Image\공업2.bmp", 10, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY))
						{
							addlog("# " a_index " 번 칸 공업 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					loop, 9
					{
						if(IsImgWithoutCapLog(clickX, clickY, "Image\엔피업1.bmp", 10, 0, SkillButtonPos[a_index].sX+17, SkillButtonPos[a_index].sY+3, SkillButtonPos[a_index].eX-17, SkillButtonPos[a_index].eY-15)
						&& IsImgWithoutCapLog(clickX, clickY, "Image\엔피업2.bmp", 10, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX-30, SkillButtonPos[a_index].eY-20))
						{
							addlog("# " a_index " 번 칸 엔피 스킬 사용")
							ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
							sleep, 3000
							break
						}
					}
					;DllCall("DeleteObject", Ptr, hBitmap)

					ClickAdb(710, 380) ;어택 클릭
					sleep, 2000

					;;;;;;;;;;;;;;;;;;;커맨드 카드 사용;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					getAdbScreen() ;한번 가져온 스샷으로 여러번 이미지 서치
					if(라운드3)
					{
						ClickAdb(260, 130)
						ClickAdb(405, 130)
						ClickAdb(550, 130)
						sleep, 10
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
						}
					}
					loop, 5 ;;남은 기술들 순서대로 사용
					{
						if(card%a_index% = 0)
						{
							ClickAdb(CmdCardPos[a_index].sX + 80, 320)
						}
						sleep, 10
					}
					;DllCall("DeleteObject", Ptr, hBitmap)

				}

				;;전멸했을 시

				;;전투가 끝났을 시
				getAdbScreen()
				if(IsImageWithoutCap(clickX, clickY, "Image\전투x.bmp", 60, 0))
				{
					ClickAdb(clickX, clickY)
					sleep, 1000
				}

				if(IsImageWithoutCap(clickX, clickY, "Image\result.bmp", 60, "black", 460, 20, 490, 55)
				|| IsImageWithoutCap(clickX, clickY, "Image\인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
				{
					ClickAdb(clickX, clickY)
					sleep, 3000
					loop
					{
						getAdbScreen()
						if(IsImageWithoutCap(clickX, clickY, "Image\result.bmp", 60, "black", 460, 20, 490, 55)
						|| IsImageWithoutCap(clickX, clickY, "Image\인연레벨업.bmp", 60, "white", 540, 217, 570, 245))
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
						if(IsImgPlusAdb(clickX, clickY, "Image\퀘스트보상.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							sleep, 3000
						}
						if(IsImgPlusAdb(clickX, clickY, "Image\닫기.bmp", 60, 0))
						{
							;ClickAdb(clickX, clickY)
							sleep, 3000
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
					if(IsImgPlusAdb(clickX, clickY, "Image\이벤트배너.bmp", 60, 0))
					{
						ClickAdb(clickX, clickY)
						sleep, 3000
					}
					;;ap없으면 ap찰때까지 반복
					loop
					{
						ClickAdb(650, 120) ;;첫번째 퀘스트 다시 누르기
						sleep, 3000
						if(IsImgPlusAdb(clickX, clickY, "Image\ap회복.bmp", 60, 0))
						{
							ClickAdb(clickX, clickY)
							addlog("ap 없음")
							sleeplog(300000) ;;ap찰때까지 5분대기
							continue
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

^f8::
	SaveAdbCropImage("image\이벤트배너.bmp", 530, 220, 630, 250)
	addlog("이벤트 배너 저장")
return


^f3::
addlog("aa")
	x:= 100
	y:= 100
	objExec := objShell.Exec(adb " -s " AdbSN " shell input tap " x " " y )
	while(!objExec.status)
		sleep, 10
	objExec := objShell.Exec(adb " -s " AdbSN " shell input tap 100 200" )
	while(!objExec.status)
		sleep, 10
	objExec := objShell.Exec(adb " -s " AdbSN " shell input tap 100 300" )
	while(!objExec.status)
		sleep, 10
	objExec := objShell.Exec(adb " -s " AdbSN " shell input tap 100 400" )
	AddLog("# 클릭: " x ", " y)
	;loop, 10
	;{
	;	addlog(objExec.status)
	;	sleep, 100
	;}
return

^f4::
addlog("테스트")
;getadbscreen()
;if(IsImgPlusAdb(clickX, clickY, "Image\인연레벨업.bmp", 60, "white", 540, 217, 565, 245))
;{
	;ClickAdb(clickX+240, clickY)
;	addlog("zz")
;}
;aa:= mod(11, 5)
;addlog(aa)
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


^f5::
getAdbScreen()
addlog("zzzz")
loop,9
{
	if(IsImgWithoutCapLog(aa, bb, "Image\엔피업1.bmp", 10, 0, SkillButtonPos[a_index].sX+17, SkillButtonPos[a_index].sY+3, SkillButtonPos[a_index].eX-15, SkillButtonPos[a_index].eY-18)
	;if(IsImgWithoutCapLog(clickX, clickY, "Image\엔피업1.bmp", 10, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX, SkillButtonPos[a_index].eY)
	&& IsImgWithoutCapLog(cc, dd, "Image\엔피업2.bmp", 10, 0, SkillButtonPos[a_index].sX, SkillButtonPos[a_index].sY, SkillButtonPos[a_index].eX-30, SkillButtonPos[a_index].eY-20))
	{
		addlog(aa " " bb " " cc " " dd "# " a_index " 번 칸 엔피 스킬 사용")
		;ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
		sleep, 3000
		break
	}
}
return

/*
^f3::
	objExec := objShell.Exec(adb " -s " AdbSN " shell screencap -p /sdcard/sc.png")
	while(!objExec.status) ; objExec.status가 1이면 프로세스 완료된 상태
		sleep, 10
	objExec := objShell.Exec(adb " -s " AdbSN " pull /sdcard/sc.png adbCapture\")
	while(!objExec.status) ; objExec.status가 1이면 프로세스 완료된 상태
		sleep, 10
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
