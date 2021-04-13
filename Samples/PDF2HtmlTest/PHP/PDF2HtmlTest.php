<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to HTML.
//
// There are two HTML modules and one of them is an optional PDFNet Add-on.
// 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
//    documents.
// 2. The optional add-on module is used to convert PDF documents to HTML documents with
//    text flowing within paragraphs.
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
	PDFNet::Initialize();
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

	if (!PDF2HtmlReflowParagraphsModule::IsModuleAvailable()) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run part of the sample: PDFTron SDK HTML reflow paragraphs module not available.\n"));
		echo(nl2br("---------------------------------------------------------------\n"));
		echo(nl2br("The HTML reflow paragraphs module is an optional add-on, available for download\n"));
		echo(nl2br("at http://www.pdftron.com/. If you have already downloaded this\n"));
		echo(nl2br("module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
		return;
	}

	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to HTML with reflow paragraphs option turned on (1)
		echo(nl2br("Converting PDF to HTML with reflow paragraphs option turned on (1)\n"));

		$outputFile = $outputPath."paragraphs_and_tables_reflow_paragraphs.html";

		$htmlOutputOptions = new HTMLOutputOptions();

		// Set e_reflow_paragraphs content reflow setting
		$htmlOutputOptions->SetContentReflowSetting(HTMLOutputOptions::e_reflow_paragraphs);

		Convert::ToHtml($inputPath."paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to HTML, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to HTML with reflow paragraphs option turned on (2)
		echo(nl2br("Converting PDF to HTML with reflow paragraphs option turned on (2)\n"));

		$outputFile = $outputPath."paragraphs_and_tables_reflow_paragraphs_no_page_width.html";

		$htmlOutputOptions = new HTMLOutputOptions();

		// Set e_reflow_paragraphs content reflow setting
		$htmlOutputOptions->SetContentReflowSetting(HTMLOutputOptions::e_reflow_paragraphs);

		// Set to flow paragraphs across the entire browser window.
		$htmlOutputOptions->SetNoPageWidth(true);

		Convert::ToHtml($inputPath."paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to HTML, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------

	echo(nl2br("Done.\n"));
}

main();
?>
