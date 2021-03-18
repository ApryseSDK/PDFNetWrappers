<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

function AnnotationHighLevelAPI($doc) {
	// The following code snippet traverses all annotations in the document
	echo nl2br("Traversing all annotations in the document...\n");
	$page_num = 1;

	for ( $itr = $doc->GetPageIterator(); $itr->HasNext(); $itr->Next() ) {
		echo nl2br("Page ".$page_num++.": \n");

		$page = $itr->Current();
		$num_annots = $page->GetNumAnnots(); 
		
		for ($i=0; $i<$num_annots; ++$i) 
		{
			$annot = $page->GetAnnot($i);
			if (!$annot->IsValid()) continue;
			echo nl2br("Annot Type: ".$annot->GetSDFObj()->Get("Subtype")->Value()->GetName()."\n"); 

			$bbox = $annot->GetRect();
			echo nl2br("  Position: ".$bbox->x1.", ".$bbox->y1.", ".$bbox->x2.", ".$bbox->y2."\n");

			switch ($annot->GetType()) 
			{
			case Annot::e_Link: 
				{
					$link = new Link($annot);
					$action = $link->GetAction();
					if (!$action->IsValid()) continue;
					if ($action->GetType() == Action::e_GoTo) 
					{
						$dest = $action->GetDest();
						if (!$dest->IsValid()) {
							echo nl2br("  Destination is not valid\n");
						}
						else {
							$page_n = $dest->GetPage()->GetIndex();
							echo nl2br("  Links to: page number ".$page_n." in this document\n");
						}
					}
					else if ($action->GetType() == Action::e_URI) 
					{						
						$uri = $action->GetSDFObj()->Get("URI")->Value()->GetAsPDFText();
						echo nl2br("  Links to: ".$uri."\n");
					}
					// ...
				}
				break;
			case Annot::e_Widget:
				break; 
			case Annot::e_FileAttachment:
				break; 
				// ...
			default:
				break; 
			}
		}
	}
	
	// Use the high-level API to create new annotations.
	$first_page = $doc->GetPage(1);

	// Create a hyperlink...
	$hyperlink = Link::Create($doc->GetSDFDoc(), new Rect(85.0, 570.0, 503.0, 524.0), Action::CreateURI($doc->GetSDFDoc(), "http://www.pdftron.com"));
	$first_page->AnnotPushBack($hyperlink);

	// Create an intra-document link...
	$goto_page_3 = Action::CreateGoto(Destination::CreateFitH($doc->GetPage(3), 0));
	$link = Link::Create($doc->GetSDFDoc(), new Rect(85.0, 458.0, 503.0, 502.0), $goto_page_3);
	$link->SetColor(new ColorPt(0.0, 0.0, 1.0));

	// Add the new annotation to the first page
	$first_page->AnnotPushBack($link);

	// Create a stamp annotation ...
	$stamp = RubberStamp::Create($doc->GetSDFDoc(), new Rect(30.0, 30.0, 300.0, 200.0));
	$stamp->SetIcon("Draft");
	$first_page->AnnotPushBack($stamp);

	// Create a file attachment annotation (embed the 'peppers.jpg').
	global $input_path;
	$file_attach = FileAttachment::Create($doc->GetSDFDoc(), new Rect(80.0, 280.0, 108.0, 320.0), ($input_path."peppers.jpg"));
	$first_page->AnnotPushBack($file_attach);

	$ink = Ink::Create($doc->GetSDFDoc(), new Rect(110.0, 10.0, 300.0, 200.0));
	$pt3 = new Point(110.0, 10.0);
	$ink->SetPoint(0, 0, $pt3);
	$pt3->x = 150; $pt3->y = 50;
	$ink->SetPoint(0, 1, $pt3);
	$pt3->x = 190; $pt3->y = 60;
	$ink->SetPoint(0, 2, $pt3);
	$pt3->x = 180; $pt3->y = 90;
	$ink->SetPoint(1, 0, $pt3);
	$pt3->x = 190; $pt3->y = 95;
	$ink->SetPoint(1, 1, $pt3);
	$pt3->x = 200; $pt3->y = 100;
	$ink->SetPoint(1, 2, $pt3);
	$pt3->x = 166; $pt3->y = 86;
	$ink->SetPoint(2, 0, $pt3);
	$pt3->x = 196; $pt3->y = 96;
	$ink->SetPoint(2, 1, $pt3);
	$pt3->x = 221; $pt3->y = 121;
	$ink->SetPoint(2, 2, $pt3);
	$pt3->x = 288; $pt3->y = 188;
	$ink->SetPoint(2, 3, $pt3);
	$ink->SetColor(new ColorPt(0.0, 1.0, 1.0), 3);
	$first_page->AnnotPushBack($ink);


}

