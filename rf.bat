@echo off
if exist settings.bat goto has_settings
echo @echo off>settings.bat
for %%a in (WORKON_HOME, needed_venv, prj_dir, addr_port) do echo set %%a=>>settings.bat

:has_settings
rem Make sure no previous project variable left
set WORKON_HOME=
set needed_venv=
set prj_dir=
set addr_port=
call settings.bat
rem echo %WORKON_HOME%
if "%WORKON_HOME%"=="" goto help_settings
if "%needed_venv%"=="" goto help_settings
if "%prj_dir%"=="" goto help_settings
if "%addr_port%"=="" set addr_port=localhost:8000
rem pause
if "%VENV%"=="%needed_venv%" goto initialized
cd %WORKON_HOME%\%needed_venv%\%prj_dir%
call workon %needed_venv%

:initialized
if "%bck_dir%"=="" set bck_dir=%WORKON_HOME%\%VENV%\bck_%prj_dir%
set bck_prompt=Please enter timestamp to backup db file: 
if "%1"=="" goto runserver
set test_param=
for %%a in (automigrate migrate backup test testone) do if "%1"=="%%a" goto %%a
python manage.py %*
goto end

:automigrate
python manage.py makemigrations
if not errorlevel 0 goto end

:migrate
:backup
set /p timestamp=%bck_prompt%
if not exist %bck_dir% mkdir %bck_dir%
if not exist %bck_dir% no_bck_dir
set bck_file=%bck_dir%\db.%timestamp%.sqlite3
if not exist %bck_file% goto backing_up
set bck_prompt=File %bck_file% exists, please enter other timestamp: 
goto migrate

:no_bck_dir
echo %bck_dir% does not exist! Could not backup.
goto end

:backing_up
echo Backup to %bck_file%
copy db.sqlite3 %bck_file%
if %1==backup goto end

python manage.py migrate
if not errorlevel 0 goto end
if not "%1"=="automigrate" goto end
goto runserver

:testone
set test_param=%test_param% --failfast

:test
set test_param=%test_param% --keepdb
python manage.py test %test_param% %2 %3 %4 %5 %6 %7 %8 %9
goto end

:runserver
echo Shortcuts:
echo     automigrate
echo     backup
echo     test
echo     testone
echo.
start python manage.py runserver %addr_port%
rem start http://%addr_port%/admin
goto end

:help_settings
echo Required variable is not set. Please create settings.bat with below settings.
echo.
echo @echo off
echo rem Required variables
echo set WORKON_HOME=path\to\your\virtualenv
echo set needed_venv=name_of_your_virtualenv
echo set prj_dir=folder_of_your_project
echo.
echo rem Optional variables, default value is below
echo set addr_port=localhost:8000
echo set bck_dir=%%WORKON_HOME%%\%%needed_venv%%\bck_%%prj_dir%%
echo.

:end
