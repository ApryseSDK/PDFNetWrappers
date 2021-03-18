<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";


function ProcessElements($reader) {
	for ($element=$reader->Next(); $element != null; $element = $reader->Next()) 	// Read page contents
	{
		switch ($element->GetType())
		{
		case Element::e_path:						// Process path data...
			{
				$data = $element->GetPathData();
				$points = $data->GetPoints();
			}
 			break; 
		case Element::e_text: 				// Process text strings...
			{
				$data = $element->GetTextString();
				echo nl2br($data."\n");
			}
			break;
		case Element::e_form:				// Process form XObjects
			{
				$reader->FormBegin(); 
                		ProcessElements($reader);
				$reader->End(); 
			}
			break; 
		}
	}
}

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Extract text data from all pages in the document

	echo nl2br("-------------------------------------------------\n");
	echo nl2br("Sample 1 - Extract text data from all pages in the document.\n");
	echo nl2br("Opening the input pdf...\n");
	
	$doc = new PDFDoc($input_path."newsletter.pdf");
	$doc->InitSecurityHandler();

	$pgnum = $doc->GetPageCount();
		
	$page_reader = new ElementReader();

	for ($itr = $doc->GetPageIterator(); $itr->HasNext(); $itr->Next())		//  Read every page
	{		
		$page_reader->Begin($itr->Current());
		ProcessElements($page_reader);
		$page_reader->End();
	}

	echo nl2br("Done.\n");
?>
