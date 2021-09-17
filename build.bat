@echo off
REM    This is the Windows build script for the Maya Dem-Bones python bindings.
REM    usage: build.bat [2018|2019|2020|2022]

set project_name=_dem_bones
set project_entry_point=%~dp0%src\main.cpp

set maya_version=%1
if "%maya_version%"=="" (set maya_version=2022)
set maya_directory=C:\Program Files\Autodesk\Maya%maya_version%
set maya_include=%maya_directory%\include
set maya_lib=%maya_directory%\lib

set build_directory=%~dp0build\windows-maya-%maya_version%

REM    Set the python include/lib path which differs per maya version and the
REM    directory to the vcvarsall.bat which requires to be called to setup the
REM    build environment.
if "%maya_version%"=="2018" (
    set python_export="init_dem_bones"
    set python_lib=python27.lib
    set python_include=python2.7
    set vs_directory="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\"
)
if "%maya_version%"=="2019" (
    set python_export="init_dem_bones"
    set python_lib=python27.lib
    set python_include=python2.7
    set vs_directory="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\"
)
if "%maya_version%"=="2020" (
    set python_export="init_dem_bones"
    set python_lib=python27.lib
    set python_include=Python
    set vs_directory="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\"
)
if "%maya_version%"=="2022" (
    set python_export="PyInit__dem_bones"
    set python_lib=python37.lib
    set python_include=Python37\Python
    set vs_directory="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\"
)

REM    Set up the Visual Studio environment variables for calling the MSVC compiler;
REM    we do this after the call to pushd so that the top directory on the stack
REM    is saved correctly; the check for DevEnvDir is to make sure the vcvarsall.bat
REM    is only called once per-session (since repeated invocations will screw up
REM    the environment)
if not defined DevEnvDir (
    call %vs_directory%vcvarsall.bat x64
    set maya_version_initial=%maya_version%
    goto start_build
)
if not "%maya_version%"=="%maya_version_initial%" (
    echo Maya version %maya_version% doesn't match initialized build environment
    goto error
)

:start_build

REM    Make a build directory
echo Building in configuration: Maya %maya_version%
echo Building in directory: %build_directory%
if not exist %build_directory% mkdir %build_directory%
pushd %build_directory%

del *.pdb > NUL 2> NUL

REM    Setup all the compiler flags
set f_compiler=
set f_compiler=%f_compiler% /Tp"%project_entry_point%"
set f_compiler=%f_compiler% /Fo"%build_directory%\%project_name%.obj"
set f_compiler=%f_compiler% /c
set f_compiler=%f_compiler% /nologo
set f_compiler=%f_compiler% /Ox
set f_compiler=%f_compiler% /MD
set f_compiler=%f_compiler% /openmp
set f_compiler=%f_compiler% /W3
set f_compiler=%f_compiler% /GS-
set f_compiler=%f_compiler% /DNDEBUG
set f_compiler=%f_compiler% /I"%maya_directory%\include" 
set f_compiler=%f_compiler% /I"%maya_directory%\include\%python_include%"
set f_compiler=%f_compiler% /I"%~dp0%extern\pybind11\include"
set f_compiler=%f_compiler% /I"%~dp0%extern\DemBones"
set f_compiler=%f_compiler% /I"%~dp0%extern\Eigen"
set f_compiler=%f_compiler% /wd5003
set f_compiler=%f_compiler% /EHsc
set f_compiler=%f_compiler% /bigobj

REM    Setup all the linker flags
set f_linker=
set f_linker=%f_linker% /DLL
set f_linker=%f_linker% /nologo
set f_linker=%f_linker% /INCREMENTAL:NO
set f_linker=%f_linker% "%maya_lib%\OpenMaya.lib"
set f_linker=%f_linker% "%maya_lib%\OpenMayaAnim.lib" 
set f_linker=%f_linker% "%maya_lib%\OpenMayaFX.lib" 
set f_linker=%f_linker% "%maya_lib%\OpenMayaRender.lib"
set f_linker=%f_linker% "%maya_lib%\OpenMayaUI.lib" 
set f_linker=%f_linker% "%maya_lib%\Foundation.lib"
set f_linker=%f_linker% "%maya_lib%\%python_lib%"
set f_linker=%f_linker% /EXPORT:%python_export%
set f_linker=%f_linker% "%build_directory%\%project_name%.obj"
set f_linker=%f_linker% /OUT:"%build_directory%\%project_name%.pyd"
set f_linker=%f_linker% /IMPLIB:"%build_directory%\%project_name%.lib"
set f_linker=%f_linker% /MANIFESTFILE:"%build_directory%\%project_name%.pyd.manifest"

cl %f_compiler%
if %errorlevel% neq 0 goto error

:link
link %f_linker%
if %errorlevel% neq 0 goto error
if %errorlevel% == 0 goto success

:error
echo Build errored
goto end

:success
echo Build completed successfully
goto end

:end
popd
exit /b %errorlevel%