function AnnotationLowLevelAPI($doc) {
	$page = $doc->GetPageIterator()->Current();
	$annots = $page->GetAnnots();

	if (!$annots)
	{
		// If there are no annotations, create a new annotation 
		// array for the page.
		$annots = $doc->CreateIndirectArray();
		$page->GetSDFObj()->Put("Annots", $annots);
	}

	// Create a Text annotation
	$annot = $doc->CreateIndirectDict();
	$annot->PutName("Subtype", "Text");
	$annot->PutBool("Open", true);
	$annot->PutString("Contents", "The quick brown fox ate the lazy mouse.");
	$annot->PutRect("Rect", 266, 116, 430, 204);

	// Insert the annotation in the page annotation array
	$annots->PushBack($annot);	

	// Create a Link annotation
	$link1 = $doc->CreateIndirectDict();
	$link1->PutName("Subtype", "Link");
	$dest = Destination::CreateFit($doc->GetPage(2));
	$link1->Put("Dest", $dest->GetSDFObj());
	$link1->PutRect("Rect", 85, 705, 503, 661);
	$annots->PushBack($link1);

	// Create another Link annotation
	$link2 = $doc->CreateIndirectDict();
	$link2->PutName("Subtype", "Link");
	$dest2 = Destination::CreateFit($doc->GetPage(3));
	$link2->Put("Dest", $dest2->GetSDFObj());
	$link2->PutRect("Rect", 85, 638, 503, 594);
	$annots->PushBack($link2);

	// Note that PDFNet API can be used to modify existing annotations. 
	// In the following example we will modify the second link annotation 
	// (link2) so that it points to the 10th page. We also use a different 
	// destination page fit type.

	// $link2 = $annots->GetAt($annots->Size()-1);
	$link2->Put("Dest", Destination::CreateXYZ($doc->GetPage(10), 100, 792-70, 10)->GetSDFObj());

	// Create a third link annotation with a hyperlink action (all other 
	// annotation types can be created in a similar way)
	$link3 = $doc->CreateIndirectDict();
	$link3->PutName("Subtype", "Link");
	$link3->PutRect("Rect", 85, 570, 503, 524);

	// Create a URI action 
	$action = $link3->PutDict("A");
	$action->PutName("S", "URI");
	$action->PutString("URI", "http://www.pdftron.com");

	$annots->PushBack($link3);
}

