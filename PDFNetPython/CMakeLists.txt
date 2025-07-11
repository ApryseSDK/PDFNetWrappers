#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

if (APPLE)
    set(CMAKE_OSX_ARCHITECTURES arm64 x86_64)
endif()

project(PDFNetPython CXX)

message(STATUS "Generating sources for Python bindings using swig...")
set(PDFNetPython_SourcesDir ${PROJECT_BINARY_DIR})

find_package(Python3 REQUIRED COMPONENTS Interpreter Development Development.SABIModule)

add_definitions(-DPy_LIMITED_API=0x03040000)

set(SWIG_DEFINE "-DPYTHON3")
set(DOXYGEN "-doxygen")

message(STATUS "-- ${DOXYGEN}")

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -python ${DOXYGEN} ${SWIG_DEFINE} -DPy_LIMITED_API=0x03040000 -DSWIGHIDDEN_SIG -I${Python3_INCLUDE_DIRS} -I${PDFNetC_Include_Dir} -outdir ${PDFNetPython_SourcesDir} -o ${PDFNetPython_SourcesDir}/PDFNetPython.cpp -oh ${PDFNetPython_SourcesDir}/PDFNetPython.hpp PDFNetPython.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if ("${SOURCE_GEN_RESULT}" STREQUAL "0")
    message(STATUS "Generating sources for Python bindings using swig... OK")
else ()
    message(FATAL_ERROR "An error has occurred while generating sources using swig. Check '${PROJECT_BINARY_DIR}/swig.err.log' for details.")
    return ()
endif ()

set (
    PDFNetPython_Sources
    ${PDFNetPython_SourcesDir}/PDFNetPython.cpp
    ${PDFNetPython_SourcesDir}/PDFNetPython.hpp
)

add_definitions(
    -DSWIG
)

include_directories(
    ${PDFNetC_Include_Dir}
    ${Python3_INCLUDE_DIRS}
)

# The PDFNetPython project.

if (MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
    set(PYTHON_LINK_LIB ${Python3_SABI_LIBRARIES})
elseif (MINGW OR MSYS)
    set(PYTHON_LINK_LIB ${Python3_SABI_LIBRARIES})
elseif (UNIX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -fPIC")
    if (APPLE)
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-headerpad_max_install_names -lSystem -undefined dynamic_lookup -Wl,-install_name,@rpath/_PDFNetPython.so -Wl,-rpath,/usr/lib -Wl,-rpath,/usr/local/lib -Wl,-rpath,.")
        set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
    else ()
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-rpath,'$ORIGIN'")
    endif ()
endif ()

add_library(PDFNetPython MODULE ${PDFNetPython_Sources})
target_link_libraries(PDFNetPython ${PDFNetC_Library} ${Python3_SABI_LIBRARIES})

# Python extension naming conventions are:
# - _PDFNetPython.so
# - _PDFNetPython.pyd (Windows)

set_property(TARGET PDFNetPython PROPERTY PREFIX "_")
if (WIN32)
    set_property(TARGET PDFNetPython PROPERTY SUFFIX ".pyd")
else ()
    set_property(TARGET PDFNetPython PROPERTY SUFFIX ".so")
endif ()

# Copy the bridge file

configure_file(${PDFNetPython_SourcesDir}/PDFNetPython.py ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPython.py COPYONLY)

# Installation rules

install(
    FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPython.py
    DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)

install(
    TARGETS PDFNetPython
    LIBRARY DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
