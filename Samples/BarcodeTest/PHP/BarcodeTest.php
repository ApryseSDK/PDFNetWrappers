<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The Barcode Module is an optional PDFNet add-on that can be used to extract
// various types of barcodes from PDF documents.
//
// The Apryse SDK Barcode Module can be downloaded from http://dev.apryse.com/
//---------------------------------------------------------------------------------------

function WriteTextToFile($outputFile, $text)
{
	$outfile = fopen($outputFile, "w");
	fwrite($outfile, $text);
	fclose($outfile);
}

function main()
{
	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/Barcode/";
	$output_path = getcwd()."/../../TestFiles/Output/";

	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// The location of the Barcode Module
	PDFNet::AddResourceSearchPath("../../../Lib/");

	if (!BarcodeModule::IsModuleAvailable()) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run BarcodeTest: Apryse SDK Barcode Module not available.\n"));
		echo(nl2br("---------------------------------------------------------------\n"));
		echo(nl2br("The Barcode Module is an optional add-on, available for download\n"));
		echo(nl2br("at https://dev.apryse.com/. If you have already downloaded this\n"));
		echo(nl2br("module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
	}
	else {
		try {
			//--------------------------------------------------------------------------------
			// Example 1) Detect and extract all barcodes from a PDF document into a JSON file

			// A) Open the .pdf document
			$doc = new PDFDoc($input_path."barcodes.pdf");

			// B) Detect PDF barcodes with the default options
			BarcodeModule::ExtractBarcodes($doc, $output_path."barcodes.json");

			echo(nl2br("Example 1: extracting barcodes from barcodes.pdf to barcodes.json\n"));


			//--------------------------------------------------------------------------------
			// Example 2) Limit barcode extraction to a range of pages, and retrieve the JSON into a
			// local string variable, which is then written to a file in a separate function call

			// A) Open the .pdf document
			$doc = new PDFDoc($input_path."barcodes.pdf");

			// B) Detect PDF barcodes with custom options
			$options = new BarcodeOptions();

			// Convert only the first two pages
			$options->SetPages("1-2");

			$json = BarcodeModule::ExtractBarcodesAsString($doc, $options);

			// C) Save JSON to file
			WriteTextToFile($output_path."barcodes_from_pages_1-2.json", $json);

			echo(nl2br("Example 2: extracting barcodes from pages 1-2 to barcodes_from_pages_1-2.json\n"));


			//--------------------------------------------------------------------------------
			// Example 3) Narrow down barcode types and allow the detection of both horizontal
			// and vertical barcodes

			// A) Open the .pdf document
			$doc = new PDFDoc($input_path."barcodes.pdf");

			// B) Detect only basic 1D barcodes, both horizontal and vertical
			$options = new BarcodeOptions();

			// Limit extraction to basic 1D barcode types, such as EAN 13, EAN 8, UPCA, UPCE,
			// Code 3 of 9, Code 128, Code 2 of 5, Code 93, Code 11 and GS1 Databar.
			$options->SetBarcodeSearchTypes(BarcodeOptions::e_barcode_group_linear);

			// Search for barcodes oriented horizontally and vertically
			$options->SetBarcodeOrientations(
				BarcodeOptions::e_barcode_direction_horizontal |
				BarcodeOptions::e_barcode_direction_vertical);

			BarcodeModule::ExtractBarcodes($doc, $output_path."barcodes_1D.json", $options);

			echo(nl2br("Example 3: extracting basic horizontal and vertical barcodes\n"));

		}
		catch (Exception $e) {
			echo(nl2br("Unable to extract form fields data, error: " . $e->getMessage() . "\n"));
		}
	}
	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
