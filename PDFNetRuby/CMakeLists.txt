#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetRuby CXX)
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

# For usage with RVM, otherwise it won't be able to find the virtual environment version
if (DEFINED ENV{MY_RUBY_HOME})
    set(MY_RUBY_HOME "$ENV{MY_RUBY_HOME}")
    message(STATUS "MY_RUBY_HOME detected, searching for virtual environment.. ${MY_RUBY_HOME}")
    string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" CMAKE_HOST_TOLOWER_NAME)

    string(REPLACE "." ";" CMAKE_VERSION_LIST "${CMAKE_HOST_SYSTEM_VERSION}")
    list(GET CMAKE_VERSION_LIST 0 MAJOR_SYS_VERSION)

    # Get major and minor versions and append a 0 for the include directories
    # Ruby happens to store includes under a base version for x.x.0
    string(REPLACE "-" ";" CMAKE_VERSION_LIST "${MY_RUBY_HOME}")
    list(GET CMAKE_VERSION_LIST -1 RUBY_BASE_VERSION)
    string(REPLACE "." ";" CMAKE_VERSION_LIST "${RUBY_BASE_VERSION}")
    list(GET CMAKE_VERSION_LIST 0 RUBY_MAJOR)
    list(GET CMAKE_VERSION_LIST 1 RUBY_MINOR)
    set(RUBY_BASE_VERSION "${RUBY_MAJOR}.${RUBY_MINOR}.0")

    set(RUBY_LIBRARY "${MY_RUBY_HOME}")
    if (APPLE)
        # On apple the directory includes a version number
        set(RUBY_INCLUDE_DIRS "${MY_RUBY_HOME}/include/ruby-${RUBY_BASE_VERSION};${MY_RUBY_HOME}/include/ruby-${RUBY_BASE_VERSION}/${CMAKE_HOST_SYSTEM_PROCESSOR}-${CMAKE_HOST_TOLOWER_NAME}${MAJOR_SYS_VERSION}")
    else ()
        set(RUBY_INCLUDE_DIRS "${MY_RUBY_HOME}/include/ruby-${RUBY_BASE_VERSION};${MY_RUBY_HOME}/include/ruby-${RUBY_BASE_VERSION}/${CMAKE_HOST_SYSTEM_PROCESSOR}-${CMAKE_HOST_TOLOWER_NAME}")
    endif ()

    message(STATUS "Using Ruby ${MY_RUBY_HOME}")
    message(STATUS "Ruby include directory: ${RUBY_INCLUDE_DIRS}")
    message(STATUS "Ruby library: ${RUBY_LIBRARY}")
else ()
    message(STATUS "Auto detecting via find_package...")
    find_package(Ruby)
    if (RUBY_FOUND)
        message(STATUS "Using Ruby ${RUBY_VERSION}")
        message(STATUS "Ruby include directory: ${RUBY_INCLUDE_DIRS}")
        message(STATUS "Ruby library: ${RUBY_LIBRARY}")
    else ()
        message(FATAL_ERROR "Cannot find Ruby libraries, please set the variables specified by the error message then try again.")
        return ()
    endif ()
endif ()

message(STATUS "Generating sources for Ruby bindings using swig...")
set(PDFNetRuby_SourcesDir ${PROJECT_BINARY_DIR})

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -ruby -DSWIGHIDDEN_SIG -I${PDFNetC_Include_Dir} -outdir ${PDFNetRuby_SourcesDir} -o ${PDFNetRuby_SourcesDir}/PDFNetRuby.cpp -oh ${PDFNetRuby_SourcesDir}/PDFNetRuby.hpp PDFNetRuby.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
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

# Platform specific compiler and linker settings
if (MSVC)
    add_definitions(-D_XKEYCHECK_H -DUNICODE -D_UNICODE)
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
    set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /MT")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MT")
    set(RUBY_LINK_LIB ${RUBY_LIBRARY} ws2_32.lib imagehlp.lib shlwapi.lib)
elseif (MINGW OR MSYS)
    set(RUBY_LINK_LIB ${RUBY_LIBRARY} ws2_32 imagehlp shlwapi)
elseif (UNIX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -fPIC")
    if (APPLE)
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-headerpad_max_install_names -lSystem -undefined dynamic_lookup -Wl,-install_name,@rpath/PDFNetRuby.bundle -Wl,-rpath,/usr/lib -Wl,-rpath,/usr/local/lib -Wl,-rpath,.")
        if(BUILD_MACOS_ARM64)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -target arm64-apple-macos11")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -target arm64-apple-macos11")
            set(CMAKE_OSX_SYSROOT "/Applications/Xcode_12.3.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
        else(BUILD_MACOS_ARM64)
            set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
        endif(BUILD_MACOS_ARM64)
    else ()
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-rpath,'$ORIGIN'")
    endif ()
endif ()

# The PDFNetRuby project.
add_library(PDFNetRuby MODULE ${PDFNetRuby_Sources})
target_link_libraries(PDFNetRuby ${PDFNetC_Library} ${RUBY_LINK_LIB})

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
