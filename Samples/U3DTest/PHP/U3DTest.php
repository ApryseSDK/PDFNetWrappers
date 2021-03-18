<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

function Create3DAnnotation($doc, $annots)
{
	// ---------------------------------------------------------------------------------
	// Create a 3D annotation based on U3D content. PDF 1.6 introduces the capability 
	// for collections of three-dimensional objects, such as those used by CAD software, 
	// to be embedded in PDF files.
	$link_3D = $doc->CreateIndirectDict();
	$link_3D->PutName("Subtype", "3D");

	// Annotation location on the page
	$link_3D_rect = new Rect(25.0, 180.0, 585.0, 643.0);
	$link_3D->PutRect("Rect", $link_3D_rect->x1, $link_3D_rect->y1,
		$link_3D_rect->x2, $link_3D_rect->y2);
	$annots->PushBack($link_3D);

	// The 3DA entry is an activation dictionary (see Table 9.34 in the PDF Reference Manual) 
	// that determines how the state of the annotation and its associated artwork can change.
	$activation_dict_3D = $link_3D->PutDict("3DA");

	// Set the annotation so that it is activated as soon as the page containing the 
	// annotation is opened. Other options are: PV (page view) and XA (explicit) activation.
	$activation_dict_3D->PutName("A", "PO");  

	// Embed U3D Streams (3D Model/Artwork).
	global $input_path;
	$u3d_file = new MappedFile($input_path."dice.u3d");
	$u3d_reader = new FilterReader($u3d_file);

	// To embed 3D stream without compression, you can omit the second parameter in CreateIndirectStream.
	$u3d_data_dict = $doc->CreateIndirectStream($u3d_reader, new FlateEncode(new Filter()));
	$u3d_data_dict->PutName("Subtype", "U3D");
	$link_3D->Put("3DD", $u3d_data_dict);

	// Set the initial view of the 3D artwork that should be used when the annotation is activated.
	$view3D_dict = $link_3D->PutDict("3DV");
	
	$view3D_dict->PutString("IN", "Unnamed");
	$view3D_dict->PutString("XN", "Default");
	$view3D_dict->PutName("MS", "M");
	$view3D_dict->PutNumber("CO", 27.5);

	// A 12-element 3D transformation matrix that specifies a position and orientation 
	// of the camera in world coordinates.
	$tr3d =	$view3D_dict->PutArray("C2W"); 
	$tr3d->PushBackNumber(1); $tr3d->PushBackNumber(0); $tr3d->PushBackNumber(0); 
	$tr3d->PushBackNumber(0); $tr3d->PushBackNumber(0); $tr3d->PushBackNumber(-1);
	$tr3d->PushBackNumber(0); $tr3d->PushBackNumber(1); $tr3d->PushBackNumber(0); 
	$tr3d->PushBackNumber(0); $tr3d->PushBackNumber(-27.5); $tr3d->PushBackNumber(0);

	// Create annotation appearance stream, a thumbnail which is used during printing or
	// in PDF processors that do not understand 3D data.
	$ap_dict = $link_3D->PutDict("AP");
	
	$builder = new ElementBuilder();
	$writer = new ElementWriter();
	$writer->Begin($doc->GetSDFDoc());

	$thumb_pathname = $input_path."dice.jpg";
	$image = Image::Create($doc->GetSDFDoc(), $thumb_pathname);
	$writer->WritePlacedElement($builder->CreateImage($image, 0.0, 0.0, $link_3D_rect->Width(), $link_3D_rect->Height()));

	$normal_ap_stream = $writer->End();
	$normal_ap_stream->PutName("Subtype", "Form");
	$normal_ap_stream->PutRect("BBox", 0, 0, $link_3D_rect->Width(), $link_3D_rect->Height());
	$ap_dict->Put("N", $normal_ap_stream);
}

// ---------------------------------------------------------------------------------

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.	

	$doc = new PDFDoc();
	$page = $doc->PageCreate();
	$doc->PagePushBack($page);
	$annots = $doc->CreateIndirectArray();
	$page->GetSDFObj()->Put("Annots", $annots);

	Create3DAnnotation($doc, $annots);
	$doc->Save($output_path."dice_u3d.pdf", SDFDoc::e_linearized);
	echo "Done.\n";	
?>
