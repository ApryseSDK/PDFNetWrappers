<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Sample 1 - Split a PDF document into multiple pages
	
	echo nl2br("_______________________________________________\n");
	echo nl2br("Sample 1 - Split a PDF document into multiple pages...\n");
	echo nl2br("Opening the input pdf...\n");
	$in_doc = new PDFDoc($input_path."newsletter.pdf");
	$in_doc->InitSecurityHandler();

	$page_num = $in_doc->GetPageCount();
	for ($i = 1; $i <= $page_num; ++$i)
	{	
		$new_doc = new PDFDoc();
		$new_doc->InsertPages(0, $in_doc, $i, $i, PDFDoc::e_none);
		$new_doc->Save($output_path."newsletter_split_page_".$i.".pdf", SDFDoc::e_remove_unused);
		echo nl2br("Done. Result saved in newsletter_split_page_".$i.".pdf\n");
		$new_doc->Close();
	}
	$in_doc->Close();

	// Sample 2 - Merge several PDF documents into one
	
	echo nl2br("_______________________________________________\n");
	echo nl2br("Sample 2 - Merge several PDF documents into one...\n");
	$new_doc = new PDFDoc();
	$new_doc->InitSecurityHandler();

	$page_num = 15;
	for ($i = 1; $i <= $page_num; ++$i)
	{	
		echo nl2br("Opening newsletter_split_page_".$i.".pdf\n");
		$in_doc = new PDFDoc($output_path."newsletter_split_page_".$i.".pdf");
		$new_doc->InsertPages($i, $in_doc, 1, $in_doc->GetPageCount(), PDFDoc::e_none);
		$in_doc->Close();
	}
	$new_doc->Save($output_path."newsletter_merge_pages.pdf", SDFDoc::e_remove_unused);
	echo nl2br("Done. Result saved in newsletter_merge_pages.pdf\n");
	$in_doc->Close();

	// Sample 3 - Delete every second page
	
	echo nl2br("_______________________________________________\n");
	echo nl2br("Sample 3 - Delete every second page...\n");
	echo nl2br("Opening the input pdf...\n");
	$in_doc = new PDFDoc($input_path."newsletter.pdf");
	$in_doc->InitSecurityHandler();
		
	$page_num = $in_doc->GetPageCount();
	while ($page_num>=1)
	{
		$itr = $in_doc->GetPageIterator($page_num);
		$in_doc->PageRemove($itr);
		$page_num -= 2;
	}		
		
	$in_doc->Save($output_path."newsletter_page_remove.pdf", 0);
	echo nl2br("Done. Result saved in newsletter_page_remove.pdf...\n");

	//Close the open document to free up document memory sooner than waiting for the
	//garbage collector
	$in_doc->Close();

	// Sample 4 - Inserts a page from one document at different 
	// locations within another document
		 
	echo nl2br("_______________________________________________\n");
	echo nl2br("Sample 4 - Insert a page at different locations...\n");
	echo nl2br("Opening the input pdf...\n");
		
	$in1_doc = new PDFDoc($input_path."newsletter.pdf");
	$in1_doc->InitSecurityHandler();

	$in2_doc = new PDFDoc($input_path."fish.pdf");
	$in2_doc->InitSecurityHandler(); 
		
	$src_page = $in2_doc->GetPageIterator();
    $dst_page = $in1_doc->GetPageIterator();
	$page_num = 1;
    while ($dst_page->HasNext()) {
        if ($page_num++ % 3 == 0) {
            $in1_doc->PageInsert($dst_page, $src_page->Current());
        }
        $dst_page->Next();
    }
	
	$in1_doc->Save($output_path."newsletter_page_insert.pdf", 0);
	echo nl2br("Done. Result saved in newsletter_page_insert.pdf...\n");

	//Close the open document to free up document memory sooner than waiting for the
	//garbage collector
	$in1_doc->Close();
	$in2_doc->Close();

	// Sample 5 - Replicate pages within a single document
	
	echo nl2br("_______________________________________________\n");
	echo nl2br("Sample 5 - Replicate pages within a single document...\n");
	echo nl2br("Opening the input pdf...\n");
	$doc = new PDFDoc($input_path."newsletter.pdf");
	$doc->InitSecurityHandler();
		
	// Replicate the cover page three times (copy page #1 and place it before the 
	// seventh page in the document page sequence)
	$cover = $doc->GetPage(1);
	$p7 = $doc->GetPageIterator(7);
	$doc->PageInsert($p7, $cover);
	$doc->PageInsert($p7, $cover);
	$doc->PageInsert($p7, $cover);
		
	// Replicate the cover page two more times by placing it before and after
	// existing pages.
	$doc->PagePushFront($cover);
	$doc->PagePushBack($cover);
		
	$doc->Save($output_path."newsletter_page_clone.pdf", 0);
	echo nl2br("Done. Result saved in newsletter_page_clone.pdf...\n");
	$doc->Close();

	// Sample 6 - Use ImportPages() in order to copy multiple pages at once 
	// in order to preserve shared resources between pages (e.g. images, fonts, 
	// colorspaces, etc.)
	
	echo nl2br("_______________________________________________\n");
	echo nl2br("Sample 6 - Preserving shared resources using ImportPages...\n");
	echo nl2br("Opening the input pdf...\n");
	$in_doc = new PDFDoc($input_path."newsletter.pdf");
	$in_doc->InitSecurityHandler();

	$new_doc = new PDFDoc();
	
	$copy_pages = new VectorPage(); 
	for ($itr=$in_doc->GetPageIterator(); $itr->HasNext(); $itr->Next())
	{
		$copy_pages->push($itr->Current());
	}
		
	$imported_pages = $new_doc->ImportPages($copy_pages);
	for ($i=0; $i<$imported_pages->size(); ++$i)
	{
		$new_doc->PagePushFront($imported_pages->get($i)); // Order pages in reverse order. 
		// Use PagePushBack() if you would like to preserve the same order.
	}		
		
	$new_doc->Save($output_path."newsletter_import_pages.pdf", 0);
	echo nl2br("Done. Result saved in newsletter_import_pages.pdf...\n\n"
		."Note that the output file size is less than half the size\n" 
		."of the file produced using individual page copy operations\n" 
		."between two documents\n");
?>
