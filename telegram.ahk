SendLine(msg, imageName = 0)
{	
    msg := UriEncode(msg)

    RunWait, curl -k -H "Authorization: Bearer %notifyToken%" -d "message=%msg%" https://notify-api.line.me/api/notify,, Hide	
    if(imageName)
        RunWait, curl -k -X POST -H "Authorization: Bearer %notifyToken%" -F "message=%imageName%" -F "imageFile=@%imageName%" https://notify-api.line.me/api/notify,, Hide
    ;objExec := objShell.Exec("curl -k -X POST -H ""Authorization: Bearer " notifyToken """ -F ""message=" msg """ https://notify-api.line.me/api/notify")
    addlog("LINE Notify 메시지 전송")
}

;#include Token.ahk
SendLine2(msg, imageName = 0)
{
     winHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")	
    winHttp.Open("POST", "https://notify-api.line.me/api/notify")
    winHttp.SetRequestHeader("Authorization","Bearer " notifyToken)	
      
    if(imageName)
    {
        objParam := { "message": msg, "imageFile": [imageName]  }		
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

SendTelegram(msg) ;;curl을 쓰면 지연이 안걸린다
{    
    msg := UriEncode(msg)

    RunWait, curl -k -d "chat_id=%chatID%&text=%msg%" https://api.telegram.org/bot%botToken%/sendMessage,, Hide        
    ;command = curl -k -d "chat_id=%chatID%&text=%msg%" https://api.telegram.org/bot%botToken%/sendMessage
    
    ;objExec := objShell.Exec(command)
    ;objExec := objShell.Exec("curl -k -d ""chat_id=" chatID "&text=" msg """ https://api.telegram.org/bot" botToken "/sendMessage" ) ;attach한 cmd 사용
    ;addlog("Telegram Bot 메시지 전송")   
}

SendTelegramImg(imageName)
{
     RunWait, curl -k -F "chat_id=%chatID%" -F "photo=@%imageName%" https://api.telegram.org/bot%botToken%/sendPhoto,, Hide
}


SendTelegram2(msg)
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

SendTelegramImg2(imageName) ;;
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
    getUpdates:= ReadURL(url)	

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

getTelegramMsgCurl()
{
    ; WshShell 객체: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec("curl -k https://api.telegram.org/bot" botToken "/getUpdates")
    getUpdates := exec.StdOut.ReadAll()

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
/*
;URLDownloadToVar , ReadURL 같은 기능으로 추정 //내부 기능이므로 지연이 걸릴수도?
URLDownloadToVar(url) 
{
    hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
    hObject.Open("GET",url)
    hObject.Send()
    return hObject.ResponseText
}

ReadURL(URL, encoding = "utf-8") ;;외부 dll이라 지연 안걸릴수도?
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
*/