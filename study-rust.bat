@echo off
REM ====================================================
REM 1. Check if cargo (and hence Rust) is installed
REM ====================================================
where cargo >nul 2>&1
if errorlevel 1 (
    echo Cargo is not installed. Installing Rust via rustup...
    REM Download rustup-init.exe if it does not exist
    if not exist rustup-init.exe (
        echo Downloading rustup-init.exe...
        powershell -Command "Invoke-WebRequest -Uri https://win.rustup.rs -OutFile rustup-init.exe"
    )
    REM Install Rust silently (default settings)
    rustup-init.exe -y
    echo Please restart your command prompt after installation.
    exit /b
) else (
    echo Cargo is already installed.
)

REM ====================================================
REM 2. Check if mdbook is installed; install via cargo if missing
REM ====================================================
where mdbook >nul 2>&1
if errorlevel 1 (
    echo mdbook not found. Installing mdbook using cargo...
    cargo install mdbook
) else (
    echo mdbook is already installed.
)

REM ====================================================
REM 3. Clone the repositories if they don't exist
REM (Requires git to be installed)
REM ----------------------------------------------------
if not exist "rust-by-practice" (
    echo Cloning the rust-by-practice repository...
    git clone https://github.com/sunface/rust-by-practice.git
) else (
    echo Repository rust-by-practice already exists.
)

if not exist "rust-by-example" (
    echo Cloning the rust-by-example repository...
    git clone https://github.com/sunface/rust-by-example.git
) else (
    echo Repository rust-by-example already exists.
)

REM ====================================================
REM 4. Ask user what they want to study
REM ====================================================
echo.
echo What do you want to study?
echo [E]xample or [P]ractice?
choice /C EP /M "Enter your choice:"

REM If the user pressed P (choice errorlevel 2), then go to PRACTICE
if errorlevel 2 goto PRACTICE
REM Otherwise, if E (errorlevel 1), then go to EXAMPLE
if errorlevel 1 goto EXAMPLE

:PRACTICE
echo.
echo Starting mdbook for rust-by-practice...

REM ====================================================
REM 5. Ask user for host type
REM ====================================================
echo.
echo Choose where to bind the mdbook server:
echo [L]ocalhost (127.0.0.1) - Only accessible from this computer
echo [A]ll Interfaces (0.0.0.0) - Accessible from other devices on the network
choice /C LA /M "Enter your choice:"

set HOST=127.0.0.1
if errorlevel 2 set HOST=0.0.0.0

cd /d "%~dp0\rust-by-practice"
start cmd /c "mdbook serve en --hostname %HOST%"
timeout /t 3 >nul
start http://127.0.0.1:3000
goto END

:EXAMPLE
echo.
echo Building and serving rust-by-example...

REM Ask for the host type again
echo.
echo Choose where to bind the mdbook server:
echo [L]ocalhost (127.0.0.1) - Only accessible from this computer
echo [A]ll Interfaces (0.0.0.0) - Accessible from other devices on the network
choice /C LA /M "Enter your choice:"

set HOST=127.0.0.1
if errorlevel 2 set HOST=0.0.0.0

cd /d "%~dp0\rust-by-example"
mdbook build
start cmd /c "mdbook serve --hostname %HOST%"
timeout /t 3 >nul
start http://127.0.0.1:3000
goto END

:END
pause

