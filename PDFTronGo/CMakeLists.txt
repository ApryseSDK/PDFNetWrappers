#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFTronGo CXX)
if(CMAKE_MAJOR_VERSION VERSION_EQUAL "4")
    cmake_minimum_required(VERSION 3.10)
else()
    cmake_minimum_required(VERSION 3.4)
endif()

find_program(GO_EXECUTABLE go PATHS $ENV{HOME}/go ENV GOROOT GOPATH PATH_SUFFIXES bin)
if(GO_EXECUTABLE)
    message(STATUS "Found Go.")
else ()
    message(FATAL_ERROR "Please install Go.")
    return ()
endif (GO_EXECUTABLE)

if (WIN32)
    message(STATUS "Windows host platform detected.")
    if(MINGW)
        message(STATUS "Found MINGW.")
    else ()
        message(FATAL_ERROR "Please install MINGW.")
        return ()
    endif (MINGW)
elseif (UNIX)
    message(STATUS "Linux host platform detected.")
elseif (APPLE)
    message(STATUS "Mac host platform detected. Not implemented yet!")
    return ()
endif (WIN32)


message(STATUS "Generating sources for Go bindings using swig...")
set(BUILD_DIR ${PROJECT_BINARY_DIR}/pdftron)
set(PDFNETC_HEADERS ${BUILD_DIR}/Headers CACHE PATH "Path to the PDFNetC header files.")
file(MAKE_DIRECTORY ${BUILD_DIR})
file(MAKE_DIRECTORY ${BUILD_DIR}/Lib)
file(MAKE_DIRECTORY ${BUILD_DIR}/Headers)
file(MAKE_DIRECTORY ${BUILD_DIR}/Resources)

if (NOT EXISTS ${CMAKE_SOURCE_DIR}/build/PDFNetC/Lib)
    message(FATAL_ERROR "PDFNetC library cannot be found. Cannot continue.")
endif ()

# Copy PDFNetC and Samples folder
message(STATUS "Copy PDFNetC")
execute_process(
    COMMAND cmake -E copy_directory ${CMAKE_SOURCE_DIR}/build/PDFNetC/Lib ${BUILD_DIR}/Lib
    COMMAND cmake -E copy_directory ${CMAKE_SOURCE_DIR}/build/PDFNetC/Headers ${BUILD_DIR}/Headers
    COMMAND cmake -E copy_directory ${CMAKE_SOURCE_DIR}/build/PDFNetC/Resources ${BUILD_DIR}/Resources
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/go.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/go.err.log
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

message(STATUS "Running ${SWIG_EXECUTABLE} -go -cgo -c++ -intgosize 64 ${SWIG_DEFINE} -I${PDFNETC_HEADERS} -outdir ${BUILD_DIR} -o ${BUILD_DIR}/pdftron_wrap.cxx -oh ${BUILD_DIR}/pdftron_wrap.h pdftron.i")
execute_process(
    COMMAND ${SWIG_EXECUTABLE} -go -cgo -c++ -intgosize 64 ${SWIG_DEFINE} -I${PDFNETC_HEADERS} -outdir ${BUILD_DIR} -o ${BUILD_DIR}/pdftron_wrap.cxx -oh ${BUILD_DIR}/pdftron_wrap.h pdftron.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# ------------------------------------------------------------------------------
# HACK: Post-processing of SWIG-generated Go bindings
#
# The C++ API uses ElementRef<T> as a value-type wrapper representing an optional
# reference (IsValid() + GetElement()).
#
# Attempts to erase or re-map ElementRef<T> using SWIG Go typemaps (gotype,
# ctype, imtype, etc.) lead to unstable or invalid generated code, including:
#   - incorrect C wrapper signatures (value return vs pointer return)
#   - broken Go code (C++ typedefs emitted into .go files)
#   - ABI mismatches and compilation errors
#
# To produce a stable and idiomatic Go API, we intentionally:
#   1) Let SWIG generate bindings using ElementRef<T> internally
#   2) Use Go-side typemaps only for final semantic conversion (Ref -> T | nil)
#   3) Post-process the generated *.go files to erase the use of artificial '*Ref'
#      types from the public Go API
#
# This post-processing step rewrites:
#   - function return types (e.g. FooRef -> Foo)
#   - local variables using Ref types
# ------------------------------------------------------------------------------
file(GLOB_RECURSE GO_FILES "${BUILD_DIR}/*.go")

set(ELEMENT_REF_TYPES
    ContentNode
    Paragraph
    TextRun
    Table
    TableRow
    TableCell
    List
    ListItem
)

file(GLOB_RECURSE GO_FILES "${BUILD_DIR}/*.go")

foreach(GO_FILE ${GO_FILES})
    file(READ "${GO_FILE}" GO_FILE_CONTENT)

    foreach(TYPE ${ELEMENT_REF_TYPES})
        # Fix function return types:
        #   (_swig_ret ContentNodeRef) -> (_swig_ret ContentNode)
        string(REPLACE
            "As${TYPE}() (_swig_ret ${TYPE}Ref)"
            "As${TYPE}() (_swig_ret ${TYPE})"
            GO_FILE_CONTENT
            "${GO_FILE_CONTENT}"
        )

        # Fix local variable declarations:
        #   var swig_r_1 ContentNodeRef -> var swig_r_1 ContentNode
        string(REPLACE
            "var swig_r_1 ${TYPE}Ref"
            "var swig_r_1 ${TYPE}"
            GO_FILE_CONTENT
            "${GO_FILE_CONTENT}"
        )
    endforeach()

    file(WRITE "${GO_FILE}" "${GO_FILE_CONTENT}")
endforeach()


if ("${SOURCE_GEN_RESULT}" STREQUAL "0")
    message(STATUS "Generating sources for Go bindings using swig... OK")
else ()
    message(FATAL_ERROR "An error has occurred while generating sources using swig.")
    return ()
endif ()
