<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/OCR/";
$output_path = getcwd()."/../../TestFiles/Output/";

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use OCR module
//---------------------------------------------------------------------------------------
	
	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// The location of the OCR Module
	PDFNet::AddResourceSearchPath("../../../Lib/");
	if(!OCRModule::IsModuleAvailable()) {
		echo "Unable to run OCRTest: PDFTron SDK OCR module not available.\n
			---------------------------------------------------------------\n
			The OCR module is an optional add-on, available for download\n
			at http://www.pdftron.com/. If you have already downloaded this\n
			module, ensure that the SDK is able to find the required files\n
			using the PDFNet::AddResourceSearchPath() function.\n";
	} else
	{
		//--------------------------------------------------------------------------------
		// Example 1) Process image without specifying options, default language - English - is used

	 
		// A) Setup empty destination doc
		$doc = new PDFDoc();

		// B) Run OCR on the .png with options

		OCRModule::ImageToPDF($doc, $input_path."psychomachia_excerpt.png", NULL);

		// C) check the result

		$doc->Save($output_path."psychomachia_excerpt.pdf", 0);

		echo "Example 1: psychomachia_excerpt.png \n";


		//--------------------------------------------------------------------------------
		// Example 2) Process document using multiple languages
	 
		// A) Setup empty destination doc
		
		$doc = new PDFDoc();

		// B) Setup options with multiple target languages, English will always be considered as secondary language

		$opts = new OCROptions();
		$opts->AddLang("rus");
		$opts->AddLang("deu");

		// B) Run OCR on the .png with options

		OCRModule::ImageToPDF($doc, $input_path."multi_lang.jpg", $opts);

		// C) check the result

		$doc->Save($output_path."multi_lang.pdf", 0);

		echo "Example 2: multi_lang.jpg \n";


		//--------------------------------------------------------------------------------
		// Example 3) Process a .pdf specifying a language - German - and ignore zone comprising a sidebar image 
		
		// A) Open the .pdf document
		
		$doc = new PDFDoc($input_path."german_kids_song.pdf");

		// B) Setup options with a single language and an ignore zone

		$opts = new OCROptions();
		$opts->AddLang("deu");

		$ignore_zones = new RectCollection();
		$rect = new Rect(424.0, 163.0, 493.0, 730.0);
		$ignore_zones->AddRect($rect);
		$opts->AddIgnoreZonesForPage($ignore_zones, 1);

		// C) Run OCR on the .pdf with options

		OCRModule::ProcessPDF($doc, $opts);

		// D) check the result

		$doc->Save($output_path."german_kids_song.pdf", 0);

		echo "Example 3: german_kids_song.pdf \n";

		//--------------------------------------------------------------------------------
		// Example 4) Process multipage tiff with text/ignore zones specified for each page, optionally provide English as the target language
		
		// A) Setup empty destination doc
		
		$doc = new PDFDoc();

		// B) Setup options with a single language plus text/ignore zones

		$opts = new OCROptions();
		$opts->AddLang("eng");

		$ignore_zones = new RectCollection();
		// ignore signature box in the first 2 pages
		$ignore_zones->AddRect(new Rect(1492.0, 56.0, 2236.0, 432.0));
		$opts->AddIgnoreZonesForPage($ignore_zones, 1);
		$opts->AddIgnoreZonesForPage($ignore_zones, 2);

		// can use a combination of ignore and text boxes to focus on the page area of interest,
		// as ignore boxes are applied first, we remove the arrows before selecting part of the diagram
		$ignore_zones->Clear();
		$ignore_zones->AddRect(new Rect(992.0, 1276.0, 1368.0, 1372.0));
		$opts->AddIgnoreZonesForPage($ignore_zones, 3);


		$text_zones = new RectCollection();
		// we only have text zones selected in page 3

		// select horizontal BUFFER ZONE sign
		$text_zones->AddRect(new Rect(900.0, 2384.0, 1236.0, 2480.0));
		// select right vertical BUFFER ZONE sign
		$text_zones->AddRect(new Rect(1960.0, 1976.0, 2016.0, 2296.0));
		// select Lot No.
		$text_zones->AddRect(new Rect(696.0, 1028.0, 1196.0, 1128.0));

		// select part of the plan inside the BUFFER ZONE
		$text_zones->AddRect(new Rect(428.0, 1484.0, 1784.0, 2344.0));
		$text_zones->AddRect(new Rect(948.0, 1288.0, 1672.0, 1476.0));
		$opts->AddTextZonesForPage($text_zones, 3);

		// C) Run OCR on the .pdf with options

		OCRModule::ImageToPDF($doc, $input_path."bc_environment_protection.tif", $opts);

		// D) check the result

		$doc->Save($output_path."bc_environment_protection.pdf", 0);

		echo "Example 4: bc_environment_protection.tif \n";


		//--------------------------------------------------------------------------------
		// Example 5) Alternative workflow for extracting OCR result JSON, postprocessing (e.g., removing words not in the dictionary or filtering special
		// out special characters), and finally applying modified OCR JSON to the source PDF document 
		// A) Setup empty destination doc
		
		$doc = new PDFDoc($input_path."zero_value_test_no_text.pdf");

		// B) Run OCR on the .pdf with default English language

		$json = OCRModule::GetOCRJsonFromPDF($doc, NULL);

		// C) Post-processing step (whatever it might be)

		echo "Have OCR result JSON, re-applying to PDF \n";

		OCRModule::ApplyOCRJsonToPDF($doc, $json);

		// D) check the result

		$doc->Save($output_path."zero_value_test_no_text.pdf", 0);

		echo "Example 5: extracting and applying OCR JSON from zero_value_test_no_text.pdf \n";


		//--------------------------------------------------------------------------------
		// Example 6) The postprocessing workflow has also an option of extracting OCR results in XML format, similar to the one used by TextExtractor
		
		// A) Setup empty destination doc

		$doc = new PDFDoc();

		// B) Run OCR on the .tif with default English language, extracting OCR results in XML format. Note that
		// in the process we convert the source image into PDF. We reuse this PDF document later to add hidden text layer to it.

		$xml = OCRModule::GetOCRXmlFromImage($doc, $input_path."physics.tif", NULL);

		// C) Post-processing step (whatever it might be)

		echo "Have OCR result XML, re-applying to PDF \n";

		OCRModule::ApplyOCRXmlToPDF($doc, $xml);

		// D) check the result

		$doc->Save($output_path."physics.pdf", 0);

		echo "Example 6: extracting and applying OCR XML from physics.tif \n";

		echo "Done. \n";


		//--------------------------------------------------------------------------------
		// Example 7) Resolution can be manually set, when DPI missing from metadata or is wrong

		// A) Setup empty destination doc

		$doc = new PDFDoc();

		// B) Setup options with a text zone

		$opts = new OCROptions();
		$text_zones = new RectCollection();
		$text_zones->AddRect(new Rect(140.0, 870.0, 310.0, 920.0));
		$opts->AddTextZonesForPage($text_zones, 1);

		// C) Manually override DPI

		$opts->AddDPI(100);

                // D) Run OCR on the .jpg with options

		OCRModule::ImageToPDF($doc, $input_path."corrupted_dpi.jpg", $opts);

		// E) check the result

		$doc->Save($output_path."corrupted_dpi.pdf", 0);

		echo "Example 7: converting image with corrupted resolution metadata corrupted_dpi.jpg to pdf with searchable text \n";

	}

?>
