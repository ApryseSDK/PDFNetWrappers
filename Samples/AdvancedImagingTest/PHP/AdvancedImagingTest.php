<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

// ---------------------------------------------------------------------------------------
// The following sample illustrates how to use Advanced Imaging module
// --------------------------------------------------------------------------------------

function main()
{
	// Relative path to the folder containing the test files.
	$inputPath = getcwd()."/../../TestFiles/AdvancedImaging/";
	$outputPath = $inputPath."Output/";

    // The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	//-----------------------------------------------------------------------------------

	PDFNet::AddResourceSearchPath("../../../PDFNetC/Lib/");

	// Test if the add-on is installed
	if (!AdvancedImagingModule::IsModuleAvailable()) {
		echo(nl2br("\n"));
		echo(nl2br("Unable to run AdvancedImagingTest: Apryse SDK Advanced Imaging module not available.\n"));
		echo(nl2br("-----------------------------------------------------------------------------\n"));
		echo(nl2br("The Advanced Imaging module is an optional add-on, available for download\n"));
		echo(nl2br("at https://docs.apryse.com/documentation/core/info/modules/. If you have already\n"));
		echo(nl2br("downloaded this module, ensure that the SDK is able to find the required files\n"));
		echo(nl2br("using the PDFNet::AddResourceSearchPath() function.\n"));
		echo(nl2br("\n"));
	}
	else {
		try {
        	$inputFileName1 = "xray.dcm";
        	$outputFileName1 = $inputFileName1.".pdf";
        	$doc1 = new PDFDoc();
        	Convert::FromDICOM($doc1, $inputPath . $inputFileName1, NULL);
        	$doc1->Save($outputPath . $outputFileName1, SDFDoc::e_linearized);
		}
		catch(Exception $e) {
			echo(nl2br("Unable to convert DICOM test file, error: " . $e->getMessage() . "\n"));
		}
		
		try {
        	$inputFileName2 = "jasper.heic";
        	$outputFileName2 = $inputFileName2.".pdf";
        	$doc2 = new PDFDoc();
        	Convert::ToPdf($doc2, $inputPath . $inputFileName2);
        	$doc2->Save($outputPath . $outputFileName2, SDFDoc::e_linearized);
		}
		catch(Exception $e) {
			echo(nl2br("Unable to convert HEIC test file, error: " . $e->getMessage() . "\n"));
		}
		
		try {
        	$inputFileName3 = "tiger.psd";
        	$outputFileName3 = $inputFileName3.".pdf";
        	$doc3 = new PDFDoc();
        	Convert::ToPdf($doc3, $inputPath . $inputFileName3);
        	$doc3->Save($outputPath . $outputFileName3, SDFDoc::e_linearized);
		}
		catch(Exception $e) {
			echo(nl2br("Unable to convert the PSD test file, error: " . $e->getMessage() . "\n"));
		}

		echo(nl2br("Done.\n"));
	}

	PDFNet::Terminate();
}

main();
?>
