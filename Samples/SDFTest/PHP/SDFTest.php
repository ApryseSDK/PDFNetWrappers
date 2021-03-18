<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

// This sample illustrates how to use basic SDF API (also known as Cos) to edit an 
// existing document.

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	echo nl2br("Opening the test file...\n");

	// Here we create a SDF/Cos document directly from PDF file. In case you have 
	// PDFDoc you can always access SDF/Cos document using PDFDoc.GetSDFDoc() method.
	$doc = new SDFDoc($input_path."fish.pdf");
	$doc->InitSecurityHandler();

	echo nl2br("Modifying info dictionary, adding custom properties, embedding a stream...\n");
	$trailer = $doc->GetTrailer();			// Get the trailer

	// Now we will change PDF document information properties using SDF API

	// Get the Info dictionary. 
	$itr = $trailer->Find("Info");
	if ($itr->HasNext()) 
	{
		$info = $itr->Value();
		// Modify 'Producer' entry.
		$info->PutString("Producer", "PDFTron PDFNet");

		// Read title entry (if it is present)
		$itr = $info->Find("Author"); 
		if ($itr->HasNext()) 
		{
			// Modify 'Producer' entry
			$itr->Value()->PutString("Producer", "PDFTron PDFNet");

			// Read title entry (if it is present)
			$itr = $info->Find("Author");
			if ($itr->HasNext()) {
				$oldstr = $itr->Value()->GetAsPDFTest();
				$info->PutText("Author",$oldstr."- Modified");
			}
			else {
				$info->PutString("Author", "Me, myself, and I");
			}
		}
		else 
		{
			$info->PutString("Author", "Me, myself, and I");
		}
	}
	else 
	{
		// Info dict is missing. 
		$info = $trailer->PutDict("Info");
		$info->PutString("Producer", "PDFTron PDFNet");
		$info->PutString("Title", "My document");
	}

	// Create a custom inline dictionary within Info dictionary
	$custom_dict = $info->PutDict("My Direct Dict");
	$custom_dict->PutNumber("My Number", 100);	 // Add some key/value pairs
	$custom_dict->PutArray("My Array");

	// Create a custom indirect array within Info dictionary
	$custom_array = $doc->CreateIndirectArray();	
	$info->Put("My Indirect Array", $custom_array);	// Add some entries
		
	// Create indirect link to root
	$custom_array->PushBack($trailer->Get("Root")->Value());

	// Embed a custom stream (file mystream.txt).
	$embed_file = new MappedFile($input_path."my_stream.txt");
	$mystm = new FilterReader($embed_file);
	$custom_array->PushBack( $doc->CreateIndirectStream($mystm) );

	// Save the changes.
	echo nl2br("Saving modified test file...\n");
	$doc->Save($output_path."sdftest_out.pdf", 0, "%PDF-1.4");
	$doc->Close();

	echo nl2br("Test completed.\n");
	
	
?>
