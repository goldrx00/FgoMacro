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
#include 서브함수.ahk
#include GUI.ahk


OnExit, Clean_up

global adb := "utility\adb.exe"
global AdbSN ;에뮬레이터 adb 주소


global bmpPtrArr := [] ; 이미지서치에 사용할 이미지 비트맵의 포인터를 저장하는 배열
global ConfigFile := "Config.ini"
global rCount ;
global 메인종료 := 1 ; 1이되면 메인함수 종료
global 퀘스트설정DDL ;현재 퀘스트 설정 이름
global gSectionVal ;현재 퀘스트 설정 섹션 내용


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

global SkillTargetPos := [{X: 200, 	Y: 270}
    ,{X: 400, 	Y: 270}
    ,{X: 600, 	Y: 270}]

global MasterSkillPos := [{X: 565, 	Y: 200}
    ,{X: 625, 	Y: 200}
    ,{X: 680, 	Y: 200}]

global NoblePhantasmPos := [{X: 260,	Y: 80}
    ,{X: 405, 	Y: 80}
    ,{X: 550, 	Y: 80}]

global OrderChagePos := [{X: 80, 	Y: 200}
    ,{X: 210, 	Y: 200}
    ,{X: 340, 	Y: 200}
    ,{X: 460, 	Y: 200}
    ,{X: 580, 	Y: 200}
    ,{X: 710, 	Y: 200}]

global EnemyPos := [{X: 330, 	Y: 25}
    ,{X: 180, 	Y: 25}
    ,{X: 30, 	Y: 25}]

global PartyPos := [{X: 330, 	Y: 30}
    ,{X: 346, 	Y: 30}
    ,{X: 361, 	Y: 30}
    ,{X: 377, 	Y: 30}
    ,{X: 393, 	Y: 30}
    ,{X: 408, 	Y: 30}
    ,{X: 424, 	Y: 30}
    ,{X: 440, 	Y: 30}
    ,{X: 455, 	Y: 30}
    ,{X: 471, 	Y: 30}]

global FriendListPos := [{sX: 30, 	sY: 110,		eX: 755, 	eY: 240}
    ,{sX: 30, 	sY: 240,		eX: 755, 	eY: 370}]

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


