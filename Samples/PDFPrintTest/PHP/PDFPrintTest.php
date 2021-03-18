<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

/** 
 * The following sample is a used to illustrate how to print 
 * PDF document using currently selected default printer. In this sample, PDF::Print class 
 * is used to send data to the printer. 
 * 
 * Following this function is the more complex way of using PDFDraw directly.
 *
 * The first example uses the new PDF::Print::StartPrintJob function to send a rasterization 
 * of the document with optimal compression to the printer.  If the OS is Windows 7, then the
 * XPS print path will be used to preserve vector quality.
 *  
 * The second example uses PDFDraw send unoptimized rasterized data via the GDI print path. 
 *  
 * If you would like to rasterize page at high resolutions (e.g. more than 600 DPI), you 
 * should use PDFRasterizer or PDFNet vector output instead of PDFDraw. 
 */
 
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Relative path to the folder containing test files.
	$input_path = getcwd()."/../../TestFiles/";
	$doc = new PDFDoc($input_path."tiger.pdf");
	$doc->InitSecurityHandler();

	// Set our PrinterMode options
	$printerMode = new PrinterMode();
	$printerMode->SetCollation(true);
	$printerMode->SetCopyCount(1);
	$printerMode->SetDPI(600); // regardless of ordering, an explicit DPI setting overrides the OutputQuality setting
	$printerMode->SetDuplexing(PrinterMode::e_Duplex_Auto);
		
	// If the XPS print path is being used, then the printer spooler file will
	// ignore the grayscale option and be in full color
	$printerMode->SetOutputColor(PrinterMode::e_OutputColor_Grayscale);
	$printerMode->SetOutputQuality(PrinterMode::e_OutputQuality_Medium);
	// $printerMode->SetNUp(2,1);
	// $printerMode->SetScaleType(PrinterMode::e_ScaleType_FitToOutputPage);

	// Print the PDF document to the default printer, using "tiger.pdf" as the document
	// name, send the file to the printer not to an output file, print all pages, set the printerMode
	// and don't provide a cancel flag.
	PDFPrint::StartPrintJob($doc, "", $doc->GetFileName(), "", null, $printerMode, null);
	
?>

