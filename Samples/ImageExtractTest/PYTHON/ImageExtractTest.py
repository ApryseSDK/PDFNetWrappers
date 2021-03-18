#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

#-----------------------------------------------------------------------------------
# This sample illustrates one approach to PDF image extraction 
# using PDFNet.
# 
# Note: Besides direct image export, you can also convert PDF images 
# to GDI+ Bitmap, or extract uncompressed/compressed image data directly 
# using element.GetImageData() (e.g. as illustrated in ElementReaderAdv 
# sample project).
#-----------------------------------------------------------------------------------

image_counter = 0

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

def ImageExtract(reader):
    element = reader.Next()
    while element != None:
        if (element.GetType() == Element.e_image or
            element.GetType() == Element.e_inline_image):
            global image_counter
            image_counter =image_counter + 1
            print("--> Image: " + str(image_counter))
            print("    Width: " + str(element.GetImageWidth()))
            print("    Height: " + str(element.GetImageHeight()))
            print("    BPC: " + str(element.GetBitsPerComponent()))
            
            ctm = element.GetCTM()
            x2 = 1
            y2 = 1
            pt = Point(x2, y2)
            point = ctm.Mult(pt)
            print("    Coords: x1=%.2f, y1=%.2f, x2=%.2f, y2=%.2f" % (ctm.m_h, ctm.m_v, point.x, point.y))
            
            if element.GetType() == Element.e_image:
                image = Image(element.GetXObject())
                
                fname = "image_extract1_" + str(image_counter)
                
                path = output_path + fname
                image.Export(path)
                
                #path = output_path + fname + ".tif"
                #image.ExportAsTiff(path)
                
                #path = output_path + fname + ".png"
                #image.ExportAsPng(path)
        elif element.GetType() == Element.e_form:
            reader.FormBegin()
            ImageExtract(reader)
            reader.End()            
        element = reader.Next()

def main():
    # Initialize PDFNet
    PDFNet.Initialize()    
    
    # Example 1: 
    # Extract images by traversing the display list for 
    # every page. With this approach it is possible to obtain 
    # image positioning information and DPI.
    
    doc = PDFDoc(input_path + "newsletter.pdf")
    doc.InitSecurityHandler()
    
    reader = ElementReader()
    
    # Read every page
    itr = doc.GetPageIterator()
    while itr.HasNext():
        reader.Begin(itr.Current())
        ImageExtract(reader)
        reader.End()
        itr.Next()

    doc.Close()
    print("Done.")
    
    print("----------------------------------------------------------------")
    
    # Example 2: 
    # Extract images by scanning the low-level document.
    
    doc = PDFDoc(input_path + "newsletter.pdf")
    doc.InitSecurityHandler()
    image_counter= 0
    
    cos_doc = doc.GetSDFDoc()
    num_objs = cos_doc.XRefSize()
    i = 1
    while i < num_objs:
        obj = cos_doc.GetObj(i)
        if(obj is not None and not obj.IsFree() and obj.IsStream()):
            
            # Process only images
            itr = obj.Find("Type")
            
            if not itr.HasNext() or not itr.Value().GetName() == "XObject":
                i = i + 1
                continue
            
            itr = obj.Find("Subtype")
            if not itr.HasNext() or not itr.Value().GetName() == "Image":
                i = i + 1
                continue
            
            image = Image(obj)
            
            image_counter = image_counter + 1
            print("--> Image: " + str(image_counter))
            print("    Width: " + str(image.GetImageWidth()))
            print("    Height: " + str(image.GetImageHeight()))
            print("    BPC: " + str(image.GetBitsPerComponent()))
            
            fname = "image_extract2_" + str(image_counter)
                
            path = output_path + fname
            image.Export(path)
            
            #path = output_path + fname + ".tif"
            #image.ExportAsTiff(path)
            
            #path = output_path + fname + ".png"
            #image.ExportAsPng(path)
        i = i + 1
    doc.Close()
    print("Done.")
    
if __name__ == '__main__':
    main()
