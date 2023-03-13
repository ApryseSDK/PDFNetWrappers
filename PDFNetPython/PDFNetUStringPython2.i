//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * Typemap for UString from and to Python standard strings.
 * This typemap is only valid in Python 2.
 */

%{
	#include <string>
%}

namespace pdftron {
	class UString;

	/**
	 * Typemap between UString/const UString and Python string
     * Python string -> UString
	 */
	%typemap(in) UString, const UString
	{  
		bool isStr$argnum = PyString_Check($input);
		bool isUni$argnum = PyUnicode_Check($input);
		if (!(isStr$argnum || isUni$argnum)) {
			PyErr_SetString(PyExc_ValueError,"Expected a String or a Unicode");
			return NULL;
		}
		if (isStr$argnum) {
			$1 = pdftron::UString(PyString_AsString($input));
		}
		else if (isUni$argnum) {
			PyObject* obj = PyUnicode_AsUTF8String($input);
			char* str = PyString_AsString(obj);
			$1 = pdftron::UString(str);
			Py_DECREF(obj);
		}
	}

    /**
     * UString -> Python string
     */
	%typemap(out) UString, const UString
	%{  
		try{
			$result = PyString_FromString($1.ConvertToUtf8().c_str());
		}catch( ... )
		{
			$result =  PyString_FromString("");
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
			$1 = PyString_FromString($input.ConvertToUtf8().c_str());
		}catch( ... )
		{
			$1 = PyString_FromString("");
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
			$result = pdftron::UString(PyString_AsString($1));
		}
		else if (isUni$argnum) {
			PyObject* obj = PyUnicode_AsUTF8String($1);
			char* str = PyString_AsString(obj);
			$result = pdftron::UString(str);
			Py_DECREF(obj);
		}
	}
    
	/**
	 * Typemap between UString const & and Python string
	 */	
	%typemap(in) UString const &
	{  
		bool isStr$argnum = PyString_Check($input);
		bool isUni$argnum = PyUnicode_Check($input);
		UString* ustr$argnum = 0;
		if (!(isStr$argnum || isUni$argnum)) {
			PyErr_SetString(PyExc_ValueError,"Expected a String or a Unicode");
			return NULL;
		}
		if (isStr$argnum) {
			$1 = new pdftron::UString(PyString_AsString($input), -1, UString::e_utf8);
		}
		else if (isUni$argnum) {
			PyObject* obj = PyUnicode_AsUTF8String($input);
			char* str = PyString_AsString(obj);
			$1 = new pdftron::UString(str, -1, UString::e_utf8);
			Py_DECREF(obj);
		}
	}
	
	/**
	 * Checks the UStrings argument to ensure that the input is of the Unicode type.
	 */
	%typemap(typecheck,precedence=SWIG_TYPECHECK_UNISTRING) UString, const UString, UString const &
	%{
		$1 = (PyString_Check($input) ? 1 : 0) || (PyUnicode_Check($input) ? 1 : 0);
	%}
	
	/**
	 * Clean up the allocated UString within the above typemaps
	 */
	%typemap(freearg) UString const &
	%{
		if($1){	delete($1); $1 = 0; }
	%}
}
