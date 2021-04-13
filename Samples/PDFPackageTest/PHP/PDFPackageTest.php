<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//-----------------------------------------------------------------------------------
/// This sample illustrates how to create, extract, and manipulate PDF Portfolios
/// (a.k.a. PDF Packages) using PDFNet SDK.
//-----------------------------------------------------------------------------------

function AddPackage($doc, $file, $desc) 
{
	$files = NameTree::Create($doc->GetSDFDoc(), "EmbeddedFiles");
	$fs = FileSpec::Create($doc->GetSDFDoc(), $file, true);
	$files->Put($file, strlen($file), $fs->GetSDFObj());
	$fs->SetDesc($desc);

	$collection = $doc->GetRoot()->FindObj("Collection");
	if (!$collection) $collection = $doc->GetRoot()->PutDict("Collection");

	// You could here manipulate any entry in the Collection dictionary. 
	// For example, the following line sets the tile mode for initial view mode
	// Please refer to section '2.3.5 Collections' in PDF Reference for details.
	$collection->PutName("View", "T");
}

function AddCoverPage($doc) 
{
	// Here we dynamically generate cover page (please see ElementBuilder 
	// sample for more extensive coverage of PDF creation API).
	$page = $doc->PageCreate(new Rect(0.0, 0.0, 200.0, 200.0));

	$builder = new ElementBuilder();
	$writer = new ElementWriter();
	$writer->Begin($page);
	$font = Font::Create($doc->GetSDFDoc(), Font::e_helvetica);
	$writer->WriteElement($builder->CreateTextBegin($font, 12.0));
	$element = $builder->CreateTextRun("My PDF Collection");
	$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 50.0, 96.0);
	$element->GetGState()->SetFillColorSpace(ColorSpace::CreateDeviceRGB());
	$element->GetGState()->SetFillColor(new ColorPt(1.0, 0.0, 0.0));
	$writer->WriteElement($element);
	$writer->WriteElement($builder->CreateTextEnd());
	$writer->End();
	$doc->PagePushBack($page);

	// Alternatively we could import a PDF page from a template PDF document
	// (for an example please see PDFPage sample project).
	// ...
}

//---------------------------------------------------------------------------------------

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Create a PDF Package.
	
	$doc = new PDFDoc();
	AddPackage($doc, $input_path."numbered.pdf", "My File 1");
	AddPackage($doc, $input_path."newsletter.pdf", "My Newsletter...");
	AddPackage($doc, $input_path."peppers.jpg", "An image");
	AddCoverPage($doc);
	$doc->Save($output_path."package.pdf", SDFDoc::e_linearized);
	$doc->Close();
	echo nl2br("Done.\n");

	// Extract parts from a PDF Package.
	
	$doc = new PDFDoc($output_path."package.pdf");
	$doc->InitSecurityHandler();

	$files = NameTree::Find($doc->GetSDFDoc(), "EmbeddedFiles");
	if($files->IsValid()) 
	{ 
		// Traverse the list of embedded files.
		$i = $files->GetIterator();
		for ($counter = 0; $i->HasNext(); $i->Next(), ++$counter) 
		{
			$entry_name = $i->Key()->GetAsPDFText();
			echo nl2br("Part: ".$entry_name."\n");
			$file_spec = new FileSpec($i->Value());
			$stm = new Filter($file_spec->GetFileData());
			if ($stm) 
			{
				$stm->WriteToFile($output_path."extract_".$counter.".".pathinfo($entry_name, PATHINFO_EXTENSION), false);
			}
		}
	}

	$doc->Close();
	echo nl2br("Done.\n");	
?>
