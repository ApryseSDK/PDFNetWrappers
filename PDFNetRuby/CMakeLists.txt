#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetRuby CXX)
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

find_package(Ruby)

if (RUBY_FOUND)
    message(STATUS "Using Ruby ${RUBY_VERSION}")
    message(STATUS "Ruby include directory: ${RUBY_INCLUDE_DIRS}")
    message(STATUS "Ruby library: ${RUBY_LIBRARY}")
else ()
    message(FATAL_ERROR "Cannot find Ruby libraries, please set the variables specified by the error message then try again.")
    return ()
endif ()

message(STATUS "Generating sources for Ruby bindings using swig...")
set(PDFNetRuby_SourcesDir ${PROJECT_BINARY_DIR})

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -ruby -DSWIGHIDDEN_SIG -I${PDFNetC_Include_Dir} -outdir ${PDFNetRuby_SourcesDir} -o ${PDFNetRuby_SourcesDir}/PDFNetRuby.cpp -oh ${PDFNetRuby_SourcesDir}/PDFNetRuby.hpp PDFNetRuby.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/swig.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/swig.err.log
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if ("${SOURCE_GEN_RESULT}" STREQUAL "0")
    message(STATUS "Generating sources for Ruby bindings using swig... OK")
else ()
    message(FATAL_ERROR "An error has occurred while generating sources using swig. Check '${PROJECT_BINARY_DIR}/swig.err.log' for details.")
    return ()
endif ()

set (
    PDFNetRuby_Sources
    ${PDFNetRuby_SourcesDir}/PDFNetRuby.cpp
    ${PDFNetRuby_SourcesDir}/PDFNetRuby.hpp
)

add_definitions(
    -DSWIG
    -DONIG_ESCAPE_UCHAR_COLLISION
    -DIMPORT
)

include_directories(
    ${PDFNetC_Include_Dir}
    ${RUBY_INCLUDE_DIRS}
)

# The PDFNetRuby project.
add_library(PDFNetRuby MODULE ${PDFNetRuby_Sources})
target_link_libraries(PDFNetRuby ${PDFNetC_Library} ${RUBY_LIBRARY})

# Ruby extension naming conventions are:
# - PDFNetRuby.so
# - PDFNetRuby.bundle (for Mac OS)

set_property(TARGET PDFNetRuby PROPERTY PREFIX "")
if (APPLE)
    set_property(TARGET PDFNetRuby PROPERTY SUFFIX ".bundle")
else ()
    set_property(TARGET PDFNetRuby PROPERTY SUFFIX ".so")
endif ()

# Installation rules

install(
    TARGETS PDFNetRuby
    LIBRARY DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
