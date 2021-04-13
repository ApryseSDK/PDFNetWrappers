<?php
#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

#---------------------------------------------------------------------------------------
# The sample code shows how to edit the page display list and how to modify graphics state 
# attributes on existing Elements. In particular the sample program strips all images from 
# the page and changes text color to blue. 
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";
$input_filename = "newsletter.pdf";
$output_filename = "newsletter_edited.pdf";

function ProcessElements($reader, $writer, $map) {
	while (($element = $reader->Next()) != null) 	// Read page contents
	{
		switch ($element->GetType())
		{		
		case Element::e_image: 
		case Element::e_inline_image: 
			// remove all images by skipping them
			break;
		case Element::e_path:
			{
				// Set all paths to red color.
				$gs = $element->GetGState();
				$gs->SetFillColorSpace(ColorSpace::CreateDeviceRGB());
				$gs->SetFillColor(new ColorPt(1.0, 0.0, 0.0));
				$writer->WriteElement($element);
				break;
			}
		case Element::e_text:// Process text strings...
			{
				// Set all text to blue color.
				$gs = $element->GetGState();
				$gs->SetFillColorSpace(ColorSpace::CreateDeviceRGB());
				$cp = new ColorPt(0.0, 0.0, 1.0);
				$gs->SetFillColor($cp);
				$writer->WriteElement($element);
				break;
			}
		case Element::e_form:// Recursively process form XObjects
			{
				$o = $element->GetXObject();
				$objNum = $o->GetObjNum();
				$map[$objNum] = $o;
				$writer->WriteElement($element);
				break; 
			}
		default:
			$writer->WriteElement($element);
		}
	}
}

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	

	// Open the test file
	echo nl2br("Opening the input file...\n");
	$doc = new PDFDoc($input_path.$input_filename);
	$doc->InitSecurityHandler();

	$writer = new ElementWriter();
	$reader = new ElementReader();
	
	$itr = $doc->GetPageIterator();

	while ($itr->HasNext())
	{
		$page = $itr->Current();
		$reader->Begin($page);
		$writer->Begin($page, ElementWriter::e_replacement, false);
		$map1 = array();
		ProcessElements($reader, $writer, $map1);
		$writer->End();
		$reader->End();
		
		$map2 = array();
		while (!(empty($map1) && empty($map2)))
		{
			foreach ($map1 as $k=>$v)
			{
				$obj = $v;
				$writer->Begin($obj);
				$reader->Begin($obj, $page->GetResourceDict());
				ProcessElements($reader, $writer, $map2);
				$reader->End();
				$writer->End();

				unset($map1[$k]);
			}
			if (empty($map1) && !empty($map2))
			{
				$map1 = $map1 + $map2;
				$map2 = array();
			}
		}
		$itr->Next();
	}

	$doc->Save($output_path.$output_filename, SDFDoc::e_remove_unused);		
	echo nl2br("Done. Result saved in ".$output_filename."...\n");
?>
