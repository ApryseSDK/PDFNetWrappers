<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert PDF documents to various raster image 
// formats (such as PNG, JPEG, BMP, TIFF, etc), as well as how to convert a PDF page to 
// GDI+ Bitmap for further manipulation and/or display in WinForms applications.
//---------------------------------------------------------------------------------------
	
	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize();

	// Optional: Set ICC color profiles to fine tune color conversion 
	// for PDF 'device' color spaces...

	// PDFNet::SetResourcesPath("../../../resources");
	// PDFNet::SetColorManagement();
	// PDFNet::SetDefaultDeviceCMYKProfile("D:/Misc/ICC/USWebCoatedSWOP.icc");
	// PDFNet::SetDefaultDeviceRGBProfile("AdobeRGB1998.icc"); // will search in PDFNet resource folder.

	// ----------------------------------------------------
	// Optional: Set predefined font mappings to override default font 
	// substitution for documents with missing fonts...

	// PDFNet::AddFontSubst("StoneSans-Semibold", "C:/WINDOWS/Fonts/comic.ttf");
	// PDFNet::AddFontSubst("StoneSans", "comic.ttf");  // search for 'comic.ttf' in PDFNet resource folder.
	// PDFNet::AddFontSubst(PDFNet::e_Identity, "C:/WINDOWS/Fonts/arialuni.ttf");
	// PDFNet::AddFontSubst(PDFNet::e_Japan1, "C:/Program Files/Adobe/Acrobat 7.0/Resource/CIDFont/KozMinProVI-Regular.otf");
	// PDFNet::AddFontSubst(PDFNet::e_Japan2, "c:/myfonts/KozMinProVI-Regular.otf");
	// PDFNet::AddFontSubst(PDFNet::e_Korea1, "AdobeMyungjoStd-Medium.otf");
	// PDFNet::AddFontSubst(PDFNet::e_CNS1, "AdobeSongStd-Light.otf");
	// PDFNet::AddFontSubst(PDFNet::e_GB1, "AdobeMingStd-Light.otf");
	
	$draw = new PDFDraw();

	//--------------------------------------------------------------------------------
	// Example 1) Convert the first page to PNG and TIFF at 92 DPI. 
	// A three step tutorial to convert PDF page to an image.
	 
	// A) Open the PDF document.
	$doc = new PDFDoc($input_path."tiger.pdf");

	// Initialize the security handler, in case the PDF is encrypted.
	$doc->InitSecurityHandler();  

	// B) The output resolution is set to 92 DPI.
	$draw->SetDPI(92);

	// C) Rasterize the first page in the document and save the result as PNG.
	$draw->Export($doc->GetPageIterator()->Current(), $output_path."tiger_92dpi.png");

	echo nl2br("Example 1: ".$output_path."tiger_92dpi.png".". Done.\n");

	// Export the same page as TIFF
	$draw->Export($doc->GetPageIterator()->Current(), $output_path."tiger_92dpi.tif", "TIFF");

	//--------------------------------------------------------------------------------
	// Example 2) Convert the all pages in a given document to JPEG at 72 DPI.
	echo nl2br("Example 2:\n");
	$hint_set = new ObjSet(); //  A collection of rendering 'hits'.
	 
	$doc = new PDFDoc($input_path."newsletter.pdf");
	// Initialize the security handler, in case the PDF is encrypted.
	$doc->InitSecurityHandler();  

	$draw->SetDPI(72); // Set the output resolution is to 72 DPI.

	// Use optional encoder parameter to specify JPEG quality.
	$encoder_param=$hint_set->CreateDict();
	$encoder_param->PutNumber("Quality", 80);

	// Traverse all pages in the document.
	for ($itr=$doc->GetPageIterator(); $itr->HasNext(); $itr->Next()) {
		$filename = $output_path."newsletter".$itr->Current()->GetIndex().".jpg";
		echo nl2br($filename."\n");
		$draw->Export($itr->Current(), $filename, "JPEG", $encoder_param);
	}

	echo nl2br("Done.\n");

	// Examples 3-5
				
	// Common code for remaining samples.
	$tiger_doc = new PDFDoc($input_path."tiger.pdf");
	// Initialize the security handler, in case the PDF is encrypted.
	$tiger_doc->InitSecurityHandler();  
	$page = $tiger_doc->GetPage(1);

	//--------------------------------------------------------------------------------
	// Example 3) Convert the first page to raw bitmap. Also, rotate the 
	// page 90 degrees and save the result as RAW.
	$draw->SetDPI(100); // Set the output resolution is to 100 DPI.
	$draw->SetRotate(Page::e_90);  // Rotate all pages 90 degrees clockwise.

	$bmp = $draw->GetBitmap($page, PDFDraw::e_rgb);

	// Save the raw RGB data to disk.
    file_put_contents($output_path."tiger_100dpi_rot90.raw", $bmp->GetBuffer());

	echo nl2br("Example 3: ".$output_path."tiger_100dpi_rot90.raw. Done.\n");
	$draw->SetRotate(Page::e_0);  // Disable image rotation for remaining samples.

	//--------------------------------------------------------------------------------
	// Example 4) Convert PDF page to a fixed image size. Also illustrates some 
	// other features in PDFDraw class such as rotation, image stretching, exporting 
	// to grayscale, or monochrome.

	// Initialize render 'gray_hint' parameter, that is used to control the 
	// rendering process. In this case we tell the rasterizer to export the image as 
	// 1 Bit Per Component (BPC) image.
	$mono_hint=$hint_set->CreateDict();  
	$mono_hint->PutNumber("BPC", 1);

	// SetImageSize can be used instead of SetDPI() to adjust page  scaling 
	// dynamically so that given image fits into a buffer of given dimensions.
	$draw->SetImageSize(1000, 1000);		// Set the output image to be 1000 wide and 1000 pixels tall
	$draw->Export($page, $output_path."tiger_1000x1000.png", "PNG", $mono_hint);
	echo nl2br("Example 4: ".$output_path."tiger_1000x1000.png. Done.\n");

	$draw->SetImageSize(200, 400);	    // Set the output image to be 200 wide and 300 pixels tall
	$draw->SetRotate(Page::e_180);  // Rotate all pages 90 degrees clockwise.

	// 'gray_hint' tells the rasterizer to export the image as grayscale.
	$gray_hint=$hint_set->CreateDict();  
	$gray_hint->PutName("ColorSpace", "Gray");

	$draw->Export($page, $output_path."tiger_200x400_rot180.png", "PNG", $gray_hint);
	echo nl2br("Example 4: ".$output_path."tiger_200x400_rot180.png. Done.\n");

	$draw->SetImageSize(400, 200, false);  // The third parameter sets 'preserve-aspect-ratio' to false.
	$draw->SetRotate(Page::e_0);    // Disable image rotation.
	$draw->Export($page, $output_path."tiger_400x200_stretch.jpg", "JPEG");
	echo nl2br("Example 4: ".$output_path."tiger_400x200_stretch.jpg. Done.\n");

	//--------------------------------------------------------------------------------
	// Example 5) Zoom into a specific region of the page and rasterize the 
	// area at 200 DPI and as a thumbnail (i.e. a 50x50 pixel image).
	$zoom_rect = new Rect(216.0, 522.0, 330.0, 600.0);
	$page->SetCropBox($zoom_rect);	// Set the page crop box.

	// Select the crop region to be used for drawing.
	$draw->SetPageBox(Page::e_crop); 
	$draw->SetDPI(900);  // Set the output image resolution to 900 DPI.
	$draw->Export($page, $output_path."tiger_zoom_900dpi.png", "PNG");
	echo nl2br("Example 5: ".$output_path."tiger_zoom_900dpi.png. Done.\n");

	$draw->SetImageSize(50, 50);	   // Set the thumbnail to be 50x50 pixel image.
	$draw->Export($page, $output_path."tiger_zoom_50x50.png", "PNG");
	echo nl2br("Example 5: ".$output_path."tiger_zoom_50x50.png. Done.\n");

	$cmyk_hint = $hint_set->CreateDict();
	$cmyk_hint->PutName("ColorSpace", "CMYK");
	
	//--------------------------------------------------------------------------------
	// Example 6) Convert the first PDF page to CMYK TIFF at 92 DPI.
	// A three step tutorial to convert PDF page to an image
	echo nl2br("Example 6:\n");

	// A) Open the PDF document.
	$doc = new PDFDoc($input_path."tiger.pdf");
	// Initialize the security handler, in case the PDF is encrypted.
	$doc->InitSecurityHandler();  

	// B) The output resolution is set to 92 DPI.
	$draw->SetDPI(92);

	// C) Rasterize the first page in the document and save the result as TIFF.
	$pg = $doc->GetPage(1);
	$draw->Export($pg, $output_path."out1.tif", "TIFF", $cmyk_hint);
	echo nl2br("Example 6: Result saved in ".$output_path."out1.tif\n");

	$doc->Close();
	
	echo "Done.";
?>
