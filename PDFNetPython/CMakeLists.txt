#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt for licensing information.
#-----------------------------------------------------------------------------------------------------------------------

project(PDFNetPython CXX)
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

find_package(PythonInterp)
find_package(PythonLibs)

if (PYTHONINTERP_FOUND AND PYTHONLIBS_FOUND)
    if ("${PYTHON_VERSION_MAJOR}" STREQUAL "2")
        set(PYTHON_2 ON)
    elseif ("${PYTHON_VERSION_MAJOR}" STREQUAL "3")
        set(PYTHON_3 ON)
    else ()
        message(FATAL_ERROR "Unsupported Python version. Please install either Python 2 or Python 3.")
    endif ()

    message(STATUS "Using Python ${PYTHON_VERSION_STRING}")
    message(STATUS "Python include directory: ${PYTHON_INCLUDE_DIRS}")
    message(STATUS "Python library: ${PYTHON_LIBRARY}")
else ()
    message(FATAL_ERROR "Cannot find Python libraries, please set the variables specified by the error message then try again.")
    return ()
endif ()

message(STATUS "Generating sources for Python bindings using swig...")
set(PDFNetPython_SourcesDir ${PROJECT_BINARY_DIR})

if (PYTHON_2)
    set(SWIG_DEFINE "-DPYTHON2")
elseif (PYTHON_3)
    set(SWIG_DEFINE "-DPYTHON3")
endif ()

execute_process(
    COMMAND ${SWIG_EXECUTABLE} -c++ -python ${SWIG_DEFINE} -DSWIGHIDDEN_SIG -I${PDFNetC_Include_Dir} -outdir ${PDFNetPython_SourcesDir} -o ${PDFNetPython_SourcesDir}/PDFNetPython.cpp -oh ${PDFNetPython_SourcesDir}/PDFNetPython.hpp PDFNetPython.i
    RESULT_VARIABLE SOURCE_GEN_RESULT
    OUTPUT_FILE ${PROJECT_BINARY_DIR}/swig.log
    ERROR_FILE ${PROJECT_BINARY_DIR}/swig.err.log
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
endif ()

add_library(PDFNetPython MODULE ${PDFNetPython_Sources})
target_link_libraries(PDFNetPython ${PDFNetC_Library} ${PYTHON_LIBRARY})

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
