/* pdftron.i */
 %module(directors="1") pdftron
 //---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult legal.txt regarding legal and license information.
//---------------------------------------------------------------------------------------

%include "pdftron_ustring.i"

%{
#define SWIG
    // header files from PDFNet SDK
	#include "C/Common/TRN_Exception.h"
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
    #include "PDF/CMSSignatureOptions.h"
    #include "PDF/DigitalSignatureField.h"
    #include "PDF/FileSpec.h"
    #include "PDF/Flattener.h"
    #include "PDF/PathData.h"
    #include "PDF/Font.h"
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
	#include "PDF/RectCollection.h"
    #include "PDF/Redactor.h"
    #include "PDF/Shading.h"
    #include "PDF/Stamper.h"
    #include "PDF/TextExtractor.h"
    #include "PDF/TextSearch.h"
    #include "PDF/WebFontDownloader.h"
    #include "PDF/PrintToPdfOptions.h"
    #include "PDF/PrintToPdfModule.h"

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

%include "exception.i"
%exception {
    try {
        $action;
    } catch (std::exception &e) {
        _swig_gopanic(e.what());
    }
}

%typemap(goout) pdftron::SDF::Obj
%{
    // Without the brackets, swig attempts to turn $1 into a c++ dereference.. seems like a bug
    if ($1).GetMp_obj().Swigcptr() != 0 {
        $result = $1
        return $result
    }

    $result = nil
%}

/**
 * Provides mapping for C++ vectors.
 * For example, vector<double> will be called as VectorDouble in GoLang.
 */
%include "std_string.i"
%include "std_vector.i"
namespace std {
   %template(VectorDouble) vector<double>;
   %template(VectorObj) vector<pdftron::SDF::Obj>;
   %template(VectorPage) vector<pdftron::PDF::Page>;
   %template(VectorUnChar) vector<unsigned char>;
   %template(VectorUChar) vector<UChar>;
   %template(VectorChar) vector<char>;
   %template(VectorInt) vector<int>;
   %template(VectorUInt) vector<unsigned int>;
   %template(VectorString) vector<std::string>;
   %template(VectorRedaction) vector<pdftron::PDF::Redaction>;
   %template(VectorQuadPoint) vector<pdftron::PDF::QuadPoint>;
   %template(VectorSeparation) vector<pdftron::PDF::Separation>;
   %template(VectorDisallowedChange) vector<pdftron::PDF::DisallowedChange>;
   %template(VectorAnnot) vector<pdftron::PDF::Annot>;
   %template(VectorX509Extension) vector<pdftron::Crypto::X509Extension>;
   %template(VectorX509Certificate) vector<pdftron::Crypto::X509Certificate>;
   %template(VectorX501AttributeTypeAndValue) vector<pdftron::Crypto::X501AttributeTypeAndValue>;
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

/**
 * Turns on the director feature for the following classes.
 * C++ equivalent of a proxy class. User extends this class in GOLang
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

%feature("director") Separation;
%{
#include "PDF/PDFRasterizer.h"
%}
%include "PDF/PDFRasterizer.h"

%feature("director") SignatureHandler;
%{
#include <SDF/SignatureHandler.h>
%}

%include "C/Common/TRN_Types.h"
%include <SDF/SignatureHandler.h>

%feature("director") Rect;
%{
#include "PDF/Rect.h"
%}
%include "PDF/Rect.h"

%feature("director") Date;
%{
#include "PDF/Date.h"
%}
%include "PDF/Date.h"

//----------------------------------------------------------------------------------------------
// Fixes overloaded methods

%rename (WriteInt16) pdftron::Filters::FilterWriter::WriteInt(Int16);
%rename (WriteInt32) pdftron::Filters::FilterWriter::WriteInt(Int32);
%rename (WriteInt64) pdftron::Filters::FilterWriter::WriteInt(Int64);
%rename (WriteUInt16) pdftron::Filters::FilterWriter::WriteInt(UInt16);
%rename (WriteUInt32) pdftron::Filters::FilterWriter::WriteInt(UInt32);
%rename (WriteUInt64) pdftron::Filters::FilterWriter::WriteInt(UInt64);
%rename (IsEqual) operator==;

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

%include "C/Common/TRN_Exception.h"

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
%include "SDF/SecurityHandler.h"
%include "SDF/PDFTronCustomSecurityHandler.h"
%include "PDF/Point.h"
%include "PDF/Function.h"
%include "PDF/ColorSpace.h"
%include "PDF/RectCollection.h"
%include "PDF/Page.h"
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
%include "FDF/FDFField.h"
%include "FDF/FDFDoc.h"
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
%include "PDF/SVGConvertOptions.h"
%include "PDF/DataExtractionOptions.h"
%include "PDF/Convert.h"
%include "PDF/DataExtractionModule.h"
%include "PDF/PathData.h"
%include "PDF/Font.h"
%include "PDF/Shading.h"
%include "PDF/PatternColor.h"
%include "PDF/GState.h"
%include "PDF/Image.h"
%include "PDF/PageLabel.h"
%include "PDF/ViewerOptimizedOptions.h"
%include "PDF/PDFDocViewPrefs.h"
%include "PDF/PDFDocInfo.h"
%include "PDF/PDFDoc.h"
%include "PDF/PrintToPdfOptions.h"
%include "PDF/PrintToPdfModule.h"

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

//Extend Initialize method to call overloaded one internally
%extend pdftron::PDFNet{
        public:
        static void Initialize(const char* license_key = 0) { 
            pdftron::PDFNet::Initialize(license_key, "{\"language\": \"Golang\"}");
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
%include "PDF/Print.h"
%include "PDF/HTML2PDF.h"
%include "PDF/Stamper.h"
%include "PDF/TextExtractor.h"
%include "PDF/TextSearch.h"
%include "PDF/Redactor.h"

