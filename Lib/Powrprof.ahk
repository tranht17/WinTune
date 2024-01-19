; https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/configure-power-settings

GetSleepIdleTimeout() {
	SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
	PowerSettingGUID:=GUID("{29f6c1db-86da-48c5-9fdb-f2b67b1f44da}")
	return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}

SetSleepIdleTimeout(Num) {
	SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
	PowerSettingGUID:=GUID("{29f6c1db-86da-48c5-9fdb-f2b67b1f44da}")
	PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}

GetHibernateIdleTimeout() {
	SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
	PowerSettingGUID:=GUID("{9d7815a6-7ee4-497e-8888-515a05f02364}")
	return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}

SetHibernateIdleTimeout(Num) {
	SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
	PowerSettingGUID:=GUID("{9d7815a6-7ee4-497e-8888-515a05f02364}")
	PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}

GetHybridSleepIdleTimeout() {
	SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
	PowerSettingGUID:=GUID("{94ac6d29-73ce-41a6-809f-6363ba21b47e}")
	return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}

SetHybridSleepIdleTimeout(Num) {
	SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
	PowerSettingGUID:=GUID("{94ac6d29-73ce-41a6-809f-6363ba21b47e}")
	PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}

GetDisplayBrightnessLevel() {
	SubGroupGUID:=GUID("{7516b95f-f776-4464-8c53-06167f40cc99}")
	PowerSettingGUID:=GUID("{aded5e82-b909-4619-9949-f5d71dac0bcb}")
	return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}

GetDisplayIdleTimeout() {
	SubGroupGUID:=GUID("{7516b95f-f776-4464-8c53-06167f40cc99}")
	PowerSettingGUID:=GUID("{3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e}")
	return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}

SetDisplayIdleTimeout(Num) {
	SubGroupGUID:=GUID("{7516b95f-f776-4464-8c53-06167f40cc99}")
	PowerSettingGUID:=GUID("{3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e}")
	PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}

PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num) {
	DllCall("powrprof\PowerGetActiveScheme", "Ptr",0, "Ptr*",&currSchemeGuid:=0, "UInt")
	If IsOnAc()
		DllCall("powrprof\PowerWriteACValueIndex", "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", SubGroupGUID, "Ptr", PowerSettingGUID, "UInt", Num, "UInt")
	Else
		DllCall("powrprof\PowerWriteDCValueIndex", "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", SubGroupGUID, "Ptr", PowerSettingGUID, "UInt", Num, "UInt")
	DllCall("powrprof\PowerSetActiveScheme", "Ptr",0, "Ptr",currSchemeGuid)
	DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
}

PowerReadValueIndex(SubGroupGUID, PowerSettingGUID) {
	DllCall("powrprof\PowerGetActiveScheme", "Ptr",0, "Ptr*",&currSchemeGuid:=0, "UInt")
	If IsOnAc()
		DllCall("powrprof\PowerReadACValueIndex", "Ptr",0, "Ptr",currSchemeGuid, "Ptr",SubGroupGUID, "Ptr",PowerSettingGUID, "UIntP",&r:=0, "UInt")
	Else
		DllCall("powrprof\PowerReadDCValueIndex", "Ptr",0, "Ptr",currSchemeGuid, "Ptr",SubGroupGUID, "Ptr",PowerSettingGUID, "UIntP",&r:=0, "UInt")
	DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
	Return r
}

IsOnAc() {
	SystemPowerStatus := Buffer(12)
	If DllCall("GetSystemPowerStatus", "Ptr", SystemPowerStatus)
		If acStatus := NumGet(SystemPowerStatus, 0, "UChar") == 1
			return True
	return False
}

GUID(sGUID) ; Converts a string to a binary GUID and returns it in a Buffer.
{
    rGUID := Buffer(16, 0)
    if DllCall("ole32\CLSIDFromString", "WStr", sGUID, "Ptr", rGUID) < 0
        throw ValueError("Invalid parameter #1", -1, sGUID)
    return rGUID
}

StringFromCLSID(rclsid)  ; Converts a binary GUID to a string.
{
    DllCall("ole32\StringFromCLSID", "Ptr", rclsid, "Ptr*", &lplpsz:=0)
    s := StrGet(lplpsz, "UTF-16")
    DllCall("ole32\CoTaskMemFree", "Ptr", lplpsz)
    return s
}