@echo off

set count=0
pushd "%~dp0

echo.
echo :: Checking for administrator elevation...
echo.
timeout /t 1 /nobreak > NUL
openfiles > NUL 2>&1
if %errorlevel%==0 (
    echo Elevation found! Proceeding...
) else (
    echo :: Please run it as Administrator
    echo. 
    echo Press anything to exit
    pause > NUL
    exit
)
timeout /t 1 /nobreak > NUL
echo.
echo :: Checking for existing folder...
echo.
timeout /t 1 /nobreak > NUL
if exist C:\winUp\ (
    echo Found C:\winUp! 
) else (
    echo Creating folder 'winUp' in C drive...
    md C:\winUp
)
timeout /t 1 /nobreak > NUL
goto menu

:menu
    CLS
    echo. 
    echo :: WINDOWS 10 UPDATE SCRIPT Version 1.0
    echo. 
    echo    1. Check installed update
    echo    2. Extract .msu to .cab
    echo    3. View Windows Update folder
    echo    4. Install update (Please turn off internet before proceeding with this option!)
    echo    5. Clean Windows Update Cache
    echo    6. Open Microsoft Website for updates
    echo    7. Reboot
    echo. 
    echo    'w' for wiki on how to update Windows manually
    echo. 
    echo    :: Please type a 'number' and press ENTER
    echo    :: If you wish to exit please type 'exit' to quit
    echo.
    
	set /P menu=
		if %menu%==1 GOTO viewme
		if %menu%==2 GOTO extractme
		if %menu%==3 GOTO viewfolder		
		if %menu%==4 GOTO updateme
        if %menu%==5 GOTO cleanme
        if %menu%==6 GOTO website
        if %menu%==7 GOTO reboot
        if %menu%==w GOTO wiki
		if %menu%==exit GOTO EOF
		
		else (
		cls
	echo.
	echo  :: Incorrect Input Entered
	echo.
	echo     Please type a 'number' or 'exit'
	echo     Press any key to return to the menu...
	echo.
		pause > NUL
		goto menu
		)

:viewme
    cls
    echo :: Installed update   
    echo. 
    wmic qfe get InstalledOn, HotFixID, InstalledBy
    echo. 
    echo    Press any key to return to the menu...
    echo. 
    pause > NUL
    goto menu

:extractme
    cls
    :: Extracting the .msu file/s* to .cab 
    if exist C:\winUp\msu-files\*.msu (
        for %%i in (C:\winUp\msu-files\*.msu) do (
            if not "%%~ni" == "exist" (
                md "C:\winUp\update-files\%%~ni" "C:\winUp\update-files\%%~ni\source"
                move "C:\winUp\msu-files\%%~nxi" "C:\winUp\update-files\%%~ni\source"
                expand -F:* "C:\winUp\update-files\%%~ni\source\%%~nxi" "C:\winUp\update-files\%%~ni" 
            )
        )
        :: This is for outputing the extracted updates
        for /F "Delims=" %%A in ('dir "C:\winUp\update-files\windows*.cab" /B/S/A-D') do (
            echo %%~nxA %%~zA Bytes
        )
    ) else (
        echo. 
        echo No msu found!
        echo. 
    )
    pause
    goto menu

:viewfolder
    cls
    echo.
    echo Opening Windows update folder... 
    echo. 
    explorer.exe C:\winUp
    echo    Press any key to return to the menu...
    echo. 
    pause > NUL
    goto menu

:updateme
    setlocal enabledelayedexpansion
    cls
    for /D %%G in ("C:\winUp\update-files\*") DO (
        set /a count=count+1
        set folderp[!count!]=%%G
    )
    set count=0
    for /F %%x in ('dir "C:\winUp\update-files\windows*.cab" /B/S/A-D') do (
        set /a count=count+1
        set size[!count!]=%%~zx
        set path[!count!]=%%~dpx
        set choice[!count!]=%%~nxx
        set folder[!count!]=%%~nx
    )

    echo.
    echo Select one:
    echo.

        :: Print list of files
    for /l %%x in (1,1,!count!) do (
        echo [%%x] !choice[%%x]!     !size[%%x]!B
    )
    echo.
    echo [b] Back to Menu 
    echo.
    :: Retrieve User input
    set /p select=Please Choose: 
        if %select%==b (
            endlocal
            GOTO menu
        )
    echo.

    :: Print out selected filename
    echo You chosen !choice[%select%]! !size[%select%]!B
    echo.
    echo Windows will now install chosen option
    echo.

    set /P option=Continue? Y/N     
        if %option%==Y (
            if not exist C:\winUp\update-files\installed (
                md C:\winUp\update-files\installed
            )

            if "!path[%select%]:~-1!"=="\" set path[%select%]=!path[%select%]:~0,-1!
            move "!path[%select%]!" C:\winUp\update-files\installed\
            for /F %%x in ('dir "C:\winUp\update-files\installed\!choice[%select%]!" /B/S/A-D') do (
                echo %%~fx
                dism /online /add-package /packagepath=%%~fx
            )
            pause
            endlocal
            goto updateme
        )
        if %option%==N (
            endlocal
            goto updateme
        )
        else (
            cls
	        echo.
	        echo  :: Incorrect Input Entered
	        echo.
	        echo     Please type a 'number' or 'exit'
	        echo     Press any key to retrn to the menu...
	        echo.
		    pause > NUL
            endlocal
            goto updateme
        )

:installme
            if not exist C:\winUp\update-files\installed (
                md C:\winUp\update-files\installed
            )
            move !folder[%select%]! C:\winUp\update-files\installed  
            pause
            endlocal
            goto updateme

:cleanme
    cls
    echo. 
    echo :: Clearing the Windows Update cache...
    echo.
    echo. 
    dism /online /Cleanup-Image /StartComponentCleanup
    goto Menu

:website
    cls
    echo. 
    echo Opening Microsoft Website...
    echo.  
    start firefox https://support.microsoft.com/en-us/topic/windows-10-update-history-e6058e7c-4116-38f1-b984-4fcacfba5e5d http://www.catalog.update.microsoft.com/Home.aspx 
    echo    Press any key to return to the menu...
    echo. 
    pause > NUL
    goto menu

:reboot
	cls
	shutdown -t 2 -r -f

:wiki
    cls
    echo. 
    echo Opening Wiki Page...
    echo.  
    start firefox https://wiki.ameliorated.info/doku.php 
    echo    Press any key to return to the menu...
    echo. 
    pause > NUL
    goto menu
