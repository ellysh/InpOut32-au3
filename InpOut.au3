#include-once

Func _Out32($PortAddress, $data)
	DllCall("inpout32.dll", "void", "Out32", "short", $PortAddress, "short", $data)
EndFunc

Func _Inp32($PortAddress)
	return DllCall("inpout32.dll", "short", "Inp32", "short", $PortAddress)
EndFunc

Func _IsInpOutDriverOpen()
	return DllCall("inpout32.dll", "bool", "IsInpOutDriverOpen")
EndFunc
