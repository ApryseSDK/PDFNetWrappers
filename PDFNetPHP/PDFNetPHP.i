//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * PDFNetPHP.i
 * SWIG interface file for PHP
 */
%module(directors="1") PDFNetPHP
#if PHP_MAJOR_VERSION > 7
%feature("php:type", "0");
#endif

%rename (OCGConfig) pdftron::PDF::OCG::Config;
%rename(ListContainer) List;

%include "PDFNet_StdStringPHP.i"
/**
 * Different versions of UString typemap will be used pending
 * on the version of PHP
 */
%include "PDFNetUStringPHP.i"

/**
 * Catches all exceptions thrown by the C++ wrapper.
 * "$action" represents the C++ method to be called.
 */
%include "exception.i"
%exception {
    try {
        $action
    } catch(pdftron::Common::Exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.GetMessage());
    } catch(std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    } catch(...) {
        SWIG_exception(SWIG_RuntimeError, "Unknown error");
    }
}

/**
 * Text enclosed in the following %{...%} block is not processed by the SWIG preprocessor
 * They are copied directly to the .c/.cxx file generated.
 */
%{
    #include <iostream>
    // Fixes for compilation in Visual Studio 2010
    #ifdef _MSC_VER
        #include <iostream>
        #define strtoll _strtoi64
        #define strtoull _strtoi64
        #undef GetMessage
    #endif

    // header files from PDFNet SDK

    // header files in /PDFNetC/Headers/Common
    #include "Common/BasicTypes.h"
    #include "Common/Common.h"
    #include "Common/Exception.h"
    #include "Common/Iterator.h"
    #include "Common/Matrix2D.h"
    #include "Common/UString.h"

    // header files in /PDFNetC/Headers/FDF
    #include "FDF/FDFDoc.h"
    #include "FDF/FDFField.h"

    // header files in /PDFNetC/Headers/Filters
    #include "Filters/ASCII85Encode.h"
    #include "Filters/Filter.h"
    #include "Filters/FilterReader.h"
    #include "Filters/FilterWriter.h"
    #include "Filters/FlateEncode.h"
    #include "Filters/MappedFile.h"
    #include "Filters/MemoryFilter.h"

    // header files in /PDFNetC/Headers/PDF/Annots
    #include "PDF/Annots/Caret.h"
    #include "PDF/Annots/Circle.h"
    #include "PDF/Annots/FileAttachment.h"
    #include "PDF/Annots/FreeText.h"
    #include "PDF/Annots/Highlight.h"
    #include "PDF/Annots/Ink.h"
    #include "PDF/Annots/Line.h"
    #include "PDF/Annots/Link.h"
    #include "PDF/Annots/Markup.h"
    #include "PDF/Annots/Movie.h"
    #include "PDF/Annots/PolyLine.h"
    #include "PDF/Annots/Popup.h"
    #include "PDF/Annots/Redaction.h"
    #include "PDF/Annots/RubberStamp.h"
    #include "PDF/Annots/Screen.h"
    #include "PDF/Annots/Sound.h"
    #include "PDF/Annots/Square.h"
    #include "PDF/Annots/Squiggly.h"
    #include "PDF/Annots/StrikeOut.h"
    #include "PDF/Annots/Text.h"
    #include "PDF/Annots/TextMarkup.h"
    #include "PDF/Annots/Underline.h"
    #include "PDF/Annots/Watermark.h"
    #include "PDF/Annots/Widget.h"
    #include "PDF/Annots/SignatureWidget.h"
    #include "PDF/Annots/CheckBoxWidget.h"
    #include "PDF/Annots/PushButtonWidget.h"
    #include "PDF/Annots/TextWidget.h"
    #include "PDF/Annots/ComboBoxWidget.h"
    #include "PDF/Annots/ListBoxWidget.h"
    #include "PDF/Annots/RadioButtonWidget.h"
    #include "PDF/Annots/RadioButtonGroup.h"

    // header files in /PDFNetC/Headers/PDF/Image
    #include "PDF/Image/Image2RGB.h"
    #include "PDF/Image/Image2RGBA.h"

    // header files in /PDFNetC/Headers/PDF/OCG
    #include "PDF/OCG/Config.h"
    #include "PDF/OCG/Context.h"
    #include "PDF/OCG/Group.h"
    #include "PDF/OCG/OCMD.h"

    // header files in /PDFNetC/Headers/PDF/PDFA
    #include "PDF/PDFA/PDFACompliance.h"
    #include "PDF/PDFA/PDFAOptions.h"
    
    // header files in /PDFNetC/Headers/PDF/PDFUA
	#include "PDF/PDFUA/PDFUAConformance.h"
	#include "PDF/PDFUA/PDFUAOptions.h"

    // header files in /PDFNetC/Headers/PDF/Struct
    #include "PDF/Struct/AttrObj.h"
    #include "PDF/Struct/ClassMap.h"
    #include "PDF/Struct/ContentItem.h"
    #include "PDF/Struct/RoleMap.h"
    #include "PDF/Struct/SElement.h"
    #include "PDF/Struct/STree.h"

    // header files in /PDFNetC/Headers/PDF
    #include "PDF/Action.h"
    #include "PDF/Annot.h"
    #include "PDF/Annots.h"
    #include "PDF/Bookmark.h"
    #include "PDF/CharData.h"
    #include "PDF/ColorSpace.h"
    #include "PDF/ContentReplacer.h" 
    #include "PDF/Date.h"
    #include "PDF/Destination.h"
    #include "PDF/Element.h"
    #include "PDF/ElementBuilder.h"
    #include "PDF/ElementReader.h"
    #include "PDF/ElementWriter.h"
    #include "PDF/Field.h"
    #include "PDF/TimestampingResult.h"
    #include "PDF/TimestampingConfiguration.h"
    #include "Crypto/ObjectIdentifier.h"
    #include "Crypto/AlgorithmParams.h"
    #include "Crypto/AlgorithmIdentifier.h"
    #include "Crypto/RSASSAPSSParams.h"
    #include "Crypto/X501DistinguishedName.h"
    #include "Crypto/X501AttributeTypeAndValue.h"
    #include "Crypto/X509Extension.h"
    #include "Crypto/X509Certificate.h"
    #include "PDF/DisallowedChange.h"
    #include "PDF/VerificationOptions.h"
    #include "PDF/TrustVerificationResult.h"
    #include "PDF/VerificationResult.h"
    #include "PDF/EmbeddedTimestampVerificationResult.h"
    #include "Crypto/DigestAlgorithm.h"
    #include "Crypto/DigestAlgorithm.h"
    #include "PDF/DigitalSignatureField.h"
    #include "PDF/FileSpec.h"
    #include "PDF/Flattener.h"
    #include "PDF/PathData.h"
    #include "PDF/ShapedText.h"
    #include "PDF/Font.h"
    #include "PDF/Function.h"
    #include "PDF/GState.h"
    #include "PDF/Highlights.h"
    #include "PDF/TextRange.h"
    #include "PDF/HTML2PDF.h"
    #include "PDF/Image.h"
	#include "PDF/OCROptions.h"
	#include "PDF/OCRModule.h"
    #include "PDF/Optimizer.h"
    #include "PDF/Page.h"
    #include "PDF/PageLabel.h"
    #include "PDF/PageSet.h"
    #include "PDF/PatternColor.h"
    #include "PDF/PDFDC.h"
    #include "PDF/PDFDCEX.h"
    #include "PDF/PDFRasterizer.h"
    #include "PDF/ViewerOptimizedOptions.h"
    #include "PDF/ConversionOptions.h"
    #include "PDF/OfficeToPDFOptions.h"
    #include "PDF/WordToPDFOptions.h"
    #include "PDF/CADConvertOptions.h"
    #include "PDF/CADModule.h"
    #include "PDF/SVGConvertOptions.h"
    #include "PDF/DataExtractionOptions.h"
    #include "PDF/AdvancedImagingModule.h"
    #include "PDF/PDF2HtmlReflowParagraphsModule.h"
    #include "PDF/PDF2WordModule.h"
    #include "PDF/StructuredOutputModule.h"
    #include "PDF/RefreshOptions.h"
    #include "PDF/DocumentConversion.h"
    #include "PDF/TemplateDocument.h"
    #include "PDF/DiffOptions.h"
    #include "PDF/TextDiffOptions.h"
    #include "PDF/PDFDoc.h"
    #include "PDF/Convert.h"
    #include "PDF/DataExtractionModule.h"
    #include "PDF/PDFDocInfo.h"
    #include "PDF/PDFDocViewPrefs.h"
    #include "PDF/PDFDraw.h"
    #include "PDF/PDFNet.h"
    #include "PDF/PDFView.h"
    #include "PDF/Point.h"
    #include "PDF/Print.h"
    #include "PDF/QuadPoint.h"
    #include "PDF/Rect.h"
	#include "PDF/RectCollection.h"
    #include "PDF/Redactor.h"
    #include "PDF/Shading.h"
    #include "PDF/Stamper.h"
    #include "PDF/TextExtractor.h"
    #include "PDF/TextSearch.h"
    #include "PDF/WebFontDownloader.h"
    
    // header files in /PDFNetC/Headers/SDF
    #include "SDF/DictIterator.h"
    #include "SDF/NameTree.h"
    #include "SDF/NumberTree.h"
    #include "SDF/Obj.h"
    #include "SDF/ObjSet.h"
    #include "SDF/SDFDoc.h"
    #include "SDF/SecurityHandler.h"
    #include "SDF/PDFTronCustomSecurityHandler.h"
    #include "SDF/UndoManager.h"
    #include "SDF/ResultSnapshot.h"
    #include "SDF/DocSnapshot.h"
    
    // header files in /PDFNetC/Headers/Layout
    #include "Layout/FlowDocument.h"
    #include "Layout/ContentTree.h"

    using namespace pdftron;
    using namespace FDF;
    using namespace Filters;
    using namespace PDF;
    using namespace SDF;
    using namespace Annots;
    using namespace OCG;
    using namespace Struct;

    #undef GetMessage
    #undef SetPort
%}

