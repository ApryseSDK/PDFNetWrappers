<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// This sample shows encryption support in PDFNet. The sample reads an encrypted document and 
// sets a new SecurityHandler. The sample also illustrates how password protection can 
// be removed from an existing PDF document.
//---------------------------------------------------------------------------------------
	PDFNet::Initialize();
	
	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	// Example 1: 
	// secure a PDF document with password protection and adjust permissions

	// Open the test file
	echo nl2br("Securing an existing document ...\n");
	$doc = new PDFDoc($input_path."fish.pdf");
	$doc->InitSecurityHandler();

	// Perform some operation on the document. In this case we use low level SDF API
	// to replace the content stream of the first page with contents of file 'my_stream.txt'
	if (true)  // Optional
	{
		echo nl2br("Replacing the content stream, use Flate compression...\n");

		// Get the page dictionary using the following path: trailer/Root/Pages/Kids/0
		$page_dict = $doc->GetTrailer()->Get("Root")->Value()
			->Get("Pages")->Value()
			->Get("Kids")->Value()
			->GetAt(0);

		// Embed a custom stream (file mystream.txt) using Flate compression.
		$embed_file = new StdFile($input_path."my_stream.txt", StdFile::e_read_mode);
		$mystm = new FilterReader($embed_file);
		$page_dict->Put("Contents", $doc->CreateIndirectStream($mystm, new FlateEncode(new Filter())));
	}

	//encrypt the document
	
	// Apply a new security handler with given security settings. 
	// In order to open saved PDF you will need a user password 'test'.
	$new_handler = new SecurityHandler();

	// Set a new password required to open a document
	$user_password="test";
	$new_handler->ChangeUserPassword($user_password);

	// Set Permissions
	$new_handler->SetPermission (SecurityHandler::e_print, true);
	$new_handler->SetPermission (SecurityHandler::e_extract_content, false);

	// Note: document takes the ownership of new_handler.
	$doc->SetSecurityHandler($new_handler);

	// Save the changes.
	echo nl2br("Saving modified file...\n");
	$doc->Save($output_path."secured.pdf", 0);
	$doc->Close();

	// Example 2:
	// Opens an encrypted PDF document and removes its security.

	$doc = new PDFDoc($output_path."secured.pdf");

	//If the document is encrypted prompt for the password
	if (!$doc->InitSecurityHandler()) 
	{
		echo nl2br("The password is: test\n");

		echo nl2br("A password required to open the document.\n"
			."Please enter the password:");
			
		include "UsrInput.html";
	}
?>
