<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to HTML.
//
// There are two HTML modules and one of them is an optional PDFNet Add-on.
// 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
//    documents.
// 2. The optional add-on module is used to convert PDF documents to HTML documents with
//    text flowing across the browser window.
//
// The PDFTron SDK HTML add-on module can be downloaded from http://www.pdftron.com/
//
// Please contact us if you have any questions.
//---------------------------------------------------------------------------------------

function main()
{
	// Relative path to the folder containing the test files.
	$inputPath = getcwd()."/../../TestFiles/";
	$outputPath = $inputPath."Output/";

	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to HTML with fixed positioning option turned on (default)
		echo(nl2br("Converting PDF to HTML with fixed positioning option turned on (default)\n"));

		$outputFile = $outputPath."paragraphs_and_tables_fixed_positioning";

		Convert::ToHtml($inputPath."paragraphs_and_tables.pdf", $outputFile);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to HTML, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------

	PDFNet::AddResourceSearchPath("../../../PDFNetC/Lib/");

	if (!StructuredOutputModule::IsModuleAvailable()) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run part of the sample: PDFTron SDK Structured Output module not available.\n"));
		echo(nl2br("-------------------------------------------------------------------------------------\n"));
		echo(nl2br("The Structured Output module is an optional add-on, available for download\n"));
		echo(nl2br("at https://docs.apryse.com/documentation/core/info/modules/. If you have already\n"));
		echo(nl2br("downloaded this module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
		return;
	}

	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to HTML with reflow full option turned on (1)
		echo(nl2br("Converting PDF to HTML with reflow full option turned on (1)\n"));

		$outputFile = $outputPath."paragraphs_and_tables_reflow_full.html";

		$htmlOutputOptions = new HTMLOutputOptions();

		// Set e_reflow_full content reflow setting
		$htmlOutputOptions->SetContentReflowSetting(HTMLOutputOptions::e_reflow_full);

		Convert::ToHtml($inputPath."paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to HTML, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to HTML with reflow full option turned on (only converting the first page) (2)
		echo(nl2br("Converting PDF to HTML with reflow full option turned on (only converting the first page) (2)\n"));

		$outputFile = $outputPath."paragraphs_and_tables_reflow_full_first_page.html";

		$htmlOutputOptions = new HTMLOutputOptions();

		// Set e_reflow_full content reflow setting
		$htmlOutputOptions->SetContentReflowSetting(HTMLOutputOptions::e_reflow_full);

		// Convert only the first page
		$htmlOutputOptions->SetPages(1, 1);

		Convert::ToHtml($inputPath."paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to HTML, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------
	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
