<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/paragraphs_and_tables.pdf";
$output_path = getcwd()."../../TestFiles/Output/";

//---------------------------------------------------------------------------------------
// This sample illustrates the basic text highlight capabilities of PDFNet.
// It simulates a full-text search engine that finds all occurrences of the word 'Federal'.
// It then highlights those words on the page.
// 
// Note: The TextSearch class is the preferred solution for searching text within a single
// PDF file. TextExtractor provides search highlighting capabilities where a large number
// of documents are indexed using a 3rd party search engine.
// --------------------------------------------------------------------------------------

	// The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize($LicenseKey);

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
		PDFNet::Terminate();
		return;
	}

	$txt = new TextExtractor();
	$txt->Begin($page); // Read the page.

	// Do not dehyphenate; that would interfere with character offsets
    $dehyphen = false;
    # Retrieve the page text
    $page_text = $txt->GetAsText($dehyphen);

	// Simulating a full-text search engine that finds all occurrences of the word 'Federal'.
    // In a real application, plug in your own search engine here.
    $search_text = "Federal";
	$char_ranges = [];

	$ofs = strpos($page_text, $search_text);
	while ($ofs !== false) {
		$cr = new CharRange();
		$cr->index = $ofs;
		$cr->length = strlen($search_text);
		$char_ranges[] = $cr;
		$ofs = strpos($page_text, $search_text, $ofs + 1);
	}

	// Retrieve Highlights object and apply annotations to the page
	$hlts = $txt->GetHighlights($char_ranges);
	$hlts->Begin($doc);

	while ($hlts->HasNext()) {

		// In PHP bindings, quads are typically returned as an array
		$quads = $hlts->GetCurrentQuads();
		$quad_count = count($quads);

		for ($i = 0; $i < $quad_count; $i++) {

			// Each quad has 4 points: p1, p2, p3, p4
			$q = $quads[$i];

			$x1 = min($q->p1->x, $q->p2->x, $q->p3->x, $q->p4->x);
			$x2 = max($q->p1->x, $q->p2->x, $q->p3->x, $q->p4->x);
			$y1 = min($q->p1->y, $q->p2->y, $q->p3->y, $q->p4->y);
			$y2 = max($q->p1->y, $q->p2->y, $q->p3->y, $q->p4->y);

			$highlight = HighlightAnnot::Create(
				$doc->GetSDFDoc(),
				new Rect($x1, $y1, $x2, $y2)
			);

			$highlight->RefreshAppearance();
			$page->AnnotPushBack($highlight);

			printf("[%.2f, %.2f, %.2f, %.2f]\n", $x1, $y1, $x2, $y2);
		}

		$hlts->Next();
	}

	// Output highlighted PDF doc
	$doc->Save($output_path . "search_highlights.pdf", SDFDoc::e_linearized);
	
	$doc->Close();
	echo nl2br("Done.\n");

	PDFNet::Terminate();
?>
