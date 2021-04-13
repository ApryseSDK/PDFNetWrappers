<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//-----------------------------------------------------------------------------------
// The sample illustrates how to work with PDF page labels.
//
// PDF page labels can be used to describe a page. This is used to 
// allow for non-sequential page numbering or the addition of arbitrary 
// labels for a page (such as the inclusion of Roman numerals at the 
// beginning of a book). PDFNet PageLabel object can be used to specify 
// the numbering style to use (for example, upper- or lower-case Roman, 
// decimal, and so forth), the starting number for the first page,
// and an arbitrary prefix to be pre-appended to each number (for 
// example, "A-" to generate "A-1", "A-2", "A-3", and so forth.)
//-----------------------------------------------------------------------------------

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	//-----------------------------------------------------------
	// Example 1: Add page labels to an existing or newly created PDF
	// document.
	//-----------------------------------------------------------
	
	$doc = new PDFDoc($input_path."newsletter.pdf");
	$doc->InitSecurityHandler();

	// Create a page labeling scheme that starts with the first page in 
	// the document (page 1) and is using uppercase roman numbering 
	// style. 
	$L1 = PageLabel::Create($doc->GetSDFDoc(), PageLabel::e_roman_uppercase, "My Prefix ", 1);
	$doc->SetPageLabel(1, $L1);

	// Create a page labeling scheme that starts with the fourth page in 
	// the document and is using decimal Arabic numbering style. 
	// Also the numeric portion of the first label should start with number 
	// 4 (otherwise the first label would be "My Prefix 1"). 
	$L2 = PageLabel::Create($doc->GetSDFDoc(), PageLabel::e_decimal, "My Prefix ", 4);
	$doc->SetPageLabel(4, $L2);

	// Create a page labeling scheme that starts with the seventh page in 
	// the document and is using alphabetic numbering style. The numeric 
	// portion of the first label should start with number 1. 
	$L3 = PageLabel::Create($doc->GetSDFDoc(), PageLabel::e_alphabetic_uppercase, "My Prefix ", 1);
	$doc->SetPageLabel(7, $L3);

	$doc->Save($output_path."newsletter_with_pagelabels.pdf", SDFDoc::e_linearized);
	echo nl2br("Done. Result saved in newsletter_with_pagelabels.pdf...\n");
	
	//-----------------------------------------------------------
	// Example 2: Read page labels from an existing PDF document.
	//-----------------------------------------------------------
	
	$doc = new PDFDoc($output_path."newsletter_with_pagelabels.pdf");
	$doc->InitSecurityHandler();

	$label = new PageLabel();
	$page_num = $doc->GetPageCount();
	for ($i=1; $i<=$page_num; ++$i) 
	{
		echo "Page number: ".$i; 
		$label = $doc->GetPageLabel($i);
		if ($label->IsValid()) {
			echo nl2br(" Label: ".$label->GetLabelTitle($i)."\n"); 
		}
		else {
			echo nl2br(" No Label.\n"); 
		}
	}
	
	//-----------------------------------------------------------
	// Example 3: Modify page labels from an existing PDF document.
	//-----------------------------------------------------------
	
	$doc = new PDFDoc($output_path."newsletter_with_pagelabels.pdf");
	$doc->InitSecurityHandler();

	// Remove the alphabetic labels from example 1.
	$doc->RemovePageLabel(7); 

	// Replace the Prefix in the decimal labels (from example 1).
	$label = $doc->GetPageLabel(4);
	if ($label->IsValid()) {
		$label->SetPrefix("A");
		$label->SetStart(1);
	}

	// Add a new label
	$new_label = PageLabel::Create($doc->GetSDFDoc(), PageLabel::e_decimal, "B", 1);
	$doc->SetPageLabel(10, $new_label);  // starting from page 10.

	$doc->Save($output_path."newsletter_with_pagelabels_modified.pdf", SDFDoc::e_linearized);
	echo nl2br("Done. Result saved in newsletter_with_pagelabels_modified.pdf...\n");

	$page_num = $doc->GetPageCount();
	for ($i=1; $i<=$page_num; ++$i) 
	{
		echo "Page number: ".$i; 
		$label = $doc->GetPageLabel($i);
		if ($label->IsValid()) {
			echo nl2br(" Label: ".$label->GetLabelTitle($i)."\n"); 
		}
		else {
			echo nl2br(" No Label.\n"); 
		}
	}
	
	$doc->Close();

	//-----------------------------------------------------------
	// Example 4: Delete all page labels in an existing PDF document.
	//-----------------------------------------------------------
	
	$doc = new PDFDoc ($output_path."newsletter_with_pagelabels.pdf");
	$doc->GetRoot()->Erase("PageLabels");
	$doc->Save($output_path."newsletter_with_pagelabels_removed.pdf", SDFDoc::e_linearized);
	echo nl2br("Done. Result saved in newsletter_with_pagelabels_removed.pdf...\n");
	// ...
?>
