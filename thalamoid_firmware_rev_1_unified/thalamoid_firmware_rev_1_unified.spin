' Note that this file will make assumptions about the hardware -- specifically that it's a thalamoid board and that it can switch stuff on and off.



CON
  _clkmode = xtal1 + pll16x
'  _xinfreq = 6_000_000
  _clkfreq = 96_000_000


OBJ
  terminal : "FullDuplexSerial"
  adb:"adb-shell-module"
  outbuf:"stringoutput_external_buffer"
  inbuf:"stringoutput_external_buffer"
  adc:"AD7706-2wire.spin"
  p: "pinout_minithalamoid"
  ping: "Ping"
  
PUB demo

  p.off(p#PWR_PHONE)
  'p.on(p#PWR_ADC)

  adc.select(||P#PWR_ADC)
  adc.InitADC(p#ADC_CLOCK,p#ADC_DATA,p#ADC_DATA, p#ADC_READY)
  adc.ConfigureChannel1(adc#ADCCLOCK_FAST,%01_000_1_0_0) 
  adc.ConfigureChannel2(adc#ADCCLOCK_FAST,%01_000_1_0_0) 
  adc.ConfigureChannel3(adc#ADCCLOCK_FAST,%01_000_1_0_0)

  'adc.deselect(||P#PWR_ADC) 
  p.on(p#PWR_DEVICE1)
  p.on(p#PWR_DEVICE2)
  terminal.start(31,30,0,115200)
  outbuf.init(@outbufmem,256)
  inbuf.init(@inbufmem,128)
  errtimes~

repeat 5

  'adc.deselect(selectpin)
  terminal.str(string("Test circuit for the ADC thingie  "))
  adc.select(||P#PWR_ADC)

  terminal.dec(adc.GetChannel1)
  terminal.tx(" ")
  
  terminal.dec(adc.GetChannel2)
  terminal.tx(" ")

  terminal.dec(adc.GetChannel3)
  terminal.tx(13)
  terminal.tx(10)




repeat
    terminal.str(string(" Sync",13,10))
    p.on(p#PWR_PHONE)
    result := \adb.PrimaryHandshake
    
    if result>-1
       result := \CommandLoop
    else
       lasterror:=result   

    if (result<>-999)
      terminal.dec(result)
      terminal.str(string(" Aborted "))
      terminal.dec(errtimes)
      terminal.tx(13)
      if (lasterror==result)
         if(lasterror == -3) ' -3 is usb enumeration and is fixed by going back and changing IFD's, so it's a special case: allow many errors to happen
            errtimes++
         else
            errtimes+=50
      else
         errtimes~
         lasterror:=result
      
      if errtimes>500'result == -135 or result == -4)
        terminal.str(string("Errors>threshold, rebooting module",13,10))
        p.off(p#PWR_PHONE)
        waitcnt(cnt+ constant(_clkfreq))      
        reboot
      p.on(p#PWR_PHONE)


con
CONNECTION_SHELL = 0
CONNECTION_LCAT = 1
CONNECTION_ADC = 2
CONNECTION_L = 3

var
long logcycle
var
byte lastcommand[129]
byte nextcommand[129]
var
long lasterror
long errtimes
var
long sensorvalues[26]
pri CommandLoop 

derpdebug
' connections:
' 3 is output to file
' 2 is ADC output to file
' 1 is input from logcat
' 0 is shell
CommandsExpected:=-10
logcycle:=log_period
logcycles~
globalecho~
'cmd (string("logcat -c",13,10),CONNECTION_LCAT)
cmd (string("logcat -c;logcat -v raw PB_IN:* *:S",13,10),CONNECTION_LCAT)
derpdebug
cmd (string("cd /data/local;chmod 666 ./PB_O_C",13,10),CONNECTION_L)
'derpdebug
'cmd (string("chmod 666 ./PB_O_C*",13,10),CONNECTION_L)
derpdebug
cmd (string("cd /data/local;chmod 666 ./PB_ADC_C",13,10),CONNECTION_ADC)
derpdebug
'cmd (string("chmod 666 ./PB_ADC_C",13,10),CONNECTION_ADC)
'derpdebug
cmd (string("cd /data/local",13,10),CONNECTION_SHELL)
derpdebug
globalecho~~

repeat

   adc.select(||P#PWR_ADC)
   sensorvalues[0]:=adc.GetChannel1
   sensorvalues[1]:=adc.GetChannel2
   sensorvalues[2]:=adc.GetChannel3
   'adc.deselect(||P#PWR_ADC)

  derpdebug
  ExecuteCommandIfThere
  listen

  --logcycle
 if (logcycle==1)

      if (CommandQueued)
        cmd(@lastcommand,CONNECTION_SHELL)  ' missed a command? try again.
        CommandQueued~

 elseif (logcycle==0) ' asynchronous stuff here (in this case, dump to ADC)

      outbuf.zap(0)
      outbuf.str(string("DATE=$(toolbox date ",quote,"+%s,%Y %m %d %H %M %S",quote,");cat ./PB_ADC_C >> /sdcard/PB_ADC_L;echo ",quote))
      outbuf.tx("S")         
      outbuf.tx(",")         
      outbuf.dec(sensorvalues[0])
      outbuf.tx(",")         
      outbuf.dec(sensorvalues[1])
      outbuf.tx(",")
      outbuf.dec(sensorvalues[2])
      outbuf.tx(",")
      outbuf.tx("T")
      outbuf.tx(",")
      outbuf.str(string(" $DATE",quote," > ./PB_ADC_C",13))
      cmd(@outbufmem,CONNECTION_ADC)
      logcycle:=log_period
      logcycles++
      
    if false'(logcycles & $04) == 0
      outbuf.str(string("am start http://f3.to/g/?g="))
      outbuf.dec(5000)
      outbuf.tx(",")         
      outbuf.dec(sensorvalues[0])
      outbuf.tx(",")         
      outbuf.dec(sensorvalues[1])
      outbuf.tx(",")
      outbuf.dec(5000)
      outbuf.tx(13)
      cmd(@outbufmem,CONNECTION_ADC)

 else

   chin~    
  repeat
    chin := terminal.rxcheck
   if (chin>-1)
    inbuf.tx(chin)
    if (chin==13 or inbuf.remaining < 80)
    
     if (byte[@inbufmem]=="@")
       bytemove(@nextcommand,@inbufmem+1,128)
       inbuf.zap(0)
     elseif (byte[@inbufmem]==">") 
      if (byte[@inbufmem+1]=="<") 
        p.off(p#PWR_PHONE)
        reboot
        
      byte[@inbufmem+1+strsize(@inbufmem+1)-1]~ 
      outbuf.zap(0)
      outbuf.str(string("cat ./PB_O_C >> /sdcard/PB_O_L;echo "))
      'outbuf.str(string("echo "))
      outbuf.str(@inbufmem+1)
      outbuf.str(string(" > ./PB_O_C",13,10))
      cmd(@outbufmem,CONNECTION_L)
      inbuf.zap(0)
      'cmd(string("cat ./PB_O_C >> /sdcard/PB_O_L",13),CONNECTION_L)

     else

      bytemove(@lastcommand,@inbufmem,128)
      CommandQueued~~
      cmd(@lastcommand,CONNECTION_SHELL)
      inbuf.zap(0)

  until chin==-1

con
log_period = 5
quote = 34


pri ExecuteCommandIfThere
    if strsize(@nextcommand)
        repeat 3
          terminal.tx(":")
        terminal.tx("@")
        terminal.str(@nextcommand)
        terminal.tx(13)
        bytefill(@nextcommand,0,128)
pri cmd(what, who)
listen
result:=adb.str(what,who)
listen   
CommandsExpected++

if (globalecho and CommandsExpected < -2)
    CommandsExpected:=-2
if (CommandsExpected > 0)
    CommandsExpected~
    terminal.tx("[")
    terminal.dec(logcycles)
    terminal.tx("]")
    if (logcycles>1 and logcycles <5) ' stuck in desync: stop it before it gets serious
       p.off(P#PWR_PHONE)
       waitcnt(cnt+clkfreq*3)
       reboot

    abort -999


pri listendebug
 
    return
    terminal.tx(",")
    terminal.tx(",")
    terminal.tx(",")
    terminal.dec(adb.debug_message_command)
    terminal.tx(",")
    terminal.dec(adb.debug_message_arg0)
    terminal.tx(",")
    terminal.dec(adb.debug_message_arg1)
    terminal.tx("=")
    terminal.tx(">")
    terminal.dec(adb.debug_activeconn)
    terminal.tx(",")
    terminal.dec(adb.debug_stat(adb.debug_activeconn))
    terminal.tx(13)
pri derpdebug : a
  return
   
  terminal.dec(logcycle)
  a~
  terminal.tx(" ")
  repeat adb#NUMCONNS
    terminal.dec(a)
    terminal.tx(",")
    terminal.dec(adb.debug_loc(a))
    terminal.tx(",")
    terminal.dec(adb.debug_rem(a))
    terminal.tx(",")
    terminal.dec(adb.debug_stat(a))
    terminal.tx(" ")
    a++
  terminal.tx(13)
  

  


pri listen
  result~~
  repeat 

   result := adb.rx
   if (adb.debug_message_command)
     CommandsExpected-=2
   listendebug

   if (result) ' can this be done better?
     CommandsExpected-=2
     if (adb.id == CONNECTION_SHELL)
        CommandQueued~
     if (adb.id == CONNECTION_LCAT)
        bytemove(@nextcommand,adb.rxbuf,128)
        
     if (EchoConnection(adb.id))
       if (strsize(adb.rxbuf)>1)
         terminal.tx("{")
         terminal.dec(adb.id)
         terminal.tx("|")
         terminal.dec(strsize(adb.rxbuf))
         terminal.tx("}")
         terminal.tx(13)
         terminal.str(adb.rxbuf)
     adb.rxclr
  until result==0

pri EchoConnection(which)
    if (globalecho==0 or which==CONNECTION_ADC or which==CONNECTION_L)
         return false
    return true
var
long logcycles
long chin
byte globalecho
byte inbufmem[128]
byte outbufmem[256]
long CommandsExpected
byte CommandQueued     