#include <InpOut.au3>

global $kLogFile = "debug.log"

func LogWrite($data)
	FileWrite($kLogFile, $data & chr(10))
endfunc

func Setup()
	return _IsInpOutDriverOpen();
endfunc

func PS2_Command($command, $value)
	if not _IsInpOutDriverOpen() then
		LogWrite("PS/2 Keyboard port driver is not opened")
		return;
	endif
	
    ;keyboard wait.
	$kb_wait_cycle_counter = 1000;
	
	;wait to get communication.
	do 
		$input = BitAND(_Inp32(0x64), 0x02)
		$kb_wait_cycle_counter -= 1
		Sleep(1)
		
		;if it didn't timeout.
        if $kb_wait_cycle_counter <> 0 then
            _Out32(0x64, $command) ;send command
            $kb_wait_cycle_counter = 1000;
			
			;wait to get communication.
			do
				$input = BitAND(_Inp32(0x64), 0x02)
				$kb_wait_cycle_counter -= 1
                Sleep(1)
			until $input <> 0 && $kb_wait_cycle_counter <> 0
			
            if kb_wait_cycle_counter == 0 then
                LogWrite("failed to get communication in cycle counter timeout, who knows what will happen now");
				return false
            endif
			
			;send data as short
            _Out32(0x60, $value)
            Sleep(1)
			return true
        else
            LogWrite("failed to get communication in counter timeout, busy")
			return false
        endif
	until $input <> 0 && $kb_wait_cycle_counter <> 0
endfunc

func PS2_PressKey($button, $release = false, $delay = 0)
	$scan_code = $button
	$result = false
	
	if $release then
		$scan_code = BitOR($scan_code, 0x80)
	endif

	if $delay <> 0 then
		Sleep($delay)
	endif
	
	;0xD2 - Write keyboard output buffer
	$result = PS2_Command(0xD2, $scan_code)
	LogWrite("result = " & $result)
endfunc

PS2_PressKey(0x1E, true)