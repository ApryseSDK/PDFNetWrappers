//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * Typemap for UString from and to Go standard strings.
 */

%{
	#include <string>
%}

namespace pdftron {
	class UString;
	%typemap(gotype) UString, const UString, const UString & %{string%}

	/**
	 * Typemap from Golang string to UString/const UString
	 */
	%typemap(in) UString, const UString
	%{  
		{
			std::string str;
			str.assign($input.p, $input.n);
			$1 = UString(str.c_str());
		}
	%}

	/**
	 * Typemap from Golang string to UString const &
	 */
	%typemap(in) UString const &
	%{
		{
			std::string str;
			str.assign($input.p, $input.n);
			$1 = new UString(str.c_str());
		}
	%}

	/**
	 * Typemap from UString/const UString to Golang string
	 */
	%typemap(out) UString, const UString
	%{  
		{
			std::string str = $1.ConvertToUtf8();
			_gostring_ ret;
			ret.p = (char*)malloc(str.length());
			memcpy(ret.p, str.c_str(), str.length());
			ret.n = str.length();
			$result = ret;
		}
	%}

	%typemap(out) const UString &
	%{ 
		{
			std::string str = $1->ConvertToUtf8();
			_gostring_ ret;
			ret.p = (char*)malloc(str.length());
			memcpy(ret.p, str.c_str(), str.length());
			ret.n = str.length();
			$result = ret;
		}
	%}
	
	/**
	 * Clean up the allocated UString within the above typemaps
	 */
	%typemap(freearg) UString const &
	%{
		delete($1);
	%}

	%typemap(freearg) const char*&
	%{
		free(*$1);
	%}

    /**
     * directorout typemaps maps types for directors (C++ classes that can be extended/inherited in Golang)
     */

    /* Golang string -> UString */
	%typemap(directorout) UString, const UString
	{
		{
			std::string str;
			str.assign($input.p, $input.n);
			$result = UString(str.c_str());
		}
	}
}
