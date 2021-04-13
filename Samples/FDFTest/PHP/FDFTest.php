<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// PDFNet includes a full support for FDF (Forms Data Format) and capability to merge/extract 
// forms data (FDF) with/from PDF. This sample illustrates basic FDF merge/extract functionality 
// available in PDFNet.
//---------------------------------------------------------------------------------------
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	// Example 1: 
	// Iterate over all form fields in the document. Display all field names.

	$doc = new PDFDoc($input_path."form1.pdf");
	$doc->InitSecurityHandler();

	for($itr = $doc->GetFieldIterator(); $itr->HasNext(); $itr->Next()) 
	{
		echo nl2br("Field name: ".$itr->Current()->GetName()."\n");
		echo nl2br("Field partial name: ".$itr->Current()->GetPartialName()."\n");

		echo "Field type: ";
		$type = $itr->Current()->GetType();
		switch($type)
		{
		case Field::e_button: echo nl2br("Button"."\n"); break;
		case Field::e_check: echo nl2br("Check"."\n"); break;
		case Field::e_radio: echo nl2br("Radio"."\n"); break;
		case Field::e_text: echo nl2br("Text"."\n"); break;
		case Field::e_choice: echo nl2br("Choice"."\n"); break;
		case Field::e_signature: echo nl2br("Signature"."\n"); break;
		case Field::e_null: echo nl2br("Null"."\n"); break;
		}

		echo nl2br("------------------------------\n");
	}
	
	$doc->Close();
	echo nl2br("Done.\n");

	// Example 2) Import XFDF into FDF, then merge data from FDF into PDF
	
	// XFDF to FDF
	// form fields
	echo nl2br("Import form field data from XFDF to FDF.\n");
	
	$fdf_doc1 = FDFDoc::CreateFromXFDF($input_path."form1_data.xfdf");
	$fdf_doc1->Save($output_path."form1_data.fdf");
	
	// annotations
	echo nl2br("Import annotations from XFDF to FDF.\n");
	
	$fdf_doc2 = FDFDoc::CreateFromXFDF($input_path."form1_annots.xfdf");
	$fdf_doc2->Save($output_path."form1_annots.fdf");	
	
	// FDF to PDF
	// form fields
	echo nl2br("Merge form field data from FDF.\n");
	
	$doc = new PDFDoc($input_path."form1.pdf");
	$doc->InitSecurityHandler();
	$doc->FDFMerge($fdf_doc1);
	
	// Refreshing missing appearances is not required here, but is recommended to make them 
	// visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
	$doc->RefreshAnnotAppearances();
	
	$doc->Save(($output_path."form1_filled.pdf"), SDFDoc::e_linearized);
	
	// annotations
	echo nl2br("Merge annotations from FDF.\n");
	
	$doc->FDFMerge($fdf_doc2);	
	// Refreshing missing appearances is not required here, but is recommended to make them 
	// visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
	$doc->RefreshAnnotAppearances();
	$doc->Save(($output_path."form1_filled_with_annots.pdf"), SDFDoc::e_linearized);
	$doc->Close();
	echo nl2br("Done.\n");


	// Example 3) Extract data from PDF to FDF, then export FDF as XFDF
	
	// PDF to FDF
	$in_doc = new PDFDoc($output_path."form1_filled_with_annots.pdf");
	$in_doc->InitSecurityHandler();
	
	// form fields only
	echo nl2br("Extract form fields data to FDF.\n");
	
	$doc_fields = $in_doc->FDFExtract(PDFDoc::e_forms_only);
	$doc_fields->SetPDFFileName("../form1_filled_with_annots.pdf");
	$doc_fields->Save($output_path."form1_filled_data.fdf");
	
	// annotations only
	echo nl2br("Extract annotations to FDF.\n");
	
	$doc_annots = $in_doc->FDFExtract(PDFDoc::e_annots_only);
	$doc_annots->SetPDFFileName("../form1_filled_with_annots.pdf");
	$doc_annots->Save($output_path."form1_filled_annot.fdf");
	
	// both form fields and annotations
	echo nl2br("Extract both form fields and annotations to FDF.\n");
	
	$doc_both = $in_doc->FDFExtract(PDFDoc::e_both);
	$doc_both->SetPDFFileName("../form1_filled_with_annots.pdf");
	$doc_both->Save($output_path."form1_filled_both.fdf");
	
	// FDF to XFDF
	// form fields
	echo nl2br("Export form field data from FDF to XFDF.\n");
	
	$doc_fields->SaveAsXFDF($output_path."form1_filled_data.xfdf");
	
	// annotations
	echo nl2br("Export annotations from FDF to XFDF.\n");
	
	$doc_annots->SaveAsXFDF($output_path."form1_filled_annot.xfdf");
	
	// both form fields and annotations
	echo nl2br("Export both form fields and annotations from FDF to XFDF.\n");
	
	$doc_both->SaveAsXFDF($output_path."form1_filled_both.xfdf");
	
	$in_doc->Close();
	echo nl2br("Done.\n");

	// Example 4) Merge/Extract XFDF into/from PDF
	
	// Merge XFDF from string
	$in_doc = new PDFDoc($input_path."numbered.pdf");
	$in_doc->InitSecurityHandler();
	
	echo nl2br("Merge XFDF string into PDF.\n");
	
	$str = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><xfdf xmlns=\"http://ns.adobe.com/xfdf\" xml:space=\"preserve\"><square subject=\"Rectangle\" page=\"0\" name=\"cf4d2e58-e9c5-2a58-5b4d-9b4b1a330e45\" title=\"user\" creationdate=\"D:20120827112326-07'00'\" date=\"D:20120827112326-07'00'\" rect=\"227.7814207650273,597.6174863387978,437.07103825136608,705.0491803278688\" color=\"#000000\" interior-color=\"#FFFF00\" flags=\"print\" width=\"1\"><popup flags=\"print,nozoom,norotate\" open=\"no\" page=\"0\" rect=\"0,792,0,792\" /></square></xfdf>";
	$fdoc = FDFDoc::CreateFromXFDF($str);
	$in_doc->FDFMerge($fdoc);
	$in_doc->Save(($output_path."numbered_modified.pdf"), SDFDoc::e_linearized);
	echo nl2br("Merge complete.\n");
	
	// Extract XFDF as string
	echo nl2br("Extract XFDF as a string.\n");
	
	$fdoc_new = $in_doc->FDFExtract(PDFDoc::e_both);
	$XFDF_str = $fdoc_new->SaveAsXFDF();
	echo nl2br("Extracted XFDF: \n");
	echo nl2br($XFDF_str);
	$in_doc->Close();
	echo nl2br("\nExtract complete.\n");
	
	// Example 5) Read FDF files directly
	
	$doc = new FDFDoc($output_path."form1_filled_data.fdf");

	for($itr = $doc->GetFieldIterator(); $itr->HasNext(); $itr->Next())
	{
		echo nl2br("Field name: ".$itr->Current()->GetName()."\n");
		echo nl2br("Field partial name: ".$itr->Current()->GetPartialName()."\n");
		echo nl2br("------------------------------\n");
	}
	
	$doc->Close();
	echo nl2br("Done.\n");

	// Example 6) Direct generation of FDF.
	
	$doc = new FDFDoc();
	// Create new fields (i.e. key/value pairs).
	$doc->FieldCreate("Company", Field::e_text, "PDFTron Systems");
	$doc->FieldCreate("First Name", Field::e_text, "John");
	$doc->FieldCreate("Last Name", Field::e_text, "Doe");
	// ...		

	// $doc->SetPdfFileName("mydoc.pdf");
	
	$doc->Save($output_path."sample_output.fdf");
	$doc->Close();
	echo nl2br("Done. Results saved in sample_output.fdf");
	
	
?>
