#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys, os
from PDFNetPython import *

#-----------------------------------------------------------------------------------
# This sample illustrates how to create, extract, and manipulate PDF Portfolios
# (a.k.a. PDF Packages) using PDFNet SDK.
#-----------------------------------------------------------------------------------

def AddPackage(doc, file, desc):
    files = NameTree.Create(doc.GetSDFDoc(), "EmbeddedFiles")
    fs = FileSpec.Create(doc.GetSDFDoc(), file, True)
    key = bytearray(file, "utf-8")
    files.Put(key, len(key), fs.GetSDFObj())
    fs.SetDesc(desc)
    
    collection = doc.GetRoot().FindObj("Collection")
    if collection is None:
        collection = doc.GetRoot().PutDict("Collection")
    
    # You could here manipulate any entry in the Collection dictionary. 
    # For example, the following line sets the tile mode for initial view mode
    # Please refer to section '2.3.5 Collections' in PDF Reference for details.
    collection.PutName("View", "T");
    
def AddCoverPage(doc):
    # Here we dynamically generate cover page (please see ElementBuilder 
    # sample for more extensive coverage of PDF creation API).
    page = doc.PageCreate(Rect(0, 0, 200, 200))
    
    b = ElementBuilder()
    w = ElementWriter()
    
    w.Begin(page)
    font = Font.Create(doc.GetSDFDoc(), Font.e_helvetica)
    w.WriteElement(b.CreateTextBegin(font, 12))
    e = b.CreateTextRun("My PDF Collection")
    e.SetTextMatrix(1, 0, 0, 1, 50, 96)
    e.GetGState().SetFillColorSpace(ColorSpace.CreateDeviceRGB())
    e.GetGState().SetFillColor(ColorPt(1, 0, 0))
    w.WriteElement(e)
    w.WriteElement(b.CreateTextEnd())
    w.End()
    doc.PagePushBack(page)
    
    # Alternatively we could import a PDF page from a template PDF document
    # (for an example please see PDFPage sample project).
    # ...
    

def main():
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # Create a PDF Package.
    doc =PDFDoc()
    AddPackage(doc, input_path + "numbered.pdf", "My File 1")
    AddPackage(doc, input_path + "newsletter.pdf", "My Newsletter...")
    AddPackage(doc, input_path + "peppers.jpg", "An image")
    AddCoverPage(doc)
    doc.Save(output_path + "package.pdf", SDFDoc.e_linearized)
    doc.Close()
    print("Done.")
    
    # Extract parts from a PDF Package
    doc = PDFDoc(output_path + "package.pdf")
    doc.InitSecurityHandler()
    
    files = NameTree.Find(doc.GetSDFDoc(), "EmbeddedFiles")
    if files.IsValid():
        # Traverse the list of embedded files.
        i = files.GetIterator()
        counter = 0
        while i.HasNext():
            entry_name = i.Key().GetAsPDFText()
            print("Part: " + entry_name)
            file_spec = FileSpec(i.Value())
            stm = Filter(file_spec.GetFileData())
            if stm != None:
                stm.WriteToFile(output_path + "extract_" + str(counter) + os.path.splitext(entry_name)[1], False)
            
            i.Next()
            counter = counter + 1
    doc.Close()
    print("Done.")

if __name__ == '__main__':
    main()
