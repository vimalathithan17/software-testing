@echo off
setlocal
REM batch to start fullstack_sqlite app and run JMeter plan (Windows CMD)
set JMETER_BIN=jmeter.bat

REM start app in background
start /B cmd /C "pipenv run python fullstack_sqlite\app.py > fullstack_sqlite_app.log 2>&1"

REM wait for app
timeout /t 3 /nobreak >nul

%JMETER_BIN% -n -t "%CD%\fullstack_sqlite\fullstack_sqlite_test_plan.jmx" -l "%CD%\fullstack_sqlite\fullstack_sqlite_non_gui_result.jtl" -j "%CD%\fullstack_sqlite\fullstack_sqlite_jmeter.log" -Jthreads=1 -Jramp=1 -Jloops=1

echo Done. Report: %CD%\fullstack_sqlite\fullstack_sqlite_report\index.html
endlocal