function CreateTestAnnots($doc) {
	$ew = new ElementWriter();
	$eb = new ElementBuilder();

	$first_page= $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$doc->PagePushBack($first_page);
	$ew->Begin($first_page, ElementWriter::e_overlay, false );	// begin writing to this page
	$ew->End();  // save changes to the current page
	
	//
	// Test of a free text annotation.
	//
	$txtannot = FreeText::Create( $doc->GetSDFDoc(), new Rect(10.0, 400.0, 160.0, 570.0)  );
	$txtannot->SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air by freezing it with an angry glare."
				."\n\nAha!\n\nAnd there was much rejoicing!");
	$txtannot->SetBorderStyle( new BorderStyle( BorderStyle::e_solid, 1.0, 10.0, 20.0 ), false );
	$txtannot->SetQuaddingFormat(0);
	$first_page->AnnotPushBack($txtannot);
	$txtannot->RefreshAppearance();

	$txtannot = FreeText::Create( $doc->GetSDFDoc(), new Rect(100.0, 100.0, 350.0, 500.0)  );
	$txtannot->SetContentRect( new Rect( 200.0, 200.0, 350.0, 500.0 ) );
	$txtannot->SetContents("\n\nSome swift brown fox snatched a gray hare out of the air by freezing it with an angry glare."
			       ."\n\nAha!\n\nAnd there was much rejoicing!");
	$txtannot->SetCalloutLinePoints( new Point(200.0,300.0), new Point(150.0,290.0), new Point(110.0,110.0) );
	$txtannot->SetBorderStyle( new BorderStyle( BorderStyle::e_solid, 1.0, 10.0, 20.0 ), false );
	$txtannot->SetEndingStyle( LineAnnot::e_ClosedArrow );
	$txtannot->SetColor( new ColorPt( 0.0, 1.0, 0.0 ) );
	$txtannot->SetQuaddingFormat(1);
	$first_page->AnnotPushBack($txtannot);
	$txtannot->RefreshAppearance();

	$txtannot = FreeText::Create( $doc->GetSDFDoc(), new Rect(400.0, 10.0, 550.0, 400.0) );
	$txtannot->SetContents("\n\nSome swift brown fox snatched a gray hare out of the air by freezing it with an angry glare."
			     ."\n\nAha!\n\nAnd there was much rejoicing!");
	$txtannot->SetBorderStyle( new BorderStyle( BorderStyle::e_solid, 1.0, 10.0, 20.0 ), false );
	$txtannot->SetColor( new ColorPt( 0.0, 0.0, 1.0 ) );
	$txtannot->SetOpacity( 0.2 );
	$txtannot->SetQuaddingFormat(2);
	$first_page->AnnotPushBack($txtannot);
	$txtannot->RefreshAppearance();

	$page = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$doc->PagePushBack($page);
	$ew->Begin($page, ElementWriter::e_overlay, false );	// begin writing to this page
	$eb->Reset();			// Reset the GState to default
	$ew->End();  // save changes to the current page

	//Create a Line annotation...
	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect(250.0, 250.0, 400.0, 400.0));
	$line->SetStartPoint( new Point(350.0, 270.0) );
	$line->SetEndPoint( new Point(260.0,370.0) );
	$line->SetStartStyle(LineAnnot::e_Square);
	$line->SetEndStyle(LineAnnot::e_Circle);
	$line->SetColor(new ColorPt(0.3, 0.5, 0.0), 3);
	$line->SetContents( "Dashed Captioned" );
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->SetBorderStyle(new BorderStyle(BorderStyle::e_dashed, 2.0, 0.0, 0.0, array(2.0, 2.0)));
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect(347.0, 377.0, 600.0, 600.0));
	$line->SetStartPoint( new Point(385.0, 410.0) );
	$line->SetEndPoint( new Point(540.0,555.0) );
	$line->SetStartStyle(LineAnnot::e_Circle);
	$line->SetEndStyle(LineAnnot::e_OpenArrow);
	$line->SetColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$line->SetInteriorColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$line->SetContents("Inline Caption");
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Inline );
	$line->SetLeaderLineExtensionLength( -4.0 );
	$line->SetLeaderLineLength( -12.0 );
	$line->SetLeaderLineOffset( 2.0 );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect(10.0, 400.0, 200.0, 600.0));
	$line->SetStartPoint( new Point(25.0, 426.0) );
	$line->SetEndPoint( new Point(180.0,555.0) );
	$line->SetStartStyle(LineAnnot::e_Circle);
	$line->SetEndStyle(LineAnnot::e_Square);
	$line->SetColor(new ColorPt(0.0, 0.0, 1.0), 3);
	$line->SetInteriorColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$line->SetContents("Offset Caption");
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->SetTextHOffset( -60 );
	$line->SetTextVOffset( 10 );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect(200.0, 10.0, 400.0, 70.0));
	$line->SetStartPoint( new Point(220.0, 25.0) );
	$line->SetEndPoint( new Point(370.0,60.0) );
	$line->SetStartStyle(LineAnnot::e_Butt);
	$line->SetEndStyle(LineAnnot::e_OpenArrow);
	$line->SetColor(new ColorPt(0.0, 0.0, 1.0), 3);
	$line->SetContents("Regular Caption");
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect(200.0, 70.0, 400.0, 130.0));
	$line->SetStartPoint( new Point(220.0, 111.0) );
	$line->SetEndPoint( new Point(370.0,78.0) );
	$line->SetStartStyle(LineAnnot::e_Circle);
	$line->SetEndStyle(LineAnnot::e_Diamond);
	$line->SetContents("Circle to Diamond");
	$line->SetColor(new ColorPt(0.0, 0.0, 1.0), 3);
	$line->SetInteriorColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect(10.0, 100.0, 160.0, 200.0));
	$line->SetStartPoint( new Point(15.0, 110.0) );
	$line->SetEndPoint( new Point(150.0, 190.0) );
	$line->SetStartStyle(LineAnnot::e_Slash);
	$line->SetEndStyle(LineAnnot::e_ClosedArrow);
	$line->SetContents("Slash to CArrow");
	$line->SetColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$line->SetInteriorColor(new ColorPt(0.0, 1.0, 1.0), 3);
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);	
	
	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect( 270.0, 270.0, 570.0, 433.0 ));
	$line->SetStartPoint( new Point(300.0, 400.0 ) );
	$line->SetEndPoint( new Point(550.0, 300.0) );
	$line->SetStartStyle(LineAnnot::e_RClosedArrow);
	$line->SetEndStyle(LineAnnot::e_ROpenArrow);
	$line->SetContents("ROpen & RClosed arrows");
	$line->SetColor(new ColorPt(0.0, 0.0, 1.0), 3);
	$line->SetInteriorColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect( 195.0, 395.0, 205.0, 505.0 ));
	$line->SetStartPoint( new Point(200.0, 400.0 ) );
	$line->SetEndPoint( new Point(200.0, 500.0) );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect( 55.0, 299.0, 150.0, 301.0 ));
	$line->SetStartPoint( new Point(55.0, 300.0 ) );
	$line->SetEndPoint( new Point(155.0, 300.0) );
	$line->SetStartStyle(LineAnnot::e_Circle);
	$line->SetEndStyle(LineAnnot::e_Circle);
	$line->SetContents("Caption that's longer than its line.");
	$line->SetColor(new ColorPt(1.0, 0.0, 1.0), 3);
	$line->SetInteriorColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$line->SetShowCaption(true);
	$line->SetCaptionPosition( LineAnnot::e_Top );
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$line = LineAnnot::Create($doc->GetSDFDoc(), new Rect( 300.0, 200.0, 390.0, 234.0 ));
	$line->SetStartPoint( new Point(310.0, 210.0 ) );
	$line->SetEndPoint( new Point(380.0, 220.0) );
	$line->SetColor(new ColorPt(0.0, 0.0, 0.0), 3);
	$line->RefreshAppearance();
	$page->AnnotPushBack($line);

	$page3 = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$ew->Begin($page3);	// begin writing to the page
	$ew->End();  // save changes to the current page
	$doc->PagePushBack($page3);

	$circle = Circle::Create($doc->GetSDFDoc(), new Rect( 300.0, 300.0, 390.0, 350.0 ));
	$circle->SetColor(new ColorPt(0.0, 0.0, 0.0), 3);
	$circle->RefreshAppearance();
	$page3->AnnotPushBack($circle);

	$circle = Circle::Create($doc->GetSDFDoc(), new Rect( 100.0, 100.0, 200.0, 200.0 ));
	$circle->SetColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$circle->SetInteriorColor(new ColorPt(0.0, 0.0, 1.0), 3);
	$circle->SetBorderStyle( new BorderStyle( BorderStyle::e_dashed, 3.0, 0.0, 0.0, array(2.0, 4.0)) );
	$circle->SetPadding( 2.0 );
	$circle->RefreshAppearance();
	$page3->AnnotPushBack($circle);

	$sq = Square::Create( $doc->GetSDFDoc(), new Rect(10.0,200.0, 80.0, 300.0 ) );
    	$sq->SetColor(new ColorPt(0.0, 0.0, 0.0), 3);
    	$sq->RefreshAppearance();
    	$page3->AnnotPushBack( $sq );
	
	$sq = Square::Create( $doc->GetSDFDoc(), new Rect(500.0,200.0, 580.0, 300.0 ) );
	$sq->SetColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$sq->SetInteriorColor(new ColorPt(0.0, 1.0, 1.0), 3);
	$sq->SetBorderStyle( new BorderStyle( BorderStyle::e_dashed, 6.0, 0.0, 0.0, array(4.0, 2.0) ) );
	$sq->SetPadding( 4.0 );
	$sq->RefreshAppearance();
	$page3->AnnotPushBack( $sq );
    
	$poly = Polygon::Create($doc->GetSDFDoc(), new Rect(5.0, 500.0, 125.0, 590.0));
	$poly->SetColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$poly->SetInteriorColor(new ColorPt(1.0, 1.0, 0.0), 3);
	$poly->SetVertex(0, new Point(12.0,510.0) );
	$poly->SetVertex(1, new Point(100.0,510.0) );
	$poly->SetVertex(2, new Point(100.0,555.0) );
	$poly->SetVertex(3, new Point(35.0,544.0) );
	$poly->SetBorderStyle( new BorderStyle( BorderStyle::e_solid, 4.0, 0.0, 0.0 ) );
	$poly->SetPadding( 4.0 );
	$poly->RefreshAppearance();
	$page3->AnnotPushBack( $poly );

	$poly = PolyLine::Create($doc->GetSDFDoc(), new Rect(400.0, 10.0, 500.0, 90.0));
	$poly->SetColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$poly->SetInteriorColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$poly->SetVertex(0, new Point(405.0,20.0) );
	$poly->SetVertex(1, new Point(440.0,40.0) );
	$poly->SetVertex(2, new Point(410.0,60.0) );
	$poly->SetVertex(3, new Point(470.0,80.0) );
	$poly->SetBorderStyle( new BorderStyle( BorderStyle::e_solid, 2.0, 0.0, 0.0 ) );
	$poly->SetPadding( 4.0 );
	$poly->SetStartStyle( LineAnnot::e_RClosedArrow );
	$poly->SetEndStyle( LineAnnot::e_ClosedArrow );
	$poly->RefreshAppearance();
	$page3->AnnotPushBack( $poly );

	$lk = Link::Create( $doc->GetSDFDoc(), new Rect(5.0,5.0,55.0,24.0) );
	//$lk->SetColor( new ColorPt(0.0,1.0,0.0), 3.0 );
	$lk->RefreshAppearance();
	$page3->AnnotPushBack( $lk );

	$page4 = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$ew->Begin($page4);	// begin writing to the page
	$ew->End();  // save changes to the current page
	$doc->PagePushBack($page4);

	$ew->Begin( $page4 );
	$font = Font::Create($doc->GetSDFDoc(), Font::e_helvetica);
	$element = $eb->CreateTextBegin( $font, 16.0 );
	$element->SetPathFill(true);
	$ew->WriteElement($element);
	$element = $eb->CreateTextRun( "Some random text on the page", $font, 16.0 );
	$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 100.0, 500.0 );
	$ew->WriteElement($element);
	$ew->WriteElement( $eb->CreateTextEnd() );
	$ew->End();

	$hl = HighlightAnnot::Create( $doc->GetSDFDoc(), new Rect(100.0,490.0,150.0,515.0) );
	$hl->SetColor( new ColorPt(0.0,1.0,0.0), 3 );
	$hl->RefreshAppearance();
	$page4->AnnotPushBack( $hl );

	$sq = Squiggly::Create( $doc->GetSDFDoc(), new Rect(100.0,450.0,250.0,600.0) );
	$sq->SetQuadPoint( 0, new QuadPoint( new Point( 122.0,455.0), new Point(240.0, 545.0), new Point(230.0, 595.0), new Point(101.0,500.0 ) ) );
	$sq->RefreshAppearance();
	$page4->AnnotPushBack( $sq );

	$cr = Caret::Create( $doc->GetSDFDoc(), new Rect(100.0,40.0,129.0,69.0) );
	$cr->SetColor( new ColorPt(0.0,0.0,1.0), 3 );
	$cr->SetSymbol( "P" );
	$cr->RefreshAppearance();
	$page4->AnnotPushBack( $cr );

	$page5 = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$ew->Begin($page5);	// begin writing to the page
	$ew->End();  // save changes to the current page
	$doc->PagePushBack($page5);
	global $input_path;
	$fs = FileSpec::Create( $doc->GetSDFDoc(), $input_path."butterfly.png", false );
	$page6 = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$ew->Begin($page6);	// begin writing to the page
	$ew->End();  // save changes to the current page
	$doc->PagePushBack($page6);


	$txt = Text::Create( $doc->GetSDFDoc(), new Point(10.0, 20.0) );
	$txt->SetIcon( "UserIcon" );
	$txt->SetContents( "User defined icon, unrecognized by appearance generator" );
	$txt->SetColor( new ColorPt(0.0,1.0,0.0) );
	$txt->RefreshAppearance();
	$page6->AnnotPushBack( $txt );

	$ink = Ink::Create( $doc->GetSDFDoc(), new Rect( 100.0, 400.0, 200.0, 550.0 ) );
	$ink->SetColor( new ColorPt(0.0,0.0,1.0) );
	$ink->SetPoint( 1, 3, new Point( 220.0, 505.0) );
	$ink->SetPoint( 1, 0, new Point( 100.0, 490.0) );
	$ink->SetPoint( 0, 1, new Point( 120.0, 410.0) );
	$ink->SetPoint( 0, 0, new Point( 100.0, 400.0) );
	$ink->SetPoint( 1, 2, new Point( 180.0, 490.0) );
	$ink->SetPoint( 1, 1, new Point( 140.0, 440.0) );		
	$ink->SetBorderStyle( new BorderStyle( BorderStyle::e_solid, 3.0, 0.0, 0.0  ) );
	$ink->RefreshAppearance();
	$page6->AnnotPushBack( $ink );

	$page7 = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$ew->Begin($page7);	// begin writing to the page
	$ew->End();  // save changes to the current page
	$doc->PagePushBack($page7);

	$snd = Sound::Create( $doc->GetSDFDoc(), new Rect( 100.0, 500.0, 120.0, 520.0 ) );
	$snd->SetColor( new ColorPt(1.0,1.0,0.0) );
	$snd->SetIcon( Sound::e_Speaker );
	$snd->RefreshAppearance();
	$page7->AnnotPushBack( $snd );

	$snd = Sound::Create( $doc->GetSDFDoc(), new Rect( 200.0, 500.0, 220.0, 520.0 ) );
	$snd->SetColor( new ColorPt(1.0,1.0,0.0) );
	$snd->SetIcon( Sound::e_Mic );
	$snd->RefreshAppearance();
	$page7->AnnotPushBack( $snd );

	$page8 = $doc->PageCreate(new Rect(0.0, 0.0, 600.0, 600.0));
	$ew->Begin($page8);	// begin writing to the page
	$ew->End();  // save changes to the current page
	$doc->PagePushBack($page8);

	for( $ipage =0; $ipage < 2; ++$ipage ) {
		$px = 5;
		$py = 520;
		for( $istamp = RubberStamp::e_Approved; $istamp <= RubberStamp::e_Draft; $istamp = $istamp + 1 ) {
				$st = RubberStamp::Create( $doc->GetSDFDoc(), new Rect(1.0,1.0,100.0,100.0) );
				$st->SetIcon( $istamp );
				$st->SetContents( $st->GetIconName() );
				$st->SetRect( new Rect((double)$px, (double)$py, (double)$px+100.0, (double)$py+25.0 ) );
				$py -= 100;
				if( $py < 0 ) {
					$py = 520;
					$px += 200;
				}
				if( $ipage == 0 ) {
					//$page7->AnnotPushBack( $st );
				}
				else {
					$page8->AnnotPushBack( $st );
					$st->RefreshAppearance();
				}
		}
	}

	$st = RubberStamp::Create( $doc->GetSDFDoc(), new Rect(400.0,5.0,550.0,45.0) );
	$st->SetIcon( "UserStamp" );
	$st->SetContents( "User defined stamp" );
	$page8->AnnotPushBack( $st );
	$st->RefreshAppearance();
}
	
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	$doc = new PDFDoc($input_path."numbered.pdf");
	$doc->InitSecurityHandler();
	
	// An example of using SDF/Cos API to add any type of annotations.
	AnnotationLowLevelAPI($doc);
	$doc->Save($output_path."annotation_test1.pdf", SDFDoc::e_remove_unused);
	echo nl2br("Done. Results saved in annotation_test1.pdf\n");

	// An example of using the high-level PDFNet API to read existing annotations,
	// to edit existing annotations, and to create new annotation from scratch.
	AnnotationHighLevelAPI($doc);
	$doc->Save($output_path."annotation_test2.pdf", SDFDoc::e_linearized);
	echo nl2br("Done. Results saved in annotation_test2.pdf\n");

	// an example of creating various annotations in a brand new document
	$doc1 = new PDFDoc();
	CreateTestAnnots( $doc1 );
	$outfname = $output_path."new_annot_test_api.pdf";
	$doc1->Save($outfname, SDFDoc::e_linearized);
	echo nl2br("Saved new_annot_test_api.pdf\n");
	
    	$doc->Close();
?>
