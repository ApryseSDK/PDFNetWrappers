#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFTronGo CXX)
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

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
set(PDFTronGo_SourcesDir ${PROJECT_BINARY_DIR}/pdftron)
file(MAKE_DIRECTORY ${PDFTronGo_SourcesDir})
file(MAKE_DIRECTORY ${PDFTronGo_SourcesDir}/PDFNetC)
file(MAKE_DIRECTORY ${PDFTronGo_SourcesDir}/Samples)
execute_process(
    COMMAND ${SWIG_EXECUTABLE} -go -cgo -c++ -intgosize 64 ${SWIG_DEFINE} -I${PDFNetC_Include_Dir} -outdir ${PDFTronGo_SourcesDir} -o ${PDFTronGo_SourcesDir}/pdftron_wrap.cxx -oh ${PDFTronGo_SourcesDir}/pdftron_wrap.h pdftron.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/swig.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/swig.err.log
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
if ("${SOURCE_GEN_RESULT}" STREQUAL "0")
    message(STATUS "Generating sources for Go bindings using swig... OK")
else ()
    message(FATAL_ERROR "An error has occurred while generating sources using swig. Check '${PROJECT_BINARY_DIR}/swig.err.log' for details.")
    return ()
endif ()
# Insert cgo flags
message(STATUS "Inserting cgo flags..")
execute_process(
    COMMAND go run -x ./helper/insertflags.go -- "${PDFTronGo_SourcesDir}/pdftron.go" "#cgo CXXFLAGS: -I./PDFNetC/Headers" "#cgo LDFLAGS: -L./PDFNetC/Lib -lPDFNetC"
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/go.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/go.err.log
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Copy PDFNetC and Samples folder
message(STATUS "Copy PDFNetC and Samples folder..")
execute_process(
    COMMAND cmake -E copy_directory ${CMAKE_SOURCE_DIR}/PDFNetC ${PDFTronGo_SourcesDir}/PDFNetC
    COMMAND cmake -E copy_directory ${CMAKE_SOURCE_DIR}/Samples ${PDFTronGo_SourcesDir}/Samples
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/go.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/go.err.log
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
