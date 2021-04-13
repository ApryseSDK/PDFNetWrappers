<?php
#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

function ProcessPath($reader, $path)
{
	if ($path->IsClippingPath())
	{
		echo nl2br("This is a clipping path\n");
	}

	$pathData = $path->GetPathData();
	$data = $pathData->GetPoints();
	$opr = $pathData->GetOperators();

	$opr_index = 0;
	$opr_end = count($opr);
	$data_index = 0;
	$data_end = count($data);

	// Use path.GetCTM() if you are interested in CTM (current transformation matrix).

	echo " Path Data Points := \"";
	for (; $opr_index<$opr_end; ++$opr_index)
	{
		switch($opr[$opr_index])
		{
		case PathData::e_moveto:
			$x1 = $data[$data_index]; ++$data_index;
			$y1 = $data[$data_index]; ++$data_index;
			$m_buf = sprintf("M%.5g %.5g", $x1, $y1);
			echo $m_buf;
			break;
		case PathData::e_lineto:
			$x1 = $data[$data_index]; ++$data_index;
			$y1 = $data[$data_index]; ++$data_index;
			$m_buf = sprintf(" L%.5g %.5g", $x1, $y1);
			echo $m_buf;
			break;
		case PathData::e_cubicto:
			$x1 = $data[$data_index]; ++$data_index;
			$y1 = $data[$data_index]; ++$data_index;
			$x2 = $data[$data_index]; ++$data_index;
			$y2 = $data[$data_index]; ++$data_index;
			$x3 = $data[$data_index]; ++$data_index;
			$y3 = $data[$data_index]; ++$data_index;
			$m_buf = sprintf(" C%.5g %.5g %.5g %.5g %.5g %.5g", $x1, $y1, $x2, $y2, $x3, $y3);
			echo $m_buf;
			break;
		case PathData::e_rect:
			{
				$x1 = $data[$data_index]; ++$data_index;
				$y1 = $data[$data_index]; ++$data_index;
				$w = $data[$data_index]; ++$data_index;
				$h = $data[$data_index]; ++$data_index;
				$x2 = $x1 + $w;
				$y2 = $y1;
				$x3 = $x2;
				$y3 = $y1 + $h;
				$x4 = $x1; 
				$y4 = $y3;
				$m_buf = sprintf("M%.5g %.5g L%.5g %.5g L%.5g %.5g L%.5g %.5g Z", 
					$x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4);
				echo $m_buf;
			}
			break;
		case PathData::e_closepath:
			echo nl2br(" Close Path\n");
			break;
		default: 
			//assert(false);
			break;
		}	
	}

	echo "\" ";

	$gs = $path->GetGState();

	// Set Path State 0 (stroke, fill, fill-rule) -----------------------------------
	if ($path->IsStroked()) 
	{
		echo nl2br("Stroke path\n"); 

		if ($gs->GetStrokeColorSpace()->GetType() == ColorSpace::e_pattern)
		{
			echo nl2br("Path has associated pattern\n"); 
		}
		else
		{
			// Get stroke color (you can use PDFNet color conversion facilities)
			// $rgb = $gs->GetStrokeColorSpace()->Convert2RGB($gs->GetStrokeColor());
		}
	}
	else 
	{
		// Do not stroke path
	}

	if ($path->IsFilled())
	{
		echo nl2br("Fill path\n"); 

		if ($gs->GetFillColorSpace()->GetType() == ColorSpace::e_pattern)
		{		
			echo nl2br("Path has associated pattern\n"); 
		}
		else
		{
			// $rgb = $gs->GetFillColorSpace()->Convert2RGB($gs->GetFillColor());
		}        
	}
	else 
	{
		// Do not fill path
	}

	// Process any changes in graphics state  ---------------------------------

	$gs_itr = $reader->GetChangesIterator();
	for (; $gs_itr->HasNext(); $gs_itr->Next()) 
	{
		switch($gs_itr->Current())
		{
		case GState::e_transform :
			// Get transform matrix for this element. Unlike path.GetCTM() 
			// that return full transformation matrix gs.GetTransform() return 
			// only the transformation matrix that was installed for this element.
			//
			// $gs->GetTransform();
			break;
		case GState::e_line_width :
			// $gs->GetLineWidth();
			break;
		case GState::e_line_cap :
			// $gs->GetLineCap();
			break;
		case GState::e_line_join :
			// $gs->GetLineJoin();
			break;
		case GState::e_flatness :	
			break;
		case GState::e_miter_limit :
			// $gs->GetMiterLimit();
			break;
		case GState::e_dash_pattern :
			{
				// $dashes = $gs->GetDashes($dashes);
				// $gs->GetPhase()
			}
			break;
		case GState::e_fill_color:
			{
				if ( $gs->GetFillColorSpace()->GetType() == ColorSpace::e_pattern &&
					$gs->GetFillPattern()->GetType() != PatternColor::e_shading )
				{	
					//process the pattern data
					$reader->PatternBegin(true);
					ProcessElements($reader);
					$reader->End();
				}
			}
			break;
		}
	}
	$reader->ClearChangeList();
}

