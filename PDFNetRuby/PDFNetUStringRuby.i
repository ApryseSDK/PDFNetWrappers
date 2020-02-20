//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2020 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * Typemap for UString from and to Ruby standard strings.
 */

%{
	#include <string>
    #include <ruby/encoding.h>
%}
namespace pdftron {
	class UString;

	/**
	 * Typemap between UString/const UString and Python string
	 */
	%typemap(in) UString, const UString
	{
		char* str = StringValuePtr($input);
		$1 = UString(str);
	}

	%typemap(out) UString, const UString
	%{  
        /* int enc = rb_enc_find_index("UTF-8"); */
		$result = rb_enc_associate_index(rb_str_new2($1.ConvertToUtf8().c_str()), rb_enc_find_index("UTF-8"));
	%}

	/**
	 * Typemap between UString const & and Python string
	 */	
	%typemap(in) UString const &
	{  
		char* str = StringValuePtr($input);
		$1 = new UString(str);
	}
	
    
    /**
     * directorout/directorin typemaps maps types for directors (C++ classes that can be extended/inherited in Python)
     */
    /* UString -> Ruby string */
	%typemap(directorin) UString, const UString
    {
        $1 = rb_enc_associate_index(rb_str_new2($input.ConvertToUtf8().c_str()), rb_enc_find_index("UTF-8"));
    }
    /* Ruby string -> UString */
    %typemap(directorout) UString, const UString
    {
		char* str = StringValuePtr($1);
		$result = UString(str);
    }
    
	/**
	 * Checks the UStrings argument to ensure that the input is of the Unicode type.
	 */
	%typemap(typecheck,precedence=SWIG_TYPECHECK_UNISTRING) UString, const UString, UString const &
	%{
		if (rb_type($input) == T_STRING) {
			$1 = 1;
		}
		else {
			$1 = 0;
		}
	%}
	
	/**
	 * Clean up the allocated UString within the above typemaps
	 */
	%typemap(freearg) UString const &
	%{
		delete($1);
	%}
}
