<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/newsletter_booklet.pdf";

//-----------------------------------------------------------------------------------
// The sample illustrates how multiple pages can be combined/imposed 
// using PDFNet. Page imposition can be used to arrange/order pages 
// prior to printing or to assemble a 'master' page from several 'source' 
// pages. Using PDFNet API it is possible to write applications that can 
// re-order the pages such that they will display in the correct order 
// when the hard copy pages are compiled and folded correctly. 
//-----------------------------------------------------------------------------------

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	echo nl2br("-------------------------------------------------\n");
	echo nl2br("Opening the input pdf...\n");

	$in_doc = new PDFDoc($input_path."newsletter.pdf");
	$in_doc->InitSecurityHandler();

	// Create a list of pages to import from one PDF document to another.
	$import_pages = new VectorPage(); 
	for ($itr=$in_doc->GetPageIterator(); $itr->HasNext(); $itr->Next())
		$import_pages->push($itr->Current());

	$new_doc = new PDFDoc();
	$imported_pages = $new_doc->ImportPages($import_pages);

	// Paper dimension for A3 format in points. Because one inch has 
	// 72 points, 11.69 inch 72 = 841.69 points
	$media_box = new Rect(0.0, 0.0, 1190.88, 841.69); 
	$mid_point = $media_box->Width()/2;

	$builder = new ElementBuilder();
	$writer = new ElementWriter();

	for ($i=0; $i<$imported_pages->size(); ++$i)
	{
		// Create a blank new A3 page and place on it two pages from the input document.
		$new_page = $new_doc->PageCreate($media_box);
		$writer->Begin($new_page);

		// Place the first page
		$src_page = $imported_pages->get($i);
		$element = $builder->CreateForm($src_page);

		$sc_x = $mid_point / $src_page->GetPageWidth();
		$sc_y = $media_box->Height() / $src_page->GetPageHeight();
		$scale = $sc_x < $sc_y ? $sc_x : $sc_y; // min(sc_x, sc_y)
		$element->GetGState()->SetTransform($scale, 0.0, 0.0, $scale, 0.0, 0.0);
		$writer->WritePlacedElement($element);
			
		// Place the second page
		++$i; 
		if ($i<$imported_pages->size())	{
			$src_page = $imported_pages->get($i);
			$element = $builder->CreateForm($src_page);
			$sc_x = $mid_point / $src_page->GetPageWidth();
			$sc_y = $media_box->Height() / $src_page->GetPageHeight();
			$scale = $sc_x < $sc_y ? $sc_x : $sc_y; // min(sc_x, sc_y)
			$element->GetGState()->SetTransform($scale, 0.0, 0.0, $scale, $mid_point, 0.0);
			$writer->WritePlacedElement($element);
		}

		$writer->End();
		$new_doc->PagePushBack($new_page);
	}		

	$new_doc->Save($output_path, SDFDoc::e_linearized);
	echo nl2br("Done. Result saved in newsletter_booklet.pdf...");	
?>
