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
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	// Example 1: 
	// secure a PDF document with password protection and adjust permissions

	// Open the test file
	echo "Securing an existing document ...\n";
	$doc = new PDFDoc($input_path."fish.pdf");
	$doc->InitSecurityHandler();

	// Perform some operation on the document. In this case we use low level SDF API
	// to replace the content stream of the first page with contents of file 'my_stream.txt'
	if (true)  // Optional
	{
		echo "Replacing the content stream, use Flate compression...\n";

		// Get the page dictionary using the following path: trailer/Root/Pages/Kids/0
		$page_dict = $doc->GetTrailer()->Get("Root")->Value()
			->Get("Pages")->Value()
			->Get("Kids")->Value()
			->GetAt(0);

		// Embed a custom stream (file mystream.txt) using Flate compression.
		$embed_file = new MappedFile($input_path."my_stream.txt");
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
	echo "Saving modified file...\n";
	$doc->Save($output_path."secured.pdf", 0);
	$doc->Close();

	// Example 2:
	// Opens an encrypted PDF document and removes its security.

	$doc = new PDFDoc($output_path."secured.pdf");

	//If the document is encrypted prompt for the password
	if (!$doc->InitSecurityHandler()) 
	{
		$success=false;
		echo "The password is: test\n";
		for($count=0; $count<3;$count++)
		{
			echo "A password required to open the document.\n"
				."Please enter the password:";
			
			$password = trim(fgets(STDIN));
			if($doc->InitStdSecurityHandler($password, strlen($password)))
			{
				$success=true;
				echo "The password is correct.\n";
				break;
			}
			else if($count<3)
			{
				echo "The password is incorrect, please try again\n";
			}
		}
		if(!$success)
		{
			echo "Document authentication error....\n";
			PDFNet::Terminate();
			return;
		}

		$hdlr = $doc->GetSecurityHandler(); 
		echo "Document Open Password: ".$hdlr->IsUserPasswordRequired()."\n";
		echo "Permissions Password: ".$hdlr->IsMasterPasswordRequired()."\n";
		echo "Permissions: " 
			."\n\tHas 'owner' permissions: ".$hdlr->GetPermission(SecurityHandler::e_owner)
			."\n\tOpen and decrypt the document: ".$hdlr->GetPermission(SecurityHandler::e_doc_open)
			."\n\tAllow content extraction: ".$hdlr->GetPermission(SecurityHandler::e_extract_content) 
			."\n\tAllow full document editing: ".$hdlr->GetPermission(SecurityHandler::e_doc_modify) 
			."\n\tAllow printing: ".$hdlr->GetPermission(SecurityHandler::e_print) 
			."\n\tAllow high resolution printing: ".$hdlr->GetPermission(SecurityHandler::e_print_high) 
			."\n\tAllow annotation editing: ".$hdlr->GetPermission(SecurityHandler::e_mod_annot) 
			."\n\tAllow form fill: ".$hdlr->GetPermission(SecurityHandler::e_fill_forms) 
			."\n\tAllow content extraction for accessibility: ".$hdlr->GetPermission(SecurityHandler::e_access_support) 
			."\n\tAllow document assembly: ".$hdlr->GetPermission(SecurityHandler::e_assemble_doc) 
			."\n";   
	}

	// remove all security on the document
	$doc->RemoveSecurity();
	$doc->Save($output_path."not_secured.pdf", 0);
	$doc->Close();

	// Example 3: 
	echo "-------------------------------------------------\n";
	echo "Encrypt a document using PDFTron Custom Security handler with a custom id and password...\n";
	$doc = new PDFDoc($input_path . "BusinessCardTemplate.pdf");

	// Create PDFTron custom security handler with a custom id. Replace this with your own integer
	$custom_id = 123456789;
	$custom_handler = new PDFTronCustomSecurityHandler($custom_id);

	// Add a password to the custom security handler
	$pass = "test";
	$custom_handler->ChangeUserPassword($pass);

	// Save the encrypted document
	$doc->SetSecurityHandler($custom_handler);
	$doc->Save($output_path . "BusinessCardTemplate_enc.pdf", 0);
	$doc->Close();

	echo "Decrypt the PDFTron custom security encrypted document above...\n";
	// Register the PDFTron Custom Security handler with the same custom id used in encryption
	PDFNet::AddPDFTronCustomHandler($custom_id);

	$doc_enc = new PDFDoc($output_path . "BusinessCardTemplate_enc.pdf");
	$doc_enc->InitStdSecurityHandler($pass);
	$doc_enc->RemoveSecurity();
	// Save the decrypted document
	$doc_enc->Save($output_path . "BusinessCardTemplate_enc_dec.pdf", 0);
	$doc->Close();
	echo "Done. Result saved in BusinessCardTemplate_enc_dec.pdf\n";
	echo "-------------------------------------------------\n";
	echo "Test Completed.\n";
?>
