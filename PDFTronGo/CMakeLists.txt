#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFTronGo CXX)
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

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

if ("${SOURCE_GEN_RESULT}" STREQUAL "0")
    message(STATUS "Generating sources for Go bindings using swig... OK")
else ()
    message(FATAL_ERROR "An error has occurred while generating sources using swig.")
    return ()
endif ()
