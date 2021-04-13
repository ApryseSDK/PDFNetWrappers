<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//---------------------------------------------------------------------------------------
// This example illustrates how to create Unicode text and how to embed composite fonts.
// 
// Note: This demo assumes that 'arialuni.ttf' is present in '/Samples/TestFiles' 
// directory. Arial Unicode MS is about 24MB in size and it comes together with Windows and 
// MS Office.
//---------------------------------------------------------------------------------------
function main()
{
    global $input_path, $output_path;

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$doc = new PDFDoc();

	$builder = new ElementBuilder();
	$writer = new ElementWriter();	

	// Start a new page ------------------------------------
	$page = $doc->PageCreate(new Rect(0.0, 0.0, 612.0, 794.0));

	$writer->Begin($page);	// begin writing to this page

	// Embed and subset the font
	$font_program = $input_path."ARIALUNI.TTF";
	if (!file_exists($font_program)) {
		if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
			$font_program = "C:/Windows/Fonts/ARIALUNI.TTF";
		}
	}
	$fnt = NULL;
	try {
		$fnt = Font::CreateCIDTrueTypeFont($doc->GetSDFDoc(), $font_program, true, true);
	}
	catch(Exception $e){

	}
	if($fnt)
	{
		echo(nl2br("Note: using " . $font_program . " for unshaped unicode text\n"));
	}
	else
	{
		echo(nl2br("Note: using system font substitution for unshaped unicode text\n"));
		$fnt = Font::Create($doc->GetSDFDoc(), "Helvetica", "");		
	}

	$element = $builder->CreateTextBegin($fnt, 1.0);
	$element->SetTextMatrix(10.0, 0.0, 0.0, 10.0, 50.0, 600.0);
	$element->GetGState()->SetLeading(2);		 // Set the spacing between lines
	$writer->WriteElement($element);

	// Hello World!
	$hello = array( 'H','e','l','l','o',' ','W','o','r','l','d','!');
	$writer->WriteElement($builder->CreateUnicodeTextRun($hello, count($hello)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Latin
	$latin = array(   
		'a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 0x45, 0x0046, 0x00C0, 
		0x00C1, 0x00C2, 0x0143, 0x0144, 0x0145, 0x0152, '1', '2' // etc.
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($latin, count($latin)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Greek
	$greek = array(   
		0x039E, 0x039F, 0x03A0, 0x03A1,0x03A3, 0x03A6, 0x03A8, 0x03A9  // etc.
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($greek, count($greek)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Cyrillic
	$cyrillic = array(   
		0x0409, 0x040A, 0x040B, 0x040C, 0x040E, 0x040F, 0x0410, 0x0411,
		0x0412, 0x0413, 0x0414, 0x0415, 0x0416, 0x0417, 0x0418, 0x0419 // etc.
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($cyrillic, count($cyrillic)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Hebrew
	$hebrew = array(
		0x05D0, 0x05D1, 0x05D3, 0x05D3, 0x05D4, 0x05D5, 0x05D6, 0x05D7, 0x05D8, 
		0x05D9, 0x05DA, 0x05DB, 0x05DC, 0x05DD, 0x05DE, 0x05DF, 0x05E0, 0x05E1 // etc. 
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($hebrew, count($hebrew)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Arabic
	$arabic = array(
		0x0624, 0x0625, 0x0626, 0x0627, 0x0628, 0x0629, 0x062A, 0x062B, 0x062C, 
		0x062D, 0x062E, 0x062F, 0x0630, 0x0631, 0x0632, 0x0633, 0x0634, 0x0635 // etc. 
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($arabic, count($arabic)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Thai 
	$thai = array(
		0x0E01, 0x0E02, 0x0E03, 0x0E04, 0x0E05, 0x0E06, 0x0E07, 0x0E08, 0x0E09, 
		0x0E0A, 0x0E0B, 0x0E0C, 0x0E0D, 0x0E0E, 0x0E0F, 0x0E10, 0x0E11, 0x0E12 // etc. 
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($thai, count($thai)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Hiragana - Japanese 
	$hiragana = array(
		0x3041, 0x3042, 0x3043, 0x3044, 0x3045, 0x3046, 0x3047, 0x3048, 0x3049, 
		0x304A, 0x304B, 0x304C, 0x304D, 0x304E, 0x304F, 0x3051, 0x3051, 0x3052 // etc. 
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($hiragana, count($hiragana)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// CJK Unified Ideographs
	$cjk_uni = array(
		0x5841, 0x5842, 0x5843, 0x5844, 0x5845, 0x5846, 0x5847, 0x5848, 0x5849, 
		0x584A, 0x584B, 0x584C, 0x584D, 0x584E, 0x584F, 0x5850, 0x5851, 0x5852 // etc. 
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($cjk_uni, count($cjk_uni)));
	$writer->WriteElement($builder->CreateTextNewLine());

	// Simplified Chinese
	$chinese_simplified = array(
		0x4e16, 0x754c, 0x60a8, 0x597d
	);
	$writer->WriteElement($builder->CreateUnicodeTextRun($chinese_simplified, count($chinese_simplified)));
	$writer->WriteElement($builder->CreateTextNewLine());

	echo("Now using text shaping logic to place text\n");

	// Create a font in indexed encoding mode 
	// normally this would mean that we are required to provide glyph indices
	// directly to CreateUnicodeTextRun, but instead, we will use the GetShapedText
	// method to take care of this detail for us.
	$indexed_font = Font::CreateCIDTrueTypeFont($doc->GetSDFDoc(), $input_path . "NotoSans_with_hindi.ttf", true, true, Font::e_Indices);
	$element = $builder->CreateTextBegin($indexed_font, 10.0);
	$writer->WriteElement($element);

	$line_pos = 350.0;
	$line_space = 20.0;

	// Transform unicode text into an abstract collection of glyph indices and positioning info 
	$shaped_text = $indexed_font->GetShapedText("Shaped Hindi Text:");

	// transform the shaped text info into a PDF element and write it to the page
	$element = $builder->CreateShapedTextRun($shaped_text);
	$element->SetTextMatrix(1.5, 0.0, 0.0, 1.5, 50.0, $line_pos);
	$writer->WriteElement($element);

	# read in unicode text lines from a file 
	$f = fopen($input_path . "hindi_sample_utf16le.txt", "r");
	$i = 0;
	while($hindi_text = fgets($f)){$i++;}
	fclose($f);
	echo("Read in " . $i . " lines of Unicode text from file\n");

	$f = fopen($input_path . "hindi_sample_utf16le.txt", "r");
	$i = 0;
	while($hindi_text = fgets($f)){
		if ($i == 0)
			$tmp1 = substr($hindi_text,0,-1);
		else if($i == 1)
			$tmp1 = substr($hindi_text,1,-2); // remove the first and the last 2 characters so encoding to UTF-8 looks correct in PHP 
		$tmp = iconv($in_charset = "UTF-16LE", $out_charset="UTF-8", $tmp1);
		$shaped_text = $indexed_font->GetShapedText($tmp);
		$element = $builder->CreateShapedTextRun($shaped_text);
		$element->SetTextMatrix(1.5, 0.0, 0.0, 1.5, 50.0, $line_pos-$line_space*($i+1));
		$writer->WriteElement($element);
		echo("Wrote shaped line to page\n");
		$i++;

	}
	fclose($f);

	// Finish the block of text
	$writer->WriteElement($builder->CreateTextEnd());

	$writer->End();  // save changes to the current page
	$doc->PagePushBack($page);

	$doc->Save($output_path."unicodewrite.pdf", SDFDoc::e_remove_unused | SDFDoc::e_hex_strings);
	echo "Done. Result saved in unicodewrite.pdf...\n";
}

main();
?>
