<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to PDF, XPS, SVG, or EMF.
//
// Certain file formats such as XPS, EMF, PDF, and raster image formats can be directly 
// converted to PDF or XPS. Other formats are converted using a virtual driver. To check 
// if ToPDF (or ToXPS) require that PDFNet printer is installed use Convert::RequiresPrinter(filename). 
// The installing application must be run as administrator. The manifest for this sample 
// specifies appropriate the UAC elevation.
//
// Note: the PDFNet printer is a virtual XPS printer supported on Vista SP1 and Windows 7.
// For Windows XP SP2 or higher, or Vista SP0 you need to install the XPS Essentials Pack (or 
// equivalent redistributables). You can download the XPS Essentials Pack from:
//		http://www.microsoft.com/downloads/details.aspx?FamilyId=B8DCFFDD-E3A5-44CC-8021-7649FD37FFEE&displaylang=en
// Windows XP Sp2 will also need the Microsoft Core XML Services (MSXML) 6.0:
// 		http://www.microsoft.com/downloads/details.aspx?familyid=993C0BCF-3BCF-4009-BE21-27E85E1857B1&displaylang=en
//
// Note: Convert.FromEmf and Convert.ToEmf will only work on Windows and require GDI+.
//
// Please contact us if you have any questions.	
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
$inputPath = getcwd()."/../../TestFiles/";
$outputPath = $inputPath."Output/";

function ConvertToPdfFromFile()
{
	global $inputPath, $outputPath;

	$testfiles = array(
	array("butterfly.png", "png2pdf.pdf"),
	array("simple-xps.xps", "xps2pdf.pdf"),
    );
    $ret = 0;
    foreach ($testfiles as &$testfile) {
		try{
			$pdfdoc = new PDFDoc();
			$inputFile = $testfile[0];
			$outputFile = $testfile[1];
			Convert::ToPdf($pdfdoc, $inputPath.$inputFile);
			$pdfdoc->Save($outputPath.$outputFile, SDFDoc::e_compatibility);
	        	$pdfdoc->Close();
			echo(nl2br("Converted file: ".$inputFile."\n"));
			echo(nl2br("to: ".$outputFile."\n"));
		}
		catch(Exception $e)
		{
			$ret = 1;
		}
    }
	return $ret;
}

function ConvertSpecificFormats()
{
	global $inputPath, $outputPath;

	$pdfdoc = new PDFDoc();
	$s1 = $inputPath."simple-xps.xps";

	$ret = 0;
	try{
		// Convert the XPS document to PDF
		echo(nl2br("Converting from XPS\n"));
		Convert::FromXps($pdfdoc, $s1 );
		$outputFile = "xps2pdf v2.pdf";
		$pdfdoc->Save($outputPath.$outputFile, SDFDoc::e_remove_unused);
		echo(nl2br("Saved ".$outputFile."\n"));


		// Convert the TXT document to PDF
		$set = new ObjSet();
		$options = $set->CreateDict();
		// Put options
		$options->PutNumber("FontSize", 15);
		$options->PutBool("UseSourceCodeFormatting", true);
		$options->PutNumber("PageWidth", 12);
		$options->PutNumber("PageHeight", 6);
		$s1 = $inputPath . "simple-text.txt";
		echo(nl2br("Converting from txt\n"));
		Convert::FromText($pdfdoc, $s1);
		$outputFile = "simple-text.pdf";
		$pdfdoc->Save($outputPath.$outputFile, SDFDoc::e_remove_unused);
		echo(nl2br("Saved ".$outputFile ."\n"));
		
		// Convert the two page PDF document to SVG
		$pdfdoc = new PDFDoc($inputPath . "newsletter.pdf");
		echo(nl2br("Converting pdfdoc to SVG\n"));
		$outputFile = "pdf2svg v2.svg";
		Convert::ToSvg($pdfdoc, $outputPath.$outputFile);
		echo(nl2br("Saved ".$outputFile."\n"));



		// Convert the PNG image to XPS
		echo(nl2br("Converting PNG to XPS\n"));
		$outputFile = "butterfly.xps";
		Convert::ToXps($inputPath."butterfly.png", $outputPath.$outputFile);
		echo(nl2br("Saved ".$outputFile."\n"));

		// Convert PDF document to XPS
		echo(nl2br("Converting PDF to XPS\n"));
		$outputFile = "newsletter.xps";
		Convert::ToXps($inputPath."newsletter.pdf", $outputPath.$outputFile);
		echo(nl2br("Saved ".$outputFile."\n"));

		// Convert PDF document to HTML
		echo(nl2br("Converting PDF to HTML\n"));
		$outputFile = "newsletter";
		Convert::ToHtml($inputPath."newsletter.pdf", $outputPath.$outputFile);
		echo(nl2br("Saved newsletter as HTML\n"));

		// Convert PDF document to EPUB
		echo(nl2br("Converting PDF to EPUB\n"));
		$outputFile = "newsletter.epub";
		Convert::ToEpub($inputPath."newsletter.pdf", $outputPath.$outputFile);
		echo(nl2br("Saved ".$outputFile."\n"));

		echo(nl2br("Converting PDF to multipage TIFF\n"));
		$tiff_options = new TiffOutputOptions();
		$tiff_options->SetDPI(200);
		$tiff_options->SetDither(true);
		$tiff_options->SetMono(true);
		Convert::ToTiff($inputPath . "newsletter.pdf", $outputPath. "newsletter.tiff", $tiff_options);
		echo(nl2br("Saved newsletter.tiff\n"));
	}
    catch(Exception $e){
        $ret = 1;
	}
    return $ret;
}

function main()
{
	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Demonstrate Convert::ToPdf and Convert::Printer
	$err = ConvertToPdfFromFile();
	if ($err)
		echo(nl2br("ConvertFile failed\n"));
	else
		echo(nl2br("ConvertFile succeeded\n"));
	
	// Demonstrate Convert::[FromEmf, FromXps, ToEmf, ToSVG, ToXPS]
	$err = ConvertSpecificFormats();
	if ($err)
		echo(nl2br("ConvertSpecificFormats failed\n"));
	else
		echo(nl2br("ConvertSpecificFormats succeeded\n"));
	echo(nl2br("Done.\n"));
}

main();
?>
