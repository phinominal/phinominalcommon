' usb ADB bridge by spiritplumber@gmail.com
' credit to the guy at code.google.com/p/microbridge  for original implementation
' license: NAVCOM license
' buy my robot kits! www.f3.to first in android robotics!
CON
  _clkmode = xtal1 + pll16x
'  _xinfreq = 6_000_000
  _clkfreq = 96_000_000


OBJ
  term : "FullDuplexSerial"
  adb:"adb-shell-module" ' edit NUMCONNS for number of connections -- making it changeable at runtime was a pain, and not that useful
  str:"stringoutput_external_buffer"
  
PUB demo
  term.start(31,30,0,115200)
  str.init(@stringbuffer,256)
  
 ' bytemove(adb.shellbuf,string("tcp:01234"),10)

  repeat
    result := \adb.PrimaryHandshake
    if result>-1
       result := \CommandLoop
    term.dec(result)
    term.str(string(" Aborted",13,10,13,10))
    waitcnt(cnt+ constant(_clkfreq))
var
long timer     
pri CommandLoop

' huge hack.... but it works & is faster than doing it in other ways.
' propeller sets up 2 connections, one only for output and one only for inputs.
' INCONN runs logcat with PROPBRIDGE as a tag, so to send stuff to the prop, you'd go Log.e("PROPBRIDGE",messagestring) this keeps android-side overhead low
' OUTCONN outputs to a file in /data/local (alternatively, move {}s around to get a shell, but you'll still get asynchronous logcat output)
' the file gets appended to, so it's the responsibility of your Android app to
' having adb.rx somewhere in your loop lets you use strsize(adb.rxbuf) to see if something came in, but right now you only get the last line. Use stringoutput_external_buffer to cache stuff if you need/want to.
' since the android app decides what/where to both send and poll, it's effectively in charge, which is normally a good thing since the UI will be on it.
   
adb.str(string("echo \$PD,254,9999 > /data/local/PROPBRIDGE_OUT",13,10),OUTCONN) ' keep in mind: the prop user is "shell", not an app_xx. this is always true.
adb.rx
adb.str(string("chmod 666 /data/local/PROPBRIDGE_OUT",13,10),OUTCONN) ' makes it accessible
adb.rx
adb.str(string("logcat -c",13,10),INCONN) ' zap logcat to avoid being spammed by older messages. If being spammed by older messages is desirable (e.g. to not lose commands after a desync), comment this out.
adb.rx
'adb.str(string("logcat -v raw PROPBRIDGE_IN:* *:S",13,10),INCONN)  ' tag is PROPBRIDGE
adb.str(string("logcat",13,10),INCONN)  ' tag is PROPBRIDGE
adb.rx

repeat
  chin~


  ' prop->phone talk, file
  repeat
   chin := term.rxcheck 
   if (chin>-1)
      stringout[outptr++]:=chin
      if (chin==13)
           str.str(string("echo "))
           byte[@stringout+strsize(@stringout)-1]~
           str.str(@stringout)
           str.str(string(" >> /data/local/PROPBRIDGE_OUT",13,10))
           adb.str(str.buf,OUTCONN)
           str.zap(0)
           bytefill(@stringout,0,128)
           outptr~

  until chin==255

{
  ' prop->phone talk, shell
  repeat
   chin := term.rxcheck 
   if (chin>-1)
    stringout[outptr++]:=chin
    if (chin==13)
           str.str(@stringout)
           str.tx(13)
           str.tx(10)
           adb.str(str.buf,OUTCONN)
           str.zap(0)
           bytefill(@stringout,0,128)
           outptr~

  until chin==255
}

  ' phone->prop talk
   repeat
    result:=adb.rx
    if (result)   ' can this be done better?
      ' if (adb.id == INCONN) ' only display stuff coming in
        term.dec(adb.id)
        term.str(adb.rxbuf)
      adb.rxclr
   until result==0

    
con
OUTCONN=0
INCONN=1
SHELLCONN=2
var
long chin
byte stringbuffer[256]
byte stringout[128]
long outptr