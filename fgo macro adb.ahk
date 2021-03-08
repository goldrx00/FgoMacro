;fgo macro adb.ahk 

#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행
#NoEnv ;변수명을 해석할 때, 환경 변수를 무시한다 (속도 상승)
SetBatchLines, -1 ; 스크립트 최고속도로

SetWorkingDir, %A_ScriptDir%	;스크립트의 작업 디렉토리를 변경. vscode autohotkey manager로 작업시 넣어줘야 폴더 인식

CoordMode,ToolTip,Screen ;ToolTip

;인식 안될 경우에 %A_ScriptDir% 붙이기
#Include Library\Gdip.ahk
#Include Library\Hibernate.ahk
#include Library\JSON.ahk
#Include Library\CreateFormData.ahk
#include macro_functions.ahk 
#include adb_functions.ahk
#Include telegram.ahk
#Include 크기조절테스트.ahk
#include GUI.ahk
#include 서브함수.ahk

OnExit, Clean_up

global adb := "utility\adb.exe"
global AdbSN ;에뮬레이터 adb 주소


global bmpPtrArr := [] ; 이미지서치에 사용할 이미지 비트맵의 포인터를 저장하는 배열
global ConfigFile := "Config.ini"
global rCount ;
global 메인종료 := 1 ; 1이되면 메인함수 종료

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

global initX, initY
IfNotExist, %ConfigFile%
{
    initX := 100
    initY := 100,
}
IfExist, %ConfigFile%
    LoadOption()

Gosub, Attach

GuiControlGet, AdbSN, 1: ;adb 에뮬 시리얼
GuiControlGet, chatID, 1: ;텔레그램
GuiControlGet, botToken, 1:

Gui, Show, x%initX% y%initY% , %MacroID% ; h350 w194 

gdipToken := Gdip_Startup()
LoadImage()

log := "# 동작 대기"
AddLog(log)

#Include HotKeys.ahk
#Include Labels.ahk
return

실행버튼()
{ 
    if(!메인함수())
    {
        addlog("# 매크로 중지")
        ;SetTimer, TelegramGetUpdates, Off
        SetTimer, 튕김확인, Off
    }
}

메인함수()
{
    AddLog("# 페그오 매크로 시작 ")
    메인종료 := 0
    
    GuiControlGet, chatID ,
    GuiControlGet, botToken , 
    if(chatID)
        SetTimer, TelegramGetUpdates, 10000 ; 10초마다 텔레그램 메시지 읽어오기

    SetTimer, 튕김확인, 300000 ;튕김확인
    
    GuiControlGet, AdbSN,  ;adb 에뮬 시리얼
    /*
    objExec := objShell.Exec(adb " connect " AdbSN)
    while(!objExec.status) ; objExec.status가 1이면 프로세스 완료된 상태
        sleep, 10
    */    
    loop
    {        
        rCount := a_index ; 반복 회차
        adbConnect()
        
        if(!퀘스트준비())
        {
            return false
        }
        if(!퀘스트배틀())
        {
            return false
        }
        if(!퀘스트리절트())
        {
            return false
        }
        if(!ap대기())
        {
            return false
        }		
    }
}

퀘스트준비()
{
    getAdbScreen()
    if(IsImgWithoutCap(clickX, clickY, "이전진행.bmp", 60, 0))
    {
        ap대기()
        getAdbScreen()
    }

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
        getAdbScreen()
        if(IsImgWithoutCap(clickX, clickY, "attack.bmp", 60, 0))
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
            스킬사용("s_내성깎", 120)
            스킬사용("s_챠지깎")
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

퀘스트리절트()
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
        if(IsImgWithoutCap(clickX, clickY, "퀘스트보상.bmp", 30, 0, 80, 240, 240, 390))
        {
            sleep, 1000
            ClickAdb(clickX, clickY)
            sleep, 1500
        }
        if(IsImgWithoutCap(clickX, clickY, "연속출격닫기.bmp", 60, 0))
        {
            ClickAdb(clickX, clickY)
            sleep, 1000
        }
        if(IsImgWithoutCap(clickX, clickY, "닫기.bmp", 60, 0))
        {
            ;ClickAdb(clickX, clickY)
            sleep, 2000
            break
        }
    }
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
    return true
}

