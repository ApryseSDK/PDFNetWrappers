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
// This sample illustrates basic PDFNet capabilities related to interactive 
// forms (also known as AcroForms). 
//---------------------------------------------------------------------------------------

function RenameAllFields($doc, $name)
{
	$itr = $doc->GetFieldIterator($name);
	for ($counter = 0; $itr->HasNext(); $itr = $doc->GetFieldIterator($name), ++$counter) {
		$f = $itr->Current();
		$f->Rename($name.$counter);
	}
}

// Note: The visual appearance of check-marks and radio-buttons in PDF documents is 
// not limited to CheckStyle-s. It is possible to create a visual appearance using 
// arbitrary glyph, text, raster image, or path object. Although most PDF producers 
// limit the options to the above 'standard' styles, using PDFNet you can generate 
// arbitrary appearances.

function CreateCheckmarkAppearance($doc) 
{
	// Create a checkmark appearance stream ------------------------------------
	$build = new ElementBuilder();
	$writer = new ElementWriter();
	$writer->Begin($doc->GetSDFDoc());
	$writer->WriteElement($build->CreateTextBegin());

	$symbol = "4";
	# other options are circle ("l"), diamond ("H"), cross ("\x35")
	# See section D.4 "ZapfDingbats Set and Encoding" in PDF Reference Manual for 
	# the complete graphical map for ZapfDingbats font.

	$checkmark = $build->CreateTextRun($symbol, Font::Create($doc->GetSDFDoc(), Font::e_zapf_dingbats), 1.0);
	$writer->WriteElement($checkmark);
	$writer->WriteElement($build->CreateTextEnd());

	$stm = $writer->End();
	$stm->PutRect("BBox", -0.2, -0.2, 1.0, 1.0); // Clip
	$stm->PutName("Subtype", "Form");
	return $stm;
}

