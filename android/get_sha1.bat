@echo off
echo Getting Signing Report...
call gradlew.bat signingReport
echo.
echo ========================================================
echo COMPARE WITH google-services.json SHA-1:
echo d252c1e4e0e85051aed6b99d3148a6255d359e24
echo ========================================================
pause
