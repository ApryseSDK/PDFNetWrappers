<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

// This sample project illustrates how to recompress bi-tonal images in an 
// existing PDF document using JBIG2 compression. The sample is not intended 
// to be a generic PDF optimization tool.
//
// You can download the entire document using the following link:
//   http://www.pdftron.com/net/samplecode/data/US061222892.pdf

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$pdf_doc = new PDFDoc("../../TestFiles/US061222892-a.pdf") ;
	$pdf_doc->InitSecurityHandler();

	$cos_doc = $pdf_doc->GetSDFDoc();
	$num_objs = $cos_doc->XRefSize();
	for($i = 1; $i < $num_objs; ++$i) 
	{
		$obj = $cos_doc->GetObj($i);
		if($obj && !$obj->IsFree() && $obj->IsStream()) 
		{
			// Process only images
			$itr = $obj->Find("Subtype");
			if(!$itr->HasNext() || $itr->Value()->GetName() != "Image")
				continue;
			
			$input_image = new Image($obj);
			// Process only gray-scale images
			if($input_image->GetComponentNum() != 1)
				continue;
			$bpc = $input_image->GetBitsPerComponent();
			if($bpc != 1)	// Recompress only 1 BPC images
				continue;

			// Skip images that are already compressed using JBIG2
			$itr = $obj->Find("Filter");
			if ($itr->HasNext() && $itr->Value()->IsName() && 
				$itr->Value()->GetName() == "JBIG2Decode") continue; 

			$filter=$obj->GetDecodedStream();
			$reader = new FilterReader($filter);


			$hint_set = new ObjSet(); 	// A hint to image encoder to use JBIG2 compression
			$hint=$hint_set->CreateArray();
			
			$hint->PushBackName("JBIG2");
			$hint->PushBackName("Lossless");

			$new_image = Image::Create($cos_doc, $reader, 
				$input_image->GetImageWidth(), 
				$input_image->GetImageHeight(), 1, ColorSpace::CreateDeviceGray(), $hint);

			$new_img_obj = $new_image->GetSDFObj();
			$itr = $obj->Find("Decode");
			if($itr->HasNext())
				$new_img_obj->Put("Decode", $itr->Value());
			$itr = $obj->Find("ImageMask");
			if ($itr->HasNext())
				$new_img_obj->Put("ImageMask", $itr->Value());
			$itr = $obj->Find("Mask");
			if ($itr->HasNext())
				$new_img_obj->Put("Mask", $itr->Value());

			$cos_doc->Swap($i, $new_img_obj->GetObjNum());
		}
	}

	$pdf_doc->Save("../../TestFiles/Output/US061222892_JBIG2.pdf", SDFDoc::e_remove_unused);
	$pdf_doc->Close();

	echo "Done.";
?>
