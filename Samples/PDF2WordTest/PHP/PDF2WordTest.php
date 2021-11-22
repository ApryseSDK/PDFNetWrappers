<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to Word.
//
// The Word module is an optional PDFNet Add-on that can be used to convert PDF
// documents into Word documents.
//
// The PDFTron SDK Word module can be downloaded from http://www.pdftron.com/
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
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	//-----------------------------------------------------------------------------------

	PDFNet::AddResourceSearchPath("../../../PDFNetC/Lib/");

	if (!PDF2WordModule::IsModuleAvailable()) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run the sample: PDFTron SDK Word module not available.\n"));
		echo(nl2br("---------------------------------------------------------------\n"));
		echo(nl2br("at https://www.pdftron.com/documentation/core/info/modules/.\n"));
		echo(nl2br("If you have already downloaded this module, ensure that the SDK\n"));
		echo(nl2br("is able to find the required files using the\n"));
		echo(nl2br("PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
		return;
	}

	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to Word
		echo(nl2br("Converting PDF to Word\n"));

		$outputFile = $outputPath."paragraphs_and_tables.docx";

		Convert::ToWord($inputPath."paragraphs_and_tables.pdf", $outputFile);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to Word, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------

	try {
		// Convert PDF document to Word with options
		echo(nl2br("Converting PDF to Word with options\n"));

		$outputFile = $outputPath."paragraphs_and_tables_first_page.docx";

		$wordOutputOptions = new WordOutputOptions(); // Convert::WordOutputOptions();

		// Convert only the first page
		$wordOutputOptions->SetPages(1, 1);

		Convert::ToWord($inputPath."paragraphs_and_tables.pdf", $outputFile, $wordOutputOptions);

		echo(nl2br("Result saved in " . $outputFile . "\n"));
	}
	catch(Exception $e) {
		echo(nl2br("Unable to convert PDF document to Word, error: " . $e->getMessage() . "\n"));
	}

	//-----------------------------------------------------------------------------------
	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
