; https://autohotkey.com/board/topic/46750-hibernate-w-wakeup/

; 일정시간 절전모드 만드는 함수

; Examples:
; Hibernate( 20100101 ) ; until a future Timestamp ( New Year )
; Hibernate( A_Now, 600, "Seconds" )
; Hibernate( A_Now, 30, "Minutes" )
; Hibernate( A_Now, 2, "Hours" ) or Hibernate( Null, 2 )
; Hibernate( A_Now, 7, "Days" )


Hibernate(T="", O=0,  U="H" ){ ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=50733
   T += %O%,%U%                
   EnvSub, T, 16010101, S
   VarSetCapacity(FT,8), DllCall( "LocalFileTimeToFileTime", Int64P,T:=T*10000000,UInt,&FT )
   If hTmr := DllCall( "CreateWaitableTimer", UInt,0, UInt,0, UInt,0 ) ;예약타이머 생성
   If DllCall( "SetWaitableTimer", UInt,hTmr, UInt,&FT, UInt,1000, Int,0, Int,0, UInt,1 ) ;예약타이머 세팅
   If DllCall( "PowrProf\SetSuspendState", UInt, 0, UInt,0, UInt,0 )  ;절전모드
   {
      ;DllCall( "WaitForSingleObject", UInt,hTmr,Int,-1 ) ;대기시간동안 오토핫키 멈추게 하는 명령어
      DllCall( "CloseHandle",UInt,hTmr )  ;핸들 클로즈함과 동시에 예약도 사라짐
   }
   Return A_LastError
}

;DllCall( "PowrProf\SetSuspendState", UInt,1, UInt,0, UInt,0 ) ;최대절전모드

