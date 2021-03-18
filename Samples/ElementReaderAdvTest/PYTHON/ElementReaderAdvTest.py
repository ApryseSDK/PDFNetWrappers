#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

def ProcessPath(reader, path):
    if path.IsClippingPath():
        print("This is a clipping path")
    
    pathData = path.GetPathData()
    data = pathData.GetPoints()
    opr = pathData.GetOperators()

    opr_index = 0
    opr_end = len(opr)
    data_index = 0
    data_end = len(data)
    
    # Use path.GetCTM() if you are interested in CTM (current transformation matrix).
    
    sys.stdout.write("Path Data Points := \"")
    
    while opr_index < opr_end:
        if opr[opr_index] == PathData.e_moveto:
            x1 = data[data_index] 
            data_index = data_index + 1
            y1 = data[data_index]
            data_index = data_index + 1
            sys.stdout.write("M" + str(x1) + " " + str(y1))
        elif opr[opr_index] == PathData.e_lineto:
            x1 = data[data_index] 
            data_index = data_index + 1
            y1 = data[data_index]
            data_index = data_index + 1
            sys.stdout.write(" L" + str(x1) + " " + str(y1))
        elif opr[opr_index] == PathData.e_cubicto:
            x1 = data[data_index]
            data_index = data_index + 1
            y1 = data[data_index]
            data_index = data_index + 1
            x2 = data[data_index]
            data_index = data_index + 1
            y2 = data[data_index]
            data_index = data_index + 1
            x3 = data[data_index]
            data_index = data_index + 1
            y3 = data[data_index]
            data_index = data_index + 1
            sys.stdout.write(" C" + str(x1) + " " + str(y1) + " " + str(x2) + 
                             " " + str(y2) + " " + str(x3) + " " + str(y3))
        elif opr[opr_index] == PathData.e_rect:
            x1 = data[data_index]
            data_index = data_index + 1
            y1 = data[data_index]
            data_index = data_index + 1
            w = data[data_index]
            data_index = data_index + 1
            h = data[data_index]
            data_index = data_index + 1
            x2 = x1 + w
            y2 = y1
            x3 = x2
            y3 = y1 + h
            x4 = x1
            y4 = y3
            sys.stdout.write("M" + str(x1) + " " + str(y1) + " L" + str(x2) + " " + str(y2) + " L" + 
                             str(x3) + " " + str(y3) + " L" + str(x4) + " " + str(y4) + " Z")
        elif opr[opr_index] == PathData.e_closepath:
            print(" Close Path")
        else:
            assert(False)
        opr_index = opr_index + 1
    
    sys.stdout.write("\" ")
    gs = path.GetGState()
    
    # Set Path State 0 (stroke, fill, fill-rule) -----------------------------------
    if path.IsStroked():
        print("Stroke path")
        
        if (gs.GetStrokeColorSpace().GetType() == ColorSpace.e_pattern):
            print("Path has associated pattern")
        else:
            # Get stroke color (you can use PDFNet color conversion facilities)
            # rgb = gs.GetStrokeColorSpace().Convert2RGB(gs.GetStrokeColor())
            pass
    else:
        pass;
        # Do not stroke path
        
    if path.IsFilled():
        print("Fill path")
        
        if (gs.GetFillColorSpace().GetType() == ColorSpace.e_pattern):
            print("Path has associated pattern")
        else:
            # rgb = gs.GetFillColorSpace().Convert2RGB(gs.GetFillColor())
            pass
    else:
        pass
        # Do not fill path
    
    # Process any changes in graphics state  ---------------------------------
    gs_itr = reader.GetChangesIterator()
    while gs_itr.HasNext():
        if gs_itr.Current() == GState.e_transform:
            # Get transform matrix for this element. Unlike path.GetCTM() 
            # that return full transformation matrix gs.GetTransform() return 
            # only the transformation matrix that was installed for this element.
            #
            # gs.GetTransform()
            pass
        elif gs_itr.Current() == GState.e_line_width:
            # gs.GetLineWidth()
            pass
        elif gs_itr.Current() == GState.e_line_cap:
            # gs.GetLineCap()
            pass
        elif gs_itr.Current() == GState.e_line_join:
            # gs.GetLineJoin()
            pass
        elif gs_itr.Current() == GState.e_flatness:
            pass
        elif gs_itr.Current() == GState.e_miter_limit:
            # gs.GetMiterLimit()
            pass
        elif gs_itr.Current() == GState.e_dash_pattern:
            # dashes = gs.GetDashes()
            # gs.GetPhase()
            pass
        elif gs_itr.Current() == GState.e_fill_color:
            if (gs.GetFillColorSpace().GetType() == ColorSpace.e_pattern and
                gs.GetFillPattern().GetType() != PatternColor.e_shading ):
                # process the pattern data
                reader.PatternBegin(True)
                ProcessElements(reader)
                reader.End()
        gs_itr.Next()
    reader.ClearChangeList()
    
