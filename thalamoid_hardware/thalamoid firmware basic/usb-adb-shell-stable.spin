' usb ADB bridge by spiritplumber@gmail.com
' buy my robot kits! www.f3.to
' license: NAVCOM license
' original implementation: Niels the MicroBridge guy, http://code.google.com/p/microbridge

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000


con
globaldebug = true ' verbosity goes here!
OBJ
  term : "Parallax Serial Terminal"

  
PUB main
  term.Start(115200)

  repeat
    term.dec(\testUART)
    term.str(string(" Aborted",13,10,13,10))
    waitcnt(cnt+clkfreq)

dat

shell byte "shell:",0  ' shell:",0 ' "shell:exec logcat",0
mbrdg byte "host::propbridge",0

PRI testUART | count, i

  term.char(term#CS)

  if showError(\Enumerate, string("Can't enumerate device"))
    abort -1         

  if showError(\Identify, string("Can't identify device"))
    abort -2
    
  if showError(\Init, string("Error initializing device"))
    abort -3
  
  term.str(string("Identified as an ADB device", term#NL))


repeat
  ' do handshaking now
  
  if (connected==0)
    'waitcnt(cnt + clkfreq)

    term.str(string("Sending string host:"))
    WriteMessage(A_CNXN,$0100_0000,4096,@mbrdg,strsize(@mbrdg)+1,true)  ' send connection
    waitcnt(cnt + (clkfreq/2))
    term.char(13)
  
    bytefill(@in_message_command,0,24)
    term.str(string("Read:"))
    term.dec(\hc.BulkRead(BulkIn,@in_message_command, 24))         ' get ack, should be also A_CNXN, returns 24

    DebugIn

    if (in_message_command <> A_CNXN)
       term.str(string("Not a connection message"))
       flip := not flip
       abort -4
    else
       connected~~
       term.str(string("Got CNXN message"))

       'waitcnt(cnt + clkfreq)

      bytefill(@stringin,0,BUFFERSIZE)
      term.dec(\hc.BulkRead(BulkIn,@stringin, in_message_data_length))         ' get payload 

      term.char(" ")
      term.str(@stringin)
      term.char(13)



  if (status == ADB_CLOSED)
    'waitcnt(cnt + clkfreq)

    term.str(string("Sending string open shell:"))
    WriteMessage(A_OPEN,0,0,@shell,strsize(@shell)+1,true)  ' send request to open shell
    term.char(13)
    status:=ADB_OPENING

    waitcnt(cnt + clkfreq)
  
    bytefill(@in_message_command,0,24)
    term.dec(\hc.BulkRead(BulkIn,@in_message_command, 24))         ' get ack, should be A_OKAY, returns 24

   if (HandleMessage(true) == false)

            abort -5

{     
   else
  
    'waitcnt(cnt + clkfreq)
    bytefill(@in_message_command,0,24)
    term.dec(\hc.BulkRead(BulkIn,@in_message_command, 24))         ' get first data chunk, should be A_WRTE, returns 24

        DebugIn

        HandleMessage
}
  if (status == ADB_OPEN)
    chin := term.RxCheck
  else
    chin := 255
    
  if (chin<255)
    if (globaldebug)
      term.str(string("Sending char:"))
      term.str(@chin)
    WriteMessage(A_WRTE,localID,RemoteID,@chin,1,globaldebug)  ' send request to open shell
    if (globaldebug)
      term.char(13)
    status := ADB_WRITING

  if (globaldebug)
  'waitcnt(cnt + clkfreq)
    term.str(string("Polling...."))
  
  bytefill(@in_message_command,0,24)
  result := \hc.BulkRead(BulkIn,@in_message_command, 24)         ' get ack, should be also A_CNXN, returns 24
  if (result < 0)
     if (result <> -160) '-160 is timeout, so that's OK
       abort -6

  HandleMessage(globaldebug)
  




pri HandleMessage(debug) | prevstatus

if (debug)
   DebugIn


if (in_message_command == A_WRTE)
      prevstatus := status
      status := ADB_RECEIVING
      if (debug)
        term.str(string("Got WRTE message of size "))
        term.dec(in_message_data_length)
        term.char(":")    
      bytefill(@stringin,0,BUFFERSIZE)
      if (debug)
        term.dec(\hc.BulkRead(BulkIn,@stringin, in_message_data_length))         ' get payload 
        term.char(":")
        term.char(13)
      else
        \hc.BulkRead(BulkIn,@stringin, in_message_data_length)

      term.str(@stringin)

      status := prevstatus

      if (debug)
         term.dec(\WriteEmptyMessage(A_OKAY, in_message_arg1, in_message_arg0,true))
      else
         \WriteEmptyMessage(A_OKAY, in_message_arg1, in_message_arg0,false)
      return true


if (in_message_command == A_CLSE)
   term.str(string("Y U CLOSE",13))
   status := ADB_CLOSED
   return true

if (in_message_command == 0)
   return false

if (in_message_command == A_OKAY)
    if (status == ADB_OPENING)
      remoteID:=in_message_arg0
      status:=ADB_OPEN
      if (debug)
        term.str(string("Got OKAY message, opened "))
        term.dec(remoteID)
        term.char(13)
      
    if (status == ADB_WRITING)
      status:=ADB_OPEN
      if (debug)
         term.str(string("Got OKAY message",13))

    return true


if (debug)
   term.str(string("Not a known message "))
   term.dec(in_message_command)
return false


pri DebugIn
    term.char(" ")
    term.dec(in_message_command)' - out_message_command)
    term.char(" ")
    term.dec(in_message_arg0)' - out_message_arg0)
    term.char(" ")
    term.dec(in_message_arg1)' - out_message_arg1)
    term.char(" ")
    term.dec(in_message_data_length)' - out_message_data_length)
    term.char(" ")
    term.dec(in_message_data_check)' - in_message_data_check)
    term.char(" ")
    term.dec(in_message_magic)' - out_message_magic)
    term.char(13)
    pad~

var
byte flip
byte chin
byte pad
byte stringin[BUFFERSIZE]



    
PRI showError(error, message) : bool
  if error < 0
    term.str(message)
    term.str(string(" (Error "))
    term.dec(error)
    term.str(string(")", term#NL))
    return 1
  return 0


OBJ
  hc : "usb-fs-host"
                   
CON
  ' Negative error codes. Most functions in this library can call
  ' "abort" with one of these codes. The range from -100 to -150 is
  ' reserved for device drivers. (See usb-fs-host.spin)

  E_SUCCESS       = 0

  ' FTDI device constants.


BUFFERSIZE = 4096 

'ADB
MAX_PAYLOAD = 4096 
A_SYNC = $434e5953  'CNYS
A_CNXN = $4e584e43  'NXNC
A_OPEN = $4e45504f  'NEPO
A_OKAY = $59414b4f  'YAKO
A_CLSE = $45534c43  'ESLC
A_WRTE = $45545257  'ETRW

ADB_CLASS = $ff
ADB_SUBCLASS = $42
ADB_PROTOCOL = $1

ADB_USB_PACKETSIZE = $40
ADB_CONNECTSTRING_LENGTH = 64
ADB_MAX_CONNECTIONS = 4
ADB_CONNECTION_RETRY_TIME = 1000


ADB_UNUSED = 0
ADB_CLOSED = 1
ADB_OPEN = 2
ADB_OPENING = 3
ADB_RECEIVING = 4
ADB_WRITING = 5

ADB_CONNECT = 6
ADB_DISCONNECT = 7
ADB_CONNECTION_OPEN = 8
ADB_CONNECTION_CLOSE = 9
ADB_CONNECTION_FAILED = 10
ADB_CONNECTION_RECEIVE = 11

DAT

bulkIn                  word    0
bulkOut                 word    0


DAT
''
''
''==============================================================================
'' Device Driver Interface
''==============================================================================

' WITH ADB
'Found device 18D1:4E12
'Raw device descriptor:
'12 01 00 02 00 00 00 40 D1 18 12 4E 27 02 01 02 03 01
'Device configuration:
'  Interface ptr=0395 number=00 alt=00 class=08 subclass=06
'    Endpoint ptr=039E address=83 maxpacket=0040
'    Endpoint ptr=03A5 address=02 maxpacket=0040
'  Interface ptr=03AC number=01 alt=00 class=FF subclass=42
'    Endpoint ptr=03B5 address=84 maxpacket=0040
'    Endpoint ptr=03BC address=03 maxpacket=0040


' WITHOUT ADB
'Device configuration:
'  Interface ptr=0395 number=00 alt=00 class=08 subclass=06
'    Endpoint ptr=039E address=83 maxpacket=0040
'    Endpoint ptr=03A5 address=02 maxpacket=0040
'Found device 18D1:4E11


ifd  long 0
epd1 long 0
epd2 long 0
PUB Enumerate
  '' Enumerate the available USB devices. This is provided for the convenience
  '' of applications that use no other USB class drivers, so they don't have to
  '' directly import the host controller object as well.

  return hc.Enumerate

pub gifd
return ifd
pub gepd1
return epd1
pub gepd2
return epd2
PUB Identify

  '' The caller must have already successfully enumerated a USB device.
  '' This function tests whether the device looks like it's compatible
  '' with this driver.

  '' This function is meant to be non-invasive: it doesn't do any setup,
  '' nor does it try to communicate with the device. If your application
  '' needs to be compatible with several USB device classes, you can call
  '' Identify on multiple drivers before committing to using any one of them.
  ''
  '' Returns 1 if the device is supported, 0 if not. Does not abort.

  '' first: it must have 2 interfaces, no more and no less
  '' second: check (and save) the interface number,class and subclass

  ifd~
  epd1~
  epd2~
  connected~
  status:=ADB_CLOSED
  
  if (hc.FirstInterface <> 0 and hc.nextInterface(hc.FirstInterface) <> 0 and hc.nextInterface(hc.nextInterface(hc.FirstInterface)) == 0)
     ifd := hc.nextInterface(hc.FirstInterface)
     epd1 := hc.NextEndpoint(ifd)
     epd2 := hc.NextEndpoint(epd1)
     if (ifd>0 and epd1>0 and epd2>0 and BYTE[ifd + hc#IFDESC_bInterfaceNumber] == ADB_PROTOCOL and BYTE[ifd + hc#IFDESC_bInterfaceClass] == ADB_CLASS and BYTE[ifd + hc#IFDESC_bInterfaceSubclass] == ADB_SUBCLASS)
        identified := 1
        return 1
        
  identified~
  return 0

PUB Init | one, two

  '' (Re)initialize this driver. This must be called after Enumerate
  '' and Identify are both run successfully. All three functions must be
  '' called again if the device disconnects and reconnects, or if it is
  '' power-cycled.
  ''
  '' This function sets the device's USB configuration, collects
  '' information about the device's descriptors, and sets default
  '' UART settings.

  one := hc.NextEndpoint(ifd)
  two := hc.NextEndpoint(one)
  if (BYTE[two + hc#EPDESC_bEndpointAddress] & $80 == $00)
     bulkIn := one
     bulkOut :=  two
  elseif (BYTE[two + hc#EPDESC_bEndpointAddress] & $80 == $80)
     bulkIn := two
     bulkOut := one
  else
     abort (BYTE[two + hc#EPDESC_bEndpointAddress])*-1
'  bulkOut := hc.NextEndpoint(hc.nextInterface(hc.FirstInterface))
'  bulkIn :=  hc.NextEndpoint(bulkOut)

  hc.Configure
  return 1


  '' (Re)initialize this driver. This must be called after Enumerate
  '' and Identify are both run successfully. All three functions must be
  '' called again if the device disconnects and reconnects, or if it is
  '' power-cycled.
  ''
  '' This function sets the device's USB configuration, collects
  '' information about the device's descriptors, and sets default
  '' UART settings.

  '' may be swapped

  
  bulkOut := hc.NextEndpoint(hc.nextInterface(hc.FirstInterface))
  bulkIn :=  hc.NextEndpoint(bulkOut)
  if (flip)
    bulkIn := hc.NextEndpoint(hc.nextInterface(hc.FirstInterface))
    bulkOut :=  hc.NextEndpoint(bulkIn)
  else
    bulkOut := hc.NextEndpoint(hc.nextInterface(hc.FirstInterface))
    bulkIn :=  hc.NextEndpoint(bulkOut)
    
  hc.Configure

  
DAT
''
''==============================================================================
'' Low-level adb interface
''============================================================================
'' connection
identified long 0 ' only one
connected long 0  ' only one

status long 0 ' can be more than one
localID long 1 ' preset' can be more than one
remoteID long 0' can be more than one

'' message out
out_message_command long 0
out_message_arg0 long 0
out_message_arg1 long 0
out_message_data_length long 0
out_message_data_check long 0
out_message_magic long 0           

'' message in
in_message_command long 0
in_message_arg0 long 0
in_message_arg1 long 0
in_message_data_length long 0
in_message_data_check long 0
in_message_magic long 0           
           {
pub FlipEndianness(DoAddr) | b0,b1,b2,b3
    b0:=byte[DoAddr+0]
    b1:=byte[DoAddr+1]
    b2:=byte[DoAddr+2]
    b3:=byte[DoAddr+3]

    byte[DoAddr+0]:=b3
    byte[DoAddr+1]:=b2
    byte[DoAddr+2]:=b1
    byte[DoAddr+3]:=b0
            }
pub WriteEmptyMessage(cmd, arg0, arg1,debug)

     out_message_command := cmd
     out_message_arg0 := arg0
     out_message_arg1 := arg1
     out_message_data_length~
     out_message_data_check~
     out_message_magic := cmd ^ $FFFF_FFFF

     if (debug)
       term.char(" ")
       term.dec(\hc.BulkWrite(BulkOut,@out_message_command, 6*4)) 
       term.char(" ")
     else
       \hc.BulkWrite(BulkOut,@out_message_command, 6*4)
pub WriteMessage(cmd, arg0, arg1, MsgAddr, MsgSize,debug)
                          
     out_message_command := cmd
     out_message_arg0 := arg0
     out_message_arg1 := arg1
     out_message_data_length := MsgSize   
     out_message_data_check~
     repeat MsgSize
        out_message_data_check := out_message_data_check + byte[MsgAddr++]
     MsgAddr -= MsgSize
     out_message_magic := cmd ^ $FFFF_FFFF
     if (debug)
       term.char(" ")
       term.dec(\hc.BulkWrite(BulkOut,@out_message_command, 6*4))
       term.char(" ")
       term.dec(\hc.BulkWrite(BulkOut,MsgAddr, MsgSize))
       term.char(" ")
     else
       \hc.BulkWrite(BulkOut,@out_message_command, 6*4)
       \hc.BulkWrite(BulkOut,MsgAddr, MsgSize)
     