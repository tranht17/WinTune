/*
  Bin2Hex() and Hex2Bin()
  Machine code functions: Bit Wizardry [ By Laszlo Hars ]
  Topic : http://www.autohotkey.com/forum/viewtopic.php?t=21172
  Post  : http://www.autohotkey.com/forum/viewtopic.php?p=180469#180469
*/

;C functions
/* 
#include <stdint.h>
void Bin2Hex(uint8_t *hex, uint8_t *bin, int32_t len) { // in hex room for 2*len+1 bytes
   int32_t i; uint8_t d;
   for (i=0; i<len; ++i) {
        d = (*bin >> 4) - 10;
        *hex++ = d + 65 - (d>>5);
        d = (*bin++ & 15) - 10;
        *hex++ = d + 65 - (d>>5);
    }
    *hex = 0;
}
#include <stdint.h>
void Hex2Bin(uint8_t *bin, uint8_t *hex) { // in bin room for ceil(strlen(hex)/2) bytes 
   uint8_t b, c, d;
   for(;;) {
      c = *hex++; if (c == 0) break;
      b = c >> 6;
      *bin = ((c & 15) + b + (b << 3)) << 4;
      d = *hex++; if (d == 0) break;
      b = d >> 6;
      *bin++ |= (d & 15) + b + (b << 3);
   }
}
*/
NumToHex(Num, NumType:="UInt", Size:=4) {
	buf:=Buffer(Size)
	NumPut(NumType, Num, buf)
	Return Bin2Hex(buf, buf.Size)
}
HexToNum(HexText, NumType:="UInt") {
	Bin:=Hex2Bin(HexText)
	Return NumGet(Bin, NumType)
}
StrToHex(Str, Encoding:="UTF-8") {
	buf := Buffer(StrPut(Str, Encoding)-1)
	StrPut(Str, buf, Encoding)
	Return Bin2Hex(buf, buf.Size)
}
HexToStr(HexText, Encoding:="UTF-8") {
	Bin:=Hex2Bin(HexText)
	Return StrGet(Bin, Encoding)
}
Bin2Hex(addr,len, rType:="CP0") {
	fun := MCode("2,x86:VTHSieVXVotNCFOLdRA58n02i0UMigQQwOgEjXg3g+gKwOgFifspw4tFDIgcUYoEEIPgD414N4PoCsDoBYn7KcOIXFEBQuvGhfa4AAAAAA9I8MYEcQBbXl9dww,x64:RTHJRTnIfjZCigQKwOgERI1QN4PoCsDoBUEpwkaIFElCigQKg+APRI1QN4PoCsDoBUEpwkaIVEkBSf/B68VFhcC4AAAAAEQPSMBNY8BCxgRBAMM")
	hex:= Buffer(2*len+1)
    DllCall(fun, "ptr", hex, "ptr", addr, "UInt", len , "CDecl")
	If !rType 
		Return hex
	Else 
		Return StrGet(hex,rType)
}
Hex2Bin(hex) {
	fun := MCode("2,x86:VTHJieVXVot9DFOLdQiKFE+E0nQwidCD4g/A6AYBwo0EwsHgBIgEDopUTwGE0nQVidOD4g/A6wYB2o0U2gnQiAQOQevJW15fXcM,x64:RTHJQooESoTAdEBBicCD4A9BwOgGRAHAQo0EwMHgBEKIBAlGikRKAUWEwHQeRYnCQYPgD0HA6gZFAdBHjQTQRAnAQogECUn/weu4ww")
	bin := Buffer(StrLen(hex)//2)
    DllCall(fun, "ptr", bin, "AStr", hex , "CDecl")
    Return bin
}
MCode(mcode) {
	static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
	if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", &m))
		return
	if (!DllCall("crypt32\CryptStringToBinaryW", "str", m[3], "uint", 0, "uint", e.%m[1]%, "ptr", 0, "uint*", &s:=0, "ptr", 0, "ptr", 0))
		return
	p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
	if (c="x64")
		DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", &op:=0)
	if (DllCall("crypt32\CryptStringToBinaryW", "str", m[3], "uint", 0, "uint", e.%m[1]%, "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
		return p
	DllCall("GlobalFree", "ptr", p)
}