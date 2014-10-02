//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
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
    catch (pdftron::Common::Exception e) {
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
    #include "PDF/FileSpec.h"
    #include "PDF/Flattener.h"
    #include "PDF/PathData.h"
    #include "PDF/Font.h"
    #include "PDF/Function.h"
    #include "PDF/GState.h"
    #include "PDF/Highlights.h"
    #include "PDF/HTML2PDF.h"
    #include "PDF/Image.h"
    #include "PDF/Optimizer.h"
    #include "PDF/Page.h"
    #include "PDF/PageLabel.h"
    #include "PDF/PageSet.h"
    #include "PDF/PatternColor.h"
    #include "PDF/PDFDC.h"
    #include "PDF/PDFDCEX.h"
    #include "PDF/PDFDoc.h"
    #include "PDF/PDFDocInfo.h"
    #include "PDF/PDFDocViewPrefs.h"
    #include "PDF/PDFDraw.h"
    #include "PDF/PDFNet.h"
    #include "PDF/PDFRasterizer.h"
    #include "PDF/PDFView.h"
    #include "PDF/Point.h"
    #include "PDF/Print.h"
    #include "PDF/QuadPoint.h"
    #include "PDF/Rect.h"
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

    using namespace pdftron;
    using namespace FDF;
    using namespace Filters;
    using namespace PDF;
    using namespace SDF;
    using namespace Annots;
    using namespace OCG;
    using namespace Struct;

    /**
     * Typedefs for nested classes
     */

    typedef pdftron::PDF::Convert::Printer Printer;
    typedef pdftron::PDF::Optimizer::ImageSettings ImageSettings;
    typedef pdftron::PDF::Optimizer::MonoImageSettings MonoImageSettings;
    typedef pdftron::PDF::TextExtractor::Style Style;
    typedef pdftron::PDF::TextExtractor::Word Word;
    typedef pdftron::PDF::TextExtractor::Line Line;
    typedef pdftron::PDF::Highlights::Highlight Highlight;
    typedef pdftron::PDF::Convert::SVGOutputOptions SVGOutputOptions;
    typedef pdftron::PDF::Convert::XPSOutputCommonOptions XPSOutputCommonOptions;
    typedef pdftron::PDF::Convert::XPSOutputOptions XPSOutputOptions;
    typedef pdftron::PDF::Convert::XODOutputOptions XODOutputOptions;
    typedef pdftron::PDF::Convert::HTMLOutputOptions HTMLOutputOptions;
    typedef pdftron::PDF::Convert::EPUBOutputOptions EPUBOutputOptions;
    typedef pdftron::PDF::HTML2PDF::Proxy Proxy;
    typedef pdftron::PDF::HTML2PDF::WebPageSettings WebPageSettings;
    typedef pdftron::PDF::HTML2PDF::TOCSettings TOCSettings;
    typedef pdftron::PDF::Redactor::Redaction Redaction;
    typedef pdftron::PDF::Redactor::Appearance Appearance;
    typedef pdftron::PDF::Annot::BorderStyle BorderStyle;
    typedef pdftron::PDF::Optimizer::TextSettings TextSettings;
    typedef pdftron::PDF::Optimizer::OptimizerSettings OptimizerSettings;
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
   %template(VectorRedaction) vector<pdftron::PDF::Redactor::Redaction>;
   %template(VectorQuadPoint) vector<pdftron::PDF::QuadPoint>;
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
 * Tyemapping for enums
 * Ruby can takes in an integer which is then converted to an enum
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

//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
// The following section redefines the nested classes as a workaround 
// for SWIG not supporting nested classes
//----------------------------------------------------------------------------------------------

class Appearance
{
public:
    Appearance() 
    {
        // Defaults
        RedactionOverlay = true;
        PositiveOverlayColor.Set(1, 1, 1); 
        NegativeOverlayColor.Set(1, 1, 1); 
        UseOverlayText = true;
        MinFontSize = 2;
        MaxFontSize = 24;
        TextColor.Set(0, 0, 0);
        HorizTextAlignment = -1; // left justified
        VertTextAlignment = 1; // top justified
        Border = true;        
    }

    /**
     * If RedactionOverlay is set to true, Redactor will draw an overlay
     * covering all redacted regions. The rest of properties in the 
     * Appearance class defines visual properties of the overlay. 
     * If false the overlay region will not be drawn.
     */
    bool RedactionOverlay;

    /**
     * PositiveOverlayColor defines the overlay background color in RGB color space for positive redactions.
     */
    pdftron::PDF::ColorPt PositiveOverlayColor;

    /**
     * NegativeOverlayColor defines the overlay background color in RGB color space for negative redactions.
     */
    pdftron::PDF::ColorPt NegativeOverlayColor;

    /**
     * Border specifies if the overlay will be surrounded by a border.
     */
    bool Border;

    /**
     * Specifies if the text (e.g. "Redacted" etc.) should be placed on 
     * top of the overlay. The remaining properties relate to the positioning, 
     * and styling of the overlay text.
     */
    bool UseOverlayText;

    /**
     * Specifies the font used to represent the text in the overlay.
     */
    pdftron::PDF::Font TextFont;

    /**
     * Specifies the font size used to represent the text in the overlay.
     */
    double MinFontSize, MaxFontSize;

    /**
     * Specifies the color used to paint the text in the overlay (in RGB).
     */
    pdftron::PDF::ColorPt TextColor;

    /**
     * Specifies the text alignment in the overlay:
     *   align<0  -> text will be left aligned.
     *   align==0 -> text will be centered aligned.
     *   align>0  -> text will be right aligned.
     */
    int HorizTextAlignment, VertTextAlignment;
};


class Redaction
{
public:
    /**
     * @param page_num - a page number on which to perform the redaction.
     * @param bbox - the bounding box for the redaction (in PDF user coordinate
     * system - or page coordinate system?).
     * @param negative - if \b true, redact the area \b outside the redaction area,
     * otherwise, when \b false, redact the area \b inside the redaction area.
     * @param text - optional anchor text to be placed in the redaction region.
     */
    Redaction(int page_num, const pdftron::PDF::Rect& bbox, bool negative, const pdftron::UString& text);
    ~Redaction();

    /**
     * Frees the native memory of the object.
     */
    void Destroy();

    // @cond PRIVATE_DOC
#ifdef SWIG
    Redaction();
#endif

    Redaction(const Redaction& other);
    Redaction(TRN_Redaction impl);
    TRN_Redaction mp_imp;
    // @endcond
};

/**
 * A class containing options for ToSvg functions
 */
class SVGOutputOptions
{
public:
    /**
     * Creates an SVGOutputOptions object with default settings
     */
    SVGOutputOptions();

    /**
     * Sets whether to embed all images
     * @param embed_images if true, images will be embedded. Default is false.
     */
    void SetEmbedImages(bool embed_images);

    /**
     * Sets whether to disable conversion of font data to SVG
     * @param no_fonts if true, font data conversion is disabled. Default is false.
     */
    void SetNoFonts(bool no_fonts);

    /**
     * Sets whether to convert all fonts to SVG or not.
     * @param svg_fonts if true, fonts are converted to SVG. Otherwise they are converted to OpenType.
     * Default is false.
     */
    void SetSvgFonts(bool svg_fonts);

    /**
     * Sets whether to embed fonts into each SVG page file, or to have them shared.
     * @param embed_fonts if true, fonts are injected into each SVG page. 
     * Otherwise they are created as separate files that are shared between SVG pages.
     * Default is false.
     */
    void SetEmbedFonts(bool embed_fonts);

    /**
     * Sets whether to disable mapping of text to public Unicode region. Instead text will be converted using a custom encoding
     * @param no_unicode if true, mapping of text to public Unicode region is disabled
     */
    void SetNoUnicode(bool no_unicode);

    /**
     * Some viewers do not support the default text positioning correctly. This option works around this issue to place text correctly, but produces verbose output. This option will override SetRemoveCharPlacement
     * @param individual_char_placement if true, text will be positioned correctly
     */
    void SetIndividualCharPlacement(bool individual_char_placement);

    /**
     * Sets whether to disable the output of character positions.  This will produce slightly smaller output files than the default setting, but many viewers do not support the output correctly
     * @param remove_char_placement if true, the output of character positions is disabled
     */
    void SetRemoveCharPlacement(bool remove_char_placement);

    /**
     * Flatten images and paths into a single background image overlaid with 
     * vector text. This option can be used to improve speed on devices with 
     * little processing power such as iPads. Default is e_fast.
     * @param flatten select which flattening mode to use.
     */
    void SetFlattenContent(enum pdftron::PDF::Convert::FlattenFlag flatten);

    /**
     * Used to control how precise or relaxed text flattening is. When some text is 
     * preserved (not flattened to image) the visual appearance of the document may be altered.
     * @param threshold the threshold setting to use.
     */
    void SetFlattenThreshold(enum pdftron::PDF::Convert::FlattenThresholdFlag threshold);

    /**
    * The output resolution, from 1 to 1000, in Dots Per Inch (DPI) at which to render elements which cannot be directly converted.
    * Default is 150.
    * @param dpi the resolution in Dots Per Inch
    */
    void SetFlattenDPI(pdftron::UInt32 dpi);

    /**
    * Specifies the maximum image size in pixels. Default is 2000000.
    * @param max_pixels the maximum number of pixels an image can have
    */
    void SetFlattenMaximumImagePixels(pdftron::UInt32 max_pixels);

    /**
     * Compress output SVG files using SVGZ.
     * @param svgz if true, SVG files are written in compressed format. Default is false.
     */
    void SetCompress(bool svgz);

    /**
     * Sets whether per page thumbnails should be included in the file. Default is true.
     * @param include_thumbs if true thumbnails will be included
     */
    void SetOutputThumbnails(bool include_thumbs);

    /**
     * The width and height of a square in which all thumbnails will 
     * be contained. Default is 400.
     * @param size the maximum dimension (width or height) that 
     * thumbnails will have. Default is 400.
     */
    void SetThumbnailSize(pdftron::UInt32 size);

    /**
     * Create a XML document that contains metadata of the SVG document created.
     * @param xml if true, XML wrapper is created. Default is true.
     */
    void SetCreateXmlWrapper(bool xml);

    /**
     * Set whether the DTD declaration is included in the SVG files.
     * @param dtd if false, no DTD is added to SVG files. Default is true.
     */
    void SetDtd(bool dtd);

    /**
     * Control generation of form fields and annotations in SVG.
     * @param annots if false, no form fields or annotations are converted. Default is true
     */
    void SetAnnots(bool annots);
protected:
    TRN_Obj m_obj;
    friend class Convert;
    SDF::ObjSet m_objset;
};

/**
 * A class containing options common to ToXps and ToXod functions
 */
class XPSOutputCommonOptions
{
public:
    /**
     * Creates an XPSConvertOptions object with default settings
     */
    XPSOutputCommonOptions();
    /**
     * Sets whether ToXps should be run in print mode
     * print mode is disabled by default
     * @param print_mode if true print mode is enabled
     */
    void SetPrintMode(bool print_mode);

    /**
     * The output resolution, from 1 to 1000, in Dots Per Inch (DPI) at which to render elements which cannot be directly converted. 
     * the default value is 150 Dots Per Inch
     * @param dpi the resolution in Dots Per Inch
     */
    void SetDPI(pdftron::UInt32 dpi);

    /**
     * Sets whether rendering of pages should be permitted when necessary to guarantee output
     * the default setting is to allow rendering in this case
     * @param render if false rendering is not permitted under any circumstance
     */
    void SetRenderPages(bool render);

    /**
     * Sets whether thin lines should be thickened
     * the default setting is to not thicken lines
     * @param thicken if true then thin lines will be thickened
     */
    void SetThickenLines(bool thicken);

    /**
     * Sets whether links should be generated from urls
     * found in the document. By default these links are generated.
     * @param generate if true links will be generated from urls
     */
    void GenerateURLLinks(bool generate);

    enum OverprintPreviewMode
    {
        e_op_off = 0,
        e_op_on,
        e_op_pdfx_on
    };

    /** 
     * Enable or disable support for overprint and overprint simulation. 
     * Overprint is a device dependent feature and the results will vary depending on 
     * the output color space and supported colorants (i.e. CMYK, CMYK+spot, RGB, etc). 
     * 
     * @default By default overprint is only enabled for PDF/X files.
     * 
     * @param op e_op_on: always enabled; e_op_off: always disabled; e_op_pdfx_on: enabled for PDF/X files only.
     */
    void SetOverprint(OverprintPreviewMode mode);
protected:
    TRN_Obj m_obj;
    friend class Convert;
    SDF::ObjSet m_objset;
};

/**
 * A class containing options for ToXps functions
 */
class XPSOutputOptions : public XPSOutputCommonOptions
{
public:
    /**
     * Sets whether the output format should be open xps
     * microsoft xps output is the default
     * @param openxps if open xps output should be used
     */
    void SetOpenXps(bool openxps);
};

/**
 * A class containing options for ToXod functions
 */
class XODOutputOptions : public XPSOutputCommonOptions
{
public:
    enum AnnotationOutputFlag {
        e_internal_xfdf,                // include the annotation file in the XOD output. This is the default option
        e_external_xfdf,                // output the annotation file externally to the same output path with extension .xfdf. 
                                        // This is not available when using streaming conversion
        e_flatten                      // flatten all annotations that are not link annotations
    };

    /**
     * Sets whether per page thumbnails should be included in the file
     * the default setting is to output thumbnails
     * @param include_thumbs if true thumbnails will be included
     */
    void SetOutputThumbnails(bool include_thumbs);

    /**
     * The width and height of a square in which all thumbnails will 
     * be contained.
     * @param size the maximum dimension (width or height) that 
     * thumbnails will have.
     */
    void SetThumbnailSize(pdftron::UInt32 size);

    /**
     * If rendering is permitted, sets the maximum number of page elements before that page will be rendered.
     * the default value is 10000 elements
     * @param element_limit the maximum number of elements before a given page will be rendered
     */
    void SetElementLimit(pdftron::UInt32 element_limit);

    /**
     * If rendering is permitted, sets whether pages containing opacity masks should be rendered.
     * This option is used as a workaround to a bug in Silverlight where opacity masks are transformed incorrectly.
     * the default setting is not to render pages with opacity masks 
     * @param opacity_render if true pages with opacity masks will be rendered
     */
    void SetOpacityMaskWorkaround(bool opacity_render);

    /**
     * Specifies the maximum image size in pixels.
     * @param max_pixels the maximum number of pixels an image can have.
     */
    void SetMaximumImagePixels(pdftron::UInt32 max_pixels);

    /**
     * Flatten images and paths into a single background image overlaid with 
     * vector text. This option can be used to improve speed on devices with 
     * little processing power such as iPads.
     * @param flatten select which flattening mode to use.
     */
    void SetFlattenContent(enum pdftron::PDF::Convert::FlattenFlag flatten);

    /**
     * Used to control how precise or relaxed text flattening is. When some text is 
     * preserved (not flattened to image) the visual appearance of the document may be altered.
     * @param threshold the threshold setting to use.
     */
    void SetFlattenThreshold(enum pdftron::PDF::Convert::FlattenThresholdFlag threshold);

    /**
     * Where possible output JPG files rather than PNG. This will apply to both 
     * thumbnails and document images.
     * @param prefer_jpg if true JPG images will be used whenever possible.
     */
    void SetPreferJPG(bool prefer_jpg);

    /**
     * Specifies the compression quality to use when generating JPEG images.
     * @param quality the JPEG compression quality, from 0(highest compression) to 100(best quality).
     */
    void SetJPGQuality(pdftron::UInt32 quality);

    /**
     * Outputs rotated text as paths. This option is used as a workaround to a bug in Silverlight 
     * where pages with rotated text could cause the plugin to crash.
     * @param workaround if true rotated text will be changed to paths
     */
    void SetSilverlightTextWorkaround(bool workaround);
    
    /**
     * Choose how to output annotations.
     * @param annot_output the flag to specify the output option
     */
    void SetAnnotationOutput(enum AnnotationOutputFlag annot_output);
    
    /**
     * Output XOD as a collection of loose files rather than a zip archive. 
     * This option should be used when using the external part retriever in Webviewer.
     * @param generate if true XOD is output as a collection of loose files
     */
    void SetExternalParts(bool generate);

    /**
     * Encrypt XOD parts with AES 128 encryption using the supplied password.
     * This option is not available when using SetExternalParts(true)
     * @param pass the encryption password
     */
    void SetEncryptPassword(const char* pass);
};

/**
 * A class containing options common to ToHtml and ToEpub functions
 */
class HTMLOutputOptions
{
public:
    /**
     * Creates an HTMLOutputCommonOptions object with default settings
     */
    HTMLOutputOptions();

    /**
     * Use JPG files rather than PNG. This will apply to all generated images.
     * @param prefer_jpg if true JPG images will be used whenever possible.
     */
    void SetPreferJPG(bool prefer_jpg);

    /**
     * Specifies the compression quality to use when generating JPEG images.
     * @param quality the JPEG compression quality, from 0(highest compression) to 100(best quality).
     */
    void SetJPGQuality(pdftron::UInt32 quality);

    /**
     * The output resolution, from 1 to 1000, in Dots Per Inch (DPI) at which to render elements which cannot be directly converted. 
     * the default value is 150 Dots Per Inch
     * @param dpi the resolution in Dots Per Inch
     */
    void SetDPI(pdftron::UInt32 dpi);

    /**
     * Specifies the maximum image size in pixels
     * @param max_pixels the maximum number of pixels an image can have
     */
    void SetMaximumImagePixels(pdftron::UInt32 max_pixels);

    /**
     * Switch between fixed (pre-paginated) and reflowable HTML generation
     * @param reflow if true, generated HTML will be reflowable, otherwise, fixed positioning will be used
     */
    void SetReflow(bool reflow);

    /**
     * Set an overall scaling of the generated HTML pages.
     * @param scale A number greater than 0 which is used as a scale factor. For example, calling SetScale(0.5) will reduce the HTML body of the page to half its original size, whereas SetScale(2) will double the HTML body dimensions of the page and will rescale all page content appropriately.
     */
    void SetScale(double scale);

    /**
     * Enable the conversion of external URL navigation. Default is false.
     * @param enable if true, links that specify external URL's are converted into HTML.
     */
    void SetExternalLinks(bool enable);

    /**
     * Enable the conversion of internal document navigation. Default is false.
     * @param enable if true, links that specify page jumps are converted into HTML.
     */
    void SetInternalLinks(bool enable);

    /**
     * Controls whether converter optimizes DOM or preserves text placement accuracy. Default is false.
     * @param enable If true, converter will try to reduce DOM complexity at the expense of text placement accuracy.
     */
    void SetSimplifyText(bool enable);
protected:
    TRN_Obj m_obj;
    friend class Convert;
    SDF::ObjSet m_objset;
};

/**
 * A class containing options common to ToEpub functions
 */
class EPUBOutputOptions
{
public:
    /**
     * Creates an EPUBOutputOptions object with default settings
     */
    EPUBOutputOptions();

    /**
     * Create the EPUB in expanded format.
     * @param expanded if false a single EPUB file will be generated, otherwise, the generated EPUB will be in unzipped (expanded) format
     */
    void SetExpanded(bool expanded);

    /**
     * Set whether the first content page in the EPUB uses the cover image or not. If this
     * is set to true, then the first content page will simply wrap the cover image in HTML.
     * Otherwise, the page will be converted the same as all other pages in the EPUB.
     * @param reuse if true the first page will simply be EPUB cover image, otherwise, the first page will be converted the same as the other pages
     */
    void SetReuseCover(bool reuse);
protected:
    TRN_Obj m_obj;
    friend class Convert;
    SDF::ObjSet m_objset;
};

/**
 * Proxy settings to be used when loading content from web pages.
 *
 * @note These Proxy settings will only be used if type is not e_default.
 */
class Proxy
{
public:
    /**
     * Default constructor
     */
    Proxy();

    /**
     * Destructor
     */
    ~Proxy();

    /**
     * Set the type of proxy to use.
     *
     * @param type - If e_default, use whatever the html2pdf library decides
     * on. If e_none, explicitly sets that no proxy is to be used. If e_http
     * or e_socks5 then the corresponding proxy protocol is used.
     */
    enum Type { e_default, e_none, e_http, e_socks5    };
    void SetType(Type type);

    /**
     * Set the proxy host to use.
     *
     * @param host - String defining the host name, e.g. "myserver" or "www.xxx.yyy.zzz"
     */
    void SetHost(const pdftron::UString& host);

    /**
     * Set the port number to use
     *
     * @param port - A valid port number, e.g. 3128.
     */
    void SetPort(int port);

    /**
     * Set the username to use when logging into the proxy
     *
     * @param username - The login name, e.g. "elbarto".
     */
    void SetUsername(const pdftron::UString& username);

    /**
     * Set the password to use when logging into the proxy with username
     *
     * @param password - The password to use, e.g. "bart".
     */
    void SetPassword(const pdftron::UString& password);

    /**
     * Frees the native memory of the object.
     */
    void Destroy();

    /// @cond PRIVATE_DOC
    TRN_HTML2PDF_Proxy mp_impl;
    /// @endcond
};

/**
 * Settings that control how a web page is opened and converted to PDF.
 */
class WebPageSettings
{
public:
    /**
     * Default constructor
     */
    WebPageSettings();

    /**
     * Destructor
     */
    ~WebPageSettings();

    /**
     * Print the background of this web page?
     *
     * @param background - If true background is printed.
     */
    void SetPrintBackground(bool background);

    /**
     * Print the images of this web page?
     *
     * @param load - If true images are printed.
     */
    void SetLoadImages(bool load);

    /**
     * Allow javascript from this web page to be run?
     *
     * @param enable - If true javascript's are allowed.
     */
    void SetAllowJavaScript(bool enable);

    /**
     * Allow intelligent shrinking to fit more content per page?
     *
     * @param enable - If true intelligent shrinking is enabled and
     * the pixel/dpi ratio is non constant.
     */
    void SetSmartShrinking(bool enable);

    /**
     * Set the smallest font size allowed, e.g 9.
     *
     * @param size - No fonts will appear smaller than this.
     */
    void SetMinimumFontSize(int size);

    /**
     * Default encoding to be used when not specified by the web page.
     *
     * @param encoding - Default encoding, e.g. utf-8 or iso-8859-1.
     *
     * @note see http://doc.qt.nokia.com/stable/qtextcodec.html for list
     * of available encodings.
     */
    void SetDefaultEncoding(const pdftron::UString& encoding);

    /**
     * Url or path to user specified style sheet.
     *
     * @param url - URL or file path to user style sheet to be used
     * with this web page.
     */
    void SetUserStyleSheet(const pdftron::UString& url);

    /**
     * Allow Netscape and flash plugins from this web page to
     * be run? Enabling will have limited success.
     *
     * @param enable - If true Netscape & flash plugins will be run.
     */
    void SetAllowPlugins(bool enable);

    /**
     * Controls how content will be printed from this web page.
     *
     * @param print - If true the print media type will be used, otherwise
     * the screen media type will be used to print content.
     */
    void SetPrintMediaType(bool print);

    /**
     * Add sections from this web page to the outline and
     * table of contents?
     *
     * @param include - If true PDF pages created from this web
     * page will show up in the outline, and table of contents,
     * otherwise, produced PDF pages will be excluded.
     */
    void SetIncludeInOutline(bool include);

    /**
     * HTTP authentication username to use when logging into the website.
     *
     * @param username - The login name to use with the server, e.g. "bart".
     */
    void SetUsername(const pdftron::UString& username);

    /**
     * HTTP authentication password to use when logging into the website.
     *
     * @param password - The login password to use with the server, e.g. "elbarto".
     */
    void SetPassword(const pdftron::UString& password);

    /**
     * Amount of time to wait for a web page to start printing after
     * it's completed loading. Converter will wait a maximum of msec milliseconds
     * for javascript to call window.print().
     *
     * @param msec - Maximum wait time in milliseconds, e.g. 1200.
     */
    void SetJavaScriptDelay(int msec);

    /**
     * Zoom factor to use when loading object.
     *
     * @param zoom - How much to magnify the web content by, e.g. 2.2.
     */
    void SetZoom(double zoom);

    /**
     * Allow local and piped files access to other local files?
     *
     * @param block - If true local files will be inaccessible.
     */
    void SetBlockLocalFileAccess(bool block);

    /**
     * Stop slow running javascript's?
     *
     * @param stop - If true, slow running javascript's will be stopped.
     */
    void SetStopSlowScripts(bool stop);

    /**
     * Forward javascript warnings and errors to output?
     *
     * @param forward - If true javascript errors and warnings will be forwarded
     * to stdout and the log.
     */
    void SetDebugJavaScriptOutput(bool forward);

    /**
     * How to handle objects that failed to load?
     *
     * @param type - If e_abort then conversion process is aborted, if
     * e_skip then the converter will not add this web page to the PDF
     * output, and if e_skip then the converter will try to add this
     * web page to the PDF output.
     */
    enum ErrorHandling {
        e_abort,    // Abort the conversion process.
        e_skip,        // Do not add the object to the final output
        e_ignore    // Try to add the object to the final output.
    };
    void SetLoadErrorHandling(ErrorHandling type);

    /**
     * Convert external links in HTML document to external
     * PDF links?
     *
     * @param convert - If true PDF pages produced from this web page
     * can have external links.
     */
    void SetExternalLinks(bool convert);

    /**
     * Should internal links in HTML document be converted
     * into PDF references?
     *
     * @param convert - If true PDF pages produced from this web page
     * will have links to other PDF pages.
     */
    void SetInternalLinks(bool convert);

    /**
     * Turn HTML forms into PDF forms?
     *
     * @param forms - If true PDF pages produced from this web page
     * will have PDF forms for any HTML forms the web page has.
     */
    void SetProduceForms(bool forms);

    /**
     * Use this proxy to load content from this web page.
     *
     * @param proxy - Contains settings for proxy
     */
    void SetProxy(const Proxy& proxy);

    /**
     * Frees the native memory of the object.
     */
     void Destroy();

    /// @cond PRIVATE_DOC
    TRN_HTML2PDF_WebPageSettings mp_impl;
    /// @endcond
};

/**
 * Settings for table of contents.
 */
class TOCSettings
{
public:
    /**
     * Default table of contents settings.
     */
    TOCSettings();

    /**
     * destructor.
     */
    ~TOCSettings();

    /**
     * Use a dotted line when creating TOC?
     *
     * @param enable - Table of contents will use dotted lines.
     */
    void SetDottedLines(bool enable);

    /**
     * Create links from TOC to actual content?
     *
     * @param enable - Entries in table of contents will
     * link to section in the PDF.
     */
    void SetLinks(bool enable);

    /**
     * Caption text to be used with TOC.
     *
     * @param caption - Text that will appear with the table of contents.
     */
    void SetCaptionText(const pdftron::UString& caption);

    /**
     * Indentation used for every TOC level...
     *
     * @param indentation - How much to indent each level, e.g. "2"
     */
    void SetLevelIndentation(int indentation);

    /**
     * How much to shrink font for every level, e.g. 0.8
     *
     * @param shrink - Rate at which lower level entries will appear smaller
     */
    void SetTextSizeShrink(double shrink);

    /**
     * xsl style sheet used to convert outline XML into a
     * table of content.
     *
     * @param style_sheet - Path to xsl style sheet to be used to generate
     * this table of contents.
     */
    void SetXsl(const pdftron::UString& style_sheet);

    /**
     * Frees the native memory of the object.
     */
     void Destroy();

    /// @cond PRIVATE_DOC
    TRN_HTML2PDF_TOCSettings mp_impl;
    /// @endcond
};


/** 
* Convert::Printer is a utility class to install the a printer for 
* print-based conversion of documents for Convert::ToPdf
*/
class Printer
{
public:
    /**
    * Install the PDFNet printer. Installation can take a few seconds, 
    * so it is recommended that you install the printer once as part of 
    * your deployment process.  Duplicated installations will be quick since
    * the presence of the printer is checked before installation is attempted.
    * There is no need to uninstall the printer after conversions, it can be 
    * left installed for later access.
    *
    * @param in_printerName the name of the printer to install and use for conversions.
    * If in_printerName is not provided then the name "PDFTron PDFNet" is used.
    *
    * @note Installing and uninstalling printer drivers requires the process
    * to be running as administrator.
    */
    static void Install(const pdftron::UString & in_printerName = "PDFTron PDFNet");

    /** 
    * Uninstall all printers using the PDFNet printer driver.  
    *
    * @note Installing and uninstalling printer drivers requires the process
    * to be running as administrator.  Only the "PDFTron PDFNet" printer can 
    * be uninstalled with this function.
    */
    static void Uninstall();

    /** 
    * Get the name of the PDFNet printer installed in this process session.
    *
    * @return the Unicode name of the PDFNet printer 
    *
    * @note if no printer was installed in this process then the predefined string
    * "PDFTron PDFNet" will be returned.
    */
    static const pdftron::UString GetPrinterName();

    /** 
    * Set the name of the PDFNet printer installed in this process session.
    *
    * @return the Unicode name of the PDFNet printer 
    *
    * @note if no printer was installed in this process then the predefined string
    * "PDFTron PDFNet" will be used.
    */
    static void SetPrinterName(const pdftron::UString & in_printerName = "PDFTron PDFNet");

    /**
    * Determine if the PDFNet printer is installed
    *
    * @param in_printerName the name of the printer to install and use for conversions.
    * If in_printerName is not provided then the name "PDFTron PDFNet" is used.
    *
    * @return true if the named printer is installed, false otherwise
    *
    * @note may or may not check if the printer with the given name is actually 
    * a PDFNet printer.
    */
    static bool IsInstalled(const pdftron::UString & in_printerName = "PDFTron PDFNet");
};

class TextSettings : public TRN_OptimizerTextSettings
{
public:
    TextSettings();
    /**
    * Sets whether embedded fonts will be subset.  This
    * will generally reduce the size of fonts, but will
    * strip font hinting.  Subsetting is off by default.
    * @param subset if true all embedded fonts will be subsetted.
    */
    void SubsetFonts(bool subset);

    /**
    * Sets whether fonts should be embedded.  This
    * will generally increase the size of the file, but will
    * make the file appear the same on different machines.  
    * Font embedding is off by default.
    * @param embed if true all fonts will be embedded.
    */
    void EmbedFonts(bool embed);
};

class OptimizerSettings
{
public:
    OptimizerSettings();
    void SetColorImageSettings(const ImageSettings& settings);
    void SetGrayscaleImageSettings(const ImageSettings& settings);
    void SetMonoImageSettings(const MonoImageSettings& settings);
    void SetTextSettings(const TextSettings& settings);

    ImageSettings m_color_image_settings;
    ImageSettings m_grayscale_image_settings;
    MonoImageSettings m_mono_image_settings;
    TextSettings m_text_settings;    
};

/**
 * A class that stores downsampling/recompression
 * settings for color and grayscale images.
 */
class ImageSettings : public TRN_OptimizerImageSettings
{
public:
    enum CompressionMode
    {
        e_retain,
        e_flate, 
        e_jpeg,
        e_jpeg2000,
        e_none
    };

    enum DownsampleMode
    {
        e_off,
        e_default
    };
    /**
     *     create an ImageSettings object with default options
     */
    ImageSettings();

    /**
     * Sets the maximum and resampling dpi for images.
     * By default these are set to 144 and 96 respectively.
     * @param maximum the highest dpi of an image before
     * it will be resampled
     * @param resampling the image dpi to resample to if an
     * image is encountered over the maximum dpi
     */
    void SetImageDPI(double maximum,double resampling);

    /**
     * Sets the output compression mode for this type of image
     * The default value is e_retain
     * @param mode the compression mode to set
     */
    void SetCompressionMode(enum CompressionMode mode);

    /**
     * Sets the downsample mode for this type of image
     * The default value is e_default
     * @param mode the compression mode to set
     */
    void SetDownsampleMode(enum DownsampleMode mode);

    /**
     * Sets the quality for lossy compression modes
     * from 1 to 10 where 10 is lossless (if possible)
     * the default value is 5
     */
    void SetQuality(pdftron::UInt32 quality);

    /**
     * Sets whether recompression to the specified compression
     * method should be forced when the image is not downsampled.
     * By default the compression method for these images
     * will not be changed.
     * @param force if true the compression method for all
     * images will be changed to the specified compression mode
     */
    void ForceRecompression(bool force);

    /**
     * Sets whether image changes that grow the
     * PDF file should be kept.  This is off by default.
     * @param force if true all image changes will be kept.
     */
    void ForceChanges(bool force);
};

/**
 * A class that stores image downsampling/recompression
 * settings for monochrome images.
 */
class MonoImageSettings : public TRN_OptimizerMonoImageSettings
{
public:
    enum CompressionMode
    {
        e_jbig2,
        e_flate,
        e_none
    };

    enum DownsampleMode
    {
        e_off,
        e_default
    };

    /**
     *     create an MonoImageSettings object with default options
     */
    MonoImageSettings();

    /**
     * Sets the maximum and resampling dpi for monochrome images.
     * By default these are set to 144 and 96 respectively.
     * @param maximum the highest dpi of an image before
     * it will be resampled
     * @param resampling the image dpi to resample to if an
     * image is encountered over the maximum dpi
     */
    void SetImageDPI(double maximum,double resampling);

    /**
     * Sets the output compression mode for monochrome images
     * The default value is e_jbig2
     * @param mode the compression mode to set
     */
    void SetCompressionMode(enum CompressionMode mode);


    /**
     * Sets the downsample mode for monochrome images
     * The default value is e_default
     * @param mode the compression mode to set
     */
    void SetDownsampleMode(enum DownsampleMode mode);


    /**
     * Sets whether recompression to the specified compression
     * method should be forced when the image is not downsampled.
     * By default the compression method for these images
     * will not be changed.
     * @param force if true the compression method for all
     * images will be changed to the specified compression mode
     */
    void ForceRecompression(bool force);

    /**
     * Sets whether image changes that grow the
     * PDF file should be kept.  This is off by default.
     * @param force if true all image changes will be kept.
     */
    void ForceChanges(bool force);
};

/** 
 * A class representing predominant text style associated with a 
 * given Line, a Word, or a Glyph. The class includes information about 
 * the font, font size, font styles, text color, etc.
 */ 
class Style 
{
public:

    /** 
     * @return low-level PDF font object. A high level font object can 
     * be instantiated as follows: 
     * In C++: pdftron.PDF.Font f(style.GetFont())
     * In C#: pdftron.PDF.Font f = new pdftron.PDF.Font(style.GetFont());
     */
    pdftron::SDF::Obj GetFont();

    /** 
     * @return the font name used to draw the selected text.
     */
    pdftron::UString GetFontName();

    /** 
     * @return The font size used to draw the selected text as it 
     * appears on the output page.
     * @note Unlike the 'font size' in the graphics state (pdftron.PDF.GState)
     * the returned font size accounts for the effects CTM, text matrix,
     * and other graphics state attributes that can affect the appearance of 
     * text.
     */
    double GetFontSize();

    /** 
     * @return The weight (thickness) component of the fully-qualified font name 
     * or font specifier. The possible values are 100, 200, 300, 400, 500, 600, 700, 
     * 800, or 900, where each number indicates a weight that is at least as dark as 
     * its predecessor. A value of 400 indicates a normal weight; 700 indicates bold.
     * Note: The specific interpretation of these values varies from font to font. 
     * For example, 300 in one font may appear most similar to 500 in another.
     */
    int GetWeight();

    /** 
     * @return true if glyphs have dominant vertical strokes that are slanted.
     * @note the return value corresponds to the state of 'italic' flag in the 'Font Descriptor'.
     */
    bool IsItalic();

    /** 
     * @return true if glyphs have serifs, which are short strokes drawn at an angle on the top 
     * and bottom of glyph stems.
     * @note the return value corresponds to the state of 'serif' flag in the 'Font Descriptor'.
     */
    bool IsSerif();

    /** 
     * @return text color in RGB color space.
     */
    std::vector<int> GetColor();

    bool operator== (const Style& s);
    bool operator!= (const Style& s);

    Style();

    /// @cond PRIVATE_DOC 
    Style(const Style& s);
    Style(TRN_TextExtractorStyle impl);
    TRN_TextExtractorStyle mp_style;
    /// @endcond
};

/**
 * TextExtractor::Word object represents a word on a PDF page. 
 * Each word contains a sequence of characters in one or more styles 
 * (see TextExtractor::Style).
 */
class Word 
{

public:
    /** 
     * @return The number of glyphs in this word.
     */
     int GetNumGlyphs();

    /** 
     * @param out_bbox The bounding box for this word (in unrotated page 
     * coordinates). 
     * @note To account for the effect of page '/Rotate' attribute, 
     * transform all points using page.GetDefaultMatrix().
     */ 
     pdftron::PDF::Rect GetBBox();

    /** 
     * @param out_quad The quadrilateral representing a tight bounding box 
     * for this word (in unrotated page coordinates).
     */
     std::vector<double> GetQuad();

    /** 
     * @param glyph_idx The index of a glyph in this word.
     * @param out_quad The quadrilateral representing a tight bounding box 
     * for a given glyph in the word (in unrotated page coordinates).
     */
     std::vector<double> GetGlyphQuad(int glyph_idx);

    /** 
     * @param char_idx The index of a character in this word.
     * @return The style associated with a given character.
     */
    Style GetCharStyle(int char_idx);

    /**
     * @return predominant style for this word.
     */
    Style GetStyle();

    /**
     * @return the number of characters in this word.
     */
    int GetStringLen();

    /** 
     * @return the content of this word represented as a Unicode string.
     */
     pdftron::UString GetString();

    /** 
     * @return the next word on the current line.
     */
    Word GetNextWord();

    /** 
     * @return the index of this word of the current line. A word that 
     * starts the line will return 0, whereas the last word in the line
     * will return (line.GetNumWords()-1).
     */
    int GetCurrentNum();

    /** 
     * @return true if this is a valid word, false otherwise.
     */
    bool IsValid();

    bool operator== (const Word&);
    bool operator!= (const Word&);
    Word();

    /// @cond PRIVATE_DOC 
    Word(TRN_TextExtractorWord impl);
    TRN_TextExtractorWord mp_word;
    /// @endcond
};

/**
 * TextExtractor::Line object represents a line of text on a PDF page. 
 * Each line consists of a sequence of words, and each words in one or 
 * more styles.
 */
class Line {
public: 

    /** 
     * @return The number of words in this line.
     */
    int GetNumWords();

    /** 
     * @return true is this line is not rotated (i.e. if the 
     * quadrilaterals returned by GetBBox() and GetQuad() coincide).
     */
    bool IsSimpleLine();

    /** 
     * @param out_bbox The bounding box for this line (in unrotated page 
     * coordinates). 
     * @note To account for the effect of page '/Rotate' attribute, 
     * transform all points using page.GetDefaultMatrix().
     */
     pdftron::PDF::Rect GetBBox();

    /** 
     * @param out_quad The quadrilateral representing a tight bounding box 
     * for this line (in unrotated page coordinates).
     */
     std::vector<double> GetQuad();

    /** 
     * @return the first word in the line.
     * @note To traverse the list of all words on this line use word.GetNextWord().
     */
    Word GetFirstWord();

    /** 
     * @return the i-th word in this line.
     */
    Word GetWord(int word_idx);

    /** 
     * @return the next line on the page.
     */
    Line GetNextLine();

    /** 
     * @return the index of this line of the current page.
     */
    int GetCurrentNum();

    /**
     * @return predominant style for this line.
     */
    Style GetStyle();

    /**
     * @return The unique identifier for a paragraph or column
     * that this line belongs to. This information can be used to 
     * identify which lines belong to which paragraphs. 
     */
    int GetParagraphID();

    /** 
     * @return The unique identifier for a paragraph or column
     * that this line belongs to. This information can be used to 
     * identify which lines/paragraphs belong to which flows. 
     */
    int GetFlowID();

    /** 
     * @return true is this line of text ends with a hyphen (i.e. '-'),
     * false otherwise.
     */
    bool EndsWithHyphen();

    /** 
     * @return true if this is a valid line, false otherwise.
     */
    bool IsValid();

    bool operator== (const Line&);
    bool operator!= (const Line&);
    Line();

    /// @cond PRIVATE_DOC 
    Line(TRN_TextExtractorLine impl);
    TRN_TextExtractorLine mp_line;
    /// @endcond
};

struct Highlight
{
    Highlight()
    {
        page_num = 0; //invalid
        position = 0;
        length = 0;
    }

    Highlight( int pg, int pos, int len ) : page_num(pg), position(pos), length(len)
    {}

    Highlight( const Highlight& hlt ) : page_num(hlt.page_num), position(hlt.position), length(hlt.length)
    {}

    int page_num;
    int position;
    int length;
};

/**
* BorderStyle structure specifies the characteristics of the annotation's border.
* The border is specified as a rounded rectangle.
*/
class BorderStyle
{
public: 
    /**
    * The border style
    */
    enum Style {
        e_solid,   ///< A solid rectangle surrounding the annotation.
        e_dashed,  ///< A dashed rectangle surrounding the annotation.
        e_beveled, ///< A simulated embossed rectangle that appears to be raised above the surface of the page.
        e_inset,   ///< A simulated engraved rectangle that appears to be recessed below the surface of the page. 
        e_underline  ///< A single line along the bottom of the annotation rectangle.
    };

    /**
    * Creates a new border style with given parameters.
    * @param s The border style.
    * @param b_width The border width expressed in the default user space.
    * @param b_hr The horizontal corner radius expressed in the default user space.
    * @param b_vr The vertical corner radius expressed in the default user space.
    * @param b_dash An array of numbers defining a pattern of dashes and gaps to be used 
    * in drawing the border. The dash array is specified in the same format as in the line 
    * dash pattern parameter of the graphics state except that the phase is assumed to be 0.
    * 
    * @note If the corner radii are 0, the border has square (not rounded) corners; if
    * the border width is 0, no border is drawn.
    */
    BorderStyle(Style s, double b_width, double b_hr =0, double b_vr =0);
    BorderStyle(Style s, double b_width, double b_hr, double b_vr, const std::vector<double>& b_dash);
    BorderStyle(const BorderStyle&);
    ~BorderStyle();

    /**
    * Frees the native memory of the object.
    */
    void Destroy();

    BorderStyle& operator=(const BorderStyle&);
    friend inline bool operator==( const BorderStyle& a, const BorderStyle& b );
    friend inline bool operator!=( const BorderStyle& a, const BorderStyle& b ) { return !( a == b ); }

    /**
    * @return the border style.
    */
    Style GetStyle() const;

    /**
    * Sets the border style.
    */
    void SetStyle(Style style);

    /**
    * @return horizontal corner radius.
    */
    double GetHR() const;

    /**
    * Sets horizontal corner radius.
    */
    void SetHR(double hr);

    /**
    * @return vertical corner radius.
    */
    double GetVR() const;

    /**
    * Sets vertical corner radius.
    */
    void SetVR(double vr);

    /**
    * @return the border width.
    */
    double GetWidth() const;

    /**
    * Sets the border width
    */
    void SetWidth(double width);

    /**
    * @return the border dash pattern.
    * @see BorderStyle()
    */
    std::vector<double> GetDash() const;

    /**
    * Sets the border dash pattern.
    * @see BorderStyle()
    */
    void SetDash( const std::vector<double>& dash);  

    BorderStyle(TRN_AnnotBorderStyle impl);
    BorderStyle() : mp_bs(0) {}
private: 
    friend class pdftron::PDF::Annot;
    TRN_AnnotBorderStyle mp_bs;
};

%nestedworkaround pdftron::PDF::Convert::Printer;
%nestedworkaround pdftron::PDF::Optimizer::ImageSettings;
%nestedworkaround pdftron::PDF::Optimizer::MonoImageSettings;
%nestedworkaround pdftron::PDF::PDFView::Selection;
%nestedworkaround pdftron::PDF::TextExtractor::Style;
%nestedworkaround pdftron::PDF::TextExtractor::Word;
%nestedworkaround pdftron::PDF::TextExtractor::Line;
%nestedworkaround pdftron::PDF::Highlights::Highlight;
%nestedworkaround pdftron::PDF::Convert::SVGOutputOptions;
%nestedworkaround pdftron::PDF::Convert::XPSOutputCommonOptions;
%nestedworkaround pdftron::PDF::Convert::XPSOutputOptions;
%nestedworkaround pdftron::PDF::Convert::XODOutputOptions;
%nestedworkaround pdftron::PDF::Convert::HTMLOutputOptions;
%nestedworkaround pdftron::PDF::Convert::EPUBOutputOptions;
%nestedworkaround pdftron::PDF::HTML2PDF::Proxy;
%nestedworkaround pdftron::PDF::HTML2PDF::WebPageSettings;
%nestedworkaround pdftron::PDF::HTML2PDF::TOCSettings;
%nestedworkaround pdftron::PDF::Redactor::Redaction;
%nestedworkaround pdftron::PDF::Redactor::Appearance;
%nestedworkaround pdftron::PDF::Annot::BorderStyle;
%nestedworkaround pdftron::PDF::Optimizer::TextSettings;
%nestedworkaround pdftron::PDF::Optimizer::OptimizerSettings;


//----------------------------------------------------------------------------------------------
// End of section for nested class fixes
//----------------------------------------------------------------------------------------------

// Include the remaining header files

%include "Filters/Filter.h"
%include "Filters/ASCII85Encode.h"
%include "Filters/FilterReader.h"
%include "Filters/FilterWriter.h"
%include "Filters/FlateEncode.h"
%include "Filters/MappedFile.h"
%include "SDF/DictIterator.h"
%include "SDF/SDFDoc.h"
%include "SDF/NameTree.h"
%include "SDF/NumberTree.h"
%include "SDF/Obj.h"
%include "SDF/ObjSet.h"
%include "SDF/SecurityHandler.h"
%include "PDF/Point.h"
%include "PDF/Function.h"
%include "PDF/ColorSpace.h"
%include "PDF/Rect.h"
%include "PDF/Page.h"
%include "PDF/Date.h"
%include "PDF/Field.h"
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
%include "PDF/Annots.h"
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
%include "PDF/Element.h"
%include "PDF/ElementBuilder.h"
%include "PDF/ElementReader.h"
%include "PDF/ElementWriter.h"
%include "PDF/Image/Image2RGB.h"
%include "PDF/Image/Image2RGBA.h"
%include "PDF/Highlights.h"
%include "PDF/Optimizer.h"
%include "PDF/PageLabel.h"
%include "PDF/PageSet.h"
%include "PDF/PDFDC.h"
%include "PDF/PDFDCEX.h"
%include "PDF/PDFDocInfo.h"
%include "PDF/PDFDocViewPrefs.h"
%include "PDF/PDFDoc.h"
%include "PDF/PDFRasterizer.h"
%include "PDF/PDFDraw.h"
%include "PDF/PDFNet.h"
%include "PDF/PDFView.h"
%include "PDF/Print.h"
%include "PDF/HTML2PDF.h"
%include "PDF/Stamper.h"
%include "PDF/TextExtractor.h"
%include "PDF/TextSearch.h"
%include "PDF/Redactor.h"
