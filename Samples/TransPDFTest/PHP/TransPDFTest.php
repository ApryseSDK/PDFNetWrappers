<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract xlf from a PDF document for translation.
// It then applies a pre-prepared translated xlf file to the PDF to produce a translated PDF.
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

		// Open a PDF document to translate
		$doc = new PDFDoc($input_path."tagged.pdf");
		$options = new TransPDFOptions();

		// Set the source language in the options
		$options->SetSourceLanguage("en");

		// Set the number of pages to process in each batch
		$options->SetBatchSize(20);

		// Optionally, subset the pages to process
		// This PDF only has a single page, but you can specify a subset of pages like this
		// $options->SetPages("-2,5-6,9,11-");

		// Extract the xlf to file and field the PDF for translation
		TransPDF::ExtractXLIFF($doc, $output_path."tagged.xlf", $options);

		// Save the fielded PDF
		$doc->Save($output_path."tagged-fielded.pdf", SDFDoc::e_linearized);

		// The extracted xlf can be translated in a system of your choice.
		// In this sample a pre-prepared translated file is used - tagged_(en_to_fr).xlf

		// Perform the translation using the pre-prepared translated xliff
		TransPDF::ApplyXLIFF($doc, $input_path."tagged_(en_to_fr).xlf", $options);

		// Save the translated PDF
		$doc->Save($output_path."tagged-fr.pdf", SDFDoc::e_linearized);
		$doc->Close();

	}
	catch (Exception $e) {
		echo(nl2br("Unable to translate PDF document, error: " . $e->getMessage() . "\n"));
	}

	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
