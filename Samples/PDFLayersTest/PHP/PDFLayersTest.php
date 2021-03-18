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
// This sample demonstrates how to create layers in PDF.
// The sample also shows how to extract and render PDF layers in documents 
// that contain optional content groups (OCGs)
//
// With the introduction of PDF version 1.5 came the concept of Layers. 
// Layers, or as they are more formally known Optional Content Groups (OCGs),
// refer to sections of content in a PDF document that can be selectively 
// viewed or hidden by document authors or consumers. This capability is useful 
// in CAD drawings, layered artwork, maps, multi-language documents etc.
// 
// Notes: 
// ---------------------------------------
// - This sample is using CreateLayer() utility method to create new OCGs. 
//   CreateLayer() is relatively basic, however it can be extended to set 
//   other optional entries in the 'OCG' and 'OCProperties' dictionary. For 
//   a complete listing of possible entries in OC dictionary please refer to 
//   section 4.10 'Optional Content' in the PDF Reference Manual.
// - The sample is grouping all layer content into separate Form XObjects. 
//   Although using PDFNet is is also possible to specify Optional Content in 
//   Content Streams (Section 4.10.2 in PDF Reference), Optional Content in  
//   XObjects results in PDFs that are cleaner, less-error prone, and faster 
//   to process.
//-----------------------------------------------------------------------------------

// A utility function used to add new Content Groups (Layers) to the document.
function CreateLayer($doc, $layer_name)
{
	$grp = Group::Create($doc, $layer_name);
	$cfg = $doc->GetOCGConfig();
	if (!$cfg->IsValid()) {
		$cfg = Config::Create($doc, true);
		$cfg->SetName("Default");
	}

	// Add the new OCG to the list of layers that should appear in PDF viewer GUI.
	$layer_order_array = $cfg->GetOrder();
	if (!$layer_order_array) {
        	$layer_order_array = $doc->CreateIndirectArray();
		$cfg->SetOrder($layer_order_array);
	}
	$layer_order_array->PushBack($grp->GetSDFObj());

	return $grp;
}

// Creates some content (3 images) and associate them with the image layer
function CreateGroup1($doc, $layer) 
{
	$writer = new ElementWriter();
	$writer->Begin($doc->GetSDFDoc());
	global $input_path;
	// Create an Image that can be reused in the document or on the same page.		
	$img = Image::Create($doc->GetSDFDoc(), $input_path."peppers.jpg");

	$builder = new ElementBuilder();
	$element = $builder->CreateImage($img, new Matrix2D((double)$img->GetImageWidth()/2, -145.0, 20.0, 
							(double)$img->GetImageHeight()/2, 200.0, 150.0));
	$writer->WritePlacedElement($element);

	$gstate = $element->GetGState();	// use the same image (just change its matrix)
	$gstate->SetTransform(200.0, 0.0, 0.0, 300.0, 50.0, 450.0);
	$writer->WritePlacedElement($element);

	// use the same image again (just change its matrix).
	$writer->WritePlacedElement($builder->CreateImage($img, 300.0, 600.0, 200.0, -150.0));

	$grp_obj = $writer->End();	

	// Indicate that this form (content group) belongs to the given layer (OCG).
	$grp_obj->PutName("Subtype","Form");
	$grp_obj->Put("OC", $layer);	
	$grp_obj->PutRect("BBox", 0, 0, 1000, 1000);  // Set the clip box for the content.

	return $grp_obj;
}

// Creates some content (a path in the shape of a heart) and associate it with the vector layer
function CreateGroup2($doc, $layer) 
{
	$writer = new ElementWriter();
	$writer->Begin($doc->GetSDFDoc());

	// Create a path object in the shape of a heart.
	$builder = new ElementBuilder();
	$builder->PathBegin();		// start constructing the path
	$builder->MoveTo(306, 396);
	$builder->CurveTo(681, 771, 399.75, 864.75, 306, 771);
	$builder->CurveTo(212.25, 864.75, -69, 771, 306, 396);
	$builder->ClosePath();
	$element = $builder->PathEnd(); // the path geometry is now specified.

	// Set the path FILL color space and color.
	$element->SetPathFill(true);
	$gstate = $element->GetGState();
	$gstate->SetFillColorSpace(ColorSpace::CreateDeviceCMYK()); 
	$gstate->SetFillColor(new ColorPt(1.0, 0.0, 0.0, 0.0));  // cyan

	// Set the path STROKE color space and color.
	$element->SetPathStroke(true); 
	$gstate->SetStrokeColorSpace(ColorSpace::CreateDeviceRGB()); 
	$gstate->SetStrokeColor(new ColorPt(1.0, 0.0, 0.0));  // red
	$gstate->SetLineWidth(20);

	$gstate->SetTransform(0.5, 0.0, 0.0, 0.5, 280.0, 300.0);

	$writer->WriteElement($element);

	$grp_obj = $writer->End();	

	// Indicate that this form (content group) belongs to the given layer (OCG).
	$grp_obj->PutName("Subtype","Form");
	$grp_obj->Put("OC", $layer);
	$grp_obj->PutRect("BBox", 0, 0, 1000, 1000); 	// Set the clip box for the content.

	return $grp_obj;
}

