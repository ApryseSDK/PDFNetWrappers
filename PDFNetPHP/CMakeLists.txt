#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2020 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetPHP CXX)
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

if (WIN32)
    message(STATUS "Windows host platform detected.")
    if (PHP_INCLUDE_DIRS AND PHP_LIBRARY)
        include_directories(${PHP_INCLUDE_DIRS})
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

    execute_process(
        COMMAND ${PHP_CONFIG} --extension-dir
        RESULT_VARIABLE PHP_CONFIG_EXT_DIR_RESULT
        OUTPUT_VARIABLE PHP_CONFIG_EXT_DIR
        ERROR_VARIABLE PHP_CONFIG_EXT_DIR_ERR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if ("${PHP_CONFIG_EXT_DIR_RESULT}" STREQUAL "0")
        message(STATUS "Using PHP extension directory: ${PHP_CONFIG_EXT_DIR}")
    else ()
        message(FATAL_ERROR "An error has occurred while getting PHP extension directory. Error: ${PHP_CONFIG_EXT_DIR_ERR}")
        return ()
    endif ()
endif ()

message(STATUS "Generating sources for PHP bindings using swig...")
set(PDFNetPHP_SourcesDir ${PROJECT_BINARY_DIR})

#configure PHP version
find_program(PHP_CONFIG_EXECUTABLE NAMES php-config7 php-config5 php-config4 php-config)
if (PHP_CONFIG_EXECUTABLE)

    execute_process(
    COMMAND
      ${PHP_CONFIG_EXECUTABLE} --vernum
      OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND sed -ne "s/....$//p"
      OUTPUT_VARIABLE PHP_MAJOR_VERSION
    )
    execute_process(
    COMMAND
      ${PHP_CONFIG_EXECUTABLE} --vernum
      OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND sed -ne "s/..$//p"
    COMMAND sed -ne "s/^.0\\?//p"
      OUTPUT_VARIABLE PHP_MINOR_VERSION
    )

    if(DEFINED PHP_MAJOR_VERSION)
        if (PHP_MAJOR_VERSION LESS 7)
            set(php_version "php")
        else()
            set(php_version "php7")
        endif()
	    set(swig_php_major_arg "PHP_MAJOR_VERSION=${PHP_MAJOR_VERSION}")
    else()
        message(FATAL_ERROR "Cannot verify PHP_MAJOR_VERSION!")
        return ()
    endif()

else()
    message(FATAL_ERROR "Cannot find php-config, please set the variable PHP_CONFIG to the location of php-config then try again.")
    return ()
endif()

if (("${SWIG_VERSION}" MATCHES "^2[\\.0-9]*[a-zA-Z0-9\\+]*$") AND (PHP_MAJOR_VERSION EQUAL 7))
    message(FATAL_ERROR "SWIG2 doesn't work with PHP7. Please make sure either SWIG2/PHP5 or SWIG3+/PHP7 are installed. Note that only SWIG-3.0.12 and above works with PHP7. Any other combination of SWIG and PHP VERSION is likely to encounter problems!")
    return ()
endif()

message(STATUS "====================================================")
message(STATUS "*** WARNING: SWIG2 doesn't work with PHP7. Please make sure either SWIG2/PHP5 or SWIG3+/PHP7 are installed. Note that only SWIG-3.0.12 and above works with PHP7. Any other combination of SWIG and PHP VERSION is likely to encounter problems!")
message(STATUS "====================================================")
message(STATUS "SWIG VERSION      = ${SWIG_VERSION}")    
message(STATUS "PHP_MAJOR_VERSION = ${PHP_MAJOR_VERSION}")
message(STATUS "PHP_MINOR_VERSION = ${PHP_MINOR_VERSION}")
message(STATUS "${SWIG_EXECUTABLE} -c++ -${php_version} -D${swig_php_major_arg}...")    

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -${php_version} -DNTS -DSWIGHIDDEN_SIG -D${swig_php_major_arg} -I${PDFNetC_Include_Dir} -outdir ${PDFNetPHP_SourcesDir} -o ${PDFNetPHP_SourcesDir}/PDFNetPHP.cpp -oh ${PDFNetPHP_SourcesDir}/PDFNetPHP.hpp PDFNetPHP.i
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

if (WIN32)
    add_definitions(
        -DPHP_WIN32
        -D_USE_32BIT_TIME_T=1
        -DZEND_WIN32
        -DZEND_WIN32_FORCE_INLINE
        -DZEND_DEBUG=0
    )
endif ()

include_directories(
    ${PDFNetC_Include_Dir}
)

# The PDFNetPHP project.

add_library(PDFNetPHP MODULE ${PDFNetPHP_Sources})
target_link_libraries(PDFNetPHP ${PDFNetC_Library} ${PHP_LIBRARY})

if(APPLE)
    set_target_properties(PDFNetPHP PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")  
endif()

# PHP extension naming conventions are:
# - PDFNetPHP.so/.dll
set_property(TARGET PDFNetPHP PROPERTY PREFIX "")

# Copy the bridge file
configure_file(${PDFNetPHP_SourcesDir}/PDFNetPHP.php ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP.php COPYONLY)

# Rename /Build/lib/PDFNetPHP.php to /Build/lib/PDFNetPHP_core.php and wrap it inside github/PDFNetPHP/PDFNetPHP.php in the destination library (Lib)
file(RENAME ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP.php ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP_core.php)

# Installation rules

# in PDFNetC/Lib/
# using github/PDFNetPHP/PDFNetPHP.php 
install(
    FILES  ${CMAKE_SOURCE_DIR}/PDFNetPHP/PDFNetPHP.php 
    DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)

# using /Build/lib/PDFNetPHP_core.php
install(
    FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP_core.php
    DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
install(
    TARGETS PDFNetPHP
    LIBRARY DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
if (NOT WIN32)
    install(
        FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPHP.so
        DESTINATION ${PHP_CONFIG_EXT_DIR}
    )
endif ()
