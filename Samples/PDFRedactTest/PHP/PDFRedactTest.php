<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// PDF Redactor is a separately licensable Add-on that offers options to remove 
// (not just covering or obscuring) content within a region of PDF. 
// With printed pages, redaction involves blacking-out or cutting-out areas of 
// the printed page. With electronic documents that use formats such as PDF, 
// redaction typically involves removing sensitive content within documents for 
// safe distribution to courts, patent and government institutions, the media, 
// customers, vendors or any other audience with restricted access to the content. 
//
// The redaction process in PDFNet consists of two steps:
// 
//  a) Content identification: A user applies redact annotations that specify the 
// pieces or regions of content that should be removed. The content for redaction 
// can be identified either interactively (e.g. using 'pdftron.PDF.PDFViewCtrl' 
// as shown in PDFView sample) or programmatically (e.g. using 'pdftron.PDF.TextSearch'
// or 'pdftron.PDF.TextExtractor'). Up until the next step is performed, the user 
// can see, move and redefine these annotations.
//  b) Content removal: Using 'pdftron.PDF.Redactor.Redact()' the user instructs 
// PDFNet to apply the redact regions, after which the content in the area specified 
// by the redact annotations is removed. The redaction function includes number of 
// options to control the style of the redaction overlay (including color, text, 
// font, border, transparency, etc.).
// 
// PDFTron Redactor makes sure that if a portion of an image, text, or vector graphics 
// is contained in a redaction region, that portion of the image or path data is 
// destroyed and is not simply hidden with clipping or image masks. PDFNet API can also 
// be used to review and remove metadata and other content that can exist in a PDF 
// document, including XML Forms Architecture (XFA) content and Extensible Metadata 
// Platform (XMP) content.
	
function Redact($input, $output, $vec, $app) {
	$doc = new PDFDoc($input);
	if ($doc->InitSecurityHandler()) {
		Redactor::Redact($doc, $vec, $app, false, true);
		$doc->Save($output, SDFDoc::e_linearized);
	}

}

	# Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$vec = new VectorRedaction();
	$vec->push(new Redaction(1, new Rect(100.0, 100.0, 550.0, 600.0), false, "Top Secret"));
	$vec->push(new Redaction(2, new Rect(30.0, 30.0, 450.0, 450.0), true, "Negative Redaction"));
	$vec->push(new Redaction(2, new Rect(0.0, 0.0, 100.0, 100.0), false, "Positive"));
	$vec->push(new Redaction(2, new Rect(100.0, 100.0, 200.0, 200.0), false, "Positive"));
   	$vec->push(new Redaction(2, new Rect(300.0, 300.0, 400.0, 400.0), false, ""));
	$vec->push(new Redaction(2, new Rect(500.0, 500.0, 600.0, 600.0), false, ""));
	$vec->push(new Redaction(3, new Rect(0.0, 0.0, 700.0, 20.0), false, ""));
	
	$app = new Appearance(); 
	$app->RedactionOverlay = true;
	$app->Border = false;
	$app->ShowRedactedContentRegions = true;
	Redact($input_path."newsletter.pdf", $output_path."redacted.pdf", $vec, $app);
    
	echo "Done...\n";	
?>
