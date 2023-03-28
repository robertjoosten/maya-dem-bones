# Copyright 2023 Robert Joosten
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Set a default Maya version if not specified
if(NOT DEFINED MAYA_VERSION)
    set(MAYA_VERSION 2023 CACHE STRING "Maya version")
endif()

if(NOT DEFINED MAYA_PYTHON_VERSION AND MAYA_VERSION STRGREATER_EQUAL 2022)
    set(MAYA_PYTHON_VERSION 3)
elseif(NOT DEFINED MAYA_PYTHON_VERSION)
    set(MAYA_PYTHON_VERSION 2)
endif()

# OS Specific environment setup
if(WIN32)
    # Windows
    set(MAYA_INSTALL_BASE_DEFAULT "C:/Program Files/Autodesk")
elseif(APPLE)
    # Apple
    set(MAYA_INSTALL_BASE_DEFAULT /Applications/Autodesk)
else()
    # Linux
    set(MAYA_INSTALL_BASE_DEFAULT /usr/autodesk)
endif()

set(MAYA_INSTALL_BASE_PATH ${MAYA_INSTALL_BASE_DEFAULT} CACHE STRING
    "Root path containing your maya installations, e.g. /usr/autodesk or /Applications/Autodesk/")

set(MAYA_LOCATION ${MAYA_INSTALL_BASE_PATH}/maya${MAYA_VERSION}${MAYA_INSTALL_BASE_SUFFIX})

# Maya python interpreter
if(MAYA_VERSION EQUAL 2022 AND MAYA_PYTHON_VERSION EQUAL 2)
    find_program(Python_EXECUTABLE mayapy2
        HINTS
            "${MAYA_LOCATION}"
            "$ENV{MAYA_LOCATION}"
        PATH_SUFFIXES
            Maya.app/Contents/bin/
            bin/
        DOC
            "Maya's Python executable path"
    )
else()
    find_program(Python_EXECUTABLE mayapy
        HINTS
            "${MAYA_LOCATION}"
            "$ENV{MAYA_LOCATION}"
        PATH_SUFFIXES
            Maya.app/Contents/bin/
            bin/
        DOC
            "Maya's Python executable path"
    )
endif()

# Maya python library
file(GLOB_RECURSE Python_LIBRARY LIST_DIRECTORIES false
    ${MAYA_LOCATION}/lib/python.lib
    ${MAYA_LOCATION}/lib/python${MAYA_PYTHON_VERSION}*.lib
    ${MAYA_LOCATION}/Maya.app/Contents/MacOS/python.lib
    ${MAYA_LOCATION}/Maya.app/Contents/MacOS/python${MAYA_PYTHON_VERSION}*.lib
    $ENV{MAYA_LOCATION}/lib/python.lib
    $ENV{MAYA_LOCATION}/lib/python${MAYA_PYTHON_VERSION}*.lib
    $ENV{MAYA_LOCATION}/Maya.app/Contents/MacOS/python.lib
    $ENV{MAYA_LOCATION}/Maya.app/Contents/MacOS/python${MAYA_PYTHON_VERSION}*.lib
)
list(GET Python_LIBRARY 0 Python_LIBRARY)

# Maya python include directory
file(GLOB_RECURSE Python_INCLUDE_DIR LIST_DIRECTORIES false
    ${MAYA_LOCATION}/include/Python${MAYA_PYTHON_VERSION}*/Python.h
    ${MAYA_LOCATION}/devkit/include/Python${MAYA_PYTHON_VERSION}*/Python.h
    $ENV{MAYA_LOCATION}/include/Python${MAYA_PYTHON_VERSION}*/Python.h
    $ENV{MAYA_LOCATION}/devkit/include/Python${MAYA_PYTHON_VERSION}*/Python.h
    ${MAYA_LOCATION}/include/Python*/Python.h
    $ENV{MAYA_LOCATION}/include/Python*/Python.h
)
list(GET Python_INCLUDE_DIR 0 Python_INCLUDE_DIR)
get_filename_component(Python_INCLUDE_DIR ${Python_INCLUDE_DIR} DIRECTORY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MayaPython
    REQUIRED_VARS Python_EXECUTABLE Python_INCLUDE_DIR Python_LIBRARY)

find_package(Python QUIET COMPONENTS Interpreter Development)