function ProcessText($page_reader) 
{
	// Begin text element
	echo nl2br("Begin Text Block:\n");

	while (($element = $page_reader->Next()) != NULL) 
	{
		switch ($element->GetType())
		{
		case Element::e_text_end: 
			// Finish the text block
			echo nl2br("End Text Block.\n");
			return;

		case Element::e_text:
			{
				$gs = $element->GetGState();

				$cs_fill = $gs->GetFillColorSpace();
				$fill = $gs->GetFillColor();

				$out = $cs_fill->Convert2RGB($fill);

				$cs_stroke = $gs->GetStrokeColorSpace();
				$stroke = $gs->GetStrokeColor();

				$font = $gs->GetFont();

				echo nl2br("Font Name: ".$font->GetName()."\n");
				// $font->IsFixedWidth();
				// $font->IsSerif();
				// $font->IsSymbolic();
				// $font->IsItalic();
				// ... 

				// $font_size = $gs->GetFontSize();
				// $word_spacing = $gs->GetWordSpacing();
				// $char_spacing = $gs->GetCharSpacing();
				// $txt = $element->GetTextString();

				if ( $font->GetType() == Font::e_Type3 )
				{
					//type 3 font, process its data
					for ($itr = $element->GetCharIterator(); $itr->HasNext(); $itr->Next()) 
					{
						$page_reader->Type3FontBegin($itr->Current());
						ProcessElements($page_reader);
						$page_reader->End();
					}
				}

				else
				{	
					$text_mtx = $element->GetTextMatrix();
					
					for ($itr = $element->GetCharIterator(); $itr->HasNext(); $itr->Next()) 
					{
						$char_code = $itr->Current()->char_code;
						if ($char_code>=32 || $char_code<=255) { // Print if in ASCII range...
							echo chr($char_code);
						}

						$x = $itr->Current()->x;		// character positioning information
						$y = $itr->Current()->y;
						$pt = new Point($x, $y);

						// Use element.GetCTM() if you are interested in the CTM 
						// (current transformation matrix).
						$ctm = $element->GetCTM();

						// To get the exact character positioning information you need to 
						// concatenate current text matrix with CTM and then multiply 
						// relative positioning coordinates with the resulting matrix.
						$mtx = $text_mtx;
						$mtx->Concat($ctm->m_a, $ctm->m_b, $ctm->m_c, $ctm->m_d, $ctm->m_h, $ctm->m_v);
						$mtx->Mult($pt);

						// Get glyph path...
						//$glyphPath = font.GetGlyphPath($char_code, false, 0);
						//$oprs = $glyphPath->GetOperators();
						//$glyph_data = $glyphPath->GetDataPoints();
					}
				}

				echo nl2br("\n");
			}
			break;
		}
	}
}

function ProcessImage($image)  
{
	$image_mask = $image->IsImageMask();
	$interpolate = $image->IsImageInterpolate();
	$width = $image->GetImageWidth();
	$height = $image->GetImageHeight();

	$out_data_sz = $width * $height * 3;

	echo "Image: " 
		." width=\"".$width."\""
		." height=\"".$height."\n";

	// $mtx = $image->GetCTM(); // image matrix (page positioning info)

	// You can use GetImageData to read the raw (decoded) image data
	//$image->GetBitsPerComponent();	
	//$image->GetImageData();	// get raw image data
	// .... or use Image2RGB filter that converts every image to RGB format,
	// This should save you time since you don't need to deal with color conversions, 
	// image up-sampling, decoding etc.

	$img_conv = new Image2RGB($image);	// Extract and convert image to RGB 8-bpc format
	$reader = new FilterReader($img_conv);

	// A buffer used to keep image data.
	$image_data_out = $reader->Read($out_data_sz);
	// $image_data_out contains RGB image data.

	// Note that you don't need to read a whole image at a time. Alternatively
	// you can read a chuck at a time by repeatedly calling reader.Read(buf_sz) 
	// until the function returns 0. 
}
    
function ProcessElements($reader) 
{
	while (($element = $reader->Next()) != NULL) 	// Read page contents
	{
		switch ($element->GetType())
		{
		case Element::e_path:						// Process path data...
			{
				ProcessPath($reader, $element);
			}
			break; 
		case Element::e_text_begin: 				// Process text block...
			{
				ProcessText($reader);
			}
			break;
		case Element::e_form:						// Process form XObjects
			{
				$reader->FormBegin(); 
				ProcessElements($reader);
				$reader->End();
			}
			break; 
		case Element::e_image:						// Process Images
			{
				ProcessImage($element);
			}	
			break; 
		}
	}
}

	# Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = $input_path."Output/";

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	# Extract text data from all pages in the document
	echo nl2br("__________________________________________________\n");
	echo nl2br("Extract page element information from all \n");
	echo nl2br("pages in the document.\n");

	$doc = new PDFDoc($input_path."newsletter.pdf");
	$doc->InitSecurityHandler();

	$pgnum = $doc->GetPageCount();
	$page_begin = $doc->GetPageIterator();

	$page_reader = new ElementReader();

	for ($itr = $page_begin; $itr->HasNext(); $itr->Next())		//  Read every page
	{				
		echo nl2br("Page ".$itr->Current()->GetIndex()."----------------------------------------\n");
		$page_reader->Begin($itr->Current());
		ProcessElements($page_reader);
		$page_reader->End();
	}
	$doc->Close();
	echo nl2br("Done.\n");		
?>
