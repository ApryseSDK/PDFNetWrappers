<?php
#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

# This sample illustrates how to edit existing text strings.

# Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	$doc = new PDFDoc();
	$builder = new ElementBuilder();	// ElementBuilder is used to build new Element objects
	$writer = new ElementWriter();		// ElementWriter is used to write Elements to the page

	// Start a new page ------------------------------------
	$page = $doc->PageCreate(new Rect(0.0, 0.0, 612.0, 794.0));

	$writer->Begin($page);	// begin writing to the page
	
	// Create an Image that can be reused in the document or on the same page.		
	$img = Image::Create($doc->GetSDFDoc(), $input_path."peppers.jpg");

	$element = $builder->CreateImage($img, new Matrix2D((double)($img->GetImageWidth()/2), -145.0, 20.0, (double)($img->GetImageHeight()/2), 200.0, 150.0));
	$writer->WritePlacedElement($element);
	$gstate = $element->GetGState();	// use the same image (just change its matrix)
	$gstate->SetTransform(200.0, 0.0, 0.0, 300.0, 50.0, 450.0);
	$writer->WritePlacedElement($element);

	// use the same image again (just change its matrix).
	$writer->WritePlacedElement($builder->CreateImage($img, 300.0, 600.0, 200.0, -150.0));

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Start a new page ------------------------------------
	// Construct and draw a path object using different styles
	$page = $doc->PageCreate(new Rect(0.0, 0.0, 612.0, 794.0));

	$writer->Begin($page);	// begin writing to this page
	$builder->Reset();	// Reset the GState to default

	$builder->PathBegin();	// start constructing the path
	$builder->MoveTo(306, 396);
	$builder->CurveTo(681, 771, 399.75, 864.75, 306, 771);
	$builder->CurveTo(212.25, 864.75, -69, 771, 306, 396);
	$builder->ClosePath();
	$element = $builder->PathEnd();		// the path is now finished
	$element->SetPathFill(true);		// the path should be filled

	// Set the path color space and color
	$gstate = $element->GetGState();
	$gstate->SetFillColorSpace(ColorSpace::CreateDeviceCMYK());
	$gstate->SetFillColor(new ColorPt(1.0, 0.0, 0.0, 0.0));  // cyan
	$gstate->SetTransform(0.5, 0.0, 0.0, 0.5, -20.0, 300.0);
	$writer->WritePlacedElement($element);

	// Draw the same path using a different stroke color
	$element->SetPathStroke(true);		// this path is should be filled and stroked
	$gstate->SetFillColor(new ColorPt(0.0, 0.0, 1.0, 0.0));  // yellow
	$gstate->SetStrokeColorSpace(ColorSpace::CreateDeviceRGB()); 
	$gstate->SetStrokeColor(new ColorPt(1.0, 0.0, 0.0));  // red
	$gstate->SetTransform(0.5, 0.0, 0.0, 0.5, 280.0, 300.0);
	$gstate->SetLineWidth(20.0);
	$writer->WritePlacedElement($element);

	// Draw the same path with with a given dash pattern
	$element->SetPathFill(false);	// this path is should be only stroked

	$gstate->SetStrokeColor(new ColorPt(0.0, 0.0, 1.0));  // blue
	$gstate->SetTransform(0.5, 0.0, 0.0, 0.5, 280.0, 0.0);
	$gstate->SetDashPattern(array(30.0), 0);
	$writer->WritePlacedElement($element);

	// Use the path as a clipping path
	$writer->WriteElement($builder->CreateGroupBegin());	// Save the graphics state
	// Start constructing the new path (the old path was lost when we created 
	// a new Element using CreateGroupBegin()).
	$builder->PathBegin();		
	$builder->MoveTo(306, 396);
	$builder->CurveTo(681, 771, 399.75, 864.75, 306, 771);
	$builder->CurveTo(212.25, 864.75, -69, 771, 306, 396);
	$builder->ClosePath();
	$element = $builder->PathEnd();	// path is now constructed
	$element->SetPathClip(true);	// this path is a clipping path
	$element->SetPathStroke(true);		// this path should be filled and stroked
	$gstate = $element->GetGState();
	$gstate->SetTransform(0.5, 0.0, 0.0, 0.5, -20.0, 0.0);

	$writer->WriteElement($element);

	$writer->WriteElement($builder->CreateImage($img, 100.0, 300.0, 400.0, 600.0));
		
	$writer->WriteElement($builder->CreateGroupEnd());	// Restore the graphics state

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Start a new page ------------------------------------
	$page = $doc->PageCreate(new Rect(0.0, 0.0, 612.0, 794.0));

	$writer->Begin($page);	// begin writing to this page
	$builder->Reset();		// Reset the GState to default

	// Begin writing a block of text
	$element = $builder->CreateTextBegin(Font::Create($doc->GetSDFDoc(), Font::e_times_roman), 12.0);
	$writer->WriteElement($element);

	$element = $builder->CreateTextRun("Hello World!");
	$element->SetTextMatrix(10.0, 0.0, 0.0, 10.0, 0.0, 600.0);
	$element->GetGState()->SetLeading(15);		 // Set the spacing between lines
	$writer->WriteElement($element);

	$writer->WriteElement($builder->CreateTextNewLine());  // New line

	$element = $builder->CreateTextRun("Hello World!");
	$gstate = $element->GetGState(); 
	$gstate->SetTextRenderMode(GState::e_stroke_text);
	$gstate->SetCharSpacing(-1.25);
	$gstate->SetWordSpacing(-1.25);
	$writer->WriteElement($element);

	$writer->WriteElement($builder->CreateTextNewLine());  // New line

	$element = $builder->CreateTextRun("Hello World!");
	$gstate = $element->GetGState(); 
	$gstate->SetCharSpacing(0);
	$gstate->SetWordSpacing(0);
	$gstate->SetLineWidth(3);
	$gstate->SetTextRenderMode(GState::e_fill_stroke_text);
	$gstate->SetStrokeColorSpace(ColorSpace::CreateDeviceRGB()); 
	$gstate->SetStrokeColor(new ColorPt(1.0, 0.0, 0.0));	// red
	$gstate->SetFillColorSpace(ColorSpace::CreateDeviceCMYK()); 
	$gstate->SetFillColor(new ColorPt(1.0, 0.0, 0.0, 0.0));	// cyan
	$writer->WriteElement($element);

	$writer->WriteElement($builder->CreateTextNewLine());  // New line

	// Set text as a clipping path to the image.
	$element = $builder->CreateTextRun("Hello World!");
	$gstate = $element->GetGState(); 
	$gstate->SetTextRenderMode(GState::e_clip_text);
	$writer->WriteElement($element);

	// Finish the block of text
	$writer->WriteElement($builder->CreateTextEnd());		

	// Draw an image that will be clipped by the above text
	$writer->WriteElement($builder->CreateImage($img, 10.0, 100.0, 1300.0, 720.0));

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Start a new page ------------------------------------
	//
	// The example illustrates how to embed the external font in a PDF document. 
	// The example also shows how ElementReader can be used to copy and modify 
	// Elements between pages.

	$reader = new ElementReader();

	// Start reading Elements from the last page. We will copy all Elements to 
	// a new page but will modify the font associated with text.
	$reader->Begin($doc->GetPage($doc->GetPageCount()));

	$page = $doc->PageCreate(new Rect(0.0, 0.0, 1300.0, 794.0));

	$writer->Begin($page);		// begin writing to this page
	$builder->Reset();		// Reset the GState to default

	// Embed an external font in the document.
	$font = Font::CreateTrueTypeFont($doc->GetSDFDoc(), $input_path."font.ttf");

	while (($element = $reader->Next()) != null) 	// Read page contents
	{
		if ($element->GetType() == Element::e_text) 
		{
			$element->GetGState()->SetFont($font, 12);
		}
		$writer->WriteElement($element);
	}

	$reader->End();
	$writer->End();  // save changes to the current page

	$doc->PagePushBack($page);


	// Start a new page ------------------------------------
	//
	// The example illustrates how to embed the external font in a PDF document. 
	// The example also shows how ElementReader can be used to copy and modify 
	// Elements between pages.

	// Start reading Elements from the last page. We will copy all Elements to 
	// a new page but will modify the font associated with text.
	$reader->Begin($doc->GetPage($doc->GetPageCount()));

	$page = $doc->PageCreate(new Rect(0.0, 0.0, 1300.0, 794.0));

	$writer->Begin($page);	// begin writing to this page
	$builder->Reset();	// Reset the GState to default

	// Embed an external font in the document.
	$font2 = Font::CreateType1Font($doc->GetSDFDoc(), $input_path."Misc-Fixed.pfa");

	while (($element = $reader->Next())) 	// Read page contents
	{
		if ($element->GetType() == Element::e_text) 
		{
			$element->GetGState()->SetFont($font2, 12);
		}

		$writer->WriteElement($element);
	}

	$reader->End();
	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Start a new page ------------------------------------
	$page = $doc->PageCreate();
	$writer->Begin($page);	// begin writing to this page
	$builder->Reset();		// Reset the GState to default

	// Begin writing a block of text
	$element = $builder->CreateTextBegin(Font::Create($doc->GetSDFDoc(), Font::e_times_roman), 12.0);
	$element->SetTextMatrix(1.5, 0.0, 0.0, 1.5, 50.0, 600.0);
	$element->GetGState()->SetLeading(15);	// Set the spacing between lines
	$writer->WriteElement($element);

	$para = "A PDF text object consists of operators that can show ".
	"text strings, move the text position, and set text state and certain ".
	"other parameters. In addition, there are three parameters that are ".
	"defined only within a text object and do not persist from one text ".
	"object to the next: Tm, the text matrix, Tlm, the text line matrix, ".
	"Trm, the text rendering matrix, actually just an intermediate result ".
	"that combines the effects of text state parameters, the text matrix ".
	"(Tm), and the current transformation matrix";

	$para_end = strlen($para);
	$text_run = 0;

	$para_width = 300;
	$cur_width = 0;

	while ($text_run < $para_end) 
	{
		$text_run_end = strpos($para, ' ', $text_run);
		if (!$text_run_end) $text_run_end = $para_end;

		$text = substr($para, $text_run, $text_run_end-$text_run+1);
		$element = $builder->CreateTextRun($text);
		if ($cur_width + $element->GetTextLength() < $para_width) 
		{
			$writer->WriteElement($element);
 			$cur_width += $element->GetTextLength();
		}
		else 
		{
			$writer->WriteElement($builder->CreateTextNewLine());  // New line
			$element = $builder->CreateTextRun($text);
			$cur_width = $element->GetTextLength();
			$writer->WriteElement($element);
		}

		$text_run = $text_run_end+1;
	}

	// -----------------------------------------------------------------------
	// The following code snippet illustrates how to adjust spacing between 
	// characters (text runs).
	$element = $builder->CreateTextNewLine();
	$writer->WriteElement($element);  // Skip 2 lines
	$writer->WriteElement($element); 
	
	$writer->WriteElement($builder->CreateTextRun("An example of space adjustments between inter-characters:")); 
	$writer->WriteElement($builder->CreateTextNewLine()); 
		
	// Write string "AWAY" without space adjustments between characters.
	$element = $builder->CreateTextRun("AWAY");
	$writer->WriteElement($element);  
		
	$writer->WriteElement($builder->CreateTextNewLine()); 
		
	// Write string "AWAY" with space adjustments between characters.
	$element = $builder->CreateTextRun("A");
	$writer->WriteElement($element);
		
	$element = $builder->CreateTextRun("W");
	$element->SetPosAdjustment(140);
	$writer->WriteElement($element);
		
	$element = $builder->CreateTextRun("A");
	$element->SetPosAdjustment(140);
	$writer->WriteElement($element);
		
	$element = $builder->CreateTextRun("Y again");
	$element->SetPosAdjustment(115);
	$writer->WriteElement($element);

	// Draw the same strings using direct content output...
	$writer->Flush();  // flush pending Element writing operations.

	// You can also write page content directly to the content stream using 
	// ElementWriter.WriteString(...) and ElementWriter.WriteBuffer(...) methods.
	// Note that if you are planning to use these functions you need to be familiar
	// with PDF page content operators (see Appendix A in PDF Reference Manual). 
	// Because it is easy to make mistakes during direct output we recommend that 
	// you use ElementBuilder and Element interface instead.

	$writer->WriteString("T* T* "); // Skip 2 lines
	$writer->WriteString("(Direct output to PDF page content stream:) Tj  T* ");
	$writer->WriteString("(AWAY) Tj T* ");
	$writer->WriteString("[(A)140(W)140(A)115(Y again)] TJ ");

	// Finish the block of text
	$writer->WriteElement($builder->CreateTextEnd());		

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Start a new page ------------------------------------

	// Image Masks
	//
	// In the opaque imaging model, images mark all areas they occupy on the page as 
	// if with opaque paint. All portions of the image, whether black, white, gray, 
	// or color, completely obscure any marks that may previously have existed in the 
	// same place on the page.
	// In the graphic arts industry and page layout applications, however, it is common 
	// to crop or 'mask out' the background of an image and then place the masked image 
	// on a different background, allowing the existing background to show through the 
	// masked areas. This sample illustrates how to use image masks. 

	$page = $doc->PageCreate();
	$writer->Begin($page);	// begin writing to the page

	// Create the Image Mask
	$imgf = new MappedFile($input_path."imagemask.dat");
	$mask_read = new FilterReader($imgf);

	$device_gray = ColorSpace::CreateDeviceGray();
	$mask = Image::Create($doc->GetSDFDoc(), $mask_read, 64, 64, 1, $device_gray, Image::e_ascii_hex);
		
	$mask->GetSDFObj()->PutBool("ImageMask", true);

	$element = $builder->CreateRect(0, 0, 612, 794);
	$element->SetPathStroke(false);
	$element->SetPathFill(true);
	$element->GetGState()->SetFillColorSpace($device_gray);
	$element->GetGState()->SetFillColor(new ColorPt(0.8));
	$writer->WritePlacedElement($element);

	$element = $builder->CreateImage($mask, new Matrix2D(200.0, 0.0, 0.0, -200.0, 40.0, 680.0));
	$element->GetGState()->SetFillColor(new ColorPt(0.1));
	$writer->WritePlacedElement($element);

	$element->GetGState()->SetFillColorSpace(ColorSpace::CreateDeviceRGB());
	$element->GetGState()->SetFillColor(new ColorPt(1.0, 0.0, 0.0));
	$element = $builder->CreateImage($mask, new Matrix2D(200.0, 0.0, 0.0, -200.0, 320.0, 680.0));
	$writer->WritePlacedElement($element);

	$element->GetGState()->SetFillColor(new ColorPt(0.0, 1.0, 0.0));
	$element = $builder->CreateImage($mask, new Matrix2D(200.0, 0.0, 0.0, -200.0, 40.0, 380.0));
	$writer->WritePlacedElement($element);

	// This sample illustrates Explicit Masking. 
	$img = Image::Create($doc->GetSDFDoc(), $input_path."peppers.jpg");

	// mask is the explicit mask for the primary (base) image
	$img->SetMask($mask);

	$element = $builder->CreateImage($img, new Matrix2D(200.0, 0.0, 0.0, -200.0, 320.0, 380.0));
	$writer->WritePlacedElement($element);

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// Transparency sample ----------------------------------
		
	// Start a new page -------------------------------------
	$page = $doc->PageCreate();
	$writer->Begin($page);		// begin writing to this page
	$builder->Reset();		// Reset the GState to default

	// Write some transparent text at the bottom of the page.
	$element = $builder->CreateTextBegin(Font::Create($doc->GetSDFDoc(), Font::e_times_roman), 100.0);

	// Set the text knockout attribute. Text knockout must be set outside of 
	// the text group.
	$gstate = $element->GetGState();
	$gstate->SetTextKnockout(false);
	$gstate->SetBlendMode(GState::e_bl_difference);
	$writer->WriteElement($element);

	$element = $builder->CreateTextRun("Transparency");
	$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 30.0, 30.0);
	$gstate = $element->GetGState();
	$gstate->SetFillColorSpace(ColorSpace::CreateDeviceCMYK());
	$gstate->SetFillColor(new ColorPt(1.0, 0.0, 0.0, 0.0));

	$gstate->SetFillOpacity(0.5);
	$writer->WriteElement($element);

	// Write the same text on top the old; shifted by 3 points
	$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 33.0, 33.0);
  	$gstate->SetFillColor(new ColorPt(0.0, 1.0, 0.0, 0.0));
	$gstate->SetFillOpacity(0.5);

	$writer->WriteElement($element);
	$writer->WriteElement($builder->CreateTextEnd());

	// Draw three overlapping transparent circles.
	$builder->PathBegin();		// start constructing the path
	$builder->MoveTo(459.223, 505.646);
	$builder->CurveTo(459.223, 415.841, 389.85, 343.04, 304.273, 343.04);
	$builder->CurveTo(218.697, 343.04, 149.324, 415.841, 149.324, 505.646);
	$builder->CurveTo(149.324, 595.45, 218.697, 668.25, 304.273, 668.25);
	$builder->CurveTo(389.85, 668.25, 459.223, 595.45, 459.223, 505.646);
	$element = $builder->PathEnd();
	$element->SetPathFill(true);

	$gstate = $element->GetGState();
	$gstate->SetFillColorSpace(ColorSpace::CreateDeviceRGB());
	$gstate->SetFillColor(new ColorPt(0.0, 0.0, 1.0));

	$gstate->SetBlendMode(GState::e_bl_normal);
	$gstate->SetFillOpacity(0.5);
	$writer->WriteElement($element);

	// Translate relative to the Blue Circle
	$gstate->SetTransform(1.0, 0.0, 0.0, 1.0, 113.0, -185.0);                
	$gstate->SetFillColor(new ColorPt(0.0, 1.0, 0.0));                     // Green Circle
	$gstate->SetFillOpacity(0.5);
	$writer->WriteElement($element);

	// Translate relative to the Green Circle
	$gstate->SetTransform(1.0, 0.0, 0.0, 1.0, -220.0, 0.0);
	$gstate->SetFillColor(new ColorPt(1.0, 0.0, 0.0));                     // Red Circle
	$gstate->SetFillOpacity(0.5);
	$writer->WriteElement($element);

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	// End page ------------------------------------

	$doc->Save($output_path."element_builder.pdf", SDFDoc::e_remove_unused);
	echo "Done. Result saved in element_builder.pdf...\n";
?>
