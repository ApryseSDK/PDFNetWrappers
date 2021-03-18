#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

#---------------------------------------------------------------------------------------
# PDFNet includes a full support for FDF (Forms Data Format) and capability to merge/extract 
# forms data (FDF) with/from PDF. This sample illustrates basic FDF merge/extract functionality 
# available in PDFNet.
#---------------------------------------------------------------------------------------

def main():
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # Example 1
    # Iterate over all form fields in the document. Display all field names.
    
    doc = PDFDoc(input_path + "form1.pdf")
    doc.InitSecurityHandler()
    
    itr = doc.GetFieldIterator()
    while itr.HasNext():
        print("Field name: " + itr.Current().GetName())
        print("Field partial name: " + itr.Current().GetPartialName())
        
        sys.stdout.write("Field type: ")
        type = itr.Current().GetType()
        if type == Field.e_button:
            print("Button")
        elif type == Field.e_check:
            print("Check")
        elif type == Field.e_radio:
            print("Radio")
        elif type == Field.e_text:
            print("Text")
        elif type == Field.e_choice:
            print("Choice")
        elif type == Field.e_signature:
            print("Signiture")
        elif type == Field.e_null:
            print("Null")
            
        print("------------------------------")
        itr.Next()
    
    doc.Close()
    print("Done.")
    
    # Example 2
    # Import XFDF into FDF, then merge data from FDF
	
	# XFDF to FDF
	# form fields
    print("Import form field data from XFDF to FDF.")
	
    fdf_doc1 = FDFDoc.CreateFromXFDF(input_path + "form1_data.xfdf")
    fdf_doc1.Save(output_path + "form1_data.fdf")
	
	# annotations
    print("Import annotations from XFDF to FDF.")
	
    fdf_doc2 = FDFDoc.CreateFromXFDF(input_path + "form1_annots.xfdf")
    fdf_doc2.Save(output_path + "form1_annots.fdf")
	
	# FDF to PDF
	# form fields
    print("Merge form field data from FDF.")
	
    doc = PDFDoc(input_path + "form1.pdf")
    doc.InitSecurityHandler()
    doc.FDFMerge(fdf_doc1)
	
    # Refreshing missing appearances is not required here, but is recommended to make them 
    # visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
    doc.RefreshAnnotAppearances()
	
    doc.Save(output_path + "form1_filled.pdf", SDFDoc.e_linearized)
	
	# annotations
    print("Merge annotations from FDF.")

    doc.FDFMerge(fdf_doc2)
    # Refreshing missing appearances is not required here, but is recommended to make them 
    # visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
    doc.RefreshAnnotAppearances()
    doc.Save(output_path + "form1_filled_with_annots.pdf", SDFDoc.e_linearized)
    doc.Close()
    print("Done.")
	
    
    # Example 3
    # Extract data from PDF to FDF, then export FDF as XFDF
    
	# PDF to FDF
    in_doc = PDFDoc(output_path + "form1_filled_with_annots.pdf")
    in_doc.InitSecurityHandler()
	
	# form fields only
    print("Extract form fields data to FDF.")
	
    doc_fields = in_doc.FDFExtract(PDFDoc.e_forms_only)
    doc_fields.SetPDFFileName("../form1_filled_with_annots.pdf")
    doc_fields.Save(output_path + "form1_filled_data.fdf")
	
	# annotations only
    print("Extract annotations to FDF.")
	
    doc_annots = in_doc.FDFExtract(PDFDoc.e_annots_only)
    doc_annots.SetPDFFileName("../form1_filled_with_annots.pdf")
    doc_annots.Save(output_path + "form1_filled_annot.fdf")
	
	# both form fields and annotations
    print("Extract both form fields and annotations to FDF.")
	
    doc_both = in_doc.FDFExtract(PDFDoc.e_both)
    doc_both.SetPDFFileName("../form1_filled_with_annots.pdf")
    doc_both.Save(output_path + "form1_filled_both.fdf")
	
	# FDF to XFDF
	# form fields
    print("Export form field data from FDF to XFDF.")
	
    doc_fields.SaveAsXFDF(output_path + "form1_filled_data.xfdf")
	
	# annotations
    print("Export annotations from FDF to XFDF.")
	
    doc_annots.SaveAsXFDF(output_path + "form1_filled_annot.xfdf")
	
	# both form fields and annotations
    print("Export both form fields and annotations from FDF to XFDF.")
	
    doc_both.SaveAsXFDF(output_path + "form1_filled_both.xfdf")
	
    in_doc.Close()
    print("Done.")
	
    # Example 4
    # Merge/Extract XFDF into/from PDF
    
    # Merge XFDF from string
    in_doc = PDFDoc(input_path + "numbered.pdf")
    in_doc.InitSecurityHandler()

    print("Merge XFDF string into PDF.")

    str = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><xfdf xmlns=\"http://ns.adobe.com/xfdf\" xml:space=\"preserve\"><square subject=\"Rectangle\" page=\"0\" name=\"cf4d2e58-e9c5-2a58-5b4d-9b4b1a330e45\" title=\"user\" creationdate=\"D:20120827112326-07'00'\" date=\"D:20120827112326-07'00'\" rect=\"227.7814207650273,597.6174863387978,437.07103825136608,705.0491803278688\" color=\"#000000\" interior-color=\"#FFFF00\" flags=\"print\" width=\"1\"><popup flags=\"print,nozoom,norotate\" open=\"no\" page=\"0\" rect=\"0,792,0,792\" /></square></xfdf>"

    fdoc = FDFDoc.CreateFromXFDF(str)
    in_doc.FDFMerge(fdoc)
    in_doc.Save(output_path + "numbered_modified.pdf", SDFDoc.e_linearized)
    print("Merge complete.")

    # Extract XFDF as string
    print("Extract XFDF as a string.")

    fdoc_new = in_doc.FDFExtract(PDFDoc.e_both)
    XFDF_str = fdoc_new.SaveAsXFDF()
    print("Extracted XFDF: ")
    print(XFDF_str)
    in_doc.Close()
    print("Extract complete.") 	
	
    # Example 5
    # Read FDF files directly
    
    doc = FDFDoc(output_path + "form1_filled_data.fdf")
    
    itr = doc.GetFieldIterator()
    while itr.HasNext():
        print("Field name: " + itr.Current().GetName())
        print("Field partial name: " + itr.Current().GetPartialName())
        print("------------------------------")
        itr.Next()
        
    doc.Close()
    print("Done.")
    
    # Example 6
    # Direct generation of FDF
    doc = FDFDoc()
    
    # Create new fields (i.r. key/value pairs
    doc.FieldCreate("Company", Field.e_text, "PDFTron Systems")
    doc.FieldCreate("First Name", Field.e_text, "John")
    doc.FieldCreate("Last Name", Field.e_text, "Doe")
    
    doc.Save(output_path + "sample_output.fdf")
    doc.Close()
    print("Done. Results saved in sample_output.fdf")

if __name__ == '__main__':
    main()
