#include JSON.ahk

global TIME_REFRESH := 250 ;매크로 대기시간 (화면전환 등)
global EmulTitle:= "[MOMO]앱플레이어"

;global wFrame := 1 ;테두리 두께 border
;global wCaption := 34 ;타이틀바 높이 

AddLog(String) ;;애드로그
{
	Gui,  Font, S7 CDefault, Verdana
	GuiControl,  Font, LogList
	nowTime := "" A_HOUR ":" A_MIN " "
	LogList .= nowTime String "|"
	GuiControl, , LogList, %LogList%
	GuiControl,  Choose, LogList, %nLog%
	nLog++
	Gui,  Font, S8 CDefault, Verdana
}

SleepLog(SleepTime) ;;슬립로그
{
	Log := "# 대기: " SleepTime "ms"
	AddLog(Log)
	sleep, %SleepTime%
}

PushLine2(msg, imageName = 0)
{	
    msg := UriEncode(msg)

    RunWait, utility\curl.exe -k -H "Authorization: Bearer %notifyToken%" -d "message=%msg%" https://notify-api.line.me/api/notify,, Hide	
    if(imageName)
        RunWait, utility\curl.exe -k -X POST -H "Authorization: Bearer %notifyToken%" -F "message=%imageName%" -F "imageFile=@%imageName%" https://notify-api.line.me/api/notify,, Hide
    ;objExec := objShell.Exec("curl.exe -k -X POST -H ""Authorization: Bearer " notifyToken """ -F ""message=" msg """ https://notify-api.line.me/api/notify")
    addlog("LINE Notify 메시지 전송")
}

;#include Token.ahk
PushLine(msg, imageName = 0)
{
	winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")	
    winHttp.Open("POST", "https://notify-api.line.me/api/notify")
	winHttp.SetRequestHeader("Authorization","Bearer " notifyToken)	
	  
    if(imageName)
	{
		objParam := { "message": msg, "photo": [imageName]  }		
		CreateFormData(postData, hdr_ContentType, objParam)
		winHttp.SetRequestHeader("Content-Type", hdr_ContentType)
		winHttp.Send(postData)
	}
	else
	{
		winHttp.SetRequestHeader("Content-Type","application/x-www-form-urlencoded")
		winHttp.Send("message=" msg)
	}
	winHttp.WaitForResponse()
	res := winHttp.ResponseText	
    addlog("LINE Notify:" res)
}

;텔레그램 챗아이디 및 봇토큰
global chatID
global botToken

PushTelegram2(msg)
{    
    msg := UriEncode(msg)

    RunWait, utility\curl.exe -k -d "chat_id=%chatID%&text=%msg%" https://api.telegram.org/bot%botToken%/sendMessage,, Hide    
    ;objExec := objShell.Exec("curl.exe -k -d ""chat_id=" chatID "&text=" msg """ https://api.telegram.org/bot" botToken "/sendMessage" ) ;attach한 cmd 사용
    ;addlog("Telegram Bot 메시지 전송")   
}

PushTelegramImg2(imageName)
{
	 RunWait, utility/curl.exe -k -F "chat_id=%chatID%" -F "photo=@%imageName%" https://api.telegram.org/bot%botToken%/sendPhoto,, Hide
}


PushTelegram(msg)
{
	winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1") 
	winHttp.Open("POST", "https://api.telegram.org/bot" botToken "/sendMessage")
	winHttp.SetRequestHeader("Content-Type","application/x-www-form-urlencoded")
	;winHttp.SetRequestHeader("Content-Type", "application/json") ;json 형태로 보낼때
	winHttp.Send("chat_id=" chatID "&text=" msg)
	winHttp.WaitForResponse() ; 보낼때까지 기다린다
	res:=winHttp.ResponseText
	addlog("Telegram Bot: " res)
}

PushTelegramImg(imageName) ;;
{
	objParam := { "chat_id": chatID	, "photo": [imageName]  }
	CreateFormData(postData, hdr_ContentType, objParam)

	winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	winHttp.Open("POST", "https://api.telegram.org/bot" botToken "/sendPhoto")
	winHttp.SetRequestHeader("Content-Type", hdr_ContentType)	
	winHttp.Send(postData)
	winHttp.WaitForResponse() ; response 기다린다
	res:=winHttp.ResponseText
	addlog("Telegram Bot: " res)	
}

global lastDate = 0
getTelegramMsg()
{
	url := "https://api.telegram.org/bot" botToken "/getUpdates"
	winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	winHttp.Open("GET", url)		
	winHttp.Send()
	winHttp.WaitForResponse() ; response 기다린다
	getUpdates:= winHttp.ResponseText	

	if(getUpdates = 0)
	{
		AddLog("# 텔레그램 메시지 업뎃 실패")
		return false
	}

	jsonDat := Json.load(getUpdates)
	num := jsonDat.result.Length() ;result 중에 가장 마지막 항 찾기
	date1 := jsonDat.result[num].message.date
	
	if(lastDate = 0) ; 기존에 저장되있던 메시지 무시하기
	{	
		lastDate := date1
		return false
	}
	if(date1 = lastDate) ; date가 변하지 않았기 때문에 새로운 메시지 온 것 아님	
	{
		return false
	}
	if(jsonDat.result[num].message.from.id != chatID) ;등록된 chatID와 메시지 보낸 사람 아이디 달라도 무시
		return false

	lastDate := date1

	newMsg := jsonDat.result[num].message.text
	;addlog(newMsg)
	return newMsg
}

;URLDownloadToVar , ReadURL 같은 기능으로 추정
URLDownloadToVar(url) 
{
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}

ReadURL(URL, encoding = "utf-8") 
{
    static a := "AutoHotkey/" A_AhkVersion
    
    if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
        return 0
    
    c := s := 0, o := ""
    
    if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
    {
        while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
        {
            VarSetCapacity(b, s, 0)
            DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
            o .= StrGet(&b, r >> (encoding = "utf-16" || encoding = "cp1200"), encoding)
        }
        DllCall("wininet\InternetCloseHandle", "ptr", f)
    }
    DllCall("wininet\InternetCloseHandle", "ptr", h)
    return o
}

RealWinSize(ByRef posX, ByRef posY, ByRef width , ByRef height, ProcessID)
{
	WinGetPos, X, Y, W, H, %ProcessID%
	SysGet, wFrame, 7
	SysGet, wCaption, 4
	posX := X
	posY := Y
	width := W - wFrame * 2
	height := H - wFrame * 2 - wCaption
	return
}

UriEncode(Uri, Enc = "UTF-8") ;텍스트를 url인코딩
{
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
		Break
		If (Code >= 0x30 && Code <= 0x39
		|| Code >= 0x41 && Code <= 0x5A
		|| Code >= 0x61 && Code <= 0x7A)
		Res .= Chr(Code)
		Else
		Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

StrPutVar(Str, ByRef Var, Enc = "") ; UriEncode 함수에 필요한 함수
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}

;;웨잇이미지플러스  이미지 대기하면서 찾다가 없으면 세나 리스타트
WaitImagePlus(ByRef clickX, ByRef clickY, ImageName, errorRange, trans, sX = 0, sY = 0, eX = 0, eY = 0) 
{
	if(ImageName != "Image\Adventure\Store.bmp")
	{
		log := "  @ 이미지 대기: " ImageName
		AddLog(log)
	}
	Delay = 0
	Loop
	{
		if(IsImagePlus(clickX, clickY, ImageName, errorRange, trans, sX, sY, eX, eY)) ;;찾는 이미지가 있다면 잠시 쉬고 트루 리턴
		{
			SleepLog( TIME_IMAGE )
			return true
		}
		if(AfterRestart = 1)
		{
			log := "# 재시작이 일어났습니다"
			AddLog(log)
			return false
		}
		sleep, %TIME_REFRESH%
		Delay++
		if(TIME_REFRESH * Delay > TIME_WAITIMAGE) ;;찾는 이미지 없다면 루프 돌리다가 너무 오래걸리면 false 리턴
		{
			waitTime := TIME_REFRESH * Delay
			log := "  @ 이미지 대기: 제한 시간 초과 (" waitTime "ms)"
			AddLog(log)
			return false
		
		}
	}
}

IsPixelSquare( ByRef clickX, ByRef clickY, ColorID, sX, sY, eX, eY ) ;;이즈픽셀스퀘어 (gdip 방식에서 사용불가)
{
	CoordMode, Pixel, Screen
	RealWinSize(posX, posY, width, height, EmulTitle)
	;SysGet, wFrame, 7
	;SysGet, wCaption, 4
	sX := sX + posX + wFrame
	sY := sY + posY + wFrame + wCaption
	eX := eX + posX + wFrame
	eY := eY + posY + wFrame + wCaption
	PixelSearch, vX, vY, sX, sY, eX, eY, %ColorID%, 5, Fast RGB 
	if (ErrorLevel = 0)
	{
		clickX := vX - posX
		clickY := vY - posY
		return true
	}
	if (ErrorLevel = 1)
	{
		clickX := 0
		clickY := 0
		return false
	}
}

Capture(filename)
{
	pToken := Gdip_Startup()
	WinGetPos, X, Y, W, H, %EmulTitle%
	;SysGet, wFrame, 32 ;7
	;SysGet, wCaption, 4 ;4
	posX := X + wFrame
	posY := Y + wFrame + wCaption
	width := W - wFrame * 2
	height := H - wFrame * 2 - wCaption
	snap := Gdip_BitmapFromScreen(posX "|" posY "|" width "|" height)
	Gdip_SaveBitmapToFile(snap, filename)
	Gdip_DisposeImage(snap)
	Gdip_ShutDown(pToken)
	log := "# 캡처 완료"
	AddLog(log)
}

Click(x, y) ;클릭
{
	sleep, %TIME_REFRESH%
	;x += wFrame
	;y += wCaption + wFrame
	Coor := x | y<<16
	WinGet, ActiveID, ID, %EmulTitle%
	if(x = 0 && y = 0)
	{
		log := "# 이미지 검색 실패로 클릭 실패"
		AddLog(log)
		return false
	}
	if not getkeystate("Ctrl" , "p")
	{
		PostMessage, 0x201, 1, %Coor%, TheRender, ahk_id %ActiveID%
		PostMessage, 0x202, 0, %Coor%, TheRender, ahk_id %ActiveID%
		log := "# 클릭: " x ", " y
		AddLog(log)
		sleep, %TIME_REFRESH%
	}
	else if getkeystate("Ctrl" , "p")
	{
		log := "# 클릭 대기 : Ctrl "
		AddLog(log)
		Loop
		{
			if not getkeystate("Ctrl" , "p")
			{
				PostMessage, 0x201, 1, %Coor%, TheRender, ahk_id %ActiveID%
				PostMessage, 0x202, 0, %Coor%, TheRender, ahk_id %ActiveID%
				log := "# 클릭: " x ", " y
				AddLog(log)
				sleep, %TIME_REFRESH%
				break
			}
			sleep, 100
		}
	}
}

ClickFast(X, Y)
{
	;x += wFrame
	;y += wCaption + wFrame
	Coor := x | y<<16
	WinGet, ActiveID, ID, %EmulTitle%
	if(x = 0 && y = 0)
	{
	log := "# 이미지 검색 실패로 클릭 실패"
	AddLog(log)
	return false
	}
	if not getkeystate("Ctrl" , "p")
	{
	PostMessage, 0x201, 1, %Coor%, TheRender, ahk_id %ActiveID%
	PostMessage, 0x202, 0, %Coor%, TheRender, ahk_id %ActiveID%
	}
	else if getkeystate("Ctrl" , "p")
	{
	log := "# 클릭 대기 : Ctrl "
	AddLog(log)
	Loop
	{
	if not getkeystate("Ctrl" , "p")
	{
	PostMessage, 0x201, 1, %Coor%, TheRender, ahk_id %ActiveID%
	PostMessage, 0x202, 0, %Coor%, TheRender, ahk_id %ActiveID%
	break
	}
	sleep, 100
	}
	}
}

ClickToImage(ByRef clickX, ByRef clickY, ImageName) ;;클릭투이미지 클릭후이미지대기
{
	sleep, %TIME_REFRESH%
	;clickX += wFrame
	;clickY += wCaption + wFrame
	Coor := clickX | clickY <<16
	x := clickX
	y := clickY
	WinGet, ActiveID, ID, %EmulTitle%
	if(clickX= 0 && clickY = 0)
	{
		log := "# 이미지 검색 실패로 클릭 실패"
		AddLog(log)
		return false
	}
	Loop
	{
		if not getkeystate("Ctrl" , "p")
		{
		PostMessage, 0x201, 1, %Coor%, TheRender, ahk_id %ActiveID%
		PostMessage, 0x202, 0, %Coor%, TheRender, ahk_id %ActiveID%
		log := "# 클릭: (" x ", " y ")후 이미지 대기 " ImageName
		AddLog(log)
		sleep, %TIME_REFRESH%
		}
		else if getkeystate("Ctrl" , "p")
		{
			log := "# 클릭 대기 : Ctrl "
			AddLog(log)
			Loop
			{
				if not getkeystate("Ctrl" , "p")
				{
					PostMessage, 0x201, 1, %Coor%, TheRender, ahk_id %ActiveID%
					PostMessage, 0x202, 0, %Coor%, TheRender, ahk_id %ActiveID%
					log := "# 클릭: (" x ", " y ")후 이미지 대기 " ImageName
					AddLog(log)
					sleep, %TIME_REFRESH%
					break
				}
				sleep, %TIME_REFRESH%
			}
		}
		Loop, 200
		{
			if(IsImagePlus(clickX, clickY, ImageName, 60, 0))
			return true
			if(AfterRestart = 1)
			{
				log := "# 재시작이 일어났습니다"
				AddLog(log)
				return false
			}
			sleep, %TIME_REFRESH%
		}
		if(A_Index > 10)
			AfterRestart := 1
		if(AfterRestart = 1)
		{
			log := "# 재시작이 일어났습니다"
			AddLog(log)
			return false
		}
		sleep, 20000
	}
}

IsImagePlus(ByRef clickX, ByRef clickY, ImageName, errorRange, trans="", sX = 0, sY = 0, eX = 0, eY = 0) ;이즈이미지플러스 gdip방식
{		
	IfNotExist, %ImageName% ;;해당이미지가 없으면 이미지 없다는 로그 출력하고 리턴
	{
		log := "  @ 이미지 없음: " ImageName
		AddLog(log)
		return false
	}
	
	WinGet, Title, ID, %EmulTitle%
    If(Gdip_ImageSearchWithHwnd(Title, ClickX, ClickY, ImageName, errorRange, trans, sX, sY, eX, eY))
    {
		log := "  @ 이미지 찾음 : " ImageName
		AddLog(log)	
        return true
    }
	else ;; 에러가 있으면
	{
		clickX := 0
		clickY := 0
		;log := "  @ 이미지 못 찾음 : " ImageName
		;AddLog(log)	
		return false
	}
}

IsImageWithoutLog(ByRef clickX, ByRef clickY, ImageName, errorRange, trans, sX = 0, sY = 0, eX = 0, eY = 0) ;gdip
{
	IfNotExist, %ImageName% ;;해당이미지가 없으면 이미지 없다는 로그 출력하고 리턴
	{
		log := "  @ 이미지 없음: " ImageName
		AddLog(log)
		return false
	}
	
	WinGet, Title, ID, %EmulTitle%
    If(Gdip_ImageSearchWithHwnd(Title, ClickX, ClickY, ImageName, errorRange, trans, sX, sY, eX, eY))
    {
		;log := "  @ 이미지 찾음 : " ImageName
		;AddLog(log)	
        return true
    }
	else ;; 에러가 있으면
	{
		clickX := 0
		clickY := 0
		;log := "  @ 이미지 못 찾음 : " ImageName
		;AddLog(log)	
		return false
	}
}

Gdip_ImageSearchWithHwnd(Hwnd,Byref X,Byref Y,Image,Variation=0,Trans="",sX = 0,sY = 0,eX = 0,eY = 0) ;핸들에서 이미지를 서치
{
	;SysGet, wFrame, 7
	;SysGet, wCaption, 4
	gdipToken := Gdip_Startup()
	bmpHaystack := Gdip_BitmapFromHwnd(Hwnd)
	bmpNeedle := Gdip_CreateBitmapFromFile(Image)
	if( sX!= 0 || sY!= 0 || eX!= 0 || eY != 0)
	{
	sX := sX + wFrame
	sY := sY + wCaption + wFrame
	eX := eX + wFrame
	eY := eY + wCaption + wFrame
	}
	RET := Gdip_ImageSearch(bmpHaystack,bmpNeedle,LIST,sX,sY,eX,eY,Variation,Trans,1,1)
	Gdip_DisposeImage(bmpHaystack)
	Gdip_DisposeImage(bmpNeedle)
	Gdip_Shutdown(gdipToken)
	StringSplit, LISTArray, LIST, `,
	X := LISTArray1 - wFrame
	Y := LISTArray2 - wCaption - wFrame
	;GuiControl,,로그, %bmpHaystack%||%bmpNeedle%||%RET%
	;msgbox, %bmpHaystack%,%bmpNeedle%,%RET%
	if(RET = 1)
		return true
	else
		return false
}

Gdip_ImageSearchWithFile(file, Byref X,Byref Y,Image,Variation=0,Trans="",sX = 0,sY = 0,eX = 0,eY = 0) ;스샷 이미지 파일에서 이미지를 서치
{
	gdipToken := Gdip_Startup()
	bmpHaystack := Gdip_CreateBitmapFromFile(file) ;gdip 이미지 서치와 다른 부분. 핸들이 아닌 adb에서 받아온 이미지로부터 서치
	bmpNeedle := Gdip_CreateBitmapFromFile(Image)
	RET := Gdip_ImageSearch(bmpHaystack,bmpNeedle,LIST,sX,sY,eX,eY,Variation,Trans,1,1)
	Gdip_DisposeImage(bmpHaystack)
	Gdip_DisposeImage(bmpNeedle)
	Gdip_Shutdown(gdipToken)
	StringSplit, LISTArray, LIST, `,
	X := LISTArray1
	Y := LISTArray2
	
	if(RET = 1)
		return true
	else
		return false
}

Gdip_ResizeBitmap(pBitmap,fixed_width=0,fixed_height=0,enable_ratio="false",ratio=1)
{
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

	if (enable_ratio = "true")
		ratio:=ratio
	Else
	{
		if !fixed_height and fixed_width
			ratio:=fixed_width/width
		if !fixed_width and  fixed_height
			ratio:=fixed_height/height
	}
	;msgbox %ratio%
	w:=floor(width*ratio)
	h:=floor(height*ratio)
	pBitmap2 := Gdip_CreateBitmap(w, h)
	G := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(G, pBitmap, 0, 0, w, h, 0, 0, Width, Height)
	Gdip_DisposeImage(pBitmap)
	Gdip_DeleteGraphics(G)
	return pBitmap2
}

Gdip_CropImage(pBitmap, x, y, w, h)
{
	pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
	Gdip_DeleteGraphics(G2)
	Gdip_DisposeImage(G2)
	return pBitmap2
}

Gdip_RotateBitmap(pBitmap, Angle, Dispose=1) ; returns rotated bitmap. By Learning one.
{
	Gdip_GetImageDimensions(pBitmap, Width, Height)
	Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
	Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

	pBitmap2 := Gdip_CreateBitmap(RWidth, RHeight)
	G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
	Gdip_TranslateWorldTransform(G2, xTranslation, yTranslation)
	Gdip_RotateWorldTransform(G2, Angle)
	Gdip_DrawImage(G2, pBitmap, 0, 0, Width, Height)

	Gdip_ResetWorldTransform(G2)
	Gdip_DeleteGraphics(G2)
	if Dispose
		Gdip_DisposeImage(pBitmap)
	return pBitmap2
} ; http://www.autohotkey.com/community/viewtopic.php?p=477333#p477333

Gdip_ImageSearch(pBitmapHaystack,pBitmapNeedle,ByRef OutputList=""
,OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,Trans=""
,SearchDirection=1,Instances=1,LineDelim="`n",CoordDelim=",") 
{
	If !( pBitmapHaystack && pBitmapNeedle )
	Return -1001
	If Variation not between 0 and 255
	return -1002
	If ( ( OuterX1 < 0 ) || ( OuterY1 < 0 ) )
	return -1003
	If SearchDirection not between 1 and 8
	SearchDirection := 1
	If ( Instances < 0 )
	Instances := 0
	Gdip_GetImageDimensions(pBitmapHaystack,hWidth,hHeight)
	If Gdip_LockBits(pBitmapHaystack,0,0,hWidth,hHeight,hStride,hScan,hBitmapData,1)
	OR !(hWidth := NumGet(hBitmapData,0))
	OR !(hHeight := NumGet(hBitmapData,4))
	Return -1004
	Gdip_GetImageDimensions(pBitmapNeedle,nWidth,nHeight)
	If(Trans = 0)
	{
	Trans := ""
	}
	If(Trans = "White")
	{
	Trans := 0xFFFFFF
	}
	If(Trans = "Black")
	{
	Trans := 0x000000
	}
	If Trans between 0 and 0xFFFFFF
	{
	pOriginalBmpNeedle := pBitmapNeedle
	pBitmapNeedle := Gdip_CloneBitmapArea(pOriginalBmpNeedle,0,0,nWidth,nHeight)
	Gdip_SetBitmapTransColor(pBitmapNeedle,Trans)
	DumpCurrentNeedle := true
	}
	If Gdip_LockBits(pBitmapNeedle,0,0,nWidth,nHeight,nStride,nScan,nBitmapData)
	OR !(nWidth := NumGet(nBitmapData,0))
	OR !(nHeight := NumGet(nBitmapData,4))
	{
	If ( DumpCurrentNeedle )
	Gdip_DisposeImage(pBitmapNeedle)
	Gdip_UnlockBits(pBitmapHaystack,hBitmapData)
	Return -1005
	}
	OuterX2 := ( !OuterX2 ? hWidth-nWidth+1 : OuterX2-nWidth+1 )
	OuterY2 := ( !OuterY2 ? hHeight-nHeight+1 : OuterY2-nHeight+1 )
	OutputCount := Gdip_MultiLockedBitsSearch(hStride,hScan,hWidth,hHeight
	,nStride,nScan,nWidth,nHeight,OutputList,OuterX1,OuterY1,OuterX2,OuterY2
	,Variation,SearchDirection,Instances,LineDelim,CoordDelim)
	Gdip_UnlockBits(pBitmapHaystack,hBitmapData)
	Gdip_UnlockBits(pBitmapNeedle,nBitmapData)
	If ( DumpCurrentNeedle )
	Gdip_DisposeImage(pBitmapNeedle)
	Return OutputCount
}

Gdip_SetBitmapTransColor(pBitmap,TransColor) {
	static _SetBmpTrans, Ptr, PtrA
	if !( _SetBmpTrans ) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	PtrA := Ptr . "*"
	MCode_SetBmpTrans := "
				(LTrim Join
				8b44240c558b6c241cc745000000000085c07e77538b5c2410568b74242033c9578b7c2414894c24288da424000000
				0085db7e458bc18d1439b9020000008bff8a0c113a4e0275178a4c38013a4e01750e8a0a3a0e7508c644380300ff450083c0
				0483c204b9020000004b75d38b4c24288b44241c8b5c2418034c242048894c24288944241c75a85f5e5b33c05dc3,405
				34c8b5424388bda41c702000000004585c07e6448897c2410458bd84c8b4424304963f94c8d49010f1f800000000085db7e3
				8498bc1488bd3660f1f440000410fb648023848017519410fb6480138087510410fb6083848ff7507c640020041ff024883c
				00448ffca75d44c03cf49ffcb75bc488b7c241033c05bc3
	)"
	if ( A_PtrSize == 8 )
	MCode_SetBmpTrans := SubStr(MCode_SetBmpTrans,InStr(MCode_SetBmpTrans,",")+1)
	else
	MCode_SetBmpTrans := SubStr(MCode_SetBmpTrans,1,InStr(MCode_SetBmpTrans,",")-1)
	VarSetCapacity(_SetBmpTrans, LEN := StrLen(MCode_SetBmpTrans)//2, 0)
	Loop, %LEN%
	NumPut("0x" . SubStr(MCode_SetBmpTrans,(2*A_Index)-1,2), _SetBmpTrans, A_Index-1, "uchar")
	MCode_SetBmpTrans := ""
	DllCall("VirtualProtect", Ptr,&_SetBmpTrans, Ptr,VarSetCapacity(_SetBmpTrans), "uint",0x40, PtrA,0)
	}
	If !pBitmap
	Return -2001
	If TransColor not between 0 and 0xFFFFFF
	Return -2002
	Gdip_GetImageDimensions(pBitmap,W,H)
	If !(W && H)
	Return -2003
	If Gdip_LockBits(pBitmap,0,0,W,H,Stride,Scan,BitmapData)
	Return -2004
	Gdip_FromARGB(TransColor,A,R,G,B), VarSetCapacity(TransColor,0), VarSetCapacity(TransColor,3,255)
	NumPut(B,TransColor,0,"UChar"), NumPut(G,TransColor,1,"UChar"), NumPut(R,TransColor,2,"UChar")
	MCount := 0
	E := DllCall(&_SetBmpTrans, Ptr,Scan, "int",W, "int",H, "int",Stride, Ptr,&TransColor, "int*",MCount, "cdecl int")
	Gdip_UnlockBits(pBitmap,BitmapData)
	If ( E != 0 ) {
	ErrorLevel := E
	Return -2005
	}
	Return MCount
}

Gdip_MultiLockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride,nScan,nWidth,nHeight
,ByRef OutputList="",OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0
,SearchDirection=1,Instances=0,LineDelim="`n",CoordDelim=",")
{
	OutputList := ""
	OutputCount := !Instances
	InnerX1 := OuterX1 , InnerY1 := OuterY1
	InnerX2 := OuterX2 , InnerY2 := OuterY2
	iX := 1, stepX := 1, iY := 1, stepY := 1
	Modulo := Mod(SearchDirection,4)
	If ( Modulo > 1 )
	iY := 2, stepY := 0
	If !Mod(Modulo,3)
	iX := 2, stepX := 0
	P := "Y", N := "X"
	If ( SearchDirection > 4 )
	P := "X", N := "Y"
	iP := i%P%, iN := i%N%
	While (!(OutputCount == Instances) && (0 == Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride
	,nScan,nWidth,nHeight,FoundX,FoundY,OuterX1,OuterY1,OuterX2,OuterY2,Variation,SearchDirection)))
	{
	OutputCount++
	OutputList .= LineDelim FoundX CoordDelim FoundY
	Outer%P%%iP% := Found%P%+step%P%
	Inner%N%%iN% := Found%N%+step%N%
	Inner%P%1 := Found%P%
	Inner%P%2 := Found%P%+1
	While (!(OutputCount == Instances) && (0 == Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride
	,nScan,nWidth,nHeight,FoundX,FoundY,InnerX1,InnerY1,InnerX2,InnerY2,Variation,SearchDirection)))
	{
	OutputCount++
	OutputList .= LineDelim FoundX CoordDelim FoundY
	Inner%N%%iN% := Found%N%+step%N%
	}
	}
	OutputList := SubStr(OutputList,1+StrLen(LineDelim))
	OutputCount -= !Instances
	Return OutputCount
}

Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride,nScan,nWidth,nHeight
,ByRef x="",ByRef y="",sx1=0,sy1=0,sx2=0,sy2=0,Variation=0,sd=1)
{
	static _ImageSearch, Ptr, PtrA
	if !( _ImageSearch ) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	PtrA := Ptr . "*"
	MCode_ImageSearch := "
				(LTrim Join
				8b44243883ec205355565783f8010f857a0100008b7c2458897c24143b7c24600f8db50b00008b44244c8b5c245c8b
				4c24448b7424548be80fafef896c242490897424683bf30f8d0a0100008d64240033c033db8bf5896c241c895c2420894424
				183b4424480f8d0401000033c08944241085c90f8e9d0000008b5424688b7c24408beb8d34968b54246403df8d4900b80300
				0000803c18008b442410745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b44
				24400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424108b7c
				24408b4c24444083c50483c30483c604894424103bc17c818b5c24208b74241c0374244c8b44241840035c24508974241ce9
				2dffffff8b6c24688b5c245c8b4c244445896c24683beb8b6c24240f8c06ffffff8b44244c8b7c24148b7424544703e8897c
				2414896c24243b7c24600f8cd5feffffe96b0a00008b4424348b4c246889088b4424388b4c24145f5e5d890833c05b83c420
				c383f8020f85870100008b7c24604f897c24103b7c24580f8c310a00008b44244c8b5c245c8b4c24448bef0fafe8f7d88944
				24188b4424548b742418896c24288d4900894424683bc30f8d0a0100008d64240033c033db8bf5896c2420895c241c894424
				243b4424480f8d0401000033c08944241485c90f8e9d0000008b5424688b7c24408beb8d34968b54246403df8d4900b80300
				0000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b44
				24400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424148b7c
				24408b4c24444083c50483c30483c604894424143bc17c818b5c241c8b7424200374244c8b44242440035c245089742420e9
				2dffffff8b6c24688b5c245c8b4c244445896c24683beb8b6c24280f8c06ffffff8b7c24108b4424548b7424184f03ee897c
				2410896c24283b7c24580f8dd5feffffe9db0800008b4424348b4c246889088b4424388b4c24105f5e5d890833c05b83c420
				c383f8030f85650100008b7c24604f897c24103b7c24580f8ca10800008b44244c8b6c245c8b5c24548b4c24448bf70faff0
				4df7d8896c242c897424188944241c8bff896c24683beb0f8c020100008d64240033c033db89742424895c2420894424283b
				4424480f8d76ffffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b80300
				0000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b44
				24400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c
				24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff
				8b6c24688b5c24548b4c24448b7424184d896c24683beb0f8d0affffff8b7c24108b44241c4f03f0897c2410897424183b7c
				24580f8c580700008b6c242ce9d4feffff83f8040f85670100008b7c2458897c24103b7c24600f8d340700008b44244c8b6c
				245c8b5c24548b4c24444d8bf00faff7896c242c8974241ceb098da424000000008bff896c24683beb0f8c020100008d6424
				0033c033db89742424895c2420894424283b4424480f8d06feffff33c08944241485c90f8e9f0000008b5424688b7c24408b
				eb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f
				752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d
				04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b742424
				8b4424280374244c40035c2450e92bffffff8b6c24688b5c24548b4c24448b74241c4d896c24683beb0f8d0affffff8b4424
				4c8b7c24104703f0897c24108974241c3b7c24600f8de80500008b6c242ce9d4feffff83f8050f85890100008b7c2454897c
				24683b7c245c0f8dc40500008b5c24608b6c24588b44244c8b4c2444eb078da42400000000896c24103beb0f8d200100008b
				e80faf6c2458896c241c33c033db8bf5896c2424895c2420894424283b4424480f8d0d01000033c08944241485c90f8ea600
				00008b5424688b7c24408beb8d34968b54246403dfeb0a8da424000000008d4900b803000000803c03008b442414745e8b44
				243c0fb67c2f020fb64c06028d04113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a
				2bca3bf97c548b44243c0fb63b0fb60c068d04113bf87f422bca3bf97c3c8b4424148b7c24408b4c24444083c50483c30483
				c604894424143bc17c818b5c24208b7424240374244c8b44242840035c245089742424e924ffffff8b7c24108b6c241c8b44
				244c8b5c24608b4c24444703e8897c2410896c241c3bfb0f8cf3feffff8b7c24688b6c245847897c24683b7c245c0f8cc5fe
				ffffe96b0400008b4424348b4c24688b74241089088b4424385f89305e5d33c05b83c420c383f8060f85670100008b7c2454
				897c24683b7c245c0f8d320400008b6c24608b5c24588b44244c8b4c24444d896c24188bff896c24103beb0f8c1a0100008b
				f50faff0f7d88974241c8944242ceb038d490033c033db89742424895c2420894424283b4424480f8d06fbffff33c0894424
				1485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d4900b803000000803c03008b442414745e8b44
				243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c06018b4424400fb67c28018d04113bf87f56
				2bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b4424148b7c24408b4c24444083c50483c30483
				c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e92bffffff8b6c24108b74241c0374242c8b5c
				24588b4c24444d896c24108974241c3beb0f8d02ffffff8b44244c8b7c246847897c24683b7c245c0f8de60200008b6c2418
				e9c2feffff83f8070f85670100008b7c245c4f897c24683b7c24540f8cc10200008b6c24608b5c24588b44244c8b4c24444d
				896c241890896c24103beb0f8c1a0100008bf50faff0f7d88974241c8944242ceb038d490033c033db89742424895c242089
				4424283b4424480f8d96f9ffff33c08944241485c90f8e9f0000008b5424688b7c24408beb8d34968b54246403dfeb038d49
				00b803000000803c18008b442414745e8b44243c0fb67c2f020fb64c06028d04113bf87f752bca3bf97c6f8b44243c0fb64c
				06018b4424400fb67c28018d04113bf87f562bca3bf97c508b44243c0fb63b0fb60c068d04113bf87f3e2bca3bf97c388b44
				24148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c24208b7424248b4424280374244c40035c2450e9
				2bffffff8b6c24108b74241c0374242c8b5c24588b4c24444d896c24108974241c3beb0f8d02ffffff8b44244c8b7c24684f
				897c24683b7c24540f8c760100008b6c2418e9c2feffff83f8080f85640100008b7c245c4f897c24683b7c24540f8c510100
				008b5c24608b6c24588b44244c8b4c24448d9b00000000896c24103beb0f8d200100008be80faf6c2458896c241c33c033db
				8bf5896c2424895c2420894424283b4424480f8d9dfcffff33c08944241485c90f8ea60000008b5424688b7c24408beb8d34
				968b54246403dfeb0a8da424000000008d4900b803000000803c03008b442414745e8b44243c0fb67c2f020fb64c06028d04
				113bf87f792bca3bf97c738b44243c0fb64c06018b4424400fb67c28018d04113bf87f5a2bca3bf97c548b44243c0fb63b0f
				b604068d0c103bf97f422bc23bf87c3c8b4424148b7c24408b4c24444083c50483c30483c604894424143bc17c818b5c2420
				8b7424240374244c8b44242840035c245089742424e924ffffff8b7c24108b6c241c8b44244c8b5c24608b4c24444703e889
				7c2410896c241c3bfb0f8cf3feffff8b7c24688b6c24584f897c24683b7c24540f8dc5feffff8b4424345fc700ffffffff8b
				4424345e5dc700ffffffffb85ff0ffff5b83c420c3,4c894c24204c89442418488954241048894c24085355565741544
				155415641574883ec188b8424c80000004d8bd94d8bd0488bda83f8010f85b3010000448b8c24a800000044890c24443b8c2
				4b80000000f8d66010000448bac24900000008b9424c0000000448b8424b00000008bbc2480000000448b9424a0000000418
				bcd410fafc9894c24040f1f84000000000044899424c8000000453bd00f8dfb000000468d2495000000000f1f80000000003
				3ed448bf933f6660f1f8400000000003bac24880000000f8d1701000033db85ff7e7e458bf4448bce442bf64503f7904d63c
				14d03c34180780300745a450fb65002438d040e4c63d84c035c2470410fb64b028d0411443bd07f572bca443bd17c50410fb
				64b01450fb650018d0411443bd07f3e2bca443bd17c37410fb60b450fb6108d0411443bd07f272bca443bd17c204c8b5c247
				8ffc34183c1043bdf7c8fffc54503fd03b42498000000e95effffff8b8424c8000000448b8424b00000008b4c24044c8b5c2
				478ffc04183c404898424c8000000413bc00f8c20ffffff448b0c24448b9424a000000041ffc14103cd44890c24894c24044
				43b8c24b80000000f8cd8feffff488b5c2468488b4c2460b85ff0ffffc701ffffffffc703ffffffff4883c418415f415e415
				d415c5f5e5d5bc38b8424c8000000e9860b000083f8020f858c010000448b8c24b800000041ffc944890c24443b8c24a8000
				0007cab448bac2490000000448b8424c00000008b9424b00000008bbc2480000000448b9424a0000000418bc9410fafcd418
				bc5894c2404f7d8894424080f1f400044899424c8000000443bd20f8d02010000468d2495000000000f1f80000000004533f
				6448bf933f60f1f840000000000443bb424880000000f8d56ffffff33db85ff0f8e81000000418bec448bd62bee4103ef496
				3d24903d3807a03007460440fb64a02418d042a4c63d84c035c2470410fb64b02428d0401443bc87f5d412bc8443bc97c554
				10fb64b01440fb64a01428d0401443bc87f42412bc8443bc97c3a410fb60b440fb60a428d0401443bc87f29412bc8443bc97
				c214c8b5c2478ffc34183c2043bdf7c8a41ffc64503fd03b42498000000e955ffffff8b8424c80000008b9424b00000008b4
				c24044c8b5c2478ffc04183c404898424c80000003bc20f8c19ffffff448b0c24448b9424a0000000034c240841ffc9894c2
				40444890c24443b8c24a80000000f8dd0feffffe933feffff83f8030f85c4010000448b8c24b800000041ffc944898c24c80
				00000443b8c24a80000000f8c0efeffff8b842490000000448b9c24b0000000448b8424c00000008bbc248000000041ffcb4
				18bc98bd044895c24080fafc8f7da890c24895424048b9424a0000000448b542404458beb443bda0f8c13010000468d249d0
				000000066660f1f84000000000033ed448bf933f6660f1f8400000000003bac24880000000f8d0801000033db85ff0f8e960
				00000488b4c2478458bf4448bd6442bf64503f70f1f8400000000004963d24803d1807a03007460440fb64a02438d04164c6
				3d84c035c2470410fb64b02428d0401443bc87f63412bc8443bc97c5b410fb64b01440fb64a01428d0401443bc87f48412bc
				8443bc97c40410fb60b440fb60a428d0401443bc87f2f412bc8443bc97c27488b4c2478ffc34183c2043bdf7c8a8b8424900
				00000ffc54403f803b42498000000e942ffffff8b9424a00000008b8424900000008b0c2441ffcd4183ec04443bea0f8d11f
				fffff448b8c24c8000000448b542404448b5c240841ffc94103ca44898c24c8000000890c24443b8c24a80000000f8dc2fef
				fffe983fcffff488b4c24608b8424c8000000448929488b4c2468890133c0e981fcffff83f8040f857f010000448b8c24a80
				0000044890c24443b8c24b80000000f8d48fcffff448bac2490000000448b9424b00000008b9424c0000000448b8424a0000
				0008bbc248000000041ffca418bcd4489542408410fafc9894c2404669044899424c8000000453bd00f8cf8000000468d249
				5000000000f1f800000000033ed448bf933f6660f1f8400000000003bac24880000000f8df7fbffff33db85ff7e7e458bf44
				48bce442bf64503f7904d63c14d03c34180780300745a450fb65002438d040e4c63d84c035c2470410fb64b028d0411443bd
				07f572bca443bd17c50410fb64b01450fb650018d0411443bd07f3e2bca443bd17c37410fb60b450fb6108d0411443bd07f2
				72bca443bd17c204c8b5c2478ffc34183c1043bdf7c8fffc54503fd03b42498000000e95effffff8b8424c8000000448b842
				4a00000008b4c24044c8b5c2478ffc84183ec04898424c8000000413bc00f8d20ffffff448b0c24448b54240841ffc14103c
				d44890c24894c2404443b8c24b80000000f8cdbfeffffe9defaffff83f8050f85ab010000448b8424a000000044890424443
				b8424b00000000f8dc0faffff8b9424c0000000448bac2498000000448ba424900000008bbc2480000000448b8c24a800000
				0428d0c8500000000898c24c800000044894c2404443b8c24b80000000f8d09010000418bc4410fafc18944240833ed448bf
				833f6660f1f8400000000003bac24880000000f8d0501000033db85ff0f8e87000000448bf1448bce442bf64503f74d63c14
				d03c34180780300745d438d040e4c63d84d03da450fb65002410fb64b028d0411443bd07f5f2bca443bd17c58410fb64b014
				50fb650018d0411443bd07f462bca443bd17c3f410fb60b450fb6108d0411443bd07f2f2bca443bd17c284c8b5c24784c8b5
				42470ffc34183c1043bdf7c8c8b8c24c8000000ffc54503fc4103f5e955ffffff448b4424048b4424088b8c24c80000004c8
				b5c24784c8b54247041ffc04103c4448944240489442408443b8424b80000000f8c0effffff448b0424448b8c24a80000004
				1ffc083c10444890424898c24c8000000443b8424b00000000f8cc5feffffe946f9ffff488b4c24608b042489018b4424044
				88b4c2468890133c0e945f9ffff83f8060f85aa010000448b8c24a000000044894c2404443b8c24b00000000f8d0bf9ffff8
				b8424b8000000448b8424c0000000448ba424900000008bbc2480000000428d0c8d00000000ffc88944240c898c24c800000
				06666660f1f840000000000448be83b8424a80000000f8c02010000410fafc4418bd4f7da891424894424084533f6448bf83
				3f60f1f840000000000443bb424880000000f8df900000033db85ff0f8e870000008be9448bd62bee4103ef4963d24903d38
				07a03007460440fb64a02418d042a4c63d84c035c2470410fb64b02428d0401443bc87f64412bc8443bc97c5c410fb64b014
				40fb64a01428d0401443bc87f49412bc8443bc97c41410fb60b440fb60a428d0401443bc87f30412bc8443bc97c284c8b5c2
				478ffc34183c2043bdf7c8a8b8c24c800000041ffc64503fc03b42498000000e94fffffff8b4424088b8c24c80000004c8b5
				c247803042441ffcd89442408443bac24a80000000f8d17ffffff448b4c24048b44240c41ffc183c10444894c2404898c24c
				8000000443b8c24b00000000f8ccefeffffe991f7ffff488b4c24608b4424048901488b4c246833c0448929e992f7ffff83f
				8070f858d010000448b8c24b000000041ffc944894c2404443b8c24a00000000f8c55f7ffff8b8424b8000000448b8424c00
				00000448ba424900000008bbc2480000000428d0c8d00000000ffc8890424898c24c8000000660f1f440000448be83b8424a
				80000000f8c02010000410fafc4418bd4f7da8954240c8944240833ed448bf833f60f1f8400000000003bac24880000000f8
				d4affffff33db85ff0f8e89000000448bf1448bd6442bf64503f74963d24903d3807a03007460440fb64a02438d04164c63d
				84c035c2470410fb64b02428d0401443bc87f63412bc8443bc97c5b410fb64b01440fb64a01428d0401443bc87f48412bc84
				43bc97c40410fb60b440fb60a428d0401443bc87f2f412bc8443bc97c274c8b5c2478ffc34183c2043bdf7c8a8b8c24c8000
				000ffc54503fc03b42498000000e94fffffff8b4424088b8c24c80000004c8b5c24780344240c41ffcd89442408443bac24a
				80000000f8d17ffffff448b4c24048b042441ffc983e90444894c2404898c24c8000000443b8c24a00000000f8dcefeffffe
				9e1f5ffff83f8080f85ddf5ffff448b8424b000000041ffc84489442404443b8424a00000000f8cbff5ffff8b9424c000000
				0448bac2498000000448ba424900000008bbc2480000000448b8c24a8000000428d0c8500000000898c24c800000044890c2
				4443b8c24b80000000f8d08010000418bc4410fafc18944240833ed448bf833f6660f1f8400000000003bac24880000000f8
				d0501000033db85ff0f8e87000000448bf1448bce442bf64503f74d63c14d03c34180780300745d438d040e4c63d84d03da4
				50fb65002410fb64b028d0411443bd07f5f2bca443bd17c58410fb64b01450fb650018d0411443bd07f462bca443bd17c3f4
				10fb603450fb6108d0c10443bd17f2f2bc2443bd07c284c8b5c24784c8b542470ffc34183c1043bdf7c8c8b8c24c8000000f
				fc54503fc4103f5e955ffffff448b04248b4424088b8c24c80000004c8b5c24784c8b54247041ffc04103c44489042489442
				408443b8424b80000000f8c10ffffff448b442404448b8c24a800000041ffc883e9044489442404898c24c8000000443b842
				4a00000000f8dc6feffffe946f4ffff8b442404488b4c246089018b0424488b4c2468890133c0e945f4ffff
	)"
	if ( A_PtrSize == 8 )
	MCode_ImageSearch := SubStr(MCode_ImageSearch,InStr(MCode_ImageSearch,",")+1)
	else
	MCode_ImageSearch := SubStr(MCode_ImageSearch,1,InStr(MCode_ImageSearch,",")-1)
	VarSetCapacity(_ImageSearch, LEN := StrLen(MCode_ImageSearch)//2, 0)
	Loop, %LEN%
	NumPut("0x" . SubStr(MCode_ImageSearch,(2*A_Index)-1,2), _ImageSearch, A_Index-1, "uchar")
	MCode_ImageSearch := ""
	DllCall("VirtualProtect", Ptr,&_ImageSearch, Ptr,VarSetCapacity(_ImageSearch), "uint",0x40, PtrA,0)
	}
	If ( sx2 < sx1 )
	return -3001
	If ( sy2 < sy1 )
	return -3002
	If ( sx2 > (hWidth-nWidth+1) )
	return -3003
	If ( sy2 > (hHeight-nHeight+1) )
	return -3004
	If ( sx2-sx1 == 0 )
	return -3005
	If ( sy2-sy1 == 0 )
	return -3006
	x := 0, y := 0
	, E := DllCall( &_ImageSearch, "int*",x, "int*",y, Ptr,hScan, Ptr,nScan, "int",nWidth, "int",nHeight
	, "int",hStride, "int",nStride, "int",sx1, "int",sy1, "int",sx2, "int",sy2, "int",Variation
	, "int",sd, "cdecl int")
	Return ( E == "" ? -3007 : E )
}