/**
 * Provides mapping for C++ vectors.
 * For example, vector<double> will be called as VectorDouble in PHP.
 */
%include "std_string.i"
%include "std_vector.i"
namespace std {
   %template(VectorDouble) vector<double>;
   %template(VectorObj) vector<pdftron::SDF::Obj>;
   %template(VectorPage) vector<pdftron::PDF::Page>;
   %template(VectorUChar) vector<unsigned char>;
   %template(VectorChar) vector<char>;
   %template(VectorInt) vector<int>;
   %template(VectorUInt) vector<unsigned int>;
   //%template(VectorString) vector<std::string>;
   %template(VectorRedaction) vector<pdftron::PDF::Redaction>;
   %template(VectorQuadPoint) vector<pdftron::PDF::QuadPoint>;
   %template(VectorSeparation) vector<pdftron::PDF::Separation>;
   %template(VectorDisallowedChange) vector<pdftron::PDF::DisallowedChange>;
   %template(VectorAnnot) vector<pdftron::PDF::Annot>;
   %template(VectorX509Extension) vector<pdftron::Crypto::X509Extension>;
   %template(VectorX501AttributeTypeAndValue) vector<pdftron::Crypto::X501AttributeTypeAndValue>;
   %template(VectorX509Certificate) vector<pdftron::Crypto::X509Certificate>;
   %template(VectorByteRange) vector<pdftron::Common::ByteRange>;
   %template(VectorVectorX509Certificate) vector<vector<pdftron::Crypto::X509Certificate> >;

// Update: we obviously can't use PyInt_Check etc functions. TODO: find/write replacements in each language
//   // note that the c-style cast (to ValidationError) is pretty hax,
//   // only works because the lexicographical replacement works out in SWIG's generator impl.
//   // I'm not actually sure what the best way is to do more complex logic, declare a function?
//   specialize_std_vector(pdftron::PDF::PDFUA::PDFUAConformance::ValidationError, PyInt_Check, (pdftron::PDF::PDFUA::PDFUAConformance::ValidationError)PyInt_AsLong, PyInt_FromLong);
   %template(VectorValidationError) vector<pdftron::PDF::PDFUA::PDFUAConformance::ValidationError>;
};