ap대기()
{
    addlog("# ap대기")
    getAdbScreen()
    if(!IsImgWithoutCap(clickX, clickY, "닫기.bmp", 60, 0))
    {
        return false
    }
    ;;ap없으면 ap찰때까지 반복
    loopNum := 0
    loop
    {
         if(메인종료 = 1)
            return false

        ClickAdb(650, 120) ;;첫번째 퀘스트 다시 누르기
        sleep, 3000
        getAdbScreen()
        if(IsImgWithoutCap(clickX, clickY, "ap회복.bmp", 60, 0))
        ;|| IsImgWithoutCap(clickX, clickY, "bp회복.bmp", 60, 0))
        {
            loopNum := 0
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
                ClickAdb(clickX, clickY) ;ap회복창 닫기
                addlog("# ap 없음")
                sleep, 2000

                GuiControlGet, Hibernate,
                GuiControlGet, 유휴시간, 
                addlog("# TimeIdle: " A_TimeIdle)
                if(Hibernate = true && A_TimeIdle > 60000*유휴시간)
                {
                    MsgBox, 1, , 10초 후 절전모드가 실행됩니다., 10
                    IfMsgBox, Cancel
                    {
                        sleeplog(300000)
                    }
                    else
                    {
                        fileName := "절전알림.png"
                        CaptureAdb(fileName)		
                        SendTelegramImg("adbCapture/" fileName)
                        GuiControlGet, 절전시간,
                        SendTelegram("절전 시작: " A_HOUR ":" A_MIN " ,  " 절전시간 "분")                        
                        addlog("# " 절전시간 "분 절전")
                        sleep, 1000
                        ;Run rundll32.exe user32.dll`,LockWorkStation ;화면잠금
                        Hibernate( A_Now, 절전시간, "Minutes" )
                        sleeplog(20000)
                        SendTelegram("절전 꺼짐: " A_HOUR ":" A_MIN )
                        ;;만약 서버 접속 에러 발생시 여기다 해당 코드 넣기

                        ;; 절전시간동안 잠겨있던 ap 실제로 맞추기
                        getAdbScreen()
                        if(IsImgWithoutCap(clickX, clickY, "메뉴.bmp", 60, 0))
                        {
                            ClickToImgAdb(clickX, clickY, "마이룸버튼.bmp")
                            ClickToImgAdb(clickX, clickY, "마이룸.bmp")
                            ClickAdb(70, 25) ;닫기 버튼
                            sleep, 4000
                        }

                    }
                
                }
                else
                {
                    sleeplog(300000) ;;ap찰때까지 5분대기
                }				
                
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

        if(loopNum > 20) ;;화면프리징 또는 기타 에러시
        {
           절전모드()
        }


        loopNum++
    }	
}

스킬사용(skillName, errorRange = 150) ;스킬이미지이름에서 숫자뺀거, 이미지 갯수
{
    loop ;;스킬이미지가 몇개 인지 확인하는 루프
    {
        skillImageName := skillName a_index ".bmp"
        ;addlog(skillImageName)
        if(!bmpPtrArr[(skillImageName)])
        {
            imageNum := a_index - 1
            break
        }
        ;addlog(skillName)
        ; if(!bmpPtrArr[(skillName) a_index])
        ; {
        ;     imageNum := a_index - 1
        ;     break
        ; }		
    }

    ;addlog(imageNum)
    ;breakLoop := 0
    loop, 9
    {
        buttonNum := a_index
        loop, %imageNum%
        {
            ;addlog(skillName a_index ".bmp")			
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

룰렛돌리기()
{
    loop
    {
        ClickAdb(270, 270)
        sleep, 200
    }
}


무료소환() ;; 무료 소환 반복 핫키
{
    adbConnect()

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
}

