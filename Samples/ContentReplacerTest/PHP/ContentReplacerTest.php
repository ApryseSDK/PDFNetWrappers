<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

include("../../../PDFNetC/Lib/PDFNetPHP.php");

//-----------------------------------------------------------------------------------------
// The sample code illustrates how to use the ContentReplacer class to make using 
// 'template' pdf documents easier.
//-----------------------------------------------------------------------------------------
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	//--------------------------------------------------------------------------------
	// Example 1) Update a business card template with personalized info
	$doc = new PDFDoc($input_path."BusinessCardTemplate.pdf");
	$doc->InitSecurityHandler();

	// first, replace the image on the first page
	$replacer = new ContentReplacer();
	$page = $doc->GetPage(1);
	$img = Image::Create($doc->GetSDFDoc(), $input_path."peppers.jpg");
	$replacer->AddImage($page->GetMediaBox(), $img->GetSDFObj());
	// next, replace the text place holders on the second page
	$replacer->AddString("NAME", "John Smith");
	$replacer->AddString("QUALIFICATIONS", "Philosophy Doctor"); 
	$replacer->AddString("JOB_TITLE", "Software Developer"); 
	$replacer->AddString("ADDRESS_LINE1", "#100 123 Software Rd"); 
	$replacer->AddString("ADDRESS_LINE2", "Vancouver, BC"); 
	$replacer->AddString("PHONE_OFFICE", "604-730-8989"); 
	$replacer->AddString("PHONE_MOBILE", "604-765-4321"); 
	$replacer->AddString("EMAIL", "info@pdftron.com"); 
	$replacer->AddString("WEBSITE_URL", "http://www.pdftron.com"); 
	// finally, apply
	$replacer->Process($page);
	
	$doc->Save($output_path."BusinessCard.pdf", 0);
	echo nl2br("Done. Result saved in BusinessCard.pdf\n");

	//--------------------------------------------------------------------------------
	// Example 2) Replace text in a region with new text
	$doc = new PDFDoc($input_path."newsletter.pdf");
	$doc->InitSecurityHandler();

	$replacer = new ContentReplacer();
	$page = $doc->GetPage(1);
	$target_region = $page->GetMediaBox();
	$replacer->AddText($target_region, "hello hello hello hello hello hello hello hello hello hello");
	$replacer->Process($page);

	$doc->Save($output_path."ContentReplaced.pdf", 0);
	echo nl2br("Done. Result saved in ContentReplaced.pdf\n");

	echo nl2br("Done.\n");
?>
