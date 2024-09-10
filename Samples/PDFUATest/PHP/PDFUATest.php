<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to make sure a file meets the PDF/UA standard, using the PDFUAConformance class object.
// Note: this feature is currently experimental and subject to change
//
// DataExtractionModule is required (Mac users can use StructuredOutputModule instead)
// https://docs.apryse.com/documentation/core/info/modules/#data-extraction-module
// https://docs.apryse.com/documentation/core/info/modules/#structured-output-module (Mac)
//---------------------------------------------------------------------------------------

function main()
{
	// Relative path to the folder containing the test files.
	$input_path = "../../TestFiles/";
	$output_path = "../../TestFiles/Output/";

	// DataExtraction library location, replace if desired, should point to a folder that includes the contents of <DataExtractionModuleRoot>/Lib.
	// If using default, unzip the DataExtraction zip to the parent folder of Samples, and merge with existing "Lib" folder.
	$extraction_module_path = "../../../PDFNetC/Lib/";

	$input_file1 = $input_path."autotag_input.pdf";
	$input_file2 = $input_path."table.pdf";
	$output_file1 = $output_path."autotag_pdfua.pdf";
	$output_file2 = $output_path."table_pdfua_linearized.pdf";

	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);

	echo(nl2br("AutoConverting...\n"));

	PDFNet::AddResourceSearchPath($extraction_module_path);

	if (!DataExtractionModule::IsModuleAvailable(DataExtractionModule::e_DocStructure)) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.\n"));
		echo(nl2br("-----------------------------------------------------------------------------\n"));
		echo(nl2br("The Data Extraction suite is an optional add-on, available for download\n"));
		echo(nl2br("at https://docs.apryse.com/documentation/core/info/modules/. If you have already\n"));
		echo(nl2br("downloaded this module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
		PDFNet::Terminate();
		return;
	}

	try {
		$pdf_ua = PDFUAConformance();

		echo(nl2br("Simple Conversion...\n"));

		// Perform conversion using default options
		$pdf_ua->AutoConvert($input_file1, $output_file1);

		echo(nl2br("Converting With Options...\n"));

		$pdf_ua_opts = new PDFUAOptions();
		$pdf_ua_opts->SetSaveLinearized(true); // Linearize when saving output
		// Note: if file is password protected, you can use $pdf_ua_opts->SetPassword()

		// Perform conversion using the options we specify
		$pdf_ua->AutoConvert($input_file2, $output_file2, $pdf_ua_opts);
	}
	catch(Exception $e) {
		echo(nl2br($e->getMessage()));
	}

	PDFNet::Terminate();
	echo(nl2br("\n"));
	echo(nl2br("PDFUAConformance test completed.\n"));
}

main();
?>