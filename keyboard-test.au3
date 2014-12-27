#include <InpOut.au3>

global $kLogFile = "debug.log"

func LogWrite($data)
	FileWrite($kLogFile, $data & chr(10))
endfunc

func Setup()
	return _IsInpOutDriverOpen()
endfunc

func PS2_Command($command, $value)
	if not _IsInpOutDriverOpen() then
		LogWrite("PS/2 Keyboard port driver is not opened")
		return
	endif
	
    ;keyboard wait.
	$kb_wait_cycle_counter = 100
	
	;wait to get communication.
	do
		$input = BitAND(_Inp32(0x64), 0x02)
		$kb_wait_cycle_counter -= 1
		Sleep(1)
		;LogWrite("Sleep #1 - input = " & $input)
	until $input = 0 or $kb_wait_cycle_counter = 0
	
	;if it didn't timeout.
    if $kb_wait_cycle_counter <> 0 then
		LogWrite("Out32 #1")
		_Out32(0x64, $command) ;send command
        $kb_wait_cycle_counter = 100
			
		;wait to get communication.
		do
			$input = BitAND(_Inp32(0x64), 0x02)
			$kb_wait_cycle_counter -= 1
            Sleep(1)
			;LogWrite("Sleep #2 - input = " & $input)
		until $input = 0 or $kb_wait_cycle_counter = 0
			
        if $kb_wait_cycle_counter = 0 then
			LogWrite("failed to get communication in cycle counter timeout, who knows what will happen now")
			return false
        endif

		LogWrite("Out32 #2")
		;send data as short
        _Out32(0x60, $value)
        Sleep(1)
		return true
    else
        LogWrite("failed to get communication in counter timeout, busy")
		return false
    endif
endfunc

func PS2_PressKey($scan_code, $release = false, $delay = 0)
	$result = false
	
	LogWrite("scan_code = " & $scan_code)

	; extra command for Up/Down/Right/Left arrow keys
	if $scan_code =	0x48 or $scan_code = 0x4B or $scan_code = 0x4D or $scan_code = 0x50 then
		$result = PS2_Command(0xD2, 0xE0);
		LogWrite("result #0 = " & $result)
	endif
	
	;0xD2 - Write keyboard output buffer
	$result = PS2_Command(0xD2, $scan_code)
	LogWrite("result #1 = " & $result)

	if $release then
		$scan_code = BitOR($scan_code, 0x80)
		$result = PS2_Command(0xD2, $scan_code)
		LogWrite("result #2 = " & $result)
	endif
	
	if $delay <> 0 then
		Sleep($delay)
	endif
	
endfunc

Sleep(2000)
;PS2_PressKey(0x1E)
;PS2_PressKey(0x3B, true)
PS2_PressKey(0x4B)
