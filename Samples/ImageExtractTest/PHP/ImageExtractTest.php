<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//-----------------------------------------------------------------------------------
// This sample illustrates one approach to PDF image extraction 
// using PDFNet.
// 
// Note: Besides direct image export, you can also convert PDF images 
// to GDI+ Bitmap, or extract uncompressed/compressed image data directly 
// using element.GetImageData() (e.g. as illustrated in ElementReaderAdv 
// sample project).
//-----------------------------------------------------------------------------------

$image_counter = 0;

function ImageExtract($reader) 
{
	while (($element = $reader->Next()) != null)
	{
		switch ($element->GetType()) 
		{
		case Element::e_image: 
		case Element::e_inline_image: 
			{
				global $image_counter;
				echo nl2br("\n--> Image: ".++$image_counter);
				echo nl2br("\n    Width: ".$element->GetImageWidth());
				echo nl2br("\n    Height: ".$element->GetImageHeight());
				echo nl2br("\n    BPC: ".$element->GetBitsPerComponent());

				$ctm = $element->GetCTM();
				$x2=1.0;
				$y2=1.0;
				$point = $ctm->Mult(new Point($x2, $y2));
				echo nl2br("\n    Coords: x1=".$ctm->m_h.", y1=".$ctm->m_v.", x2=".$point->x.", y2=".$point->y);

				if ($element->GetType() == Element::e_image) 
				{
					$image = new Image($element->GetXObject());

					$fname = "image_extract1_".$image_counter;
					global $output_path;
					$path = $output_path.$fname;
					$image->Export($path);

					//$path = $output_path.$fname.".tif";
					//$image->ExportAsTiff($path);

					//$path = $output_path $fname.".png";
					//$image->ExportAsPng($path);
				}
			}
			break;
		case Element::e_form:		// Process form XObjects
			$reader->FormBegin(); 
            		ImageExtract($reader);
			$reader->End(); 
			break; 
		}
	}
}

	// Initialize PDFNet
	PDFNet::Initialize();

	// Example 1: 
	// Extract images by traversing the display list for 
	// every page. With this approach it is possible to obtain 
	// image positioning information and DPI.
	$doc = new PDFDoc($input_path."newsletter.pdf");
	$doc->InitSecurityHandler();

	$reader = new ElementReader();
	//  Read every page
	for ($itr=$doc->GetPageIterator(); $itr->HasNext(); $itr->Next()) 
	{				
		$reader->Begin($itr->Current());
		ImageExtract($reader);
		$reader->End();
	}

	$doc->Close();
	echo nl2br("Done...\n");

	echo nl2br("----------------------------------------------------------------\n");

	// Example 2: 
	// Extract images by scanning the low-level document.
	$doc = new PDFDoc($input_path."newsletter.pdf");

	$doc->InitSecurityHandler();
	$image_counter = 0;

	$cos_doc=$doc->GetSDFDoc();
	$num_objs = $cos_doc->XRefSize();
	for($i=1; $i<$num_objs; ++$i) 
	{
		$obj = $cos_doc->GetObj($i);
		if($obj != null && !$obj->IsFree() && $obj->IsStream()) 
		{
			// Process only images
			$itr = $obj->Find("Type");
			if(!$itr->HasNext() || !($itr->Value()->GetName() == "XObject"))
			{
				continue;
			}

			$itr = $obj->Find("Subtype");
			if(!$itr->HasNext() || !($itr->Value()->GetName() == "Image"))
			{
				continue;
			}
				
			$image = new Image($obj);
			echo nl2br("\n-. Image: ".++$image_counter);
			echo nl2br("\n    Width: ".$image->GetImageWidth());
			echo nl2br("\n    Height: ".$image->GetImageHeight());
			echo nl2br("\n    BPC: ".$image->GetBitsPerComponent());

			$fname = "image_extract2_".$image_counter;
			$path = $output_path.$fname;
			$image->Export($path);

			//$path = $output_path.$fname.".tif");
			//$image->ExportAsTiff($path);

			//$path = $output_path.fname.".png");
			//$image->ExportAsPng($path);
		}
	}

	$doc->Close();
	
	
?>
