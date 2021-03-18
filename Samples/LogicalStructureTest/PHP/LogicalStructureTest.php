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
// This sample explores the structure and content of a tagged PDF document and dumps 
// the structure information to the console window.
//
// In tagged PDF documents StructTree acts as a central repository for information 
// related to a PDF document's logical structure. The tree consists of StructElement-s
// and ContentItem-s which are leaf nodes of the structure tree.
//
// The sample can be extended to access and extract the marked-content elements such 
// as text and images.
//---------------------------------------------------------------------------------------

function PrintIdent($ident) { echo nl2br("\n"); for ($i=0; $i<$ident; ++$i) echo "  "; }

// Used in code snippet 1.
function ProcessStructElement($element, $ident) 
{
	if (!$element->IsValid()) {
		return;
	}

	// Print out the type and title info, if any.
	PrintIdent($ident++);
	echo "Type: ".$element->GetType();
	if ($element->HasTitle()) {
		echo ". Title: ".$element->GetTitle();
	}

	$num = $element->GetNumKids();
	for ($i=0; $i<$num; ++$i) 
	{
		// Check is the kid is a leaf node (i.e. it is a ContentItem).
		if ($element->IsContentItem($i)) { 
			$cont = $element->GetAsContentItem($i); 
			$type = $cont->GetType();

			$page = $cont->GetPage();

			PrintIdent($ident);
			echo "Content Item. Part of page #".$page->GetIndex();

			PrintIdent($ident);
			switch ($type) {
				case ContentItem::e_MCID:
				case ContentItem::e_MCR:
					echo "MCID: ".$cont->GetMCID();
					break;
				case ContentItem::e_OBJR:
					{
						echo "OBJR ";
						if ($ref_obj = $cont->GetRefObj())
							echo "- Referenced Object#: ".$ref_obj->GetObjNum();
					}
					break;
				default: 
					break;
			}
		}
		else {  // the kid is another StructElement node.
			ProcessStructElement($element->GetAsStructElem($i), $ident);
		}
	}
}

// Used in code snippet 2.
function ProcessElements($reader) 
{
	while ($element = $reader->Next()) 	// Read page contents
	{
		// In this sample we process only paths & text, but the code can be 
		// extended to handle any element type.
		$type = $element->GetType();
		if ($type == Element::e_path || $type == Element::e_text || $type == Element::e_path) 
		{   
			switch ($type)	{
			case Element::e_path:				// Process path ...
				echo nl2br("\nPATH: ");
				break; 
			case Element::e_text: 				// Process text ...
				echo nl2br("\nTEXT: ".$element->GetTextString()."\n");
				break;
			case Element::e_form:				// Process form XObjects
				echo nl2br("\nFORM XObject: ");
				//$reader->FormBegin(); 
				//ProcessElements($reader);
				//$reader->End(); 
				break; 
			}

			// Check if the element is associated with any structural element.
			// Content items are leaf nodes of the structure tree.
			$struct_parent = $element->GetParentStructElement();
			if ($struct_parent->IsValid()) {
				// Print out the parent structural element's type, title, and object number.
				echo " Type: ".$struct_parent->GetType() 
					.", MCID: ".$element->GetStructMCID();
				if ($struct_parent->HasTitle()) {
					echo ". Title: ".$struct_parent->GetTitle();
				}
				echo ", Obj#: ".$struct_parent->GetSDFObj()->GetObjNum();
			}
		}
	}
}

// Used in code snippet 3.
function ProcessElements2($reader, &$mcid_page_map) 
{
	while (($element = $reader->Next()) != null) // Read page contents
	{
		// In this sample we process only text, but the code can be extended 
		// to handle paths, images, or any other Element type.
		$mcid = $element->GetStructMCID();
		if ($mcid>= 0 && $element->GetType() == Element::e_text) {
			$val = $element->GetTextString();
			$exist = array_key_exists($mcid, $mcid_page_map);
			if ($exist == true) {
				$mcid_page_map[$mcid] = $mcid_page_map[$mcid].$val;
			}
			else {
				$mcid_page_map[$mcid] = $val;
			}
		}
	}
}

// Used in code snippet 3.
function ProcessStructElement2($element, &$mcid_doc_map, $ident) 
{
	if (!$element->IsValid()) {
		return;
	}

	// Print out the type and title info, if any.
	PrintIdent($ident);
	echo "<".$element->GetType();
	if ($element->HasTitle()) {
		echo " title=\"".$element->GetTitle()."\"";
	}
	echo ">";

	$num = $element->GetNumKids();
	for ($i=0; $i<$num; ++$i) 
	{		
		if ($element->IsContentItem($i)) { 
			$cont = $element->GetAsContentItem($i); 
			if ($cont->GetType() == ContentItem::e_MCID) {
				$page_num = $cont->GetPage()->GetIndex();
				if (array_key_exists($page_num, $mcid_doc_map)) {
					$mcid_page_map = $mcid_doc_map[$page_num];
					if (array_key_exists($cont->GetMCID(), $mcid_page_map)) {
						echo $mcid_page_map[$cont->GetMCID()]; 
					}                    
				}
			}
		}
		else {  // the kid is another StructElement node.
			ProcessStructElement2($element->GetAsStructElem($i), $mcid_doc_map, $ident+1);
		}
	}

	PrintIdent($ident);
	echo "</".$element->GetType().">";
}

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// Extract logical structure from a PDF document

	$doc = new PDFDoc($input_path."tagged.pdf");
	$doc->InitSecurityHandler();

	echo nl2br("____________________________________________________________\n");
	echo nl2br("Sample 1 - Traverse logical structure tree...\n");

	$tree = $doc->GetStructTree();
	if ($tree->IsValid()) {
		echo nl2br("Document has a StructTree root.\n");

		for ($i=0; $i<$tree->GetNumKids(); ++$i) {
			// Recursively get structure info for all child elements.
			ProcessStructElement($tree->GetKid($i), 0);
		}
	}
	else {
		echo nl2br("This document does not contain any logical structure.\n");
	}

	echo nl2br("\nDone 1.\n");

	echo nl2br("____________________________________________________________\n");
	echo nl2br("Sample 2 - Get parent logical structure elements from\n");
	echo nl2br("layout elements.\n");
	
	$reader = new ElementReader();
	for ($itr = $doc->GetPageIterator(); $itr->HasNext(); $itr->Next()) {				
		$reader->Begin($itr->Current());
		ProcessElements($reader);
		$reader->End();
	}
	
	echo nl2br("\nDone 2.\n");

	echo nl2br("____________________________________________________________\n");
	echo nl2br("Sample 3 - 'XML style' extraction of PDF logical structure and page content.\n");
	
	$mcid_doc_map = array();
	$reader = new ElementReader();
	for ($itr = $doc->GetPageIterator(); $itr->HasNext(); $itr->Next()) {				
		$reader->Begin($itr->Current());
		$mcid_doc_map[$itr->Current()->GetIndex()] = array();
		ProcessElements2($reader, $mcid_doc_map[$itr->Current()->GetIndex()]);
		$reader->End();
	}
	$tree = $doc->GetStructTree();
	if ($tree->IsValid()) {
		for ($i=0; $i<$tree->GetNumKids(); ++$i) {
			ProcessStructElement2($tree->GetKid($i), $mcid_doc_map, 0);
		}
	}
	
	echo nl2br("\nDone 3.\n");	
	$doc->Save(($output_path ."LogicalStructure.pdf"), SDFDoc::e_linearized);
	$doc->Close();        
?>
