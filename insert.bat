copy /Y m12fresh.gba m12.gba
xkas\xkas.exe m12.gba m2-hack.asm m12.sym.bak
pushd working
..\xkas\xkas.exe ..\m12.gba m12-includes.asm
popd
resize m12.gba 16777216
pause
