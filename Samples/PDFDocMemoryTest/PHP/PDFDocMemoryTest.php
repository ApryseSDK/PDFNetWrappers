<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

	// The following sample illustrates how to read/write a PDF document from/to 
	// a memory buffer.  This is useful for applications that work with dynamic PDF
	// documents that don't need to be saved/read from a disk.
	
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	
	// Read a PDF document in a memory buffer.
	$file = new MappedFile($input_path."tiger.pdf");
	$file_sz = $file->FileSize();
        
	$file_reader = new FilterReader($file);
	$mem = $file_reader->Read($file_sz);
	$test = array();
	for ($i = 0; $i < strlen($mem); $i++) {
		$test[] = ord($mem[$i]);
	}
	$doc = new PDFDoc($mem, $file_sz);
	$doc->InitSecurityHandler();
	$num_pages = $doc->GetPageCount();

	$writer = new ElementWriter();
	$reader = new ElementReader();

	// Create a duplicate of every page but copy only path objects
	for($i=1; $i<=$num_pages; ++$i)
	{
		$itr = $doc->GetPageIterator(2*$i-1);

		$reader->Begin($itr->Current());
		$new_page = $doc->PageCreate($itr->Current()->GetMediaBox());
		$next_page = $itr;
		$next_page->Next(); 
		$doc->PageInsert($next_page, $new_page);

		$writer->Begin($new_page);
		while (($element = $reader->Next()) !=null) 	// Read page contents
		{
			//if ($element->GetType() == Element::e_path)
            $writer->WriteElement($element);
		}

		$writer->End();
		$reader->End();
	}

	$doc->Save($output_path."doc_memory_edit.pdf", SDFDoc::e_remove_unused);

	// Save the document to a memory buffer.
	$buffer = $doc->Save(SDFDoc::e_remove_unused);

	// Write the contents of the buffer to the disk
    $outfile = fopen($output_path."doc_memory_edit.txt", "w");
    fwrite($outfile, $buffer);
    fclose($outfile);;

	// Read some data from the file stored in memory
	$reader->Begin($doc->GetPage(1));
	while (($element = $reader->Next()) !=null) {
		if ($element->GetType() == Element::e_path) echo "Path, ";
	}
	$reader->End();

	echo nl2br("\n\nDone. Result saved in doc_memory_edit.pdf and doc_memory_edit.txt ...\n");
?>
