^f6::
    스크린샷()
return

 x := 10  
^f10:: 

네모그리기(x,10,30,50)
x+=5
;GuiControl, 2: move,  square1, x100 y100 w100 h450
return

hbm2 := 0

zsa(a,b)
{
    MsgBox, % a b
}


^f11::
a := 12
b:=2
fn := Func("zsa").Bind(a,b)
SetTimer,%fn%, -1000

return
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