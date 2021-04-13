<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");
	
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	// Test - Adjust the position of content within the page.
	echo nl2br("_______________________________________________\n");
	echo nl2br("Opening the input pdf...\n");
	
	$input_doc = new PDFDoc($input_path."tiger.pdf");
	$input_doc->InitSecurityHandler();
	$pg_itr1 = $input_doc->GetPageIterator();

	$media_box = new Rect($pg_itr1->Current()->GetMediaBox());

	$media_box->x1 -= 200;
	$media_box->x2 -= 200;
	
	$media_box->Update();
	$input_doc->Save($output_path."tiger_shift.pdf", 0);
	$input_doc->Close();
    
	echo nl2br("Done. Result saved in tiger_shift...\n");
?>
