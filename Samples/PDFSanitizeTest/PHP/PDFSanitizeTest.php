<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult legal.txt regarding legal and license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//------------------------------------------------------------------------------
// PDFNet's Sanitizer is a security-focused feature that permanently removes
// hidden, sensitive, or potentially unsafe content from a PDF document.
// While redaction targets visible page content such as text or graphics,
// sanitization focuses on non-visual elements and embedded structures.
//
// PDFNet Sanitizer ensures hidden or inactive content is destroyed,
// not merely obscured or disabled. This prevents leakage of sensitive
// data such as authoring details, editing history, private identifiers,
// and residual form entries, and neutralizes scripts or attachments.
//
// Sanitization is recommended prior to external sharing with clients,
// partners, or regulatory bodies. It helps align with privacy policies
// and compliance requirements by permanently removing non-visual data.
//------------------------------------------------------------------------------

	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Relative paths to folders containing test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	// The following example illustrates how to retrieve the existing
	// sanitizable content categories within a document.
	try
	{
		$doc = new PDFDoc($input_path."numbered.pdf");
		$doc->InitSecurityHandler();

		$opts = Sanitizer::GetSanitizableContent($doc);
		if ($opts->GetMetadata())
		{
			echo(nl2br("Document has metadata.\n"));
		}
		if ($opts->GetMarkups())
		{
			echo(nl2br("Document has markups.\n"));
		}
		if ($opts->GetHiddenLayers())
		{
			echo(nl2br("Document has hidden layers.\n"));
		}
		echo(nl2br("Done...\n"));
	}
	catch(Exception $e)
	{
		echo(nl2br($e->getMessage()."\n"));
	}

	// The following example illustrates how to sanitize a document with default options,
	// which will remove all sanitizable content present within a document.
	try
	{
		$doc = new PDFDoc($input_path."financial.pdf");
		$doc->InitSecurityHandler();

		Sanitizer::SanitizeDocument($doc, null);
		$doc->Save($output_path."financial_sanitized.pdf", SDFDoc::e_linearized);
		echo(nl2br("Done...\n"));
	}
	catch(Exception $e)
	{
		echo(nl2br($e->getMessage()."\n"));
	}

	// The following example illustrates how to sanitize a document with custom set options,
	// which will only remove the content categories specified by the options object.
	try
	{
		$options = new SanitizeOptions();
		$options->SetMetadata(true);
		$options->SetFormData(true);
		$options->SetBookmarks(true);

		$doc = new PDFDoc($input_path."form1.pdf");
		$doc->InitSecurityHandler();

		Sanitizer::SanitizeDocument($doc, $options);
		$doc->Save($output_path."form1_sanitized.pdf", SDFDoc::e_linearized);
		echo(nl2br("Done...\n"));
	}
	catch(Exception $e)
	{
		echo(nl2br($e->getMessage()."\n"));
	}

	PDFNet::Terminate();
?>

