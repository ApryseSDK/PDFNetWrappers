#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetLanguageBindings CXX)
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

set(CUSTOM_SWIG CACHE STRING "")
set(BUILD_PDFNetPython OFF CACHE BOOL "Build PDFNet language bindings for Python.")
set(BUILD_PDFNetRuby OFF CACHE BOOL "Build PDFNet language bindings for Ruby.")
set(BUILD_PDFNetPHP OFF CACHE BOOL "Build PDFNet language bindings for PHP.")
set(BUILD_PDFTronGo OFF CACHE BOOL "Build PDFNet language bindings for GO.")
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/PDFNetC" CACHE PATH "CMAKE_INSTALL_PREFIX" FORCE)

if ("${CMAKE_INSTALL_PREFIX}" STREQUAL "${CMAKE_SOURCE_DIR}/PDFNetC")
    set(INSTALL_DESTINATION_LIB_DIR "Lib")
else ()
    set(INSTALL_DESTINATION_LIB_DIR "lib")
endif ()


if ("${CUSTOM_SWIG}" STREQUAL "")
    # Find SWIG
    find_package(SWIG)

    if (SWIG_FOUND)
        message(STATUS "Using SWIG ${SWIG_VERSION}")
    else ()
        message(FATAL_ERROR "SWIG not found. Cannot continue.")
        return ()
    endif ()
else ()
    set(SWIG_EXECUTABLE "${CUSTOM_SWIG}")
endif ()

# Check PDFNetC
if (EXISTS ${CMAKE_SOURCE_DIR}/PDFNetC/Headers)
    set(PDFNetC_Include_Dir ${CMAKE_SOURCE_DIR}/PDFNetC/Headers CACHE PATH "Path to the PDFNetC header files.")
elseif (BUILD_PDFTronGo)
    message(STATUS "Letting PDFTronGo handle PDFNetC...")
else ()
    message(FATAL_ERROR "PDFNetC headers directory not found. Cannot continue.")
endif ()

if (EXISTS ${CMAKE_SOURCE_DIR}/PDFNetC/Lib/libPDFNetC.so)
    set(PDFNetC_Library ${CMAKE_SOURCE_DIR}/PDFNetC/Lib/libPDFNetC.so CACHE FILEPATH "File path to the PDFNetC library.")
elseif (EXISTS ${CMAKE_SOURCE_DIR}/PDFNetC/Lib/PDFNetC.lib)
    set(PDFNetC_Library ${CMAKE_SOURCE_DIR}/PDFNetC/Lib/PDFNetC.lib CACHE FILEPATH "File path to the PDFNetC library.")
elseif (EXISTS ${CMAKE_SOURCE_DIR}/PDFNetC/Lib/libPDFNetC.dylib)
    set(PDFNetC_Library ${CMAKE_SOURCE_DIR}/PDFNetC/Lib/libPDFNetC.dylib CACHE FILEPATH "File path to the PDFNetC library.")
elseif (BUILD_PDFTronGo)
    message(STATUS "Letting PDFTronGo handle PDFNetC...")
else ()
    message(FATAL_ERROR "PDFNetC library cannot be found. Cannot continue.")
endif ()

# Put all the output files to $BUILD_DIR/lib
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(LIBRARY_OUTPUT_PATH ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

if (BUILD_PDFNetPython)
    add_subdirectory(${CMAKE_SOURCE_DIR}/PDFNetPython)
endif ()

if (BUILD_PDFNetRuby)
    add_subdirectory(${CMAKE_SOURCE_DIR}/PDFNetRuby)
endif ()

if (BUILD_PDFNetPHP)
    add_subdirectory(${CMAKE_SOURCE_DIR}/PDFNetPHP)
endif ()

if (BUILD_PDFTronGo)
    add_subdirectory(${CMAKE_SOURCE_DIR}/PDFTronGo)
endif ()
