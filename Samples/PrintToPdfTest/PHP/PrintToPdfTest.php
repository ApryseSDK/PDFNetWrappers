<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = getcwd()."/../../TestFiles/Output/";

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert documents to PDF format by printing
// them to the Apryse PDF printer via the Windows print verb, using the
// 'PrintToPdfModule' class.
//
// The PrintToPdf module is an optional PDFNet Add-on that can be used to convert any
// printable document into a PDF.
//
// The Apryse SDK PrintToPdf module can be downloaded from http://www.apryse.com/
//
// Note: The PrintToPdf module is only available on Windows.
//---------------------------------------------------------------------------------------

	// The first step in every application using PDFNet is to initialize the
	// library and set the path to common PDF resources. The library is usually
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// The location of the PrintToPdf Module
	PDFNet::AddResourceSearchPath("../../../PDFNetC/Lib/");
	if(!PrintToPdfModule::IsModuleAvailable()) {
		echo "Unable to run PrintToPdfTest: Apryse SDK PrintToPdf module not available.\n
			---------------------------------------------------------------\n
			The PrintToPdf module is an optional add-on, available for download\n
			at http://www.apryse.com/. If you have already downloaded this\n
			module, ensure that the SDK is able to find the required files\n
			using the PDFNet::AddResourceSearchPath() function.\n";
	} else
	{
		$input_file_name = "simple-word_2007.docx";
		$output_file_name = $input_file_name.".pdf";

		try {
			$doc = new PDFDoc();

			// Convert the document with some user options
			$opts = new PrintToPdfOptions();
			$opts->SetPageOrientation("portrait");
			$opts->SetHorizontalPageMargin(18);
			$opts->SetVerticalPageMargin(18);
			// Page width and height in points (1/72 of an inch).
			// If both are zero (default), letter paper size is used.
			// $opts->SetPageWidth(612);
			// $opts->SetPageHeight(792);

			PrintToPdfModule::PrintToPdf($doc, $input_path.$input_file_name, $opts);
			$doc->Save($output_path.$output_file_name, SDFDoc::e_linearized);
			echo "Printed file: ".$input_file_name."\n";
			echo "to: ".$output_file_name."\n";
		} catch (Exception $e) {
			echo "Unable to convert file ".$input_file_name."\n";
			echo $e->getMessage()."\n";
		}

		echo "PrintToPdf conversion example \n";
	}
	PDFNet::Terminate();
?>