function CreateButtonAppearance($doc, $button_down) 
{
	// Create a button appearance stream ------------------------------------
	$build = new ElementBuilder();
	$writer = new ElementWriter();
	$writer->Begin($doc->GetSDFDoc()); 

	// Draw background
	$element = $build->CreateRect(0, 0, 101, 37);
	$element->SetPathFill(true);
	$element->SetPathStroke(false);
	$element->GetGState()->SetFillColorSpace(ColorSpace::CreateDeviceGray());
	$element->GetGState()->SetFillColor(new ColorPt(0.75, 0.0, 0.0));
	$writer->WriteElement($element); 

	// Draw 'Submit' text
	$writer->WriteElement($build->CreateTextBegin()); 
	
	$text = "Submit";
	$element = $build->CreateTextRun($text, Font::Create($doc->GetSDFDoc(), Font::e_helvetica_bold), 12.0);
	$element->GetGState()->SetFillColor(new ColorPt(0.0, 0.0, 0.0));

	if ($button_down) 
		$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 33.0, 10.0);
	else 
		$element->SetTextMatrix(1.0, 0.0, 0.0, 1.0, 30.0, 13.0);
	$writer->WriteElement($element);
	
	$writer->WriteElement($build->CreateTextEnd());

	$stm = $writer->End(); 

	// Set the bounding box
	$stm->PutRect("BBox", 0, 0, 101, 37);
	$stm->PutName("Subtype","Form");
	return $stm;
}

	PDFNet::Initialize();

	//----------------------------------------------------------------------------------
	// Example 1: Programatically create new Form Fields and Widget Annotations.
	//----------------------------------------------------------------------------------

	$doc = new PDFDoc();
	$blank_page = $doc->PageCreate(); // Create a blank new page and add some form fields.

	// Create new fields.
	$emp_first_name = $doc->FieldCreate("employee.name.first", Field::e_text, "John", "");
	$emp_last_name = $doc->FieldCreate("employee.name.last", Field::e_text, "Doe", "");
	$emp_last_check1 = $doc->FieldCreate("employee.name.check1", Field::e_check, "Yes", "");

	$submit = $doc->FieldCreate("submit", Field::e_button);

	// Create page annotations for the above fields.

	// Create text annotations
	$annot1 = Widget::Create($doc->GetSDFDoc(), new Rect(50.0, 550.0, 350.0, 600.0), $emp_first_name);
	$annot2 = Widget::Create($doc->GetSDFDoc(), new Rect(50.0, 450.0, 350.0, 500.0), $emp_last_name);

	// Create a check-box annotation
	$annot3 = Widget::Create($doc->GetSDFDoc(), new Rect(64.0, 356.0, 120.0, 410.0), $emp_last_check1);
	// Set the annotation appearance for the "Yes" state...
	$annot3->SetAppearance(CreateCheckmarkAppearance($doc, Annot::e_normal, "Yes"));
		
	// Create button annotation
	$annot4 = Widget::Create($doc->GetSDFDoc(), new Rect(64.0, 284.0, 163.0, 320.0), $submit);
	// Set the annotation appearances for the down and up state...
	$annot4->SetAppearance(CreateButtonAppearance($doc, false), Annot::e_normal);
	$annot4->SetAppearance(CreateButtonAppearance($doc, true), Annot::e_down);
		
	// Create 'SubmitForm' action. The action will be linked to the button.
	$url = FileSpec::CreateURL($doc->GetSDFDoc(), "http://www.pdftron.com");
	$button_action = Action::CreateSubmitForm($url);

	// Associate the above action with 'Down' event in annotations action dictionary.
	$annot_action = $annot4->GetSDFObj()->PutDict("AA");
	$annot_action->Put("D", $button_action->GetSDFObj());

	$blank_page->AnnotPushBack($annot1);  // Add annotations to the page
	$blank_page->AnnotPushBack($annot2);
	$blank_page->AnnotPushBack($annot3);
	$blank_page->AnnotPushBack($annot4);

	$doc->PagePushBack($blank_page);	// Add the page as the last page in the document.

	// If you are not satisfied with the look of default auto-generated appearance 
	// streams you can delete "AP" entry from the Widget annotation and set 
	// "NeedAppearances" flag in AcroForm dictionary:
	//    $doc->GetAcroForm()->PutBool("NeedAppearances", true);
	// This will force the viewer application to auto-generate new appearance streams 
	// every time the document is opened.
	//
	// Alternatively you can generate custom annotation appearance using ElementWriter 
	// and then set the "AP" entry in the widget dictionary to the new appearance
	// stream.
	//
	// Yet another option is to pre-populate field entries with dummy text. When 
	// you edit the field values using PDFNet the new field appearances will match 
	// the old ones.

	$doc->RefreshFieldAppearances();

	$doc->Save($output_path."forms_test1.pdf", 0);
	echo "Done.\n";

	//----------------------------------------------------------------------------------
	// Example 2: 
	// Fill-in forms / Modify values of existing fields.
	// Traverse all form fields in the document (and print out their names). 
	// Search for specific fields in the document.
	//----------------------------------------------------------------------------------

	$doc = new PDFDoc($output_path."forms_test1.pdf");
	$doc->InitSecurityHandler();

	$itr = $doc->GetFieldIterator();

	for(; $itr->HasNext(); $itr->Next()) 
	{
		echo nl2br("Field name: ".$itr->Current()->GetName()."\n");
		echo nl2br("Field partial name: ".$itr->Current()->GetPartialName()."\n");

		echo "Field type: ";
		$type = $itr->Current()->GetType();
		$str_val = $itr->Current()->GetValueAsString();

		switch($type)
		{
		case Field::e_button: 
			echo nl2br("Button\n"); 
			break;
		case Field::e_radio: 
			echo nl2br("Radio button: Value = ".$str_val."\n"); 
			break;
		case Field::e_check: 
			$itr->Current()->SetValue(true);
			echo nl2br("Check box: Value = ".$str_val."\n"); 
			break;
		case Field::e_text: 
			{
				echo nl2br("Text\n");
				// Edit all variable text in the document
				$itr->Current()->SetValue("This is a new value. The old one was: ".$str_val);
			}
			break;
		case Field::e_choice: echo nl2br("Choice\n"); break;
		case Field::e_signature: echo nl2br("Signature\n"); break;
		}

		echo "------------------------------\n";
	}
	
	// Search for a specific field
	$f = $doc->GetField("employee.name.first");
	if ($f) 
	{
		echo nl2br("Field search for ".$f->GetName()." was successful\n");
	}
	else 
	{
		echo nl2br("Field search failed\n");
	}

	// Regenerate field appearances.
	$doc->RefreshFieldAppearances();
	$doc->Save(($output_path."forms_test_edit.pdf"), 0);
	echo nl2br("Done.\n");

	//----------------------------------------------------------------------------------
	// Sample: Form templating
	// Replicate pages and form data within a document. Then rename field names to make 
	// them unique.
	//----------------------------------------------------------------------------------
	
	// Sample: Copying the page with forms within the same document
	$doc = new PDFDoc($output_path."forms_test1.pdf");
	$doc->InitSecurityHandler();

	$src_page = $doc->GetPage(1);
	$doc->PagePushBack($src_page);  // Append several copies of the first page
	$doc->PagePushBack($src_page);	 // Note that forms are successfully copied
	$doc->PagePushBack($src_page);
	$doc->PagePushBack($src_page);

	// Now we rename fields in order to make every field unique.
	// You can use this technique for dynamic template filling where you have a 'master'
	// form page that should be replicated, but with unique field names on every page. 
	RenameAllFields($doc, "employee.name.first");
	RenameAllFields($doc, "employee.name.last");
	RenameAllFields($doc, "employee.name.check1");
	RenameAllFields($doc, "submit");

	$doc->Save($output_path."forms_test1_cloned.pdf", 0);
	echo nl2br("Done.\n");

	//----------------------------------------------------------------------------------
	// Sample: 
	// Flatten all form fields in a document.
	// Note that this sample is intended to show that it is possible to flatten
	// individual fields. PDFNet provides a utility function PDFDoc.FlattenAnnotations()
	// that will automatically flatten all fields.
	//----------------------------------------------------------------------------------
	$doc = new PDFDoc($output_path."forms_test1.pdf");
	$doc->InitSecurityHandler();

	// Traverse all pages
	if (true) {
		$doc->FlattenAnnotations();
	}
	else // Manual flattening
	{			
			
		for ($pitr = $doc->GetPageIterator(); $pitr->HasNext(); $pitr->Next())  
		{
			$page = $pitr->Current();
			$annots = $page->GetAnnots();
			if ($annots)
			{	// Look for all widget annotations (in reverse order)
				for ($i = ($annots->Size())-1; $i>=0; --$i)
				{
					if (!strcmp(annots.GetAt(i).Get("Subtype").Value().GetName(), "Widget"))
					{
						$field($annots->GetAt(i));
						$field->Flatten($page);

						// Another way of making a read only field is by modifying 
						// field's e_read_only flag: 
						//    field.SetFlag(Field::e_read_only, true);
					}
				}
			}
		}
	}

	$doc->Save(($output_path."forms_test1_flattened.pdf"), 0);
	echo nl2br("Done.\n");	
?>
