<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to PDF, XPS, or SVG, or EMF. The sample also shows how to convert MS Office files 
// using our built in conversion.
//
// Certain file formats such as XPS, EMF, PDF, and raster image formats can be directly 
// converted to PDF or XPS. 
//
// Please contact us if you have any questions.	
//
// Please contact us if you have any questions.    
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
$inputPath = getcwd()."/../../TestFiles/";
$outputPath = $inputPath."Output/";


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

		// Convert SVG file to PDF
		echo(nl2br("Converting SVG to PDF\n"));
		$pdfdoc = new PDFDoc();
		Convert::FromSVG($pdfdoc, $inputPath . "tiger.svg");
		$pdfdoc->Save($outputPath . "svg2pdf.pdf", SDFDoc::e_remove_unused);
		echo(nl2br("Saved svg2pdf.pdf\n"));
	}
    catch(Exception $e){
        $ret = 1;
	}
    return $ret;
}

function ConvertToPdfFromFile()
{
	global $inputPath, $outputPath;

	$testfiles = array(
	array("simple-word_2007.docx","docx2pdf.pdf"),
	array("simple-powerpoint_2007.pptx","pptx2pdf.pdf"),
	array("simple-excel_2007.xlsx","xlsx2pdf.pdf"),
	array("simple-text.txt","txt2pdf.pdf"),
	array("butterfly.png", "png2pdf.pdf"),
	array("simple-xps.xps", "xps2pdf.pdf"),
    );
    $ret = 0;
    foreach ($testfiles as &$testfile) {
		try{
			$pdfdoc = new PDFDoc();
			$inputFile = $testfile[0];
			$outputFile = $testfile[1];
			Printer::SetMode(Printer::e_prefer_builtin_converter)
			Convert::ToPdf($pdfdoc, $inputPath.$inputFile);
			$pdfdoc->Save($outputPath.$outputFile, SDFDoc::e_linearized);
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

function main()
{
	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	global $LicenseKey;
	PDFNet::Initialize($LicenseKey);
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
	
	PDFNet::Terminate();
	echo(nl2br("Done.\n"));
}

main();
?>
