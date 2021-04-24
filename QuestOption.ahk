#SingleInstance Force ; 스크립트를 동시에 한개만 실행


;global guiNum := "quest:"

;global ConfigFile := "qo.ini"

Gui, q: default,
Gui, q: +Owner1
Gui, q: Add, ListView,  w150 h550 section v리스트뷰 g리스트함수  NoSortHdr -multi , 더블 클릭으로 선택 ; g리스트함수
Gui, q: ListView, 리스트뷰
;Gui, q:Add, UpDown, x+5 vPos gUpDown Range1-2 -16 ;업다운버튼 -16 넣을시 앞 gui에 붙지 않음
;addlog( A_DefaultListView)

Gui, q: Add, Button, xm y+m g추가버튼, 추가
Gui, q: Add, Button, x+m g제거버튼, 제거
Gui, q: Add, Button, x+15 g업버튼, ▲
Gui, q: Add, Button, x+5 g다운버튼, ▼
;Gui, q: Add, Button, x+10 gsaveListView, 세이브
;Gui, q: Add, Button, x+10 gloadListView, 로드

Gui, q: Add, Edit, ym v설정이름 section ReadOnly,
Gui, q: Add, Text, x+m , 파티선택:
Gui, q: Add, DropDownList, x+m w75 AltSubmit v파티선택, 선택안함||1|2|3|4|5|6|7|8|9|10
Gui, q: Add, Text, x+m yp w200 vIsData,
Gui, q: Add, Button, xs+520 ys  gsaveData , 데이터 저장

;1라
loop, 3
{	
	Gui, q: Add, GroupBox, xs y+10 w600 h155 , %a_index%라운드
	Gui, q: Add, Text, xp+10 yp+15 section , 적 타겟 ;;점사 기준점
	Gui, q: Add, DropDownList, w60 AltSubmit v타겟%a_index%, 전||중|후

	Gui, q: Add, Text, x+30 ys , 보구 
	;;Gui, q: Add, DropDownList,  w60 AltSubmit v보구%a_index%라1, ||사용
	; Gui, q: Add, DropDownList, x+1 yp w60 AltSubmit v보구%a_index%라2, ||사용
	; Gui, q: Add, DropDownList, x+1 yp w60 AltSubmit v보구%a_index%라3, ||사용
	Gui, q: Add, Checkbox,  w60 v보구%a_index%라1, 보구1
	Gui, q: Add, Checkbox, x+1 yp w60  v보구%a_index%라2, 보구2
	Gui, q: Add, Checkbox, x+1 yp w60  v보구%a_index%라3, 보구3
	

	Gui, q: Add, Text, x+30 ys , 마스터 스킬
	Gui, q: Add, DropDownList, w60 AltSubmit v마스터%a_index%라1, ||사용|사용:1|사용:2|사용:3
	Gui, q: Add, DropDownList, x+1 yp w60 AltSubmit v마스터%a_index%라2, ||사용|사용:1|사용:2|사용:3
	Gui, q: Add, DropDownList, x+1 yp w60 AltSubmit v마스터%a_index%라3, ||사용|사용:1|사용:2|사용:3

	Gui, q: Add, Text, xs y+10 , 서번트 스킬 ;;점사 기준점
	Gui, q: Add, Text, y+5, ; 스킬기준점
	ii := a_index
	loop,9
	{
		aa:= 61*(a_index-1)
		if	a_index>3 
			aa+=15
		if a_index>6
			aa+=15
		Gui, q: Add, DropDownList, AltSubmit xs+%aa% yp w60 v스킬%ii%라%a_index%, ||사용:자신|사용:1|사용:2|사용:3
	}
	Gui, q: Add, Text, xs y+10 , 오더 체인지       오첸후 스킬
	Gui, q: Add, DropDownList, y+5 w30 AltSubmit v오더%a_index%라1, ||1|2|3
	Gui, q: Add, DropDownList, x+1 w30 AltSubmit v오더%a_index%라2, ||4|5|6
	Gui, q: Add, DropDownList, x+30 yp w60 AltSubmit v오첸스킬%a_index%라1, ||사용:자신|사용:1|사용:2|사용:3
	Gui, q: Add, DropDownList, x+1 yp w60 AltSubmit v오첸스킬%a_index%라2, ||사용:자신|사용:1|사용:2|사용:3
	Gui, q: Add, DropDownList, x+1 yp w60 AltSubmit v오첸스킬%a_index%라3, ||사용:자신|사용:1|사용:2|사용:3
	Gui, q: Add, Checkbox, xs+450 yp v자동스킬%a_index% ,1턴 후부터 자동스킬
	Gui, q: Add, Text, xs-10 yp+10 Hidden section, ;;다음그룹과 위치조절
	
}

