#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetPython CXX)

message(STATUS "Generating sources for Python bindings using swig...")
set(PDFNetPython_SourcesDir ${PROJECT_BINARY_DIR})

find_package(Python3 REQUIRED COMPONENTS Interpreter Development)

if (PYTHON_3 AND ("${SWIG_VERSION}" MATCHES "^2[\\.0-9]*[a-zA-Z0-9\\+]*$"))
    message(FATAL_ERROR "Cannot build PYTHON3 wrapper with SWIG2. Please install SWIG 3.0.12 or above and rebuild the wrapper.")
    return ()
endif ()

set(DOXYGEN "")
if (PYTHON_2)
    set(SWIG_DEFINE "-DPYTHON2")
elseif (PYTHON_3)
    set(SWIG_DEFINE "-DPYTHON3")
    set(DOXYGEN "-doxygen")
endif ()

message(STATUS "-- ${DOXYGEN}")

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -python ${DOXYGEN} ${SWIG_DEFINE} -DPy_LIMITED_API=0x03040000 -DSWIGHIDDEN_SIG -I${PDFNetC_Include_Dir} -outdir ${PDFNetPython_SourcesDir} -o ${PDFNetPython_SourcesDir}/PDFNetPython.cpp -oh ${PDFNetPython_SourcesDir}/PDFNetPython.hpp PDFNetPython.i
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
    ${PYTHON_INCLUDE_DIRS}
)

# The PDFNetPython project.

if (MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
    set(PYTHON_LINK_LIB ${PYTHON_LIBRARY})
elseif (MINGW OR MSYS)
    set(PYTHON_LINK_LIB ${PYTHON_LIBRARY})
elseif (UNIX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -fPIC")
    if (APPLE)
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-headerpad_max_install_names -lSystem -undefined dynamic_lookup -Wl,-install_name,@rpath/_PDFNetPython.so -Wl,-rpath,/usr/lib -Wl,-rpath,/usr/local/lib -Wl,-rpath,.")
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

add_library(PDFNetPython MODULE ${PDFNetPython_Sources})
target_link_libraries(PDFNetPython ${PDFNetC_Library} ${PYTHON_LINK_LIB})

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
    FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPython.py ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/PDFNetPyLibInfo 
    DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
install(
    TARGETS PDFNetPython
    LIBRARY DESTINATION ${INSTALL_DESTINATION_LIB_DIR}
)