/**
 * Forward declaration of some classes which helps solve circular dependency
 * issues. Circular dependency may occur, for example, when class A contains 
 * a method which refers to another class B, while class B has similar
 * dependecy on A. The following fixes this issue by telling SWIG the existance
 * of one of the classes.
 */
namespace pdftron {
	namespace Crypto
	{
        class DigestAlgorithm;
	}
    namespace PDF {
        class Font;
        class ColorPt;
        class Field;
		class PatternColor;
        class ViewerOptimizedOptions;
        class EmbeddedTimestampVerificationResult;
        class TrustVerificationResult;
        class ObjectIdentifier;
        namespace Struct {
            class SElement;
        }
    
        namespace OCG {
            class Context;
        }
    
        namespace Annots {
            class Markup;
        }
    }
}

//----------------------------------------------------------------------------------------------

// Typemapping
%include "typemaps.i"

/**
 * Action::CreateHideField
 * PHP array of strings to char** (map to String[] in java wrapper)
 */
%typemap (in) char** {

    HashTable *arr_hash;
    HashPosition pointer;
    int array_count;
    char ** result;
    int i = 0;
#if PHP_MAJOR_VERSION >= 7
	zval *data;
    	convert_to_array_ex(&$input);
        arr_hash = Z_ARRVAL_P(&$input);
        array_count = zend_hash_num_elements(arr_hash);

        for(zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    (data = zend_hash_get_current_data_ex(arr_hash, &pointer)) != NULL && i < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {

        if (Z_TYPE_P(data) == IS_STRING) {
            result[i] = Z_STRVAL_P(data);
           }
#else
	zval **data;
	convert_to_array_ex($input);
        arr_hash = Z_ARRVAL_PP($input);
        array_count = zend_hash_num_elements(arr_hash);

        for(zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    zend_hash_get_current_data_ex(arr_hash, (void**) &data, &pointer) == SUCCESS && i < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {

        if (Z_TYPE_PP(data) == IS_STRING) {
            result[i] = Z_STRVAL_PP(data);
           }
#endif
        else {
            zend_error(E_ERROR, "Expected a string");
        }
        i++;
    }
    $1 = result;
}

%typemap (typecheck) char** {
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_ARRAY ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_ARRAY ) ? 1 : 0;
#endif
}

//----------------------------------------------------------------------------------------------

/** 
 * Typemapping for enums
 * PHP can takes in an integer which is then converted to an enum
 * in the wrapper. The following mapping is needed because ErrorCode is
 * passed in as a pointer
 */
%typemap (in) pdftron::PDF::PDFA::PDFACompliance::ErrorCode* 
%{
    // converts python int to C long
#if PHP_MAJOR_VERSION >= 7
    convert_to_long_ex(&$input);
    $1 = (pdftron::PDF::PDFA::PDFACompliance::ErrorCode*)&Z_LVAL_P(&$input);
#else
    convert_to_long_ex($input);
    $1 = (pdftron::PDF::PDFA::PDFACompliance::ErrorCode*)&Z_LVAL_PP($input);
#endif
%}

%typemap (typecheck) pdftron::PDF::PDFA::PDFACompliance::ErrorCode* {
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_LONG ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_LONG ) ? 1 : 0;
#endif
}

//----------------------------------------------------------------------------------------------

/**
 * Treats volatile bool* as a regular bool*
 */
%apply bool* INPUT {volatile bool*}

//----------------------------------------------------------------------------------------------
/** 
 * Ignoring one of the overloaded methods
 */

%ignore pdftron::PDF::RectCollection::AddRect(double, double, double, double);

//----------------------------------------------------------------------------------------------


/**
 * Maps a PHP list of integers or strings to Unicode*
 */
%typemap(in) const pdftron::Unicode* text_data 
{ 
    
    HashTable *arr_hash;
    HashPosition pointer;
    int array_count;
    int i = 0;
#if PHP_MAJOR_VERSION >= 7
	zval *data;
    convert_to_array_ex(&$input);
    arr_hash = Z_ARRVAL_P(&$input);
    array_count = zend_hash_num_elements(arr_hash);

    pdftron::Unicode* $temp = new pdftron::Unicode[array_count];

    for (zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    (data = zend_hash_get_current_data_ex(arr_hash, &pointer)) != NULL && i < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {
        if (Z_TYPE_P(data) == IS_STRING) {
            $temp[i] = (pdftron::Unicode)*Z_STRVAL_P(data);
           }
        else if (Z_TYPE_P(data) == IS_LONG) {
            $temp[i] = (pdftron::Unicode)Z_LVAL_P(data);
        }
#else
	zval **data;
    convert_to_array_ex($input);
    arr_hash = Z_ARRVAL_PP($input);
    array_count = zend_hash_num_elements(arr_hash);

    pdftron::Unicode* $temp = new pdftron::Unicode[array_count];

    for (zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    zend_hash_get_current_data_ex(arr_hash, (void**) &data, &pointer) == SUCCESS && i < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {
        if (Z_TYPE_PP(data) == IS_STRING) {
            $temp[i] = (pdftron::Unicode)*Z_STRVAL_PP(data);
           }
        else if (Z_TYPE_PP(data) == IS_LONG) {
            $temp[i] = (pdftron::Unicode)Z_LVAL_PP(data);
        }
#endif
        else {
            zend_error(E_ERROR, "Expected a string or int");
        }
        i++;
    }
    $1 = (pdftron::Unicode *) $temp;
}

%typemap(typecheck) const pdftron::Unicode* text_data  {
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_ARRAY ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_ARRAY ) ? 1 : 0;
#endif
}

/**
 * clean up the allocated Unicode* within the above typemap
 */
%typemap(freearg) const pdftron::Unicode* text_data  
%{
	if($1){ delete[]($1); $1 = 0; }
%}

//----------------------------------------------------------------------------------------------

/**
 * Maps PHP array (of floats) to C++ vector<double>
 */
%typemap (in) std::vector<double> {

    HashTable *arr_hash;
    HashPosition pointer;
    int array_count;
    std::vector<double> $vec;
    int i = 0;

#if PHP_MAJOR_VERSION >= 7
    zval *data;
    convert_to_array_ex(&$input);
    arr_hash = Z_ARRVAL_P(&$input);
    array_count = zend_hash_num_elements(arr_hash);
    $vec.resize(array_count);

		for(zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    (data = zend_hash_get_current_data_ex(arr_hash, &pointer)) != NULL && i < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {

    if (Z_TYPE_P(data) == IS_DOUBLE) {
		$vec[i] = Z_DVAL_P(data);
	}
#else
	zval **data;
    convert_to_array_ex($input);
        arr_hash = Z_ARRVAL_PP($input);
        array_count = zend_hash_num_elements(arr_hash);
    $vec.resize(array_count);

        for(zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    zend_hash_get_current_data_ex(arr_hash, (void**) &data, &pointer) == SUCCESS && i < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {

        if (Z_TYPE_PP(data) == IS_DOUBLE) {
            $vec[i] = Z_DVAL_PP(data);
           }
#endif
        else {
            zend_error(E_ERROR, "Expected a double");
        }
        i++;
    }
    $1 = $vec;
}

/**
 * Maps PHP array (of floats) to C++ vector<double>&
 */
%typemap (in) std::vector<double>& {

      HashTable *arr_hash;
    HashPosition pointer;
    int array_count;

    int i$argnum = 0;
#if PHP_MAJOR_VERSION >= 7
    zval *data;
    convert_to_array_ex(&$input);
        arr_hash = Z_ARRVAL_P(&$input);
        array_count = zend_hash_num_elements(arr_hash);
    std::vector<double>* vec$argnum = new std::vector<double>(array_count);

        for(zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    (data = zend_hash_get_current_data_ex(arr_hash, &pointer)) != NULL && i$argnum < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {

        if (Z_TYPE_P(data) == IS_DOUBLE) {
            (*vec$argnum)[i$argnum] = Z_DVAL_P(data);
           }
#else
	zval **data;
    convert_to_array_ex($input);
        arr_hash = Z_ARRVAL_PP($input);
        array_count = zend_hash_num_elements(arr_hash);
    std::vector<double>* vec$argnum = new std::vector<double>(array_count);

        for(zend_hash_internal_pointer_reset_ex(arr_hash, &pointer); 
    zend_hash_get_current_data_ex(arr_hash, (void**) &data, &pointer) == SUCCESS && i$argnum < array_count; 
    zend_hash_move_forward_ex(arr_hash, &pointer)) {

        if (Z_TYPE_PP(data) == IS_DOUBLE) {
            (*vec$argnum)[i$argnum] = Z_DVAL_PP(data);
           }
#endif
        else {
            zend_error(E_ERROR, "Expected a double");
        }
        i$argnum++;
    }
    $1 = vec$argnum;
}

%typemap(out) std::vector<double> {
    array_init($result);
    int i;
    for (i = 0; i < $1.size(); i++) {
        add_next_index_double($result, $1[i]);
    }
}

%typemap(typecheck) std::vector<double>, std::vector<double>&  {
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_ARRAY ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_ARRAY ) ? 1 : 0;
#endif
}

%typemap(freearg) std::vector<double>&
%{
	if($1){	delete($1);$1 = 0;}
%}

//----------------------------------------------------------------------------------------------

/**
 * Maps PHP String to unsigned char *
 */

%typemap(in) unsigned char *
%{  
#if PHP_MAJOR_VERSION >= 7
    convert_to_string_ex(&$input);
    $1 = (unsigned char*)Z_STRVAL_P(&$input);
#else
    convert_to_string_ex($input);
    $1 = (unsigned char*)Z_STRVAL_PP($input);
#endif
%}

%typemap(typecheck) unsigned char *  {
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_STRING ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_STRING ) ? 1 : 0;
#endif
}

%typemap(out) std::vector<unsigned char> {
#if PHP_MAJOR_VERSION >= 7
    ZVAL_STRINGL($result, (const char*)&$1[0], $1.size());
#else
    ZVAL_STRINGL($result, (const char*)&$1[0], $1.size(), 1);
#endif
}

//----------------------------------------------------------------------------------------------
/**
 * Maps PHP String to std::vector<unsigned char>
 */

%typemap(in) std::vector<unsigned char>
{  
#if PHP_MAJOR_VERSION >= 7
    convert_to_string_ex(&$input);
    unsigned char* temp = (unsigned char*)Z_STRVAL_P(&$input);
    $1.resize(Z_STRLEN_P(&$input));
    memcpy(&$1[0], temp, Z_STRLEN_P(&$input));
#else
    convert_to_string_ex($input);
    unsigned char* temp = (unsigned char*)Z_STRVAL_PP($input);
    $1.resize(Z_STRLEN_PP($input));
    memcpy(&$1[0], temp, Z_STRLEN_PP($input));
#endif
}

%typemap(in) const std::vector<unsigned char>&
{
#if PHP_MAJOR_VERSION >= 7
    convert_to_string_ex(&$input);
    unsigned char* temp = (unsigned char*)Z_STRVAL_P(&$input);
    $1 = new std::vector<unsigned char>();
    $1->resize(Z_STRLEN_P(&$input));
    memcpy(&((*$1)[0]), temp, Z_STRLEN_P(&$input));
#else
    convert_to_string_ex($input);
    unsigned char* temp = (unsigned char*)Z_STRVAL_PP($input);
    $1 = new std::vector<unsigned char>();
    $1->resize(Z_STRLEN_PP($input));
    memcpy(&((*$1)[0]), temp, Z_STRLEN_PP($input));
#endif
}

%typemap(typecheck) std::vector<unsigned char>
{
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_STRING ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_STRING ) ? 1 : 0;
#endif
}

%typemap(typecheck) const std::vector<unsigned char>&
{
#if PHP_MAJOR_VERSION >= 7
    $1 = ( Z_TYPE_P(&$input) == IS_STRING ) ? 1 : 0;
#else
    $1 = ( Z_TYPE_PP($input) == IS_STRING ) ? 1 : 0;
#endif
}

/**
 * Typemap for directors
 */
/* std::vector<unsigned char> -> PHP string */
%typemap(directorin) std::vector<unsigned char>
{
#if PHP_MAJOR_VERSION >= 7
    ZVAL_STRINGL($1, (const char*) &($input[0]), $input.size());
#else
    ZVAL_STRINGL($1, (const char*) &($input[0]), $input.size(), 1);
#endif
}
/* PHP string -> std::vector<unsigned char> */
%typemap(directorout) std::vector<unsigned char>
{
#if PHP_MAJOR_VERSION >= 7
    convert_to_string_ex($1);
    unsigned char* temp = (unsigned char*) Z_STRVAL_P($1);
    $result.resize(Z_STRLEN_P($1));
    memcpy(&($result[0]), temp, Z_STRLEN_P($1));
#else
    convert_to_string_ex(&$1);
    unsigned char* temp = (unsigned char*) Z_STRVAL_PP(&$1);
    $result.resize(Z_STRLEN_PP(&$1));
    memcpy(&($result[0]), temp, Z_STRLEN_PP(&$1));
#endif
}
/* const std::vector<unsigned char>& -> PHP string */
%typemap(directorin) const std::vector<unsigned char>&
{
#if PHP_MAJOR_VERSION >= 7
    ZVAL_STRINGL($input, (const char*) &($1_name[0]), $1_name.size());
#else
    ZVAL_STRINGL($input, (const char*) &($1_name[0]), $1_name.size(), 1);
#endif
}

%typemap(freearg) const std::vector<unsigned char>&
%{
    if($1){ delete($1); $1 = 0; }
%}

//----------------------------------------------------------------------------------------------
/**
 * Typemap to ensure Python None is returned if a C++ function returns NULL.
 * Without the following, SWIG would wrap the NULL object, causing the following
 * PHP statement: nullElement == null, to be false.
 */
%typemap(out) pdftron::PDF::Element 
%{  
    if ($1) {
        pdftron::PDF::Element * resultobj = new pdftron::PDF::Element((const pdftron::PDF::Element &) result);
            SWIG_SetPointerZval(return_value, (void *)resultobj, SWIGTYPE_p_pdftron__PDF__Element, 1);
        return;
    }
%}

%typemap(out) pdftron::SDF::Obj 
%{  
    if ($1) {
        pdftron::SDF::Obj * resultobj = new pdftron::SDF::Obj((const pdftron::SDF::Obj &) result);
            SWIG_SetPointerZval(return_value, (void *)resultobj, SWIGTYPE_p_pdftron__SDF__Obj, 1);
        return;
    }
%}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::ContentNode> {
    if ($1.IsValid()) {
        pdftron::Layout::ContentNode* resultobj = new pdftron::Layout::ContentNode($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__ContentNode, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::Paragraph> {
    if ($1.IsValid()) {
        pdftron::Layout::Paragraph* resultobj = new pdftron::Layout::Paragraph($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__Paragraph, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::TextRun> {
    if ($1.IsValid()) {
        pdftron::Layout::TextRun* resultobj = new pdftron::Layout::TextRun($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__TextRun, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::Table> {
    if ($1.IsValid()) {
        pdftron::Layout::Table* resultobj = new pdftron::Layout::Table($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__Table, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::TableRow> {
    if ($1.IsValid()) {
        pdftron::Layout::TableRow* resultobj = new pdftron::Layout::TableRow($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__TableRow, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::TableCell> {
    if ($1.IsValid()) {
        pdftron::Layout::TableCell* resultobj = new pdftron::Layout::TableCell($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__TableCell, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::List> {
    if ($1.IsValid()) {
        pdftron::Layout::List* resultobj = new pdftron::Layout::List($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__List, 1);
    }
}

%typemap(out) pdftron::Layout::ElementRef<pdftron::Layout::ListItem> {
    if ($1.IsValid()) {
        pdftron::Layout::ListItem* resultobj = new pdftron::Layout::ListItem($1.GetElement());
        SWIG_SetPointerZval(return_value, (void*) resultobj, SWIGTYPE_p_pdftron__Layout__ListItem, 1);
    }
}

/**
 * Mapping of C++ vector<int> to PHP array
 */
%typemap(out) std::vector<int> {
    array_init($result);
    int i;
    for (i = 0; i < $1.size(); i++) {
        add_next_index_long($result, $1[i]);
    }
}

//----------------------------------------------------------------------------------------------
/**
 * Typemap for function pointers
 */

/**
 * Turns on the director feature for the following classes.
 * C++ equivalent of a proxy class. User extends this class in Python
 * and overrides the virtual functions of interest. These functions can
 * then be called from C++. 
 */
%feature("director") Callback;
%{
#include <PDF/Selection.h>
#include <PDF/Callback.h>
%}
%include <PDF/Selection.h>
%include <PDF/Callback.h>

%feature("director") SignatureHandler;
%{
#include <SDF/SignatureHandler.h>
%}
%include <SDF/SignatureHandler.h>

/*
// This block can be uncommented if we want to throw an exception for director class
// related errors.
%feature("director:except") {
    if ($error != NULL) {
        throw Swig::DirectorMethodException();
    }
}
*/

//----------------------------------------------------------------------------------------------
// Fixes overloaded methods

%rename (WriteInt16) pdftron::Filters::FilterWriter::WriteInt(Int16);
%rename (WriteInt32) pdftron::Filters::FilterWriter::WriteInt(Int32);
%rename (WriteInt64) pdftron::Filters::FilterWriter::WriteInt(Int64);
%rename (WriteUInt16) pdftron::Filters::FilterWriter::WriteInt(UInt16);
%rename (WriteUInt32) pdftron::Filters::FilterWriter::WriteInt(UInt32);
%rename (WriteUInt64) pdftron::Filters::FilterWriter::WriteInt(UInt64);
%rename (IsEqual) operator==;

// rename overridden methods of different signatures from base', which causes fatal errors in PHP8
#if PHP_MAJOR_VERSION > 7
%ignore pdftron::PDF::Annots::Popup::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::FileAttachment::Create(SDF::SDFDoc&, const Rect&, FileSpec);
%ignore pdftron::PDF::Annots::FileAttachment::Create(SDF::SDFDoc&, const Rect&, FileSpec, Icon);
%ignore pdftron::PDF::Annots::FileAttachment::Create(SDF::SDFDoc&, const Rect&, const UString&);
%ignore pdftron::PDF::Annots::FileAttachment::Create(SDF::SDFDoc&, const Rect&, const UString&, Icon);
%ignore pdftron::PDF::Annots::FileAttachment::Create(SDF::SDFDoc&, const Rect&, const UString&, const char*);
%ignore pdftron::PDF::Annots::Ink::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Circle::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Caret::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Caret::Create(SDF::SDFDoc&, const Rect&, Rect);
%ignore pdftron::PDF::Annots::HighlightAnnot::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::LineAnnot::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::FreeText::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Movie::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::RedactionAnnot::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Screen::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Square::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Squiggly::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::StrikeOut::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Underline::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Watermark::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::RubberStamp::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::RubberStamp::Create(SDF::SDFDoc&, const Rect&, Icon);
%ignore pdftron::PDF::Annots::Sound::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Sound::Create(SDF::SDFDoc&, const Rect&, Icon);
%ignore pdftron::PDF::Annots::Sound::Create(SDF::SDFDoc&, const Point&);
%ignore pdftron::PDF::Annots::Sound::Create(SDF::SDFDoc&, const Point&, Icon);
%ignore pdftron::PDF::Annots::Text::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Text::Create(SDF::SDFDoc&, const Rect&, const UString&);
%ignore pdftron::PDF::Annots::Text::Create(SDF::SDFDoc&, const Point&);
%ignore pdftron::PDF::Annots::Text::Create(SDF::SDFDoc&, const Point&, const UString&);
%ignore pdftron::PDF::Annots::Link::Create(SDF::SDFDoc&, const Rect&);
%ignore pdftron::PDF::Annots::Link::Create(SDF::SDFDoc&, const Rect&, const Action&);
#endif
//----------------------------------------------------------------------------------------------
// Fixes the python not recognizing default arguments problem
// Instead of generating overloaded method for default arguments, only a single method
// is generated.
%feature("compactdefaultargs") pdftron::PDF::ElementBuilder::Reset;
%feature("compactdefaultargs") pdftron::PDF::Rect::Update;

//----------------------------------------------------------------------------------------------

// header files in /PDFNetC/Headers/Common
%include "C/Common/TRN_BasicTypes.h"
%include "Common/BasicTypes.h"
%include "Common/Common.h"
%import "Common/Iterator.h"
%include "Common/Matrix2D.h"

// Header files from other folders are included after the nested class workaround

//----------------------------------------------------------------------------------------------

// Similar to the vector mapping done earlier. The following maps the 
// iterators to the names indicated within ().
// This section needs to be implemented **AFTER** Iterator.h is wrapper. 
// Otherwise, SWIG will not recognize the Iterator class

%template (GSChangesIterator) pdftron::Common::Iterator<int>;
%template (UInt32Iterator) pdftron::Common::Iterator<unsigned int>;
%template (PageIterator) pdftron::Common::Iterator<pdftron::PDF::Page>; 
%template (FDFFieldIterator) pdftron::Common::Iterator<pdftron::FDF::FDFField>;
%template (FieldIterator) pdftron::Common::Iterator<pdftron::PDF::Field>;
%template (CharIterator) pdftron::Common::Iterator<TRN_CharData>;
%template (DigitalSignatureFieldIterator) pdftron::Common::Iterator<pdftron::PDF::DigitalSignatureField>;
%template (ContentNodeIterator) pdftron::Common::Iterator<pdftron::Layout::ContentElement>;

//----------------------------------------------------------------------------------------------


// Include the remaining header files

%include "Filters/Filter.h"
%include "Filters/ASCII85Encode.h"
%include "Filters/FilterReader.h"
%include "Filters/FilterWriter.h"
%include "Filters/FlateEncode.h"
%include "Filters/MappedFile.h"
%include "Filters/MemoryFilter.h"
%include "SDF/DictIterator.h"
%include "SDF/SDFDoc.h"
%include "SDF/NameTree.h"
%include "SDF/NumberTree.h"
%include "SDF/Obj.h"
%include "SDF/ObjSet.h"
%include "SDF/DocSnapshot.h"
%include "SDF/ResultSnapshot.h"
%include "SDF/UndoManager.h"
#define Clone CloneHandler
%include "SDF/SecurityHandler.h"
%include "SDF/PDFTronCustomSecurityHandler.h"
#undef
%include "PDF/Point.h"
#define Function PDFFunction
#define Eval EvalFunction
%include "PDF/Function.h"
#undef Eval
#undef Function
%include "PDF/ColorSpace.h"
%include "PDF/Rect.h"
%include "PDF/RectCollection.h"
%include "PDF/Page.h"
%include "PDF/Date.h"
%include "PDF/Field.h"
%include "PDF/TimestampingResult.h"
%include "PDF/TimestampingConfiguration.h"
%include "Crypto/ObjectIdentifier.h"
%include "Crypto/AlgorithmParams.h"
%include "Crypto/AlgorithmIdentifier.h"
%include "Crypto/RSASSAPSSParams.h"
%include "Crypto/X501DistinguishedName.h"
%include "Crypto/X501AttributeTypeAndValue.h"
%include "Crypto/X509Extension.h"
%include "Crypto/X509Certificate.h"
%include "PDF/DisallowedChange.h"
%include "FDF/FDFField.h"
%include "FDF/FDFDoc.h"
%include "PDF/VerificationOptions.h"
%include "PDF/TrustVerificationResult.h"
%include "PDF/VerificationResult.h"
%include "PDF/EmbeddedTimestampVerificationResult.h"
%include "Crypto/DigestAlgorithm.h"
%include "PDF/CMSSignatureOptions.h"
%include "PDF/DigitalSignatureField.h"
%include "PDF/FileSpec.h"
%include "PDF/Flattener.h"
%include "PDF/RefreshOptions.h"
%include "PDF/Annot.h"
%include "PDF/Annots/Popup.h"
%include "PDF/Annots/Markup.h"
%include "PDF/Annots/FileAttachment.h"
%include "PDF/QuadPoint.h"
%include "PDF/Annots/TextMarkup.h"
%include "PDF/Annots/Ink.h"
%include "PDF/Destination.h"
%include "PDF/Action.h"
%include "PDF/PageSet.h"
%include "PDF/OCG/Config.h"
%include "PDF/OCG/Group.h"
%include "PDF/OCG/Context.h"
%include "PDF/OCG/OCMD.h"
%include "PDF/PDFA/PDFAOptions.h"
%include "PDF/PDFA/PDFACompliance.h"
%include "PDF/PDFUA/PDFUAConformance.h"
%include "PDF/PDFUA/PDFUAOptions.h"
%include "PDF/Struct/AttrObj.h"
%include "PDF/Struct/ClassMap.h"
%include "PDF/Struct/ContentItem.h"
%include "PDF/Struct/RoleMap.h"
%include "PDF/Struct/STree.h"
%include "PDF/Struct/SElement.h"
%include "PDF/Bookmark.h"
%include "PDF/CharData.h"
%include "PDF/ContentReplacer.h"
%include "PDF/DiffOptions.h"
%include "PDF/TextDiffOptions.h"
%include "PDF/ConversionOptions.h"
%include "PDF/OfficeToPDFOptions.h"
%include "PDF/WordToPDFOptions.h"
%include "PDF/DocumentConversion.h"
%include "PDF/TemplateDocument.h"
%include "PDF/CADConvertOptions.h"
%include "PDF/SVGConvertOptions.h"
%include "PDF/DataExtractionOptions.h"
%include "PDF/Convert.h"
%include "PDF/DataExtractionModule.h"
%include "PDF/PathData.h"
%include "PDF/ShapedText.h"
%include "PDF/Font.h"
%include "PDF/Shading.h"
%include "PDF/PatternColor.h"
%include "PDF/GState.h"
%include "PDF/Image.h"
%include "PDF/PageLabel.h"
%include "PDF/PDFRasterizer.h"
%include "PDF/ViewerOptimizedOptions.h"
%include "PDF/PDFDocViewPrefs.h"
%include "PDF/PDFDocInfo.h"
%include "PDF/PDFDoc.h"

%include "PDF/Annots.h"
%include "PDF/Annots/Caret.h"
%include "PDF/Annots/Circle.h"
%include "PDF/Annots/Highlight.h"
%include "PDF/Annots/Line.h"
%include "PDF/Annots/FreeText.h"
%include "PDF/Annots/Link.h"
%include "PDF/Annots/Movie.h"
%include "PDF/Annots/PolyLine.h"
%include "PDF/Annots/Redaction.h"
%include "PDF/Annots/RubberStamp.h"
%include "PDF/Annots/Screen.h"
%include "PDF/Annots/Sound.h"
%include "PDF/Annots/Square.h"
%include "PDF/Annots/Squiggly.h"
%include "PDF/Annots/StrikeOut.h"
%include "PDF/Annots/Text.h"
%include "PDF/Annots/Underline.h"
%include "PDF/Annots/Watermark.h"
%include "PDF/Annots/Widget.h"
%include "PDF/Annots/SignatureWidget.h"
%include "PDF/Annots/CheckBoxWidget.h"
%include "PDF/Annots/PushButtonWidget.h"
%include "PDF/Annots/TextWidget.h"
%include "PDF/Annots/ComboBoxWidget.h"
%include "PDF/Annots/ListBoxWidget.h"
%include "PDF/Annots/RadioButtonWidget.h"
%include "PDF/Annots/RadioButtonGroup.h"
%include "PDF/Element.h"
%include "PDF/ElementBuilder.h"
%include "PDF/ElementReader.h"
%include "PDF/ElementWriter.h"
%include "PDF/Image/Image2RGB.h"
%include "PDF/Image/Image2RGBA.h"

//Rename to prevent naming conflict between nested class Highlight and Highlight.h
%include "PDF/Highlights.h"
%include "PDF/TextRange.h"
%include "PDF/OCROptions.h"
%include "PDF/OCRModule.h"
%include "PDF/CADModule.h"
%include "PDF/AdvancedImagingModule.h"
%include "PDF/PDF2HtmlReflowParagraphsModule.h"
%include "PDF/PDF2WordModule.h"
%include "PDF/StructuredOutputModule.h"
%include "PDF/Optimizer.h"
%include "PDF/PDFDC.h"
%include "PDF/PDFDCEX.h"
%include "PDF/PDFDraw.h"
%include "PDF/WebFontDownloader.h"
%include "Layout/ContentTree.h"
%include "Layout/FlowDocument.h"

// The Ref tyoes are not used (automatically converted to either null or the underlying object)
// but we still need to difine them so they are handled correctly.
%template (ContentNodeRef) pdftron::Layout::ElementRef<pdftron::Layout::ContentNode>;
%template (ParagraphRef) pdftron::Layout::ElementRef<pdftron::Layout::Paragraph>;
%template (TextRunRef) pdftron::Layout::ElementRef<pdftron::Layout::TextRun>;
%template (TableRef) pdftron::Layout::ElementRef<pdftron::Layout::Table>;
%template (TableRowRef) pdftron::Layout::ElementRef<pdftron::Layout::TableRow>;
%template (TableCellRef) pdftron::Layout::ElementRef<pdftron::Layout::TableCell>;
%template (ListRef) pdftron::Layout::ElementRef<pdftron::Layout::List>;
%template (ListItemRef) pdftron::Layout::ElementRef<pdftron::Layout::ListItem>;

//Extend Initialize method to call overloaded one internally
%extend pdftron::PDFNet{
        public:
        static void Initialize(const char* license_key = 0) { 
            pdftron::PDFNet::Initialize(license_key, "{\"language\": \"PHP\"}");
        }
}
%ignore pdftron::PDFNet::Initialize(const char* license_key = 0);

//Extend Terminate method to call overloaded one internally
%extend pdftron::PDFNet{
        public:
        static void Terminate() {
            pdftron::PDFNet::Terminate(1);
        }
}
%ignore pdftron::PDFNet::Terminate();

%include "PDF/PDFNet.h"
%include "PDF/PDFView.h"
#define Print PDFPrint
%include "PDF/Print.h"
#undef Print
%include "PDF/HTML2PDF.h"
%include "PDF/Stamper.h"

//Rename to prevent naming conflict against Line.h
%include "PDF/TextExtractor.h"

%include "PDF/TextSearch.h"

//Rename to prevent naming conflict between nested class Redaction and Redaction.h
//#define Redaction Redaction
%include "PDF/Redactor.h"
//#undef Redaction
