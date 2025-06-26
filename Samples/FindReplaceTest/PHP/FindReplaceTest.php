<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to find and replace text in a PDF document.
//---------------------------------------------------------------------------------------

function main()
{
	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = getcwd()."/../../TestFiles/Output/";

	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	try {

		// Open a PDF document to edit
		$doc = new PDFDoc($input_path . "find-replace-test.pdf");
		$options = new FindReplaceOptions();

		// Set some find/replace options
		$options->SetWholeWords(true);
		$options->SetMatchCase(true);
		$options->SetMatchMode(FindReplaceOptions::e_exact);
		$options->SetReflowMode(FindReplaceOptions::e_para);
		$options->SetAlignment(FindReplaceOptions::e_left);

		// Perform a Find/Replace finding "the" with "THE INCREDIBLE"
		FindReplace::FindReplaceText($doc, "the", "THE INCREDIBLE", $options);

		// Save the edited PDF
		$doc->Save($output_path . "find-replace-test-replaced.pdf", SDFDoc::e_linearized);

	}
	catch (Exception $e) {
		echo(nl2br("Unable to perform Find and Replace, error: " . $e->getMessage() . "\n"));
	}

	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
