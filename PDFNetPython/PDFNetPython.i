//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt for licensing information.
//----------------------------------------------------------------------------------------------------------------------

/**
 * PDFNetPython.i
 * SWIG interface file for Python
 */
%module(directors="1") PDFNetPython


/**
 * Different versions of UString typemap will be used pending
 * on the version of Python
 */
#ifdef PYTHON2
%include "PDFNetUStringPython2.i"
#endif
#ifdef PYTHON3
%include "PDFNetUStringPython3.i"
#endif

/**
 * Catches all exceptions thrown by the C++ wrapper.
 * "$action" represents the C++ method to be called.
 */
%include "exception.i"
%exception {
    try {
        $action
    } catch(pdftron::Common::Exception e) {
        PyErr_SetString(PyExc_Exception, e.GetMessage());
        return NULL;
    } catch(Swig::DirectorException e) {
        PyErr_SetString(PyExc_Exception, e.getMessage());
        return NULL;
    } catch (...) {
        PyErr_SetString(PyExc_Exception, "Unknown Exception");
        return NULL;
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

    // header files in /PDFNetC/Headers/PDF/PDFA
    #include "PDF/PDFA/PDFACompliance.h"

    // header files in /PDFNetC/Headers/PDF/Struct
    #include "PDF/Struct/AttrObj.h"
    #include "PDF/Struct/ClassMap.h"
    #include "PDF/Struct/ContentItem.h"
    #include "PDF/Struct/RoleMap.h"
    #include "PDF/Struct/SElement.h"
    #include "PDF/Struct/STree.h"

    // header files in /PDFNetC/Headers/PDF
    #include "PDF/ViewChangeCollection.h"
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

    #undef GetMessage
    #undef SetPort
%}

/**
 * Provides mapping for C++ vectors.
 * For example, vector<double> will be called as VectorDouble in Python.
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
        class ViewChangeCollection;
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
 * python list to char** (map to String[] in java wrapper)
 * The following typemap is dependent on the python version.
 */
%typemap (in) char** {
    if (!PyList_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a list");
        return NULL;
    }
    int size = PyList_Size($input);
    char** arr;

    int i = 0;
    for (i = 0; i < size; i++) {
    #ifdef PYTHON2
        if (PyString_Check(PyList_GetItem($input, i))) {
            arr[i] = (char*)PyString_AsString(PyList_GetItem($input, i));
        }
    #endif
    #ifdef PYTHON3 
        if (PyUnicode_Check(PyList_GetItem($input, i))) {
            arr[i] = (char*)PyUnicode_AS_DATA(PyList_GetItem($input, i));
        }
    #endif
        else {
            PyErr_SetString(PyExc_ValueError,"Expected a string");
            return NULL;
        }
    }

    $1 = arr;
}

%typemap (typecheck) char** {
    $1 = PyList_Check($input) ? 1 : 0;
}

//----------------------------------------------------------------------------------------------

/** 
 * Typemapping for enums
 * Python can takes in an integer which is then converted to an enum
 * in the wrapper. The following mapping is needed because ErrorCode is
 * passed in as a pointer
 */
%typemap (in) pdftron::PDF::PDFA::PDFACompliance::ErrorCode* 
{
    // converts python int to C long
    long $temp = PyInt_AsLong($input);
    if ($temp == -1) {
        // checks whether -1 is returned because an exception occured, or
        // the value is originally -1. Assign the argument as -1 if no exception
        PyObject* exp = PyErr_Occurred();
        if (exp) {
            PyErr_SetString(exp, "PDFACompliance::Errorcode conversion error.");
        }
        else {
            $1 = (pdftron::PDF::PDFA::PDFACompliance::ErrorCode*)&$temp;
        }
    }
    else {
        $1 = (pdftron::PDF::PDFA::PDFACompliance::ErrorCode*)&$temp;
    }
}

%typemap (typecheck) pdftron::PDF::PDFA::PDFACompliance::ErrorCode* {
    $1 = PyInt_Check($input) ? 1 : 0;
}

//----------------------------------------------------------------------------------------------
/** 
 * Ignoring one of the overloaded methods
 */

%ignore pdftron::PDF::RectCollection::AddRect(double, double, double, double);

//----------------------------------------------------------------------------------------------

/**
 * Treats volatile bool* as a regular bool*
 */
%apply bool* INPUT {volatile bool*}

//----------------------------------------------------------------------------------------------

/**
 * This version only works for Python 2
 * Maps a Python list of integers or strings to Unicode*
 */
#ifdef PYTHON2
%typemap(in) const pdftron::Unicode* text_data 
{ 
    Unicode* $temp = new Unicode[PyList_Size($input)];
    int i;

    for (i = 0; i < PyList_Size($input); i++) {
        // Get item from list
        PyObject* $str = PyList_GetItem($input, i);
        // Checks the item to be either string or integer
        if (!(PyString_Check($str) || PyInt_Check($str))) {
            PyErr_SetString(PyExc_ValueError,"Expected a character or integer");
            return NULL;
        }
        if (PyString_Check($str)) {
            // Ensure String only contains 1 character
            if (PyString_Size($str) != 1) {
                PyErr_SetString(PyExc_ValueError,"Only one character allowed per list item");
                return NULL;
            }
            char* $temp1 = (char*)PyString_AsString($str);
            $temp[i] = (pdftron::Unicode)*$temp1;
        }
        else if (PyInt_Check($str)) {
            $temp[i] = (pdftron::Unicode)PyInt_AsLong($str);
        }
    }
    $1 = (pdftron::Unicode *) $temp;
}
#endif

/**
 * This version only works for Python 3
 * Maps a Python list of integers or strings to Unicode*
 */
#ifdef PYTHON3
%typemap(in) const pdftron::Unicode* text_data 
{ 
    Unicode* $temp = new Unicode[PyList_Size($input)];
    int i;
    for (i = 0; i < PyList_Size($input); i++) {
        // Get item from list
        PyObject* $str = PyList_GetItem($input, i);
        // Checks the item to be either unicode or integer
        if (!(PyInt_Check($str) || PyUnicode_Check($str))) {
            PyErr_SetString(PyExc_ValueError,"Expected a character or integer");
            return NULL;
        }
        if (PyUnicode_Check($str)) {
            // Ensure String only contains 1 character
            if (PyUnicode_GET_SIZE($str) != 1) {
                PyErr_SetString(PyExc_ValueError,"Only one character allowed per list item");
                return NULL;
            }
            char* $temp1 = (char*)PyUnicode_AS_DATA($str);
            $temp[i] = (pdftron::Unicode)*$temp1;
        }
        else {
            $temp[i] = (pdftron::Unicode)PyInt_AsLong($str);
        }
    }
    $1 = (pdftron::Unicode *) $temp;
}
#endif

%typemap(typecheck) const pdftron::Unicode* text_data  {
    $1 = PyList_Check($input) ? 1 : 0;
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
 * Maps Python list (of floats) to C++ vector<double>
 */
%typemap(in) std::vector<double> {
    std::vector<double> $vec(PyList_Size($input));
    int i = 0;
    for (i = 0; i < PyList_Size($input); i++) {
        PyObject* $obj = PyList_GetItem($input, i);
        if (!PyFloat_Check($obj)) {
            PyErr_SetString(PyExc_ValueError,"Expected a float");
            return NULL;
        }
        $vec[i] = PyFloat_AsDouble($obj);
    }
    $1 = $vec;
}

/**
 * Maps Python list (of floats) to C++ vector<double>&
 */
%typemap(in) std::vector<double>& {
    std::vector<double>* vec$argnum = new std::vector<double>(PyList_Size($input));
    int i$argnum = 0;
    for (i$argnum = 0; i$argnum < PyList_Size($input); i$argnum++) {
        PyObject* $obj = PyList_GetItem($input, i$argnum);
        if (!PyFloat_Check($obj)) {
            PyErr_SetString(PyExc_ValueError,"Expected a float");
            return NULL;
        }
        (*vec$argnum)[i$argnum] = PyFloat_AsDouble($obj);
    }
    $1 = vec$argnum;
}

%typemap(freearg) std::vector<double>&
%{
    delete ($1);
%}

%typemap(typecheck) std::vector<double>  {
    $1 = PyList_Check($input) ? 1 : 0;
}

//----------------------------------------------------------------------------------------------

/**
 * Maps Python bytearray to unsigned char *
 */
%typemap(in) (unsigned char *)
{
  if (!PyByteArray_Check($input)) {
    PyErr_SetString(PyExc_ValueError,"Expected a byteArray");
    return NULL;
  }
  $1 = (unsigned char *)PyByteArray_AsString($input);
}

%typemap(typecheck) unsigned char *  {
    $1 = PyByteArray_Check($input) ? 1 : 0;
}

/**
 * Maps std::vector<unsigned char> to bytearray
 */
%typemap(out) std::vector<unsigned char> {
    $result = PyByteArray_FromStringAndSize((const char*)&$1[0], (int)$1.size());
}

//----------------------------------------------------------------------------------------------
/**
 * Maps Python bytearray to std::vector<unsigned char>
 */
%typemap(in) std::vector<unsigned char>{
    int size = PyByteArray_Size($input);
    unsigned char* $arr = (unsigned char*)PyByteArray_AsString($input);
    std::vector<unsigned char> $vec;
    $vec.resize(size);
    memcpy(&$vec[0], $arr, size);
    $1 = $vec;
}

%typemap(typecheck) std::vector<unsigned char> {
    $1 = PyByteArray_Check($input) ? 1 : 0;
}
//----------------------------------------------------------------------------------------------
/**
 * Typemap for directors
 */
/* std::vector<unsigned char> -> Python bytearray */
%typemap(directorin) std::vector<pdftron::UInt8>
{
    $1 = PyByteArray_FromStringAndSize((const char*) &$input[0], (int) $input.size());
}
/* Python bytearray -> std::vector<unsigned char> */
%typemap(directorout) std::vector<pdftron::UInt8>
{
    int size = PyByteArray_Size($1);
    unsigned char* ucptr = (unsigned char*) PyByteArray_AsString($1);
    std::vector<unsigned char> ucvec;
    ucvec.resize(size);
    memcpy(&(ucvec[0]), ucptr, size);
    $result = ucvec;
}
/* std::vector<unsigned char>& -> Python bytearray */
%typemap(directorin) const std::vector<pdftron::UInt8>&
%{
    $input = PyByteArray_FromStringAndSize((const char*) &$1_name[0], (int) $1_name.size());
%}



//----------------------------------------------------------------------------------------------
/**
 * Typemap to ensure Python None is returned if a C++ function returns NULL.
 * Without the following, SWIG would wrap the NULL object, causing the following
 * Python statement: nullElement == None, to be false.
 */
%typemap(out) pdftron::PDF::Element 
%{  
    if ($1) {
        $result = SWIG_NewPointerObj((new pdftron::PDF::Element(static_cast< const pdftron::PDF::Element& >(result))), SWIGTYPE_p_pdftron__PDF__Element, SWIG_POINTER_OWN |  0 );
        return $result;
    }
    Py_INCREF(Py_None);
    $result = Py_None;
%}


%typemap(out) pdftron::SDF::Obj 
%{  
    if ($1) {
        $result = SWIG_NewPointerObj((new pdftron::SDF::Obj(static_cast< const pdftron::SDF::Obj& >(result))), SWIGTYPE_p_pdftron__SDF__Obj, SWIG_POINTER_OWN |  0 );
        return $result;
    }
    Py_INCREF(Py_None);
    $result = Py_None;
%}

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
//%feature("director") SecurityHandler;
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
%include "PDF/ViewChangeCollection.h"
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
%include "PDF/OCROptions.h"
%include "PDF/OCRModule.h"
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

//Rename to prevent naming conflict against Line.h
%include "PDF/TextExtractor.h"

%include "PDF/TextSearch.h"

//Rename to prevent naming conflict between nested class Redaction and Redaction.h
//#define Redaction Redaction
%include "PDF/Redactor.h"
//#undef Redaction