def ProcessText (page_reader):
    # Begin text element
    print("Begin Text Block:")
    
    element = page_reader.Next()
    
    while element != None:
        type = element.GetType()
        if type == Element.e_text_end:
            # Finish the text block
            print("End Text Block.")
            return
        elif type == Element.e_text:
            gs = element.GetGState()
            
            cs_fill = gs.GetFillColorSpace()
            fill = gs.GetFillColor()
            
            out = cs_fill.Convert2RGB(fill)
            
            cs_stroke = gs.GetStrokeColorSpace()
            stroke = gs.GetStrokeColor()
            
            font = gs.GetFont()
            print("Font Name: " + font.GetName())
            # font.IsFixedWidth()
            # font.IsSerif()
            # font.IsSymbolic()
            # font.IsItalic()
            # ... 

            # font_size = gs.GetFontSize()
            # word_spacing = gs.GetWordSpacing()
            # char_spacing = gs.GetCharSpacing()
            # txt = element.GetTextString()
            if font.GetType() == Font.e_Type3:
                # type 3 font, process its data
                itr = element.GetCharIterator()
                while itr.HasNext():
                    page_reader.Type3FontBegin(itr.Current())
                    ProcessElements(page_reader)
                    page_reader.End()
            else:
                text_mtx = element.GetTextMatrix()
                
                itr = element.GetCharIterator()
                while itr.HasNext():
                    char_code = itr.Current().char_code
                    if char_code>=32 and char_code<=255:     # Print if in ASCII range...
                        a = font.MapToUnicode(char_code)
                        sys.stdout.write( a[0] if sys.version_info.major < 3 else ascii(a[0]) )
                        
                    pt = Point()   
                    pt.x = itr.Current().x     # character positioning information
                    pt.y = itr.Current().y
                    
                    # Use element.GetCTM() if you are interested in the CTM 
                    # (current transformation matrix).
                    ctm = element.GetCTM()
                    
                    # To get the exact character positioning information you need to 
                    # concatenate current text matrix with CTM and then multiply 
                    # relative positioning coordinates with the resulting matrix.
                    mtx = ctm.Multiply(text_mtx)
                    mtx.Mult(pt)
                    itr.Next()
            print("")
        element = page_reader.Next()
    
def ProcessImage (image):
    image_mask = image.IsImageMask()
    interpolate = image.IsImageInterpolate()
    width = image.GetImageWidth()
    height = image.GetImageHeight()
    out_data_sz = width * height * 3
    
    print("Image: width=\"" + str(width) + "\"" + " height=\"" + str(height))
    
    # Matrix2D& mtx = image->GetCTM() # image matrix (page positioning info)

    # You can use GetImageData to read the raw (decoded) image data
    #image->GetBitsPerComponent()    
    #image->GetImageData()    # get raw image data
    # .... or use Image2RGB filter that converts every image to RGB format,
    # This should save you time since you don't need to deal with color conversions, 
    # image up-sampling, decoding etc.
    
    img_conv = Image2RGB(image)     # Extract and convert image to RGB 8-bps format
    reader = FilterReader(img_conv)

    image_data_out = reader.Read(out_data_sz)
    
    # Note that you don't need to read a whole image at a time. Alternatively
    # you can read a chuck at a time by repeatedly calling reader.Read(buf, buf_sz) 
    # until the function returns 0. 

def ProcessElements(reader):
    element = reader.Next()     # Read page contents
    while element != None:
        type = element.GetType()
        if type == Element.e_path:      # Process path data...
            ProcessPath(reader, element)
        elif type == Element.e_text_begin:      # Process text block...
            ProcessText(reader)
        elif type == Element.e_form:    # Process form XObjects
            reader.FormBegin()
            ProcessElements(reader)
            reader.End()
        elif type == Element.e_image:    # Process Images
            ProcessImage(element)
        element = reader.Next()

if __name__ == '__main__':
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # Extract text data from all pages in the document
    
    print("__________________________________________________")
    print("Extract page element information from all ")
    print("pages in the document.")
    
    doc = PDFDoc(input_path + "newsletter.pdf")
    doc.InitSecurityHandler()
    pgnum = doc.GetPageCount()
    page_begin = doc.GetPageIterator()
    page_reader = ElementReader()
    
    itr = page_begin
    while itr.HasNext():    # Read every page
        print("Page " + str(itr.Current().GetIndex()) + "----------------------------------------")
        page_reader.Begin(itr.Current())
        ProcessElements(page_reader)
        page_reader.End()
        itr.Next()
    doc.Close()
    print("Done.")
