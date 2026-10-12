@echo off
rem Converts every .tga screenshot in this folder to .png (needs ImageMagick 7), then deletes the .tga files.
cd /d "%~dp0"
magick mogrify -format png *.tga && del *.tga
