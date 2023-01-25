<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The Data Extraction suite is an optional PDFNet add-on collection that can be used to
// extract various types of data from PDF documents.
//
// The PDFTron SDK Data Extraction suite can be downloaded from
// https://www.pdftron.com/documentation/core/info/modules/
//
// Please contact us if you have any questions.
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
	$inputPath = getcwd()."/../../TestFiles/";
	$outputPath = $inputPath."Output/";

	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	//-----------------------------------------------------------------------------------

	PDFNet::AddResourceSearchPath("../../../PDFNetC/Lib/");

	//////////////////////////////////////////////////////////////////////////
	// The following sample illustrates how to extract tables from PDF documents.
	//////////////////////////////////////////////////////////////////////////

	// Test if the add-on is installed
	if (!DataExtractionModule::IsModuleAvailable(DataExtractionModule::e_Tabular)) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run Data Extraction: PDFTron SDK Tabular Data module not available.\n"));
		echo(nl2br("-----------------------------------------------------------------------------\n"));
		echo(nl2br("The Data Extraction suite is an optional add-on, available for download\n"));
		echo(nl2br("at https://www.pdftron.com/documentation/core/info/modules/. If you have already\n"));
		echo(nl2br("downloaded this module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
	}
	else {
		try {
			// Extract tabular data as a JSON file
			echo(nl2br("Extract tabular data as a JSON file\n"));

			$outputFile = $outputPath."table.json";
			$json = DataExtractionModule::ExtractData($inputPath."table.pdf", DataExtractionModule::e_Tabular);
			WriteTextToFile($outputFile, $json);

			echo(nl2br("Result saved in " . $outputFile . "\n"));
		}
		catch(Exception $e) {
			echo(nl2br("Unable to extract tabular data, error: " . $e->getMessage() . "\n"));
		}

		try {
			// Extract tabular data as an XLSX file
			echo(nl2br("Extract tabular data as an XLSX file\n"));

			$outputFile = $outputPath."table.xlsx";
			DataExtractionModule::ExtractToXSLX($inputPath."table.pdf", $outputFile);

			echo(nl2br("Result saved in " . $outputFile . "\n"));
		}
		catch(Exception $e) {
			echo(nl2br("Unable to extract tabular data, error: " . $e->getMessage() . "\n"));
		}

		try {
			// Extract tabular data as an XLSX stream (also known as filter)
			echo(nl2br("Extract tabular data as an XLSX stream\n"));

			$outputFile = $outputPath."table_streamed.xlsx";
			$outputXlsxStream = new MemoryFilter(0, false);
			$options = new DataExtractionOptions();
			$options.setPages("1"); // page 1
			DataExtractionModule::ExtractToXSLX($inputPath."table.pdf", $outputXlsxStream, $options);
			$outputXlsxStream.setAsInputFilter();
			$outputXlsxStream.writeToFile($outputFile, false);

			echo(nl2br("Result saved in " . $outputFile . "\n"));
		}
		catch(Exception $e) {
			echo(nl2br("Unable to extract tabular data, error: " . $e->getMessage() . "\n"));
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// The following sample illustrates how to extract document structure from PDF documents.
	//////////////////////////////////////////////////////////////////////////

	// Test if the add-on is installed
	if (!DataExtractionModule::IsModuleAvailable(DataExtractionModule::e_DocStructure)) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.\n"));
		echo(nl2br("-----------------------------------------------------------------------------\n"));
		echo(nl2br("The Data Extraction suite is an optional add-on, available for download\n"));
		echo(nl2br("at https://www.pdftron.com/documentation/core/info/modules/. If you have already\n"));
		echo(nl2br("downloaded this module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
	}
	else {
		try {
			// Extract document structure as a JSON file
			echo(nl2br("Extract document structure as a JSON file\n"));

			$outputFile = $outputPath."paragraphs_and_tables.json";
			$json = DataExtractionModule::ExtractData($inputPath."paragraphs_and_tables.pdf", DataExtractionModule::e_DocStructure);
			WriteTextToFile($outputFile, $json);

			echo(nl2br("Result saved in " . $outputFile . "\n"));
		}
		catch(Exception $e) {
			echo(nl2br("Unable to extract document structure data, error: " . $e->getMessage() . "\n"));
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// The following sample illustrates how to extract form fields from PDF documents.
	//////////////////////////////////////////////////////////////////////////

	// Test if the add-on is installed
	if (!DataExtractionModule::IsModuleAvailable(DataExtractionModule::e_Form)) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run Data Extraction: PDFTron SDK AIFormFieldExtractor module not available.\n"));
		echo(nl2br("-----------------------------------------------------------------------------\n"));
		echo(nl2br("The Data Extraction suite is an optional add-on, available for download\n"));
		echo(nl2br("at https://www.pdftron.com/documentation/core/info/modules/. If you have already\n"));
		echo(nl2br("downloaded this module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
	}
	else {
		try {
			// Extract form fields as a JSON file
			echo(nl2br("Extract form fields as a JSON file\n"));

			$outputFile = $outputPath."formfield.json";
			$json = DataExtractionModule::ExtractData($inputPath."formfield.pdf", DataExtractionModule::e_Form);
			WriteTextToFile($outputFile, $json);

			echo(nl2br("Result saved in " . $outputFile . "\n"));
		}
		catch(Exception $e) {
			echo(nl2br("Unable to extract form fields data, error: " . $e->getMessage() . "\n"));
		}
	}

	//-----------------------------------------------------------------------------------

	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
