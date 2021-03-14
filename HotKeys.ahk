; ^f6::
;     스크린샷()
; return

 
^f10:: 
getAdbScreen()
loop, 10
{
    if(IsImgWithoutCap(clickX, clickY, "파티선택.bmp", 60, 0,PartyPos[a_index].X-5,PartyPos[a_index].Y-5,PartyPos[a_index].X+5,PartyPos[a_index].Y+5))
    {
        addlog(a_index)
    }
}
return

hbm2 := 0

zsa(a,b)
{
    MsgBox, % a b
}


^f11::
;getAdbScreen()
;loop,5
;{
    ; if( IsImgWithoutCap(clickX, clickY, "buster1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
    ; && IsImgWithoutCap(clickX, clickY, "buster2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
    ; {
    ;     ;ClickAdb(CmdCardPos[a_index].sX + 80, 320)
    ;     card%a_index% := 1
    ;     ;sleep, 300
    ;     addlog("buster " a_index)
    ; }
    ; if( IsImgWithoutCap(clickX, clickY, "arts1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
    ; && IsImgWithoutCap(clickX, clickY, "arts2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
    ; {
    ;     ;ClickAdb(CmdCardPos[a_index].sX + 80, 320)
    ;     card%a_index% := 1
    ;     ;sleep, 300
    ;     addlog("arts " a_index)
    ; }
    ; if( IsImgWithoutCap(clickX, clickY, "quick1.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 )
    ; && IsImgWithoutCap(clickX, clickY, "quick2.bmp", 10, 0, CmdCardPos[a_index].sX+30, CmdCardPos[a_index].sY+85, CmdCardPos[a_index].eX-80, CmdCardPos[a_index].eY-30 ))
    ; {
    ;     ;ClickAdb(CmdCardPos[a_index].sX + 80, 320)
    ;     ;card%a_index% := 1
    ;     ;sleep, 300
    ;     addlog("quick " a_index)
    ; }
    ; if(IsImgWithoutCap(clickX, clickY, "effective.bmp", 90, "white", CmdCardPos[a_index].sX+110, CmdCardPos[a_index].sY-40, CmdCardPos[a_index].eX-15, CmdCardPos[a_index].sY+5 ))
    ; {   
    ;     addlog("ef " a_index)
    ; }

   
;}
GuiControlGet, 퀘스트설정DDL, 1:
IniRead, gSectionVal, %ConfigFile%, QUEST_%퀘스트설정DDL%
; section := "QUEST_" 퀘스트설정DDL
; IniRead, OutputVarSection, %ConfigFile%, %Section%
; ;msgbox, % OutputVarSection
; Loop, Parse, OutputVarSection , `n, `r
; {
;     StringSplit, word_array, A_LoopField, =
;     addlog(word_array1 " " word_array2)
; }
;  gosub, 설정불러오기

; aa := ini찾기("자동스킬3")
; addlog(aa)
;     bac()
; addlog(g타겟1 "a")
;     addlog(퀘스트설정DDL "b")
return



bac()
{
    
    addlog(g타겟1 "a")
    addlog(퀘스트설정DDL "b")
}
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


;  ^F2::
; ;fileName := A_DD "d_" A_HOUR "h_" A_MIN "m_" A_SEC "s.png"
; ;		CaptureAdb(fileName)
; 		addlog("zz")
; 		SendTelegramImg2("adbCapture/party.png")
;  return


; ^f4::
; 	array := [[1,2,3],[4,5,6]]
; 	addlog(array[2,1])
; return


;/*