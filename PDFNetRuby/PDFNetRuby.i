//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * PDFNetRuby.i
 * SWIG interface file for Ruby
 */

%module(directors="1") PDFNetRuby

/**
 * Includes UString mapping for Ruby
 */
%include "PDFNetUStringRuby.i"

/**
 * Catches all exceptions thrown by the C++ wrapper.
 * "$action" represents the C++ method to be called.
 */
%include "exception.i"
%exception {
    try {
        $action
    }
    catch (pdftron::Common::Exception& e) {
        rb_raise(rb_eStandardError, "PDFNet Exception: %s", e.GetMessage());
    }
    catch (...) {
        rb_raise(rb_eStandardError, "Non-PDFNet Exception");
    } 
}

/**
 * Text enclosed in the following %{...%} block is not processed by the SWIG preprocessor
 * They are copied directly to the .c/.cxx file generated.
 */
%{
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

    // header files in /PDFNetC/Headers/PDF/PDfA
    #include "PDF/PDFA/PDFACompliance.h"

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
    #include "PDF/Convert.h"
    #include "PDF/Date.h"
    #include "PDF/Destination.h"
    #include "PDF/Element.h"
    #include "PDF/ElementBuilder.h"
    #include "PDF/ElementReader.h"
    #include "PDF/ElementWriter.h"
    #include "PDF/Field.h"
    #include "PDF/DigitalSignatureField.h"
    #include "PDF/FileSpec.h"
    #include "PDF/Flattener.h"
    #include "PDF/PathData.h"
    #include "PDF/Font.h"
    #include "PDF/Function.h"
    #include "PDF/GState.h"
    #include "PDF/Highlights.h"
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
    #include "PDF/PDFDoc.h"
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

    // header files in /PDFNetC/Headers/SDF
    #include "SDF/DictIterator.h"
    #include "SDF/NameTree.h"
    #include "SDF/NumberTree.h"
    #include "SDF/Obj.h"
    #include "SDF/ObjSet.h"
    #include "SDF/SDFDoc.h"
    #include "SDF/SecurityHandler.h"
    #include "SDF/UndoManager.h"
    #include "SDF/ResultSnapshot.h"
    #include "SDF/DocSnapshot.h"

    using namespace pdftron;
    using namespace FDF;
    using namespace Filters;
    using namespace PDF;
    using namespace SDF;
    using namespace Annots;
    using namespace OCG;
    using namespace Struct;

   
%}

/**
 * Provides mapping for C++ vectors.
 * For example, vector<double> can be called as VectorDouble in Ruby.
 * By default, the std_vector.i file maps all std::vectors to Ruby arrays.
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
   %template(VectorString) vector<std::string>;
   %template(VectorRedaction) vector<pdftron::PDF::Redaction>;
   %template(VectorQuadPoint) vector<pdftron::PDF::QuadPoint>;
   %template(VectorSeparation) vector<pdftron::PDF::Separation>;
   %template(VectorAnnot) vector<pdftron::PDF::Annot>;
};

/**
 * Forward declaration of some classes which helps solve circular dependency
 * issues. Circular dependency may occur, for example, when class A contains 
 * a method which refers to another class B, while class B has similar
 * dependecy on A. The following fixes this issue by telling SWIG the existance
 * of one of the classes.
 */
