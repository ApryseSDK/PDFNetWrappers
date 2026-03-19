<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/HandwritingICR/";
$output_path = getcwd()."/../../TestFiles/Output/";

function WriteTextToFile($outputFile, $text)
{
	$outfile = fopen($outputFile, "w");
	fwrite($outfile, $text);
	fclose($outfile);
}

//---------------------------------------------------------------------------------------
// The Handwriting ICR Module is an optional PDFNet add-on that can be used to extract
// handwriting from image-based pages and apply them as hidden text.
//
// The Apryse SDK Handwriting ICR Module can be downloaded from https://dev.apryse.com/
//---------------------------------------------------------------------------------------
	
	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize($LicenseKey);
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// The location of the Handwriting ICR Module
	PDFNet::AddResourceSearchPath("../../../PDFNetC/Lib/");

	// Test if the add-on is installed
	if(!HandwritingICRModule::IsModuleAvailable()) {
		echo "Unable to run HandwritingICRTest: PDFTron SDK Handwriting ICR Module\n
			not available.\n
			---------------------------------------------------------------\n
			The Handwriting ICR Module is an optional add-on, available for download\n
			at https://dev.apryse.com/. If you have already downloaded this\n
			module, ensure that the SDK is able to find the required files\n
			using the PDFNet::AddResourceSearchPath() function.\n";
	} else
	{
		//--------------------------------------------------------------------------------
		// Example 1) Process a PDF without specifying options
		echo "Example 1: processing icr.pdf\n";
	 
		// Open the .pdf document
		$doc = new PDFDoc($input_path."icr.pdf");

		// Run ICR on the .pdf with the default options
		HandwritingICRModule::ProcessPDF($doc);

		// Save the result with hidden text applied
		$doc->Save($output_path."icr-simple.pdf", SDFDoc::e_linearized);
		$doc->Close();

		//--------------------------------------------------------------------------------
		// Example 2) Process a subset of PDF pages
		echo "Example 2: processing pages from icr.pdf\n";
	 
		// Open the .pdf document
		$doc = new PDFDoc($input_path."icr.pdf");

		// Process handwriting with custom options
		$options = new HandwritingICROptions();
		
		// Optionally, process a subset of pages
		$options->SetPages("2-3");

		// Run ICR on the .pdf
		HandwritingICRModule::ProcessPDF($doc, $options);

		// Save the result with hidden text applied
		$doc->Save($output_path."icr-pages.pdf", SDFDoc::e_linearized);
		$doc->Close();

		//--------------------------------------------------------------------------------
		// Example 3) Ignore zones specified for each page
		echo "Example 3: processing & ignoring zones\n";
	 
		// Open the .pdf document
		$doc = new PDFDoc($input_path."icr.pdf");

		// Process handwriting with custom options
		$options = new HandwritingICROptions();
		
		// Process page 2 by ignoring the signature area on the bottom
		$options->SetPages("2");
		$ignore_zones_page2 = new RectCollection();
		// These coordinates are in PDF user space, with the origin at the bottom left corner of the page.
		// Coordinates rotate with the page, if it has rotation applied.
		$rect = new Rect(78, 850.1 - 770, 340, 850.1 - 676);
		$ignore_zones_page2->AddRect($rect);
		$options->AddIgnoreZonesForPage($ignore_zones_page2, 2);

		// Run ICR on the .pdf
		HandwritingICRModule::ProcessPDF($doc, $options);

		// Save the result with hidden text applied
		$doc->Save($output_path."icr-ignore.pdf", SDFDoc::e_linearized);
		$doc->Close();

		//--------------------------------------------------------------------------------
		// Example 4) The postprocessing workflow has also an option of extracting ICR results
		// in JSON format, similar to the one used by the OCR Module
		echo "Example 4: extract & apply\n";
	 
		// Open the .pdf document
		$doc = new PDFDoc($input_path."icr.pdf");
		
		// Extract ICR results in JSON format
		$json = HandwritingICRModule::GetICRJsonFromPDF($doc);
		WriteTextToFile($output_path."icr-get.json", $json);

		// Insert your post-processing step (whatever it might be)
		// ...

		// Apply potentially modified ICR JSON to the PDF
		HandwritingICRModule::ApplyICRJsonToPDF($doc, $json);

		// Save the result with hidden text applied
		$doc->Save($output_path."icr-get-apply.pdf", SDFDoc::e_linearized);
		$doc->Close();

		echo "Done.\n";
	}
	PDFNet::Terminate();

?>
