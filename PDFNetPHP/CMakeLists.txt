#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetPHP CXX)
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

if (WIN32)
    message(STATUS "Windows host platform detected.")
    if (PHP_INCLUDE_DIRS AND PHP_LIBRARY)
        include_directories(PHP_INCLUDE_DIRS)
    else ()
        message(FATAL_ERROR "Cannot find PHP include directories and library, please set the variable PHP_INCLUDE_DIRS and PHP_LIBRARY then try again.")
        return ()
    endif ()
else ()
    find_program(PHP_CONFIG php-config)
    if (PHP_CONFIG-NOTFOUND)
        message(FATAL_ERROR "Cannot find php-config, please set the variable PHP_CONFIG to the location of php-config then try again.")
        return ()
    endif ()

    execute_process(
        COMMAND ${PHP_CONFIG} --includes
        RESULT_VARIABLE PHP_CONFIG_INCLUDES_RESULT
        OUTPUT_VARIABLE PHP_CONFIG_INCLUDES
        ERROR_VARIABLE PHP_CONFIG_INCLUDES_ERR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if ("${PHP_CONFIG_INCLUDES_RESULT}" STREQUAL "0")
        message(STATUS "Using PHP include directories: ${PHP_CONFIG_INCLUDES}")
    else ()
        message(FATAL_ERROR "An error has occurred while getting PHP include directories. Error: ${PHP_CONFIG_INCLUDES_ERR}")
        return ()
    endif ()
    
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PHP_CONFIG_INCLUDES}")
endif ()

message(STATUS "Generating sources for PHP bindings using swig...")
set(PDFNetPHP_SourcesDir ${PROJECT_BINARY_DIR})

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -php -DNTS -DSWIGHIDDEN_SIG -I${PDFNetC_Include_Dir} -outdir ${PDFNetPHP_SourcesDir} -o ${PDFNetPHP_SourcesDir}/PDFNetPHP.cpp -oh ${PDFNetPHP_SourcesDir}/PDFNetPHP.hpp PDFNetPHP.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/swig.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/swig.err.log
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if ("${SOURCE_GEN_RESULT}" STREQUAL "0")
    message(STATUS "Generating sources for PHP bindings using swig... OK")
else ()
    message(FATAL_ERROR "An error has occurred while generating sources using swig. Check '${PROJECT_BINARY_DIR}/swig.err.log' for details.")
    return ()
endif ()

set (
    PDFNetPHP_Sources
    ${PDFNetPHP_SourcesDir}/PDFNetPHP.cpp
    ${PDFNetPHP_SourcesDir}/PDFNetPHP.hpp
)

add_definitions(
    -DSWIG
    -DNDEBUG
    -DIMPORT
    -DSWIG_ZEND_ERROR_NORETURN=zend_error
    -DPrint=PDFPrint
    -DFunction=PDFFunction
    -DClone=CloneHandler
    -DEval=EvalFunction
)

include_directories(
    ${PDFNetC_Include_Dir}
)

# The PDFNetPHP project.

add_library(PDFNetPHP MODULE ${PDFNetPHP_Sources})
target_link_libraries(PDFNetPHP ${PDFNetC_Library} ${PHP_LIBRARY})

# PHP extension naming conventions are:
# - PDFNetPHP.so/.dll
set_property(TARGET PDFNetPHP PROPERTY PREFIX "")

# Copy the bridge file

configure_file(${PDFNetPHP_SourcesDir}/PDFNetPHP.php ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP.php COPYONLY)

# Installation rules

install(
    FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP.php
    DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
install(
    TARGETS PDFNetPHP
    LIBRARY DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
