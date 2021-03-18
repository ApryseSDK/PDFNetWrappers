#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# PDFNet includes a full support for FDF (Forms Data Format) and capability to merge/extract 
# forms data (FDF) with/from PDF. This sample illustrates basic FDF merge/extract functionality 
# available in PDFNet.
#---------------------------------------------------------------------------------------

	PDFNet.Initialize()
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	# Example 1
	# Iterate over all form fields in the document. Display all field names.
	
	doc = PDFDoc.new(input_path + "form1.pdf")
	doc.InitSecurityHandler()
	
	itr = doc.GetFieldIterator()
	while itr.HasNext() do
		puts "Field name: " + itr.Current().GetName()
		puts "Field partial name: " + itr.Current().GetPartialName()
		
		print "Field type: "
		type = itr.Current().GetType()
		if type == Field::E_button
			puts "Button"
		elsif type == Field::E_check
			puts "Check"
		elsif type == Field::E_radio
			puts "Radio"
		elsif type == Field::E_text
			puts "Text"
		elsif type == Field::E_choice
			puts "Choice"
		elsif type == Field::E_signature
			puts "Signiture"
		elsif type == Field::E_null
			puts "Null"
		end
			
		puts "------------------------------"
		itr.Next()
	end
	
	doc.Close()
	puts "Done."
	
	# Example 2
	# Import XFDF into FDF, then merge data from FDF into PDF
	
	# XFDF to FDF
	# form fields
	puts "Import form field data from XFDF to FDF."
	
	fdf_doc1 = FDFDoc.CreateFromXFDF(input_path + "form1_data.xfdf")
	fdf_doc1.Save(output_path + "form1_data.fdf")
	
	# annotations
	puts "Import annotations from XFDF to FDF."
	
	fdf_doc2 = FDFDoc.CreateFromXFDF(input_path + "form1_annots.xfdf")
	fdf_doc2.Save(output_path + "form1_annots.fdf")
	
	# FDF to PDF
	# form fields
	puts "Merge form field data from FDF."
	
	doc = PDFDoc.new(input_path + "form1.pdf")
	doc.InitSecurityHandler()
	doc.FDFMerge(fdf_doc1)
	
	# Refreshing missing appearances is not required here, but is recommended to make them  
	# visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
	doc.RefreshAnnotAppearances()
	
	doc.Save(output_path + "form1_filled.pdf", SDFDoc::E_linearized)
	
	# annotations
	puts "Merge annotations from FDF."
	
	doc.FDFMerge(fdf_doc2)
	# Refreshing missing appearances is not required here, but is recommended to make them  
	# visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
	doc.RefreshAnnotAppearances()
	doc.Save(output_path + "form1_filled_with_annots.pdf", SDFDoc::E_linearized)
	doc.Close()
	puts "Done."
	
	
	# Example 3
	# Extract data from PDF to FDF, then export FDF as XFDF
	
	# PDF to FDF
	in_doc = PDFDoc.new(output_path + "form1_filled_with_annots.pdf")
	in_doc.InitSecurityHandler()
	
	# form fields only
	puts "Extract form fields data to FDF."
	
	doc_fields = in_doc.FDFExtract(PDFDoc::E_forms_only)
	doc_fields.SetPDFFileName("../form1_filled_with_annots.pdf")
	doc_fields.Save(output_path + "form1_filled_data.fdf")
	
	# annotations only
	puts "Extract annotations to FDF."
	
	doc_annots = in_doc.FDFExtract(PDFDoc::E_annots_only)
	doc_annots.SetPDFFileName("../form1_filled_with_annots.pdf")
	doc_annots.Save(output_path + "form1_filled_annot.fdf")
	
	# both form fields and annotations
	puts "Extract both form fields and annotations to FDF."
	
	doc_both = in_doc.FDFExtract(PDFDoc::E_both)
	doc_both.SetPDFFileName("../form1_filled_with_annots.pdf")
	doc_both.Save(output_path + "form1_filled_both.fdf")
	
	# FDF to XFDF
	# form fields
	puts "Export form field data from FDF to XFDF."
	
	doc_fields.SaveAsXFDF(output_path + "form1_filled_data.xfdf")
	
	# annotations
	puts "Export annotations from FDF to XFDF."
	
	doc_annots.SaveAsXFDF(output_path + "form1_filled_annot.xfdf")
	
	# both form fields and annotations
	puts "Export both form fields and annotations from FDF to XFDF."
	
	doc_both.SaveAsXFDF(output_path + "form1_filled_both.xfdf")
	
	in_doc.Close()
	puts "Done."

	# Example 4
	# Merge/Extract XFDF into/from PDF
	in_doc = PDFDoc.new(input_path + "numbered.pdf")
	in_doc.InitSecurityHandler()
	
	puts "Merge XFDF string into PDF."
	
	str = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><xfdf xmlns=\"http://ns.adobe.com/xfdf\" xml:space=\"preserve\"><square subject=\"Rectangle\" page=\"0\" name=\"cf4d2e58-e9c5-2a58-5b4d-9b4b1a330e45\" title=\"user\" creationdate=\"D:20120827112326-07'00'\" date=\"D:20120827112326-07'00'\" rect=\"227.7814207650273,597.6174863387978,437.07103825136608,705.0491803278688\" color=\"#000000\" interior-color=\"#FFFF00\" flags=\"print\" width=\"1\"><popup flags=\"print,nozoom,norotate\" open=\"no\" page=\"0\" rect=\"0,792,0,792\" /></square></xfdf>"
	
	fdoc = FDFDoc.CreateFromXFDF(str)
	in_doc.FDFMerge(fdoc)
	in_doc.Save(output_path + "numbered_modified.pdf", SDFDoc::E_linearized)
	puts "Merge complete."
	
	# Extract XFDF as string
	puts "Extract XFDF as a string."
	
	fdoc_new = in_doc.FDFExtract(PDFDoc::E_both)
	XFDF_str = fdoc_new.SaveAsXFDF()
	puts "Extracted XFDF: "
	puts XFDF_str
	in_doc.Close()
	puts "Extract complete."
	
	# Example 5
	# Read FDF files directly
	
	doc = FDFDoc.new(output_path + "form1_filled_data.fdf")
	
	itr = doc.GetFieldIterator()
	while itr.HasNext() do
		puts "Field name: " + itr.Current().GetName()
		puts "Field partial name: " + itr.Current().GetPartialName()
		puts "------------------------------"
		itr.Next()
	end
		
	doc.Close()
	puts "Done."
	
	# Example 6
	# Direct generation of FDF
	doc = FDFDoc.new()
	
	# Create new fields (i.r. key/value pairs
	doc.FieldCreate("Company", Field::E_text, "PDFTron Systems")
	doc.FieldCreate("First Name", Field::E_text, "John")
	doc.FieldCreate("Last Name", Field::E_text, "Doe")
	
	doc.Save(output_path + "sample_output.fdf")
	doc.Close()
	puts "Done. Results saved in sample_output.fdf"

