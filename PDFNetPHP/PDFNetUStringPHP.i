//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * Typemap for UString from and to PHP standard strings.
 */

%{
	#include <string>
%}

namespace pdftron {
	class UString;

	/**
	 * Typemap between UString/const UString and Python string
	 */
	%typemap(in) UString, const UString
	{  
#if PHP_MAJOR_VERSION >= 7
		convert_to_string_ex(&$input);
		char* temp$argnum = Z_STRVAL_P(&$input);
#else
		convert_to_string_ex($input);
		char* temp$argnum = Z_STRVAL_PP($input);
#endif
		$1 = UString(temp$argnum);
	}

	%typemap(out) UString, const UString
	{  
		std::string temp$argnum = $1.ConvertToUtf8();
#if PHP_MAJOR_VERSION >= 7
		ZVAL_STRINGL($result, const_cast<char*>(temp$argnum.data()), temp$argnum.size());
#else
		ZVAL_STRINGL($result, const_cast<char*>(temp$argnum.data()), temp$argnum.size(), 1);
#endif
	}

	/**
	 * Typemap between UString const & and Python string
	 */	
	%typemap(in) UString const &
	{  		
#if PHP_MAJOR_VERSION >= 7	
		convert_to_string_ex(&$input);
		char* temp$argnum = Z_STRVAL_P(&$input);
#else
		convert_to_string_ex($input);
		char* temp$argnum = Z_STRVAL_PP($input);
#endif
		$1 = new UString(temp$argnum);
	}
	
	/**
	 * Checks the UStrings argument to ensure that the input is of the Unicode type.
	 */
	%typemap(typecheck,precedence=SWIG_TYPECHECK_UNISTRING) UString, const UString, UString const &
	%{
#if PHP_MAJOR_VERSION >= 7	
		$1 = ( Z_TYPE_P(&$input) == IS_STRING ) ? 1 : 0;
#else
		$1 = ( Z_TYPE_PP($input) == IS_STRING ) ? 1 : 0;
#endif
	%}
	
	/**
	 * Clean up the allocated UString within the above typemaps
	 */
	%typemap(freearg) UString const &
	%{
		delete($1);
	%}
    
    /**
     * directorout/directorin typemaps maps types for directors (C++ classes that can be extended/inherited in PHP)
     */
    /* UString -> PHP string */
	%typemap(directorin) UString, const UString
	%{
        std::string temp$argnum = $input.ConvertToUtf8();
#if PHP_MAJOR_VERSION >= 7
		ZVAL_STRINGL($1, const_cast<char*>(temp$argnum.data()), temp$argnum.size());
#else
		ZVAL_STRINGL($1, const_cast<char*>(temp$argnum.data()), temp$argnum.size(), 1);
#endif
	%}
    
    /* PHP string -> UString */
	%typemap(directorout) UString, const UString
	{
#if PHP_MAJOR_VERSION >= 7
		convert_to_string_ex($1);
		char* temp$argnum = Z_STRVAL_P($1);
#else
		convert_to_string_ex(&$1);
		char* temp$argnum = Z_STRVAL_PP(&$1);
#endif
		$result = UString(temp$argnum);
	}
}
