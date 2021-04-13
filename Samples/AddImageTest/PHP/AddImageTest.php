<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//-----------------------------------------------------------------------------------
// This sample illustrates how to embed various raster image formats
// (e.g. TIFF, JPEG, JPEG2000, JBIG2, GIF, PNG, BMP, etc.) in a PDF document.
//
// Note: On Windows platform this sample utilizes GDI+ and requires GDIPLUS.DLL to
// be present in the system path.
//-----------------------------------------------------------------------------------
	
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	$doc = new PDFDoc();
	$builder = new ElementBuilder();	// Used to build new Element objects
	$writer = new ElementWriter();		// Used to write Elements to the page
	
	$page = $doc->PageCreate();		// Start a new page
	$writer->Begin($page);			// Begin writing to this page
	
	// ----------------------------------------------------------
    	// Add JPEG image to the output file
    	$img = Image::Create($doc->GetSDFDoc(), $input_path."peppers.jpg");
    	$element = $builder->CreateImage($img, 50.0, 500.0, (double)($img->GetImageWidth())/2, (double)($img->GetImageHeight())/2);
    	$writer->WritePlacedElement($element);

   	// ----------------------------------------------------------
    	// Add a PNG image to the output file
    	$img = Image::Create($doc->GetSDFDoc(), $input_path."butterfly.png");
    	$element = $builder->CreateImage($img, new Matrix2D(100.0, 0.0, 0.0, 100.0, 300.0, 500.0));
    	$writer->WritePlacedElement($element);

   	// ----------------------------------------------------------
   	// Add a GIF image to the output file
    	$img = Image::Create($doc->GetSDFDoc(), $input_path."pdfnet.gif");
    	$element = $builder->CreateImage($img, new Matrix2D((double)($img->GetImageWidth()), 0.0, 0.0, (double)($img->GetImageHeight()), 50.0, 350.0));
    	$writer->WritePlacedElement($element);
    
    	// ----------------------------------------------------------
    	// Add a TIFF image to the output file
  
    	$img = Image::Create($doc->GetSDFDoc(), $input_path."grayscale.tif");
    	$element = $builder->CreateImage($img, new Matrix2D((double)($img->GetImageWidth()), 0.0, 0.0, (double)($img->GetImageHeight()), 10.0, 50.0));
    	$writer->WritePlacedElement($element);
    
    	$writer->End();                // Save the page
    	$doc->PagePushBack($page);     // Add the page to the document page sequence
     
    	// ----------------------------------------------------------
    	// Embed a monochrome TIFF. Compress the image using lossy JBIG2 filter.

    	$page = $doc->PageCreate(new Rect(0.0, 0.0, 612.0, 794.0));
    	$writer->Begin($page);           // begin writing to this page

	// Note: encoder hints can be used to select between different compression methods. 
	// For example to instruct PDFNet to compress a monochrome image using JBIG2 compression.
    	$hint_set = new ObjSet();
    	$enc = $hint_set->CreateArray();  // Initilaize encoder 'hint' parameter 
    	$enc->PushBackName("JBIG2");
    	$enc->PushBackName("Lossy");

    	$img = Image::Create($doc->GetSDFDoc(), $input_path."multipage.tif");
    	$element = $builder->CreateImage($img, new Matrix2D(612.0, 0.0, 0.0, 794.0, 0.0, 0.0));
    	$writer->WritePlacedElement($element);

    	$writer->End();                   // Save the page
    	$doc->PagePushBack($page);        // Add the page to the document page sequence

    	// ----------------------------------------------------------
    	// Add a JPEG2000 (JP2) image to the output file
    
   	// Create a new page
    	$page = $doc->PageCreate();
    	$writer->Begin($page);             // Begin writing to the page
    
    	// Embed the image
    	$img = Image::Create($doc->GetSDFDoc(), $input_path."palm.jp2");
    
    	// Position the image on the page
    	$element = $builder->CreateImage($img, new Matrix2D((double)($img->GetImageWidth()), 0.0, 0.0, (double)($img->GetImageHeight()), 96.0, 80.0));
    	$writer->WritePlacedElement($element);
    
    	// Write 'JPEG2000 Sample' text string under the image
    	$writer->WriteElement($builder->CreateTextBegin(Font::Create($doc->GetSDFDoc(), Font::e_times_roman), 32.0));
    	$element = $builder->CreateTextRun("JPEG2000 Sample");
    	$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 190.0, 30.0);
    	$writer->WriteElement($element);
    	$writer->WriteElement($builder->CreateTextEnd());
    	
    	$writer->End();                   // Finish writing to the page
    	$doc->PagePushBack($page);
    
    	$doc->Save(($output_path."addimage.pdf"), SDFDoc::e_linearized);
    	$doc->Close();
    	echo nl2br("Done. Result saved in addimage.pdf...\n");
?>
