REM @C:\PROGRA~2\LETASSIG\LETASSIG.EXE @LETTERS.INI /O:DRIVEMAP.DAT /CD

rem PATH used for have possiblity to run executable inside them from every other directory

SET PATH=C:\WINDOWS;C:\m602;C:\DRIVERS;C:\PROGRA~2\Access~1\;C:WINDOWS\COMMAND;C:\PROGRA~2\BORLAND\CBUILD~1\BIN;C:\PROGRA~2\BORLAND\CBUILD~1\PROJECTS\BPL;C:\PROGRA~2\Access~1;

REM Rloew AHCIBIOS Patch
REM C:\WINDOWS\AHCIBIOS.COM

REM Load contents of config.sys file
GOTO %CONFIG%

REM In next part For Indiviaul Config ":branches" is there added specific code

:win
rem Start the of Windows 98
AHCIBIOS
win.com

rem JUMP to END marker
GOTO END


:dosXMS
AHCIBIOS
C:\WINDOWS\COMMAND\MSCDEX /D:OPTICAL
rem LH IN Front of driver means that drive will move to upper memory
LH C:\Drivers\ctmouse.exe
REM MSDCDEX is driver for CD/DVD drive

rem Soundcard older definition
REM SET MIDI=SYNTH:1 MAP:E MODE:0
REM SET BLASTER=A220 I5 D1 H5 P330 T6
REM SET CTSYN=C:\drivers\dosdrv
REM C:\DRIVERS\DOSDRV\SBEINIT.COM

REM Soundcard newer
SET BLASTER=A220 I5 D1 H5 P330
SET CTSYN=C:\DRIVERS\DOSDRV
C:\DRIVERS\DOSDRV\SBEINIT.COM

LH C:\Windows\SMARTDRV.EXE /L /X
PAUSE

c:\m602\m602.exe

GOTO END

:DOsproctedMod
AHCIBIOS
LH C:\windows\system\MSCDEX /D:mscd001
LH C:\Drivers\ctmouse.exe
LH C:\Windows\SMARTDRV.EXE /L /X
LH c:\m602\m602.exe
GOTO END

:DOSems
AHCIBIOS
LH C:\WINDOWS\COMMAND\MSCDEX.EXE /D:CDROM /L:E 
LH C:\Drivers\ctmouse.exe

rem Soundcard
SET MIDI=SYNTH:1 MAP:E MODE:0
SET BLASTER=A220 I5 D1 H5 P330 T6
SET CTSYN=C:\drivers\dosdrv
LH C:\DRIVERS\DOSDRV\SBEINIT.COM
LH C:\Windows\SMARTDRV.EXE /L /X

REM m602 is filemanager
LH c:\m602\m602.exe

GOTO END

REM by RuThaN all safe mode
:Win98SafeMode

mode con codepage prepare=((852) C:\WINDOWS\COMMAND\ega.cpi)
mode con codepage select=852
keyb cz,,C:\WINDOWS\COMMAND\keybrd2.sys
REM run Windows 98 in safe mode
C:\windows\win.com /D:N

GOTO END

:END


