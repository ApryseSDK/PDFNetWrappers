<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/newsletter.pdf";

//---------------------------------------------------------------------------------------
// This sample illustrates the basic text extraction capabilities of PDFNet.
//---------------------------------------------------------------------------------------

// A utility method used to dump all text content in the browser.
function DumpAllText($reader) 
{
	while (($element = $reader->Next()) != NULL)
	{
		switch ($element->GetType()) 
		{
		case Element::e_text_begin: 
			echo nl2br("\n--> Text Block Begin\n");
			break;
		case Element::e_text_end:
			echo nl2br("\n--> Text Block End\n");
			break;
		case Element::e_text:
			{
				$bbox = $element->GetBBox();
				echo nl2br("\n--> BBox: ".$bbox->x1.", "
							.$bbox->y1.", " 
							.$bbox->x2.", " 
							.$bbox->y2."\n");

				$arr = $element->GetTextString();
				echo nl2br($arr."\n");
			}
			break;
		case Element::e_text_new_line:
			echo nl2br("\n--> New Line\n");
			break;
		case Element::e_form:				// Process form XObjects
			$reader->FormBegin(); 
            		DumpAllText(reader);
			$reader->End(); 
			break; 
		}
	}
}

// A helper method for ReadTextFromRect
function RectTextSearch($reader, $pos) 
{		
	$srch_str = "";	
	while (($element = $reader->Next()) != null)
	{
		switch ($element->GetType()) 
		{
		case Element::e_text:
			{
				$bbox = $element->GetBBox();
				if($bbox->IntersectRect($bbox, $pos)) 
				{
					$arr = $element->GetTextString();
					$srch_str .= $arr;
					$srch_str .= nl2br("\n");
				}
				break;
			}
		case Element::e_text_new_line:
			{
				break;
			}
		case Element::e_form: // Process form XObjects
			{
				$reader->FormBegin(); 
				$srch_str .= RectTextSearch($reader, $pos);
				$reader->End(); 
				break; 
			}
		}
	}
	return $srch_str;
}

// A utility method used to extract all text content from
// a given selection rectangle. The rectangle coordinates are
// expressed in PDF user/page coordinate system.
function ReadTextFromRect($page, $pos, $reader)
{
	$reader->Begin($page);
	$str = RectTextSearch($reader, $pos);
	$reader->End();
	return $str;
}

function PrintStyle($style)
{
	$text_color = $style->GetColor();
	$tmp = sprintf("%02X%02X%02X;", $text_color[0], $text_color[1], $text_color[2]);
	echo " style=\"font-family:".$style->GetFontName()."; "
		."font-size:".$style->GetFontSize().";" 
		.($style->IsSerif() ? " sans-serif; " : " ")
		."color:#".$tmp."\"";
}

