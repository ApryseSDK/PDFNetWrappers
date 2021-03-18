#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

#---------------------------------------------------------------------------------------
# This sample explores the structure and content of a tagged PDF document and dumps 
# the structure information to the console window.
#
# In tagged PDF documents StructTree acts as a central repository for information 
# related to a PDF document's logical structure. The tree consists of StructElement-s
# and ContentItem-s which are leaf nodes of the structure tree.
#
# The sample can be extended to access and extract the marked-content elements such 
# as text and images.
#---------------------------------------------------------------------------------------

def PrintIndent(indent):
    sys.stdout.write("\n")
    i = 0
    while i < indent:
        sys.stdout.write("  ")
        i = i + 1
        
def ProcessStructElement(element, indent):
    if not element.IsValid():
        return
    
    # Print out the type and title info, if any.
    PrintIndent(indent)
    indent = indent + 1
    sys.stdout.write("Type: " + element.GetType())
    if element.HasTitle():
        sys.stdout.write(". Title:" + element.GetTitle())
    
    num = element.GetNumKids()
    i = 0
    while i < num:
        # Check if the kid is a leaf node (i.e. it is a ContentItem)
        if element.IsContentItem(i):
            cont = element.GetAsContentItem(i)
            type = cont.GetType()
            
            page = cont.GetPage()
            
            PrintIndent(indent)
            sys.stdout.write("Content Item. Part of page #" + str(page.GetIndex()))
            PrintIndent(indent)
            if type == ContentItem.e_MCID:
                sys.stdout.write("MCID: " + str(cont.GetMCID()))
            elif type == ContentItem.e_MCR:
                sys.stdout.write("MCID: " + str(cont.GetMCID()))
            elif type == ContentItem.e_OBJR:
                sys.stdout.write("OBJR ")
                ref_obj = cont.GetRefObj()
                if ref_obj != None:
                    sys.stdout.write("- Referenced Object#: " + str(ref_obj.GetObjNum()))
        else:
            ProcessStructElement(element.GetAsStructElem(i), indent)
        i = i + 1
    

# Used in code snippet 3.
def ProcessElements2(reader, mcid_page_map):
    element = reader.Next()
    while element != None: # Read page contents
        # In this sample we process only text, but the code can be extended
        # to handle paths, images, or other Element type.
        mcid = element.GetStructMCID()
        
        if mcid>=0 and element.GetType() == Element.e_text:
            val = element.GetTextString()
            
            if mcid in mcid_page_map:
                mcid_page_map[mcid] = str(mcid_page_map[mcid]) + val
            else:
                mcid_page_map[mcid] = val
        element = reader.Next()

# Used in code snippet 2.
def ProcessElements(reader):
    element = reader.Next()
    while element != None:  # Read page contents
        # In this sample we process only paths & text, but the code can be 
        # extended to handle any element type.
        type = element.GetType()
        if (type == Element.e_path or
            type == Element.e_text or
            type == Element.e_path):
            if type == Element.e_path:      # Process path ...
                sys.stdout.write("\nPATH: ")
            elif type == Element.e_text:    # Process text ...
                sys.stdout.write("\nTEXT: " + element.GetTextString() + "\n")
            elif type == Element.e_path:    # Process from XObjects
                sys.stdout.write("\nFORM XObject: ")
            
            # Check if the element is associated with any structural element.
            # Content items are leaf nodes of the structure tree.
            struct_parent = element.GetParentStructElement()
            if struct_parent.IsValid():
                # Print out the parent structural element's type, title, and object number.
                sys.stdout.write(" Type: " + str(struct_parent.GetType()) 
                                 + ", MCID: " + str(element.GetStructMCID()))
                if struct_parent.HasTitle():
                    sys.stdout.write(". Title: " + struct_parent.GetTitle())
                sys.stdout.write(", Obj#: " + str(struct_parent.GetSDFObj().GetObjNum()))
        element = reader.Next()
        
        
def ProcessStructElement2(element, mcid_doc_map, indent):
    if not element.IsValid():
        return
    
    # Print out the type and title info, if any
    PrintIndent(indent)
    sys.stdout.write("<" + element.GetType())
    if element.HasTitle():
        sys.stdout.write(" title=\"" + element.GetTitle() + "\"")
    sys.stdout.write(">")
    
    num = element.GetNumKids()
    i = 0
    while i < num:
        if element.IsContentItem(i):
            cont = element.GetAsContentItem(i)
            if cont.GetType() == ContentItem.e_MCID:
                page_num = cont.GetPage().GetIndex()
                if page_num in mcid_doc_map:
                    mcid_page_map = mcid_doc_map[page_num]
                    mcid_key = cont.GetMCID()
                    if mcid_key in mcid_page_map:
                        sys.stdout.write(mcid_page_map[mcid_key])
        else: # the kid is another StructElement node.
            ProcessStructElement2(element.GetAsStructElem(i), mcid_doc_map, indent+1)      
        i = i + 1
    PrintIndent(indent)
    sys.stdout.write("</" + element.GetType() + ">")
        

def main():
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # Extract logical structure from a PDF document
    doc = PDFDoc(input_path + "tagged.pdf")
    doc.InitSecurityHandler()
    
    print("____________________________________________________________")
    print("Sample 1 - Traverse logical structure tree...")
    
    tree = doc.GetStructTree()
    if tree.IsValid():
        print("Document has a StructTree root.")
        
        i = 0
        while i<tree.GetNumKids():
            # Recursively get structure info for all child elements.
            ProcessStructElement(tree.GetKid(i), 0)
            i = i + 1
    else:
        print("This document does not contain any logical structure.")
    
    print("\nDone 1.")

    print("____________________________________________________________")
    print("Sample 2 - Get parent logical structure elements from")
    print("layout elements.")
    
    reader = ElementReader()
    itr = doc.GetPageIterator()
    while itr.HasNext():
        reader.Begin(itr.Current())
        ProcessElements(reader)
        reader.End()
        itr.Next()
    
    print("\nDone 2.")
    
    print("____________________________________________________________")
    print("Sample 3 - 'XML style' extraction of PDF logical structure and page content.")
    # A map which maps page numbers(as Integers)
    # to page Maps(which map from struct mcid(as Integers) to
    # text Strings)
    mcid_doc_map = dict()
    reader = ElementReader()
    itr = doc.GetPageIterator()
    while itr.HasNext():
        reader.Begin(itr.Current())
        page_mcid_map = dict()
        mcid_doc_map[itr.Current().GetIndex()] = page_mcid_map
        ProcessElements2(reader, page_mcid_map)
        reader.End()
        itr.Next()  
    tree = doc.GetStructTree()
    if tree.IsValid():
        i = 0
        while i < tree.GetNumKids():
            ProcessStructElement2(tree.GetKid(i), mcid_doc_map, 0)
            i = i + 1  
    print("\nDone 3.")
    doc.Save((output_path + "LogicalStructure.pdf"), SDFDoc.e_linearized)
    doc.Close()        

if __name__ == '__main__':
    main()