Gui, q: Add, Text, xs y+15 section, 카드 우선 순위:
Gui, q: Add, Edit, x+m w250 v카드순위 , ;be>ae>qe>bn>an>qn>br>ar>qr

;Gui, q: Add, Text, xs , 프렌드 선택하기
Gui, q: Add, Checkbox, xs v프렌드체크 section ,프렌드 서번트 선택
Gui, q: Add, Button, g프렌드버튼 , 프렌드 서번트 캡쳐
Gui, q: Add, Button, g프렌드삭제버튼 , 프렌드 서번트 삭제
Gui, q: Add, Picture,  ys w45 h35  vSupportPic, 프렌드 서번트
Gui, q: Add, Checkbox, ys v예장체크, 프렌드 예장 선택
Gui, q: Add, Checkbox, xp y+m v풀돌체크, 예장 풀돌만
Gui, q: Add, Button, xp y+m g예장버튼 , 프렌드 예장 캡쳐
Gui, q: Add, Button,  xp y+m g예장삭제버튼 , 프렌드 예장 삭제
Gui, q: Add, Picture, ys  vfrEssencePic, 개념예장



; loadListView()
; Gui, q: Show, , 퀘스트 설정     
; LV_Modify(1, "select")
; LV_GetText(Text, 1)		
; loadData(text)
;Focus

예장버튼()
{
	GuiControlGet, 설정이름, q:
	fileName := "Image\Quest\" 설정이름 "_frEssence.bmp"	
	SaveAdbCropImage(filename, 80, 210, 110, 230)
	Guicontrol, q:, frEssencePic ,%fileName%
}

예장삭제버튼()
{
	GuiControlGet, 설정이름, q:
	fileName := "Image\Quest\" 설정이름 "_frEssence.bmp"
	FileDelete, %fileName%
	Guicontrol, q:, frEssencePic ,
}

프렌드버튼()
{
	GuiControlGet, 설정이름, q:
	fileName := "Image\Quest\" 설정이름 "_support.bmp"
	SaveAdbCropImage(filename, 80, 150, 125, 185)
	Guicontrol, q:, SupportPic ,%fileName%
	;GuiControlGet, SupportPic, q:
	;addlog(SupportPic)
	;IniWrite("SupportPic","q:", "Quest_" 설정이름)
}

프렌드삭제버튼()
{
	GuiControlGet, 설정이름, q:
	fileName := "Image\Quest\" 설정이름 "_support.bmp"
	FileDelete, %fileName%
	Guicontrol, q:, SupportPic ,
}


showQusetConfig()
{
	IfWinNotExist, 퀘스트 설정    
    {
        RealWinSize(posX, posY, width, height, MacroID)
        ChildX := posX + width + 10
        ChildY := posY
		Gui, q: Default    
        loadListView()
		Gui, q: Show, x%ChildX% y%ChildY% , 퀘스트 설정
		; LV_Modify(1, "select")
		; LV_GetText(Text, 1)
		GuiControlGet, 퀘스트설정DDL, 1:
		Loop % LV_GetCount()
		{
			LV_GetText(RetrievedText, A_Index)
			if (RetrievedText = 퀘스트설정DDL)
				LV_Modify(A_Index, "Select")  ; 첫 필드에 여과 텍스트가 들어 있는 행을 선택합니다.
		}				
		loadData(퀘스트설정DDL)		
    }
    else
    {
        Gui, q: Show, hide        
    }
}

; for i, v in ["One", "Two", "Three"] {
; 	addlog(LV_Add(, v))
; }
; LV_ModifyCol(1, "AutoHdr")


