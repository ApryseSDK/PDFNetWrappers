#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

#-----------------------------------------------------------------------------------
# The sample illustrates how multiple pages can be combined/imposed 
# using PDFNet. Page imposition can be used to arrange/order pages 
# prior to printing or to assemble a 'master' page from several 'source' 
# pages. Using PDFNet API it is possible to write applications that can 
# re-order the pages such that they will display in the correct order 
# when the hard copy pages are compiled and folded correctly. 
#-----------------------------------------------------------------------------------

def main(args):
    PDFNet.Initialize()
    
    resource_path = args[3] if len(args) > 3 else "../../../resources"
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/newsletter.pdf"
    output_path = "../../TestFiles/Output/newsletter_booklet.pdf"
    
    print("-------------------------------------------------")
    print("Opening the input pdf...")
    
    filein = args[1] if len(args)>1 else input_path
    fileout = args[2] if len(args)>2 else output_path
    
    in_doc = PDFDoc(filein)
    in_doc.InitSecurityHandler()
    
    # Create a list of pages to import from one PDF document to another
    import_pages = VectorPage()
    itr = in_doc.GetPageIterator()
    while itr.HasNext():
        import_pages.append(itr.Current())
        itr.Next()

    new_doc = PDFDoc()
    imported_pages = new_doc.ImportPages(import_pages)

    # Paper dimension for A3 format in points. Because one inch has 
    # 72 points, 11.69 inch 72 = 841.69 points
    media_box = Rect(0, 0, 1190.88, 841.69)
    mid_point = media_box.Width()/2

    builder = ElementBuilder()
    writer = ElementWriter()

    i = 0    
    while i < len(imported_pages):
        # Create a blank new A3 page and place on it two pages from the input document.
        new_page = new_doc.PageCreate(media_box)
        writer.Begin(new_page)
        
        # Place the first page
        src_page = imported_pages[i]
        
        element = builder.CreateForm(imported_pages[i])
        sc_x = mid_point / src_page.GetPageWidth()
        sc_y = media_box.Height() / src_page.GetPageHeight()
        scale = sc_x if sc_x < sc_y else sc_y # min(sc_x, sc_y)
        element.GetGState().SetTransform(scale, 0, 0, scale, 0, 0)
        writer.WritePlacedElement(element)
        
        # Place the second page
        i = i + 1
        if i < len(imported_pages):
            src_page = imported_pages[i]
            element = builder.CreateForm(src_page)
            sc_x = mid_point / src_page.GetPageWidth()
            sc_y = media_box.Height() / src_page.GetPageHeight()
            scale = sc_x if sc_x < sc_y else sc_y # min(sc_x, sc_y)
            element.GetGState().SetTransform(scale, 0, 0, scale, mid_point, 0)
            writer.WritePlacedElement(element)
            
        writer.End()
        new_doc.PagePushBack(new_page)
        i = i + 1
        
    new_doc.Save(fileout, SDFDoc.e_linearized)
    print("Done. Result saved in newsletter_booklet.pdf...")
    
if __name__ == '__main__':
    args = []
    main(args)