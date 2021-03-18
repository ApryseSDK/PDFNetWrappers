<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert HTML pages to PDF format using
// the HTML2PDF class.
// 
// 'pdftron.PDF.HTML2PDF' is an optional PDFNet Add-On utility class that can be 
// used to convert HTML web pages into PDF documents by using an external module (html2pdf).
//
// html2pdf modules can be downloaded from http://www.pdftron.com/pdfnet/downloads.html.
//
// Users can convert HTML pages to PDF using the following operations:
// - Simple one line static method to convert a single web page to PDF. 
// - Convert HTML pages from URL or string, plus optional table of contents, in user defined order. 
// - Optionally configure settings for proxy, images, java script, and more for each HTML page. 
// - Optionally configure the PDF output, including page size, margins, orientation, and more. 
// - Optionally add table of contents, including setting the depth and appearance.
//---------------------------------------------------------------------------------------

	$output_path = "../../TestFiles/Output/html2pdf_example";
	$host = "http://www.gutenberg.org/";
	$page0 = "wiki/Main_Page";
	$page1 = "catalog/";
	$page2 = "browse/recent/last1";
	$page3 = "wiki/Gutenberg:The_Sheet_Music_Project";

	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// For HTML2PDF we need to locate the html2pdf module. If placed with the 
	// PDFNet library, or in the current working directory, it will be loaded
	// automatically. Otherwise, it must be set manually using HTML2PDF.SetModulePath.
	HTML2PDF::SetModulePath("./../../../PDFNetC/Lib");

	//--------------------------------------------------------------------------------
	// Example 1) Simple conversion of a web page to a PDF doc. 

	$doc = new PDFDoc();

	// now convert a web page, sending generated PDF pages to doc
	$converter = new HTML2PDF();
	$converter->InsertFromURL($host.$page0);
	if ( $converter->Convert($doc) ) {
		$doc->Save($output_path."_01.pdf", SDFDoc::e_linearized);
	}
	else {
		echo printf("Conversion failed. HTTP Code: %d\n%s", $converter->GetHTTPErrorCode(), $converter->GetLog());
	}
	$doc->Close();

	//--------------------------------------------------------------------------------
	// Example 2) Modify the settings of the generated PDF pages and attach to an
	// existing PDF document. 

	// open the existing PDF, and initialize the security handler
	$doc = new PDFDoc("../../TestFiles/numbered.pdf");
	$doc->InitSecurityHandler();

	// create the HTML2PDF converter object and modify the output of the PDF pages
	$converter = new HTML2PDF();
	$converter->SetImageQuality(25);
	$converter->SetPaperSize(PrinterMode::e_11x17);

	// insert the web page to convert
	$converter->InsertFromURL($host.$page0);

	// convert the web page, appending generated PDF pages to doc
	if ( $converter->Convert($doc) ) {
		$doc->Save($output_path."_02.pdf", SDFDoc::e_linearized);
	}
	else {
		echo printf("Conversion failed. HTTP Code: %d\n%s", $converter->GetHTTPErrorCode(), $converter->GetLog());
	}
	$doc->Close();

	//--------------------------------------------------------------------------------
	// Example 3) Convert multiple web pages, adding a table of contents, and setting
	// the first page as a cover page, not to be included with the table of contents outline. 

	$doc = new PDFDoc();

	$converter = new HTML2PDF();

	// Add a cover page, which is excluded from the outline, and ignore any errors
	$cover = new WebPageSettings();
	$cover->SetLoadErrorHandling(WebPageSettings::e_ignore);
	$cover->SetIncludeInOutline(false);
	$converter->InsertFromURL($host.$page3, $cover);

	// Add a table of contents settings (modifying the settings is optional)
	$toc = new TOCSettings();
	$toc->SetDottedLines(false);
	$converter->InsertTOC($toc);

	// Now add the rest of the web pages, disabling external links and 
	// skipping any web pages that fail to load.
	//
	// Note that the order of insertion matters, so these will appear
	// after the cover and table of contents, in the order below.
	$settings = new WebPageSettings();
	$settings->SetLoadErrorHandling(WebPageSettings::e_skip);
	$settings->SetExternalLinks(false);
	$converter->InsertFromURL($host.$page0, $settings);
	$converter->InsertFromURL($host.$page1, $settings);
	$converter->InsertFromURL($host.$page2, $settings);

	if ($converter->Convert($doc) == true) {
		$doc->Save($output_path."_03.pdf", SDFDoc::e_linearized);
	}
	else {
		echo printf("Conversion failed. HTTP Code: %d\n%s", $converter->GetHTTPErrorCode(), $converter->GetLog());
	}
	$doc->Close();
	
	//--------------------------------------------------------------------------------
	// Example 4) Convert HTML string to PDF. 

	$doc = new PDFDoc();

	$converter = new HTML2PDF();
	
	// Our HTML data
	$html = "<html><body><h1>Heading</h1><p>Paragraph.</p></body></html>";
		
	// Add html data
	$converter->InsertFromHtmlString($html);
	// Note, InsertFromHtmlString can be mixed with the other Insert methods.
	
	if ( $converter->Convert($doc) ) {
		$doc->Save($output_path."_04.pdf", SDFDoc::e_linearized);
	}
	else {
		echo printf("Conversion failed. HTTP Code: %d\n%s", $converter->GetHTTPErrorCode(), $converter->GetLog());
	}
	$doc->Close();
?>