추가버튼()
{	
	;Gui, q: 제목: Show, ,설정이름 입력
    ;static guiNum := "1:"
	InputBox, OutputVar, 설정이름 입력, ,, 200, 100
	if ErrorLevel ;cancel 눌렀을 시
    	return 
	else if OutputVar
	{		
		length := LV_GetCount()		
		loop, %length%
		{
			LV_GetText(text, a_index)			
			if(OutputVar = text)
			{
				msgbox, 설정이름 중복
				return false
			}				
		}
		LV_Add("", OutputVar)
		Loop % LV_GetCount()
		{
			LV_GetText(RetrievedText, A_Index)
			if (RetrievedText = OutputVar)
				LV_Modify(A_Index, "Select")  ; 첫 필드에 여과 텍스트가 들어 있는 행을 선택합니다.
		}				
		loadData(OutputVar)	
		saveListView()
		return true	
	}  	
	
}


제거버튼()
{
	RowNumber := LV_GetNext()  ; 앞의 반복에서 발견한 행 바로 다음부터 검색을 재개합니다.
	LV_GetText(Text, RowNumber)
	;MsgBox The next selected row is #%RowNumber%, whose first field is "%Text%".
	; row := LV_GetCount("Selected")
	MsgBox, 1, , %Text% 삭제됩니다. ,
	IfMsgBox, Ok
	{
		LV_Delete(RowNumber)
		IniDelete, %ConfigFile%, QUEST_%text%
		saveListView()
		return true
	}
}

리스트함수()
{
	;addlog(A_EventInfo)
	;A_EventInfo : 행 
	if(A_GuiEvent = "DoubleClick")
	{
		RowNumber := LV_GetNext()
		if(RowNumber = 0)
			return false
		LV_GetText(Text, RowNumber)    
		; addlog(Text)
		;GuiControl, q:, 설정이름, %Text%		
		loadData(text)
	}
return
}


업버튼()
{
	length := LV_GetCount()
	row := LV_GetNext()
	LV_GetText(text, row)
	if(row > 1) 
	{
		LV_Delete(row)
		LV_Insert(row - 1, , text)
		LV_Modify(row - 1, "Select")
	}
	saveListView()
}
다운버튼()
{
	length := LV_GetCount()
	row := LV_GetNext()
	LV_GetText(text, row)
	if(row < length && row > 0) 
	{
		LV_Delete(row)
		LV_Insert(row + 1, , text)
		LV_Modify(row + 1, "Select")
	}
	saveListView()
}

UpDown()
{
	global Pos
	;위버튼 누르면 pos := 2 아래는 := 1
	;addlog(A_GuiEvent)

	;멀티셀렉트 가능할시엔 이거 사용
	length := LV_GetCount()
	selection := []
	last := 0
	loop % LV_GetCount("Selected") {
		new := LV_GetNext(last)
		selection.Push(new)
		last := new
	}	
	loop % selection.Length() {
		row := Pos = 2 ? selection[A_Index] : selection[selection.Length() - A_Index + 1]
		LV_GetText(text, row)
		if(Pos = 2 && row > 1) {
			LV_Delete(row)
			LV_Insert(row - 1, , text)
			LV_Modify(row - 1, "Select")
		} else if(Pos = 1 && row < length) {
			LV_Delete(row)
			LV_Insert(row + 1, , text)
			LV_Modify(row + 1, "Select")
		}
	}
}


saveListView()
{
	listViewItems := ""
	Loop, % LV_GetCount()
	{
		LV_GetText(text, a_index)	
		listViewItems .= text . "|" ;모든 행의 내용을 하나로 연결
	}
	IniWrite, %listViewItems%, %ConfigFile%,  LVitem, LV
}

loadListView()
{
	LV_Delete()
	IniRead, text, %ConfigFile%, LVitem, LV
	;addlog(text)
	Loop, Parse, text, |
	{		
		if !(A_LoopField = "")
			LV_Add("", A_LoopField)
	}
}

