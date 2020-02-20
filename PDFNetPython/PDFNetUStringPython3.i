//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2020 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * Typemap for UString from and to Python standard strings.
 * This typemap is only valid in Python 3.
 */

%{
	#include <string>
%}

namespace pdftron {
	class UString;

	/**
	 * Typemap from Python string to UString/const UString
	 */
	%typemap(in) UString, const UString
	{  
		if (!PyUnicode_Check(& $input)) {
			PyErr_SetString(PyExc_ValueError,"Expected a String");
			return NULL;
		}
		PyObject* bytes$argnum = PyUnicode_AsUTF8String($input);
		$1 = (UString(PyBytes_AsString(bytes$argnum)));
		Py_DECREF(bytes$argnum);
	}

	/**
	 * Typemap from UString/const UString to Python string
	 */
	%typemap(out) UString, const UString
	%{  
		try{
			$result = PyUnicode_FromString($1.ConvertToUtf8().c_str());
		}catch( ... )
		{
			$result =  PyUnicode_FromString("");
			//SWIG_exception(SWIG_RuntimeError,"UTF8 exception"); //SWIG_fail;
		}
	%}

    /**
     * directorout/directorin typemaps maps types for directors (C++ classes that can be extended/inherited in Python)
     */
    /* UString -> Python string */
	%typemap(directorin) UString, const UString
	%{  
		try{
			$1 = PyUnicode_FromString($input.ConvertToUtf8().c_str());
		}catch( ... )
		{
			$1 = PyUnicode_FromString("");
		}
	%}
    
    /* Python string -> UString */
	%typemap(directorout) UString, const UString
	{
		bool isStr$argnum = PyString_Check($1);
		bool isUni$argnum = PyUnicode_Check($1);
		if (!(isStr$argnum || isUni$argnum)) {
			PyErr_SetString(PyExc_ValueError,"Expected a String or a Unicode");
			Swig::DirectorMethodException::raise("Expected a String or a Unicode");
		}
		if (isStr$argnum) {
			$result = UString(PyString_AsString($1));
		}
		else if (isUni$argnum) {
			PyObject* obj = PyUnicode_AsUTF8String($1);
			char* str = PyString_AsString(obj);
			$result = UString(str);
			Py_DECREF(obj);
		}
	}

	/**
	 * Typemap from Python string to const UString&
	 */
	%typemap(in) UString const &
	{  
		if (!PyUnicode_Check($input)) {
			PyErr_SetString(PyExc_ValueError,"Expected a String");
			return NULL;
		}
		PyObject* bytes$argnum = PyUnicode_AsUTF8String($input);
		$1 = new UString(PyBytes_AsString(bytes$argnum));
		Py_DECREF(bytes$argnum);
	}

	/**
	 * Checks the UStrings argument to ensure that the input is of the Unicode type.
	 */
	%typemap(typecheck,precedence=SWIG_TYPECHECK_UNISTRING) UString, const UString, UString const &
	%{
		$1 = PyUnicode_Check($input) ? 1 : 0;
	%}
	
	/**
	 * Clean up the allocated UString within the above typemaps
	 */
	%typemap(freearg) UString const &
	%{
		delete($1);
	%}
}