function IsStyleEqual($style1, $style2)
{
	if($style1->GetFontName() == $style2->GetFontName() && 
		$style1->GetFontSize() == $style1->GetFontSize() && 
		!($style1->IsSerif() xor $style1->IsSerif()) &&
		$style1->GetColor() == $style2->GetColor() ) {
		return true;
	}
	return false; 
}
//---------------------------------------------------------------------------------------

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$example1_basic     = false;
	$example2_xml       = false;
	$example3_wordlist  = false;
	$example4_advanced  = true;
	$example5_low_level = false;

	// Sample code showing how to use high-level text extraction APIs.
	
	$doc = new PDFDoc($input_path);
	$doc->InitSecurityHandler();

	$page = $doc->GetPage(1);
	if (!$page){
		echo nl2br("Page not found.\n");
		return;
	}

	$txt = new TextExtractor();
	$txt->Begin($page); // Read the page.
	// Other options you may want to consider...
	// txt.Begin(*itr, 0, TextExtractor::e_no_dup_remove);
	// txt.Begin(*itr, 0, TextExtractor::e_remove_hidden_text);

	// Example 1. Get all text on the page in a single string.
	// Words will be separated with space or new line characters.
	if ($example1_basic) 
	{
		// Get the word count.
		echo "Word Count: ".$txt->GetWordCount()."\n";

		$text = $txt->GetAsText();
		echo nl2br("\n\n- GetAsText --------------------------\n".$text."\n");
		echo nl2br("-----------------------------------------------------------\n");
	}

	// Example 2. Get XML logical structure for the page.
	if ($example2_xml) 
	{
		$text = $txt->GetAsXML(TextExtractor::e_words_as_elements | TextExtractor::e_output_bbox | TextExtractor::e_output_style_info);
		echo nl2br("\n\n- GetAsXML  --------------------------\n".$text."\n");
		echo nl2br("-----------------------------------------------------------\n");
	}

	// Example 3. Extract words one by one.
	if ($example3_wordlist) 
	{
		for ($line = $txt->GetFirstLine(); $line->IsValid(); $line=$line->GetNextLine())	{
			for ($word=$line->GetFirstWord(); $word->IsValid(); $word=$word->GetNextWord()) {
				echo nl2br($word->GetString()."\n");
			}
		}
		echo nl2br("-----------------------------------------------------------\n");
	}

	// Example 4. A more advanced text extraction example. 
	// The output is XML structure containing paragraphs, lines, words, 
	// as well as style and positioning information.
	if ($example4_advanced) 
	{
		$cur_flow_id=-1;
		$cur_para_id=-1;

		echo nl2br("<PDFText>\n");
		// For each line on the page...
		for ($line=$txt->GetFirstLine(); $line->IsValid(); $line=$line->GetNextLine())
		{
			if ($line->GetNumWords() == 0) continue;
			
			if ($cur_flow_id != $line->GetFlowID()) {
				if ($cur_flow_id != -1) {
					if ($cur_para_id != -1) {
						$cur_para_id = -1;
						echo nl2br("</Para>\n");
					}
					echo nl2br("</Flow>\n");
				}
				$cur_flow_id = $line->GetFlowID();
				echo nl2br("<Flow id=\"".$cur_flow_id."\">\n");
			}

			if ($cur_para_id != $line->GetParagraphID()) {
				if ($cur_para_id != -1)
					echo nl2br("</Para>\n");
				$cur_para_id = $line->GetParagraphID();
				echo nl2br("<Para id=\"".$cur_para_id."\">\n");
			}	

			$bbox1 = $line->GetBBox();
			$line_style = $line->GetStyle();
			printf("<Line box=\"%.2f, %.2f, %.2f, %.2f\"", $bbox1->x1, $bbox1->y1, $bbox1->x2, $bbox1->y2);
			PrintStyle($line_style);
			echo  " cur_num=\"".$line->GetCurrentNum()."\"";
			echo nl2br(">\n");

			// For each word in the line...
			for ($word=$line->GetFirstWord(); $word->IsValid(); $word=$word->GetNextWord())
			{
				// Output the bounding box for the word.
				$bbox2 = $word->GetBBox();
				printf("<Word box=\"%.2f, %.2f, %.2f, %.2f\"", $bbox2->x1, $bbox2->y1, $bbox2->x2, $bbox2->y2);
				echo " cur_num=\"" .$word->GetCurrentNum()."\"";
				$sz = $word->GetStringLen();
				if ($sz == 0) continue;

				// If the word style is different from the parent style, output the new style.
				$s = $word->GetStyle();
				if(!$s->IsEqual($line_style)){
					PrintStyle($s);
				}
				
				echo ">".$word->GetString();
				echo nl2br("</Word>\n");
			}
			echo nl2br("</Line>\n");
		}

		if ($cur_flow_id != -1) {
			if ($cur_para_id != -1) {
				$cur_para_id = -1;
				echo nl2br("</Para>\n");
			}
			echo nl2br("</Flow>\n");


		}
		echo nl2br("</PDFText>\n");

		$txt->Destroy();
		$doc->Close();

	}

	if($example5_low_level)
	{
		$doc = new PDFDoc($input_path);
		$doc->InitSecurityHandler();

		// Example 1. Extract all text content from the document

		$reader = new ElementReader();

		//  Read every page
		for ($itr=$doc->GetPageIterator(); $itr->HasNext(); $itr->Next()) 
		{
			$reader->Begin($itr->Current());
			DumpAllText($reader);
			$reader->End();
		}

		// Example 2. Extract text content based on the 
		// selection rectangle.
		echo nl2br("\n----------------------------------------------------");
		echo nl2br("\nExtract text based on the selection rectangle.");
		echo nl2br("\n----------------------------------------------------\n");

		$first_page = $doc->GetPage(1);
		$s1 = ReadTextFromRect($first_page, new Rect(27.0, 392.0, 563.0, 534.0), $reader);
		echo nl2br("\nField 1: ".$s1);

		$s1 = ReadTextFromRect($first_page, new Rect(28.0, 551.0, 106.0, 623.0), $reader);
		echo nl2br("\nField 2: ".$s1);

		$s1 = ReadTextFromRect($first_page, new Rect(208.0, 550.0, 387.0, 621.0), $reader);
		echo nl2br("\nField 3: ".$s1);

		// ... 
		$doc->Close();
		echo nl2br("Done.\n");
	}
?>