saveData()
{
	GuiControlGet, 설정이름, q:
	; row := LV_GetNext()
	; if row = 0
	; 	return
	;addlog(row)
	;LV_GetText(text, row)
	;Gui, q: Submit , NoHide	
	;IniWrite, %text%, %ConfigFile%,  QUEST_%text% , 설정이름

	gui := "q:"
	section := "QUEST_" 설정이름
	;addlog(section)
	IniWrite("파티선택", gui, section)
	loop, 3
	{
		IniWrite("타겟" a_index, gui, section)
	}
	loop, 3
    {
        ii := a_index
        loop, 3           
            IniWrite("보구" ii "라" a_index, gui, section)
    }
	loop, 3
    {
        ii := a_index
        loop, 3           
            IniWrite("마스터" ii "라" a_index, gui, section)
    }
	loop, 3
    {
        ii := a_index
        loop, 9           
            IniWrite("스킬" ii "라" a_index, gui, section)
    }
	loop, 3
    {
        ii := a_index
        loop, 2        
            IniWrite("오더" ii "라" a_index, gui, section)
    }
	loop, 3
    {
        ii := a_index
        loop, 3       
            IniWrite("오첸스킬" ii "라" a_index, gui, section)
    }
	loop, 3
    {          
        IniWrite("자동스킬" a_index, gui, section)
    }
	IniWrite("카드순위", gui, section)
	IniWrite("프렌드체크", gui, section)
	IniWrite("예장체크", gui, section)
	IniWrite("풀돌체크", gui, section)
	addlog("# " 설정이름 " 세이브 완료")
}

loadData(text)
{	
	GuiControl, q:, 설정이름, %Text%
	IniRead, OutputVar, %ConfigFile%,  QUEST_%text%, ,
	if(OutputVar = "")
		GuiControl,q:, IsData, 데이터 없음!!
	else
		GuiControl,q:, IsData,
	; IniRead, OutputVar, %ConfigFile%,  QUEST_%text%, 체크박스,  데이터 없음
	; GuiControl,q:, 체크박스, %OutputVar%
	; IniRead, OutputVar, %ConfigFile%,  QUEST_%text%, 드랍다운,  데이터 없음
	; GuiControl,q: choose, 드랍다운, %OutputVar%
	gui := "q:"
	section := "QUEST_" text
	
	IniRead("파티선택", gui, section, 1, "choose")
	loop, 3       
		IniRead("타겟" a_index, gui, section, 1, "choose")

	loop,3
    {
        ii := a_index
        loop, 3
            IniRead("보구" ii "라" a_index, gui, section, 0) 
    }
	loop,3
    {
        ii := a_index
        loop, 3       
            IniRead("마스터" ii "라" a_index, gui, section, 1, "choose") 
	}
	loop,3
    {
		ii := a_index
		loop, 9
			IniRead("스킬" ii "라" a_index, gui, section, 1, "choose") 
	}
	loop, 3
    {
        ii := a_index
        loop, 2        
            IniRead("오더" ii "라" a_index, gui, section, 1, "choose")
    }
	loop, 3
    {
        ii := a_index
        loop, 3       
            IniRead("오첸스킬" ii "라" a_index, gui, section,1 , "choose")
    }
	loop, 3
    {          
        IniRead("자동스킬" a_index, gui, section, 0)
    }
	IniRead("카드순위", gui, section, "EB>EA>EQ>B>A>Q>RB>RA>RQ")
	; IniRead, OutputVar, %ConfigFile%, %section%, 카드순위, BE>AE>QE>BN>AN>QN>BR>AR>QR
	; GuiControl, %gui% , 카드순위, %OutputVar%	
	;IniRead("카드순위", gui, section)
	IniRead("프렌드체크", gui, section, 0)
	IniRead("예장체크", gui, section, 0)
	IniRead("풀돌체크", gui, section, 0)
	;addlog("# " text " 로드 완료")
	fileName := "Image\Quest\" Text "_support.bmp"	
	Guicontrol, q:, SupportPic ,%fileName%
	fileName := "Image\Quest\" Text "_frEssence.bmp"
	Guicontrol, q:, frEssencePic ,%fileName%
}

qGuiClose()
{
	IniRead, OutputVar, %ConfigFile%, LVitem, LV
	;GuiControl,1:, 퀘스트설정DDL,
	GuiControlGet, 퀘스트설정DDL, 1:
    GuiControl,1:, 퀘스트설정DDL, |%OutputVar%
	GuiControl,1: choose, 퀘스트설정DDL, %퀘스트설정DDL%
}

; IniReadDDL(key, gui = "1:", Section = "Option")
; {
;     IniRead, OutputVar, %ConfigFile%, %Section%, %key%
; 	if (OutputVar = "ERROR")
; 		GuiControl, %gui% Choose, %key%, 1
;     else
; 		GuiControl, %gui% Choose, %key%, %OutputVar%
; }