#include 화면보기.ahk
#include QuestOption.ahk
Gui, 1: Show, x%initX% y%initY% , %MacroID% ; h350 w194 

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
    
    GuiControlGet, chatID , 1:
    GuiControlGet, botToken , 1:
    if(chatID)
        SetTimer, TelegramGetUpdates, 10000 ; 10초마다 텔레그램 메시지 읽어오기

    SetTimer, 튕김확인, 300000 ;튕김확인
    
    GuiControlGet, AdbSN, 1:  ;adb 에뮬 시리얼
    
    GuiControlGet, 퀘스트설정DDL, 1:
    IniRead, gSectionVal, %ConfigFile%, QUEST_%퀘스트설정DDL%   

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
    해상도검사()
    if(IsImgWithoutCap(clickX, clickY, "닫기.bmp", 60, 0))
    {
        ap대기()
        getAdbScreen()
    }

    ;if(IsImgWithoutCap(clickX, clickY, "돌아가기.bmp", 60, 0))
    if(IsImgWithoutCap(clickX, clickY, "리스트갱신.bmp", 60, 0))
    {
        프렌드체크 := findiniStr("프렌드체크")
        예장체크 := findiniStr("예장체크")
        풀돌체크 := findiniStr("풀돌체크")      
 
        loopBreak := 0
        loop, {
            if(프렌드체크 = 0 && 예장체크 = 0)
            {
                ClickAdb(400, 200) ;첫칸클릭
                sleep, 3000
                getAdbScreen()
                break
            }

            getAdbScreen()            
            ;프렌드체크
            loop, 2 {
                프렌드찾음 := 0
                예장찾음 := 0
                풀돌찾음 := 0
                ;global 프렌드체크
                addlog(프렌드체크 "ㅗㅓㅏ")
                if ( !프렌드체크 || IsImgWithoutCap(clickX, clickY, "Quest\" 퀘스트설정DDL "_support.bmp", 90, 0, FriendListPos[a_index].sX, FriendListPos[a_index].sY,  FriendListPos[a_index].eX,  FriendListPos[a_index].eY))
                {
                    프렌드찾음 := 1                  
                }
                if (!예장체크 || IsImgWithoutCap(clickX, clickY, "Quest\" 퀘스트설정DDL "_frEssence.bmp", 90, 0, FriendListPos[a_index].sX, FriendListPos[a_index].sY,  FriendListPos[a_index].eX,  FriendListPos[a_index].eY))
                {       
                    예장찾음 := 1
                }
                if (!예장체크 || !풀돌체크 || IsImgWithoutCap(clickX, clickY, "풀돌.bmp", 90, "black", FriendListPos[a_index].sX+80, FriendListPos[a_index].sY+100,  FriendListPos[a_index].sX+100,  FriendListPos[a_index].eY))
                {                         
                    풀돌찾음 := 1
                }

                if(프렌드찾음 && 예장찾음 && 풀돌찾음)
                {
                    loopBreak := 1
                    ClickAdb(FriendListPos[a_index].sX+30, FriendListPos[a_index].sY+30)
                    sleep, 3000
                    getAdbScreen()
                    break
                }              
            }

            if(loopBreak)
                break
            
            if(IsImgWithoutCap(clickX, clickY, "스크롤끝.bmp", 60, 0, 760,420,799,449)
            || IsImgWithoutCap(clickX, clickY, "스크롤끝2.bmp", 60, 0, 760,420,799,449)) {

                loop {
                    ClickAdb(535, 80) ;리스트 갱신
                    sleep, 1000
                    getAdbScreen()
                    if (IsImgWithoutCap(clickX, clickY, "팝업닫기.bmp", 60, 0)) {
                        ClickAdb(clickX, clickY)
                        sleep, 3000
                    }
                    else if (IsImgWithoutCap(clickX, clickY, "리스트갱신네.bmp", 60, 0)) {
                        ClickAdb(clickX, clickY)
                        sleep, 2000
                        break
                    }
                }
                
            }
            else {
                SwipeAdb(30,247,30,139,1000)
                sleep, 1500
            }
            if (a_index > 500)
            {
                addlog("프렌드 검색 실패")
                return false
            }
        }
           

        ; else
        ; {           
        ;     ClickAdb(400, 200) ;첫칸클릭
        ;     sleep, 3000
        ;     getAdbScreen()
        ; }
    }

    if(IsImgWithoutCap(clickX, clickY, "퀘스트개시.bmp", 60, 0)) 
    {
        파티선택 := findiniStr("파티선택")
        if(파티선택 > 1)
        {
            if(!IsImgWithoutCap(clickX, clickY, "파티선택.bmp", 60, 0,PartyPos[파티선택-1].X-5,PartyPos[파티선택-1].Y-5,PartyPos[파티선택-1].X+5,PartyPos[파티선택-1].Y+5))
            {
                addlog("# " 파티선택-1 " 번 파티 선택")
                ClickAdb(PartyPos[파티선택-1].X, PartyPos[파티선택-1].Y)
            }
            
        }
        ;ClickToImgAdb(clickX, clickY, "퀘스트개시.bmp")
        sleep, 5000
        ClickAdb(745, 420) ;퀘스트개시
        sleep, 1500
        if(IsImgPlusAdb(clickX, clickY, "아이템을사용하지않고.bmp", 60, 0)) ;퀘스트개시를 눌러도 뭐가 뜰때 여기 이미지 변경
        {
            ClickAdb(clickX, clickY)
        }
        addlog("# 반복 " rCount "회차 시작")
        sleep, 7000 ; 10초 대기
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
        addlog("# 매크로 시작 실패")
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
            
            ;; 점사 타겟 선택
            if(라운드시작) {

                타겟선택(라운드)

                스킬사용(라운드)                

                마스터스킬(라운드)

                오더체인지(라운드)
            }

            var = 자동스킬%라운드%
            자동스킬%라운드% := findiniStr(var)
            if(자동스킬%라운드% = true && 라운드시작 = false)
            {
                자동스킬()
            }

            라운드시작 := false

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

            보구사용(라운드)       

            카드사용()
            
        } ;attack
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

                GuiControlGet, Hibernate, 1:
                GuiControlGet, 유휴시간, 1:
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
                        GuiControlGet, 절전시간, 1:
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

타겟선택(라운드)
{
    loop, 3
    {
        if(라운드 = a_index)
        {
            var = 타겟%a_index%
            타겟%a_index% := findiniStr(var)
            ;IniRead, 타겟%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 타겟%a_index% 
            addlog("# " a_index "라 시작")
            ;라운드시작 := false
            ;GuiControlGet, 점사%a_index%, 1:  
            if(타겟%a_index% != 1)							
                ClickAdb(EnemyPos[타겟%a_index%].X, EnemyPos[타겟%a_index%].Y)
            sleep, 500
            ClickAdb(663,93)
            sleep, 1000
        }
    }
}

스킬사용(라운드)
{
    addlog("# 스킬사용")
    loop, 3
    {
        ii := a_index
        if(라운드 = ii)
        {
            loop,9 
            {
                var = 스킬%ii%라%a_index%
                스킬%ii%라%a_index% := findiniStr(var)
                ;IniRead, 스킬%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 스킬%ii%라%a_index%
                ;addlog(스킬1라%a_index% "asdf")
                if(스킬%ii%라%a_index% = 2) ;사용
                {
                    ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
                    sleep, 500
                    ClickAdb(690, 110) ; 선택창 떴을 때 끄기
                    sleep, 500
                    WaitImageAdb(clickX, clickY, "attack.bmp", 60)
                }
                else if(스킬%ii%라%a_index% > 2) ;아군한테 사용
                {
                    jj := 스킬%ii%라%a_index% -2
                    ClickAdb(SkillButtonPos[a_index].sX+20, SkillButtonPos[a_index].sY+20)
                    sleep, 500                        
                    ClickAdb(SkillTargetPos[jj].X, SkillTargetPos[jj].Y)
                    sleep, 500
                    ClickAdb(690, 110) ; 선택창 떴을 때 끄기
                    sleep, 500
                    WaitImageAdb(clickX, clickY, "attack.bmp", 60)
                }
                ;addlog(a_index)
            }
        }
    }
}

마스터스킬(라운드)
{
    addlog("# 마스터스킬사용")
    loop, 3
    {                    
        ii := a_index
        if(라운드 = ii)
        {
            loop,3 
            {
                var = 마스터%ii%라%a_index%
                마스터%ii%라%a_index% := findiniStr(var)
                ;IniRead, 마스터%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 마스터%ii%라%a_index%
                ;addlog(마스터1라%a_index% "asdf")
                if(마스터%ii%라%a_index% = 2) ;사용
                {
                    ClickAdb(745,200) ;마스터 스킬버튼
                    sleep, 500
                    ClickAdb(MasterSkillPos[a_index].X, MasterSkillPos[a_index].Y)
                    sleep, 500
                    ClickAdb(690, 110) ; 선택창 떴을 때 끄기
                    sleep, 500
                    ClickAdb(745,200) ;마스터 스킬버튼
                    sleep, 500
                    WaitImageAdb(clickX, clickY, "attack.bmp", 60)                      
                }
                else if(마스터%ii%라%a_index% > 2) ;아군한테 사용
                {                            
                    jj := 마스터%ii%라%a_index% -2
                    ClickAdb(745,200) ;마스터 스킬버튼
                    sleep, 500
                    ClickAdb(MasterSkillPos[a_index].X, MasterSkillPos[a_index].Y)
                    sleep, 500                        
                    ClickAdb(SkillTargetPos[jj].X, SkillTargetPos[jj].Y)
                    sleep, 500
                    ClickAdb(690, 110) ; 선택창 떴을 때 끄기
                    sleep, 500
                    ClickAdb(745,200) ;마스터 스킬버튼
                    sleep, 500
                    WaitImageAdb(clickX, clickY, "attack.bmp", 60)
                }
                ;addlog(a_index)
            }
        }
    }
}

오더체인지(라운드)
{
    ;addlog("오더체인지")
    loop, 3
    {                   
        ii := a_index
        if(라운드 = ii)
        {                        
            loop, 2
            {
                var = 오더%ii%라%a_index%
                오더%ii%라%a_index% := findiniStr(var)
                ;IniRead, 오더%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 오더%ii%라%a_index%
            }

            startingMember := 오더%ii%라1 -1
            subMember := 오더%ii%라2 +2
            ; addlog(startingMember)
            ; addlog(subMember)                                           
            if(startingMember > 0 && subMember >3 ) ;사용
            {
                ClickAdb(745,200) ;마스터 스킬버튼
                sleep, 500
                ClickAdb(MasterSkillPos[3].X, MasterSkillPos[3].Y)
                sleep, 500
                ClickAdb(OrderChagePos[startingMember].X, OrderChagePos[startingMember].Y)
                sleep, 500
                
                ClickAdb(OrderChagePos[subMember].X, OrderChagePos[subMember].Y)
                sleep, 500
                ClickAdb(400, 400) ; 교체하기
                sleep, 500
                WaitImageAdb(clickX, clickY, "attack.bmp", 60)

                loop, 3
                {
                    var = 오첸스킬%ii%라%a_index%
                    오첸스킬%ii%라%a_index% := findiniStr(var)
                    ;IniRead, 오첸스킬%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 오첸스킬%ii%라%a_index%
                    num := a_index+((startingMember-1)*3)
                    if(오첸스킬%ii%라%a_index% = 2) ;사용
                    {                                
                        ClickAdb(SkillButtonPos[num].sX+20, SkillButtonPos[num].sY+20)
                        sleep, 500
                        ClickAdb(690, 110) ; 선택창 떴을 때 끄기
                        sleep, 500
                        WaitImageAdb(clickX, clickY, "attack.bmp", 60)                           
                    }
                    else if(오첸스킬%ii%라%a_index% > 2) ;아군한테 사용
                    {
                        
                        jj := 오첸스킬%ii%라%a_index% -2
                        ClickAdb(SkillButtonPos[num].sX+20, SkillButtonPos[num].sY+20)
                        sleep, 500
                        ;                       
                        ClickAdb(SkillTargetPos[jj].X, SkillTargetPos[jj].Y)
                        sleep, 500
                        ClickAdb(690, 110) ; 선택창 떴을 때 끄기
                        sleep, 500
                        WaitImageAdb(clickX, clickY, "attack.bmp", 60)
                    }
                }                           
            }        
        }
    }
}

보구사용(라운드)
{
    ;;보구사용
    loop,3 
    {
        ii := A_Index
        if(라운드 = ii)
        {
            loop, 3
            {
                var = 보구%ii%라%a_index%
                보구%ii%라%a_index% := findiniStr(var)
                ;IniRead, 보구%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 보구%ii%라%a_index%                      
                if(보구%ii%라%a_index% = 2) ;사용
                {
                    ClickAdb(NoblePhantasmPos[a_index].X, NoblePhantasmPos[a_index].Y)
                    sleep, 300                                                    
                }
                ;GuiControlGet, 보구%ii%라%a_index%, 1:							
            }
        }        
    }
}

카드사용()
{
    loop, 5
        card%a_index% := 0 ;skill 배열: 사용한 카드는 1

    카드순위 := findiniStr("카드순위")
    ;addlog(카드순위)
    if 카드순위 = ""
        카드순위 := "EB>EA>EQ>B>A>Q>RB>RA>RQ"
    ;IniRead, 카드순위, %ConfigFile%, QUEST_%퀘스트설정DDL%, 카드순위, EB>EA>EQ>B>A>Q>RB>RA>RQ
    Loop, Parse, 카드순위, >
    {
        ;addlog(A_LoopField a_index)
        Switch A_LoopField
        {                    
            Case "EB":
                loop, 5 ;이펙티브 버스터
                {
                    if(card%a_index% = 1)
                        continue
                    if(IsImgWithoutCapLog(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
                    && IsImgWithoutCapLog(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "EA":
                loop, 5 ;이펙티브 아츠
                {
                    if(card%a_index% = 1)
                        continue
                    if(IsImgWithoutCapLog(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
                    && IsImgWithoutCapLog(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "EQ":
                loop, 5 ; 이펙티브 퀵
                {
                    if(card%a_index% = 1)
                        continue
                    if(IsImgWithoutCapLog(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 )
                    && IsImgWithoutCapLog(clickX, clickY, "quick1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "quick2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "B":
                loop, 5 ;레지스트 아닌 버스터 사용 ( 버스터)
                {
                    if(card%a_index% = 1)
                        continue
                    if(!IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
                    && IsImgWithoutCapLog(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "A":
                loop, 5 ;레지스트 아닌 아츠 사용 (아츠)
                {
                    if(card%a_index% = 1)
                        continue
                    if(!IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
                    && IsImgWithoutCapLog(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "Q":
                loop, 5 ; 퀵
                {
                    if(card%a_index% = 1)
                        continue
                    if(!IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
                    && IsImgWithoutCapLog(clickX, clickY, "quick1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "quick2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "RB":
                loop, 5 ; 레지스트 버스터
                {
                    if(card%a_index% = 1)
                        continue
                    if(IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
                    && IsImgWithoutCapLog(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "RA":
                loop, 5 ;레지스트 아츠
                {
                    if(card%a_index% = 1)
                        continue
                    if(IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
                    && IsImgWithoutCapLog(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }
            Case "RQ":
                loop, 5 ; 레지스트 퀵 
                {
                    if(card%a_index% = 1)
                        continue
                    if(IsImgWithoutCapLog(clickX, clickY, "resist.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-30, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+20 )
                    && IsImgWithoutCapLog(clickX, clickY, "quick1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
                    && IsImgWithoutCapLog(clickX, clickY, "quick2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
                    {
                        ClickAdb(CmdCardPos[a_index].sX + 80, 320)
                        card%a_index% := 1
                        sleep, 300
                    }
                }                    
        } ;switch
    } ;loop
    loop, 5 ;;남은 기술들 순서대로 사용
    {
        if(card%a_index% = 0)
        {
            ClickAdb(CmdCardPos[a_index].sX + 80, 320)
            sleep, 300
        }                
    }
}

자동스킬()
{
    addlog("자동스킬")
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
    ;addlog(자동스킬%라운드%)
    ;;;공멀슼 스킬사용
    loop, 3
    {
        GuiControlGet, 공명%a_index%, 1:
        if(라운드 = a_index && 공명%a_index%)
        {					
            if(IsImgWithoutCap(clickX, clickY, "skill\s_크리1.bmp", 60, 0, SkillButtonPos[7].sX, SkillButtonPos[7].sY, SkillButtonPos[7].eX, SkillButtonPos[7].eY)
            && IsImgWithoutCap(clickX, clickY, "공명.bmp", 120, "black", 500, 433, 550, 448))
            {
                ClickAdb(440, 360)
                sleep, 500
                ClickAdb(220, 260)
                sleep, 3000
                getAdbScreen()
            }
            if(IsImgWithoutCap(clickX, clickY, "skill\s_np업1.bmp", 60, 0, SkillButtonPos[9].sX, SkillButtonPos[9].sY, SkillButtonPos[9].eX, SkillButtonPos[9].eY))
            && IsImgWithoutCap(clickX, clickY, "스카디.bmp", 120, "black", 500, 433, 550, 448)
            {
                ClickAdb(560, 360)
                sleep, 500
                ClickAdb(220, 260)
                sleep, 3000
                getAdbScreen()
            }
        }
        GuiControlGet, 멀린%a_index%, 1:
        if(라운드 = a_index && 멀린%a_index%)
        {			
            if(IsImgWithoutCap(clickX, clickY, "skill\s_버스터1.bmp", 60, 0, SkillButtonPos[9].sX, SkillButtonPos[9].sY, SkillButtonPos[9].eX, SkillButtonPos[9].eY))
            && IsImgWithoutCap(clickX, clickY, "멀린.bmp", 120, "black", 500, 433, 550, 448)
            {
                ClickAdb(560, 360)
                sleep, 500
                ClickAdb(220, 260)
                sleep, 3000
                getAdbScreen()
            }
        }				
        GuiControlGet, 스카디%a_index%, 1:
        if(라운드 = a_index && 스카디%a_index%)
        {			
            if(IsImgWithoutCap(clickX, clickY, "skill\s_퀵1.bmp", 60, 0, SkillButtonPos[7].sX, SkillButtonPos[7].sY, SkillButtonPos[7].eX, SkillButtonPos[7].eY))
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

    이미지스킬("skill\s_방업")
    이미지스킬("skill\s_공업")
    이미지스킬("skill\s_방깎")
    이미지스킬("skill\s_공깎")
    이미지스킬("skill\s_np획득량")
    이미지스킬("skill\s_np업")
    이미지스킬("skill\s_스타")
    이미지스킬("skill\s_버스터", 110)
    이미지스킬("skill\s_아츠")
    이미지스킬("skill\s_퀵")
    이미지스킬("skill\s_스집", 110)
    이미지스킬("skill\s_내성깎", 120)
    이미지스킬("skill\s_챠지깎")
    이미지스킬("skill\s_거츠")
    이미지스킬("skill\s_회피")
}

이미지스킬(skillName, errorRange = 150) ;스킬이미지이름에서 숫자뺀거, 이미지 갯수
{
    loop ;;스킬이미지가 몇개 인지 확인하는 루프
    {
        skillImageName := skillName a_index ".bmp"
        if(!bmpPtrArr[(skillImageName)])
        {
            imageNum := a_index - 1
            break
        }
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

