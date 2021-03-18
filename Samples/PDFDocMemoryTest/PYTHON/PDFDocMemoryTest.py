#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

def main():
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # The following sample illustrates how to read/write a PDF document from/to 
    # a memory buffer.  This is useful for applications that work with dynamic PDF
    # documents that don't need to be saved/read from a disk.
    
    # Read a PDF document in a memory buffer.
    file = MappedFile(input_path + "tiger.pdf")
    file_sz = file.FileSize()
    
    file_reader = FilterReader(file)
    
    mem = file_reader.Read(file_sz)
    doc = PDFDoc(bytearray(mem), file_sz)
    doc.InitSecurityHandler()
    num_pages = doc.GetPageCount()
    
    writer = ElementWriter()
    reader = ElementReader()
    element = Element()
    
    # Create a duplicate of every page but copy only path objects
    
    i = 1
    while i <= num_pages:
        itr = doc.GetPageIterator(2*i - 1)
        
        reader.Begin(itr.Current())
        new_page = doc.PageCreate(itr.Current().GetMediaBox())
        next_page = itr
        next_page.Next()
        doc.PageInsert(next_page, new_page)
        
        writer.Begin(new_page)
        element = reader.Next()
        while element != None: # Read page contents
            #if element.GetType() == Element.e_path:
            writer.WriteElement(element)
            element = reader.Next()
        writer.End()
        reader.End()           
        i = i + 1
    
    doc.Save(output_path + "doc_memory_edit.pdf", SDFDoc.e_remove_unused)
    
    # Save the document to a memory buffer
    buffer = doc.Save(SDFDoc.e_remove_unused)
    
    # Write the contents of the buffer to the disk
    if sys.version_info.major >= 3:
        f = open(output_path + "doc_memory_edit.txt", "w")
    else:	
        f = open(output_path + "doc_memory_edit.txt", "wb")
    try:
        f.write(str(buffer))
    finally:
        f.close()
    
    # Read some data from the file stored in memory
    reader.Begin(doc.GetPage(1))
    element = reader.Next()
    while element != None:
        if element.GetType() == Element.e_path:
            sys.stdout.write("Path, ")
        element = reader.Next()
    reader.End()
    
    print("\n\nDone. Result saved in doc_memory_edit.pdf and doc_memory_edit.txt ...")

if __name__ == '__main__':
    main()
