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

	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";
	$doc = new PDFDoc($output_path."secured.pdf");
	
	$success = false;
	$password = $_GET["ps"];
	if($doc->InitStdSecurityHandler($password, strlen($password)))
	{
		$success = true;
		echo "The password is correct.\n";
	}

	if(!$success)
	{
		echo "Document authentication error....\n";	
		return;
	}

	$hdlr = $doc->GetSecurityHandler(); 
	echo nl2br("Document Open Password: ".$hdlr->IsUserPasswordRequired()."\n");
	echo nl2br("Permissions Password: ".$hdlr->IsMasterPasswordRequired()."\n");
	echo nl2br("Permissions: " 
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
		."\n");   


	// remove all security on the document
	$doc->RemoveSecurity();
	$doc->Save($output_path."not_secured.pdf", 0);
	$doc->Close();

	echo "Test Completed.\n";
?>