// Creates some text and associate it with the text layer
function CreateGroup3($doc, $layer) 
{
	$writer = new ElementWriter();
	$writer->Begin($doc->GetSDFDoc());

	// Create a path object in the shape of a heart.
	$builder = new ElementBuilder();

	// Begin writing a block of text
	$element = $builder->CreateTextBegin(Font::Create($doc->GetSDFDoc(), Font::e_times_roman), 120.0);
	$writer->WriteElement($element);

	$element = $builder->CreateTextRun("A text layer!");

	// Rotate text 45 degrees, than translate 180 pts horizontally and 100 pts vertically.
	$transform = Matrix2D::RotationMatrix(-45 *  (3.1415/ 180.0));
	$transform->Concat(1, 0, 0, 1, 180, 100);  
	$element->SetTextMatrix($transform);

	$writer->WriteElement($element);
	$writer->WriteElement($builder->CreateTextEnd());

	$grp_obj = $writer->End();	

	// Indicate that this form (content group) belongs to the given layer (OCG).
	$grp_obj->PutName("Subtype","Form");
	$grp_obj->Put("OC", $layer);
	$grp_obj->PutRect("BBox", 0, 0, 1000, 1000); 	// Set the clip box for the content.

	return $grp_obj;
}

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$doc = new PDFDoc();

	// Create three layers...
	$image_layer = CreateLayer($doc, "Image Layer");
	$text_layer = CreateLayer($doc, "Text Layer");
	$vector_layer = CreateLayer($doc, "Vector Layer");

	// Start a new page ------------------------------------
	$page = $doc->PageCreate();

	$builder = new ElementBuilder();	// ElementBuilder is used to build new Element objects
	$writer = new ElementWriter;	// ElementWriter is used to write Elements to the page	
	$writer->Begin($page);		// Begin writing to the page

	// Add new content to the page and associate it with one of the layers.
	$element = $builder->CreateForm(CreateGroup1($doc, $image_layer->GetSDFObj()));
	$writer->WriteElement($element);

	$element = $builder->CreateForm(CreateGroup2($doc, $vector_layer->GetSDFObj()));
	$writer->WriteElement($element);

	// Add the text layer to the page...
	if (false)  // set to true to enable 'ocmd' example.
	{
		// A bit more advanced example of how to create an OCMD text layer that 
		// is visible only if text, image and path layers are all 'ON'.
		// An example of how to set 'Visibility Policy' in OCMD.
		$ocgs = $doc->CreateIndirectArray();
		$ocgs->PushBack($image_layer->GetSDFObj());
		$ocgs->PushBack($vector_layer->GetSDFObj());
		$ocgs->PushBack($text_layer->GetSDFObj());
		$text_ocmd = OCMD::Create($doc, $ocgs, OCMD::e_AllOn);
		$element = $builde->CreateForm(CreateGroup3($doc, $text_ocmd->GetSDFObj()));
	}
	else {
		$element = $builder->CreateForm(CreateGroup3($doc, $text_layer->GetSDFObj()));
	}

	$writer->WriteElement($element);

	// Add some content to the page that does not belong to any layer...
	// In this case this is a rectangle representing the page border.
	$element = $builder->CreateRect(0, 0, $page->GetPageWidth(), $page->GetPageHeight());
	$element->SetPathFill(false);
	$element->SetPathStroke(true);
	$element->GetGState()->SetLineWidth(40);
	$writer->WriteElement($element);

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Set the default viewing preference to display 'Layer' tab.
	$prefs = $doc->GetViewPrefs();
	$prefs->SetPageMode(PDFDocViewPrefs::e_UseOC);

	$doc->Save($output_path."pdf_layers.pdf", SDFDoc::e_linearized);
	echo nl2br("Done.\n");

	// The following is a code snippet shows how to selectively render 
	// and export PDF layers.
	
	$doc = new PDFDoc($output_path."pdf_layers.pdf");
	$doc->InitSecurityHandler();

	if (!$doc->HasOC()) {
		echo nl2br("The document does not contain 'Optional Content'\n");
	}
	else {
		$init_cfg = $doc->GetOCGConfig();
		$ctx = new Context($init_cfg);

		$pdfdraw = new PDFDraw();
		$pdfdraw->SetImageSize(1000, 1000);
		$pdfdraw->SetOCGContext($ctx); // Render the page using the given OCG context.

		$page = $doc->GetPage(1); // Get the first page in the document.
		$pdfdraw->Export($page, $output_path."pdf_layers_default.png");

		// Disable drawing of content that is not optional (i.e. is not part of any layer).
		$ctx->SetNonOCDrawing(false);

		// Now render each layer in the input document to a separate image.
		$ocgs = $doc->GetOCGs(); // Get the array of all OCGs in the document.
		if ($ocgs != null) {
			$sz = $ocgs->Size();
			for ($i=0; $i<$sz; ++$i) {
				$ocg = new Group($ocgs->GetAt($i));
				$ctx->ResetStates(false);
				$ctx->SetState($ocg, true);
				$fname = "pdf_layers_".$ocg->GetName().".png";
				echo nl2br($fname."\n");
				$pdfdraw->Export($page, $output_path.$fname);
			}
		}

		// Now draw content that is not part of any layer...
		$ctx->SetNonOCDrawing(true);
		$ctx->SetOCDrawMode(Context::e_NoOC);
		$pdfdraw->Export($page, $output_path."pdf_layers_non_oc.png");
	}

	$doc->Close();
	echo nl2br("Done.\n");	
?>
