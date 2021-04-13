<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$doc = new PDFDoc($input_path."credit card numbers.pdf");
	$doc->InitSecurityHandler();

	$txt_search = new TextSearch();
	$mode = TextSearch::e_whole_word | TextSearch::e_page_stop;
	$pattern = "joHn sMiTh";

	//call Begin() method to initialize the text search.
	$txt_search->Begin( $doc, $pattern, $mode );

	$step = 0;
	
	//call Run() method iteratively to find all matching instances.
	while ( true )
	{
		$searchResult = $txt_search->Run();
		if ( $searchResult->IsFound() )
		{
			if ( $step == 0 )
			{	//step 0: found "John Smith"
				//note that, here, 'ambient_string' and 'hlts' are not written to, 
				//as 'e_ambient_string' and 'e_highlight' are not set.

				echo nl2br($searchResult->GetMatch()."'s credit card number is: \n");

				//now switch to using regular expressions to find John's credit card number
				$mode = $txt_search->GetMode();
				$mode |= TextSearch::e_reg_expression | TextSearch::e_highlight;
				$txt_search->SetMode($mode);
				$pattern = "\\d{4}-\\d{4}-\\d{4}-\\d{4}"; //or "(\\d{4}-){3}\\d{4}"
				$txt_search->SetPattern($pattern);

				++$step;
			}
			else if ( $step == 1 )
			{
				//step 1: found John's credit card number
				echo nl2br("  ".$searchResult->GetMatch()."\n");
				
				//note that, here, 'hlts' is written to, as 'e_highlight' has been set.
				//output the highlight info of the credit card number.
				$hlts = $searchResult->GetHighlights();
				$hlts->Begin($doc);
				while ( $hlts->HasNext() )
				{
					echo nl2br("The current highlight is from page: ".$hlts->GetCurrentPageNumber()."\n");
					$hlts->Next();
				}

				//see if there is an AMEX card number
				$pattern = "\\d{4}-\\d{6}-\\d{5}";
				$txt_search->SetPattern($pattern);

				++$step;
			}
			else if ( $step == 2 )
			{
				//found an AMEX card number
				echo nl2br("\nThere is an AMEX card number:\n  ".$searchResult->GetMatch()."\n");

				//change mode to find the owner of the credit card; supposedly, the owner's
				//name proceeds the number
				$mode = $txt_search->GetMode();
				$mode |= TextSearch::e_search_up;
				$txt_search->SetMode($mode);
				$pattern = "[A-z]++ [A-z]++";
				$txt_search->SetPattern($pattern);

				++$step;
			}
			else if ( $step == 3 )
			{
				//found the owner's name of the AMEX card
				echo nl2br("Is the owner's name:\n  ".$searchResult->GetMatch()."?\n");

				//add a link annotation based on the location of the found instance
				$hlts = $searchResult->GetHighlights();
				$hlts->Begin($doc);
				while ( $hlts->HasNext() )
				{
					$cur_page= $doc->GetPage($hlts->GetCurrentPageNumber());
					$quadsInfo = $hlts->GetCurrentQuads();

					for ( $i = 0; $i < $quadsInfo->size(); ++$i )
					{
						//assume each quad is an axis-aligned rectangle
						$q = $quadsInfo->get($i);
						$x1 = min(min(min($q->p1->x, $q->p2->x), $q->p3->x), $q->p4->x);
						$x2 = max(max(max($q->p1->x, $q->p2->x), $q->p3->x), $q->p4->x);
						$y1 = min(min(min($q->p1->y, $q->p2->y), $q->p3->y), $q->p4->y);
						$y2 = max(max(max($q->p1->y, $q->p2->y), $q->p3->y), $q->p4->y);
						$hyper_link = Link::Create($doc->GetSDFDoc(), new Rect($x1, $y1, $x2, $y2), 
										Action::CreateURI($doc->GetSDFDoc(), "http://www.pdftron.com"));
						$cur_page->AnnotPushBack($hyper_link);
					}
					$hlts->Next();
				}
				
				$doc->Save($output_path."credit card numbers_linked.pdf", SDFDoc::e_linearized);

				break;
			}
		}
		else if ( $code == TextSearch::e_page )
		{
			//you can update your UI here, if needed
		}
		else
		{
			break;
		}
	}
	
	$doc->Close();	
?>
