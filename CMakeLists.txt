cmake_minimum_required(VERSION 3.15)

project(dem_bones VERSION 1.0 DESCRIPTION "DemBones Python bindings for Maya" LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/modules)

set(ENV{EIGEN3_ROOT_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/extern/Eigen)
set(DEMBONES_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/extern/DemBones)

include_directories("${DEMBONES_ROOT_DIR}/include")

set(SOURCE_FILES
    "src/main.cpp"
    "src/utils.h"
)

SET(DEMBONES_FILES
    "extern/DemBones/include/DemBones/ConvexLS.h"
    "extern/DemBones/include/DemBones/DemBones.h"
    "extern/DemBones/include/DemBones/DemBonesExt.h"
    "extern/DemBones/include/DemBones/Indexing.h"
    "extern/DemBones/include/DemBones/MatBlocks.h"
)

find_package(OpenMP)

if (OPENMP_FOUND)
	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    add_compile_options("$<$<AND:$<CXX_COMPILER_ID:MSVC>,$<CONFIG:DEBUG>>:/bigobj>")
endif()

if (SKBUILD)
    string(SUBSTRING $CACHE{PYTHON_VERSION_STRING} 0 1 MAYA_PYTHON_VERSION)
    message(STATUS, "$CACHE{PYTHON_EXECUTABLE}")
    string(REGEX MATCH Maya[0-9][0-9][0-9][0-9] MAYA_VERSION "$CACHE{PYTHON_EXECUTABLE}")
    string(SUBSTRING ${MAYA_VERSION} 4 -1 MAYA_VERSION)
endif()

find_package(Eigen3 REQUIRED)
find_package(Maya REQUIRED)
find_package(MayaPython REQUIRED)

add_subdirectory(extern/pybind11)

Python_add_library(_core ${SOURCE_FILES} ${DEMBONES_FILES})
target_link_libraries(_core PRIVATE Maya::Maya Eigen3::Eigen pybind11::module)
target_include_directories(_core
    PRIVATE Maya::Maya Eigen3::Eigen pybind11::module
    PUBLIC "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}"
)

install(TARGETS _core DESTINATION .)
