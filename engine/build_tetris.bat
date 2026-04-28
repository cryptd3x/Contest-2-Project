@echo off
setlocal enabledelayedexpansion

echo =============================================
echo    Tetris Assembly Project - Build Script (VS 2019 x86)
echo =============================================

REM =============================================
REM ml.exe and link.exe are already in PATH in x86 Native Tools Prompt
REM =============================================

set EXE=Tetris.exe

echo [1/4] Assembling all .asm files...

set ASM_FILES=main.asm scene.asm game_object.asm tetromino.asm tetris_board.asm tetris_manager.asm renderer.asm unordered_vector.asm component.asm rect_component.asm renderable_component.asm transform_component.asm camera.asm heap_functions.asm input_manager.asm

REM Loop through each file and stop immediately if any fail to assemble
for %%f in (%ASM_FILES%) do (
    ml.exe /c /coff /Zi /Fl "%%f"
    if errorlevel 1 (
        echo.
        echo ERROR: Assembly failed on %%f!
        pause
        exit /b 1
    )
)

echo [2/4] Linking...

REM Store objects in a variable to avoid fragile multi-line carets (^)
set OBJ_FILES=main.obj scene.obj game_object.obj tetromino.obj tetris_board.obj tetris_manager.obj renderer.obj unordered_vector.obj component.obj rect_component.obj renderable_component.obj transform_component.obj camera.obj heap_functions.obj input_manager.obj

link.exe /SUBSYSTEM:WINDOWS /ENTRY:main@0 /DEBUG /OUT:%EXE% %OBJ_FILES% kernel32.lib user32.lib gdi32.lib

if errorlevel 1 (
    echo.
    echo ERROR: Linking failed!
    pause
    exit /b 1
)

echo [3/4] Cleaning up temporary files...
del *.obj *.lst *.ilk 2>nul

echo.
echo =============================================
echo    Build Successful!
echo    Executable: %EXE%
echo =============================================

echo Running %EXE%...
start "" "%EXE%"

pause