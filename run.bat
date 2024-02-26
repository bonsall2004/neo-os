@echo off
setlocal enabledelayedexpansion

echo Building... 
wsl make

qemu-system-i386 -fda build/main_floppy.img