namespace pdftron {
    namespace PDF {
        class Font;
        class ColorPt;
        class Field;
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
 * Ruby array of strings to char** (map to String[] in java wrapper)
 */
%typemap (in) char** {
    int size = RARRAY_LEN($input);
    char** arr;

    int i = 0;
    for (i = 0; i < size; i++) {
        VALUE val = rb_ary_entry($input, i);
        if (rb_type(val) == T_STRING) {
            arr[i] = (char*)(StringValuePtr(val));
        }
        else {
            rb_raise(rb_eStandardError, "Expected an array of Strings");
            return Qnil;
        }
    }

    $1 = arr;
}

%typemap (typecheck) char** {
    if (rb_type($input) == T_ARRAY) {
        $1 = 1;
    }
    else {
        $1 = 0;
    }
}

//----------------------------------------------------------------------------------------------

/** 
 * Typemapping for enums
 * Ruby can take in an integer which is then converted to an enum
 * in the wrapper. The following mapping is needed because ErrorCode is
 * passed in as a pointer.
 */
%typemap (in) pdftron::PDF::PDFA::PDFACompliance::ErrorCode* 
%{
    // converts python int to C long
    $1 = (pdftron::PDF::PDFA::PDFACompliance::ErrorCode*)NUM2INT($input);
%}

%typemap (typecheck) pdftron::PDF::PDFA::PDFACompliance::ErrorCode* {
    $1 = FIXNUM_P($input) ? 1 : 0;
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
 * Maps a Ruby array of integers or strings to Unicode*
 */
%typemap(in) const pdftron::Unicode* text_data 
{
    int size = RARRAY_LEN($input);
    pdftron::Unicode* $temp = new pdftron::Unicode[size];
    int i;
    for (i = 0; i < size; i++) {
        VALUE val = rb_ary_entry($input, i);
        if (rb_type(val) == T_STRING) {
            $temp[i] = (Unicode)(*StringValuePtr(val));
        }
        else if (FIXNUM_P(val)) {
            $temp[i] = FIX2INT(val);
        }
    }
    $1 = $temp;
}

%typemap(typecheck) const pdftron::Unicode* text_data
{
    if (rb_type($input) == T_ARRAY) {
        $1 = 1;
    }
    else {
        $1 = 0;
    }
}

/**
 * clean up the allocated Unicode* within the above typemap
 */
%typemap(freearg) const pdftron::Unicode* text_data  
%{
    delete[]($1);
%}

//----------------------------------------------------------------------------------------------

/**
 * Maps PHP array (of floats) to C++ vector<double>
 *//*
%typemap (in) std::vector<double> {
    int size = RARRAY_LEN($input);
    std::vector<double> $vec(size);
    int i;
    for (i = 0; i < size; i++) {
        $vec[i] = FIX2INT(rb_ary_entry($input, i));
    }
    $1 = $vec;
}

/**
 * Maps PHP array (of floats) to C++ vector<double>&
 *//*
%typemap (in) std::vector<double>& {
    int size = RARRAY_LEN($input);
    std::vector<double>* $vec = new std::vector<double>(size);
    int i;
    for (i = 0; i < size; i++) {
        (*$vec)[i] = FIX2INT(rb_ary_entry($input, i));
    }
    $1 = $vec;
}
/*
%typemap(out) std::vector<double> {

}

%typemap(typecheck) std::vector<double>, std::vector<double>&  {
    if (rb_type($input) == T_ARRAY) {
        $1 = 1;
    }
    else {
        $1 = 0;
    }
}

%typemap(freearg) std::vector<double>&
%{
    delete ($1);
%}

//----------------------------------------------------------------------------------------------

/**
 * Maps Ruby String to unsigned char *
 */

%typemap(in) unsigned char *
%{
    $1 = (unsigned char*)StringValuePtr($input);
%}

%typemap(typecheck) unsigned char *, pdftron::UChar const *  {
    if (rb_type($input) == T_STRING) {
        $1 = 1;
    }
    else {
        $1 = 0;
    }
}

%typemap(out) std::vector<unsigned char> {
    $result = rb_str_new((char*)&$1[0], $1.size());
}

//----------------------------------------------------------------------------------------------
/**
 * Maps Ruby String to std::vector<unsigned char>
 */

%typemap(in) std::vector<unsigned char>
{  
    unsigned char* temp = (unsigned char*)StringValuePtr($input);
    $1.resize(NUM2INT(rb_str_length($input)));
    memcpy(&$1[0], temp, NUM2INT(rb_str_length($input)));
}

%typemap(typecheck) std::vector<unsigned char>
{
    if (rb_type($input) == T_STRING) {
        $1 = 1;
    }
    else {
        $1 = 0;
    }
}
//----------------------------------------------------------------------------------------------
/**
 * Typemap for directors
 */
/* std::vector<unsigned char> -> Ruby string */
%typemap(directorin) std::vector<unsigned char>
{
    $1 = rb_str_new((char*) &($input[0]), $input.size());
}
/* Ruby string -> std::vector<unsigned char> */
%typemap(directorout) std::vector<unsigned char>
{
    unsigned char* temp = (unsigned char*) StringValuePtr($1);
    $result.resize(NUM2INT(rb_str_length($1)));
    memcpy(&($result[0]), temp, NUM2INT(rb_str_length($1)));
}
/* const std::vector<unsigned char>& -> Ruby string */
%typemap(directorin) const std::vector<unsigned char>&
{
    $input = rb_str_new((char*) &($1_name[0]), $1_name.size());
}

//----------------------------------------------------------------------------------------------
/**
 * Typemap to ensure Ruby nil is returned if a C++ function returns NULL.
 * Without the following, SWIG would wrap the NULL object. If this null object is compared the nil in Ruby,
 * the returned value would be false.
 */

%typemap(out) pdftron::PDF::Element 
%{  
    if ($1) {
        vresult = SWIG_NewPointerObj((new pdftron::PDF::Element(static_cast< const pdftron::PDF::Element& >(result))), SWIGTYPE_p_pdftron__PDF__Element, SWIG_POINTER_OWN | 0 );
        return vresult;
    }
    return Qnil;
%}

%typemap(out) pdftron::SDF::Obj 
%{
    if ($1) {
        vresult = SWIG_NewPointerObj((new pdftron::SDF::Obj(static_cast< const pdftron::SDF::Obj& >(result))), SWIGTYPE_p_pdftron__SDF__Obj, SWIG_POINTER_OWN |  0 );
        return vresult;
    }
    return Qnil;
%}

//----------------------------------------------------------------------------------------------
/**
 * Typemap for function pointers
 */

/**
 * Turns on the director feature for the following classes.
 * C++ equivalent of a proxy class. User extends this class in Ruby
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

//----------------------------------------------------------------------------------------------
// Fixes the recognition default arguments problem
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
%include "SDF/SecurityHandler.h"
%include "SDF/DocSnapshot.h"
%include "SDF/ResultSnapshot.h"
%include "SDF/UndoManager.h"
%include "PDF/Point.h"
%include "PDF/Function.h"
%include "PDF/ColorSpace.h"
%include "PDF/Rect.h"
%include "PDF/RectCollection.h"
%include "PDF/Page.h"
%include "PDF/Date.h"
%include "PDF/Field.h"
%include "PDF/DigitalSignatureField.h"
%include "PDF/FileSpec.h"
%include "PDF/Flattener.h"
%include "PDF/Annot.h"
%include "PDF/Annots/Popup.h"
%include "PDF/Annots/Markup.h"
%include "PDF/Annots/FileAttachment.h"
%include "PDF/QuadPoint.h"
%include "PDF/Annots/TextMarkup.h"
%include "PDF/Annots/Ink.h"
%include "PDF/Destination.h"
%include "PDF/Action.h"
%include "FDF/FDFField.h"
%include "FDF/FDFDoc.h"

%include "PDF/OCG/Config.h"
%include "PDF/OCG/Group.h"
%include "PDF/OCG/Context.h"
%include "PDF/OCG/OCMD.h"
%include "PDF/PDFA/PDFACompliance.h"
%include "PDF/Struct/AttrObj.h"
%include "PDF/Struct/ClassMap.h"
%include "PDF/Struct/ContentItem.h"
%include "PDF/Struct/RoleMap.h"
%include "PDF/Struct/STree.h"
%include "PDF/Struct/SElement.h"
%include "PDF/Bookmark.h"
%include "PDF/CharData.h"
%include "PDF/ContentReplacer.h"
%include "PDF/Convert.h"
%include "PDF/PathData.h"
%include "PDF/Font.h"
%include "PDF/Shading.h"
%include "PDF/PatternColor.h"
%include "PDF/GState.h"
%include "PDF/Image.h"
%include "PDF/OCROptions.h"
%include "PDF/OCRModule.h"
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
%include "PDF/Highlights.h"
%include "PDF/Optimizer.h"
%include "PDF/PageSet.h"
%include "PDF/PDFDC.h"
%include "PDF/PDFDCEX.h"
%include "PDF/PDFDraw.h"
%include "PDF/PDFNet.h"
%include "PDF/PDFView.h"
%include "PDF/Print.h"
%include "PDF/HTML2PDF.h"
%include "PDF/Stamper.h"
%include "PDF/TextExtractor.h"
%include "PDF/TextSearch.h"
%include "PDF/Redactor.h"
