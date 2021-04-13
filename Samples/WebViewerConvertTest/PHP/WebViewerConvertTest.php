<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert PDF, XPS, image, MS Office, and 
// other image document formats to XOD format.
//
// Certain file formats such as PDF, generic XPS, EMF, and raster image formats can 
// be directly converted to XOD. 
// These types of conversions guarantee optimal output, while preserving important 
// information such as document metadata, intra document links and hyper-links, 
// bookmarks etc. 
//
// In case there is no direct conversion available, PDFNet can still convert from 
// any printable document to XOD using a virtual printer driver. To check 
// if a virtual printer is required use Convert::RequiresPrinter(filename). In this 
// case the installing application must be run as administrator. The manifest for this 
// sample specifies appropriate the UAC elevation. The administrator privileges are 
// not required for direct or interop conversions. 
//
// Please note that PDFNet Publisher (i.e. 'pdftron.PDF.Convert.ToXod') is an
// optionally licensable add-on to PDFNet Core SDK. For details, please see
// http://www.pdftron.com/webviewer/licensing.html.
//---------------------------------------------------------------------------------------


// Relative path to the folder containing the test files.
$inputPath = "../../TestFiles/";
$outputPath = "../../TestFiles/Output/";

function main()
{
    global $inputPath, $outputPath;

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Sample 1:
	// Directly convert from PDF to XOD.
	echo(nl2br("Converting: ".$inputPath."newsletter.pdf"." to ".$outputPath."from_pdf.xod"."\n"));
	Convert::ToXod($inputPath."newsletter.pdf", $outputPath."from_pdf.xod");

	// Sample 2:
	// Directly convert from generic XPS to XOD.
	echo(nl2br("Converting: ".$inputPath."simple-xps.xps"." to ".$outputPath."from_xps.xod"."\n"));
	Convert::ToXod($inputPath."simple-xps.xps", $outputPath."from_xps.xod");

	// Sample 3:
	// Directly convert from PNG to XOD.
	echo(nl2br("Converting: ".$inputPath."butterfly.png"." to ".$outputPath."butterfly.xod"."\n"));
	Convert::ToXod($inputPath."butterfly.png", $outputPath."butterfly.xod");

	// Sample 4:
   	echo(nl2br("Converting: " . $inputPath . "numbered.pdf" . " to: " . $outputPath . "numbered.xod\n"));
	Convert::ToXod($inputPath . "numbered.pdf", $outputPath . "numbered.xod");
	
	// Sample 5:
	// Directly convert from JPG to XOD.
	echo(nl2br("Converting: ".$inputPath."dice.jpg"." to ".$outputPath."dice.xod"."\n"));
	Convert::ToXod($inputPath."dice.jpg", $outputPath."dice.xod");

	// Sample 6:
	// Directly convert from generic XPS to XOD.
   	echo(nl2br("Converting: " . $inputPath . "simple-xps.xps" . " to: " . $outputPath . "simple-xps.xod\n"));
	Convert::ToXod($inputPath . "simple-xps.xps", $outputPath . "simple-xps.xod");
	echo(nl2br("Done.\n"));
}

main();
?>
