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
// This sample illustrates basic PDFNet capabilities related to interactive 
// forms (also known as AcroForms). 
//---------------------------------------------------------------------------------------

function RenameAllFields($doc, $name, $field_nums = 1)
{
	$itr = $doc->GetFieldIterator($name);
	for ($counter = 1; $itr->HasNext(); $itr = $doc->GetFieldIterator($name), ++$counter) {
		$f = $itr->Current();
		$tmp = (int)ceil($counter*1.0/$field_nums);
		$f->Rename($name."-".$tmp);

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

function CreateCustomButtonAppearance($doc, $button_down) 
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
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	//----------------------------------------------------------------------------------
	// Example 1: Programatically create new Form Fields and Widget Annotations.
	//----------------------------------------------------------------------------------

	$doc = new PDFDoc();

	// Create a blank new page and add some form fields.
	$blank_page = $doc->PageCreate();

	// Text Widget Creation 
	// Create an empty text widget with black text.
	$text1 = TextWidget::Create($doc, new Rect(110.0, 700.0, 380.0, 730.0));
	$text1->SetText("Basic Text Field");
	$text1->RefreshAppearance();
	$blank_page->AnnotPushBack($text1);
	// Create a vertical text widget with blue text and a yellow background.
	$text2 = TextWidget::Create($doc, new Rect(50.0, 400.0, 90.0, 730.0));
	$text2->SetRotation(90);
	// Set the text content.
	$text2->SetText("    ****Lucky Stars!****");
	// Set the font type, text color, font size, border color and background color.
	$text2->SetFont(Font::Create($doc->GetSDFDoc(), Font::e_helvetica_oblique));
	$text2->SetFontSize(28);
	$text2->SetTextColor(new ColorPt(0.0, 0.0, 1.0), 3);
	$text2->SetBorderColor(new ColorPt(0.0, 0.0, 0.0), 3);
	$text2->SetBackgroundColor(new ColorPt(1.0, 1.0, 0.0), 3);
	$text2->RefreshAppearance();
	// Add the annotation to the page.
	$blank_page->AnnotPushBack($text2);
	// Create two new text widget with Field names employee.name.first and employee.name.last
	// This logic shows how these widgets can be created using either a field name string or
	// a Field object
	$text3 = TextWidget::Create($doc, new Rect(110.0, 660.0, 380.0, 690.0), "employee.name.first");
	$text3->SetText("Levi");
	$text3->SetFont(Font::Create($doc->GetSDFDoc(), Font::e_times_bold));
	$text3->RefreshAppearance();
	$blank_page->AnnotPushBack($text3);
	$emp_last_name = $doc->FieldCreate("employee.name.last", Field::e_text, "Ackerman"); 
	$text4 = TextWidget::Create($doc, new Rect(110.0, 620.0, 380.0, 650.0), $emp_last_name);
	$text4->SetFont(Font::Create($doc->GetSDFDoc(), Font::e_times_bold));
	$text4->RefreshAppearance();
	$blank_page->AnnotPushBack($text4);

	// Signature Widget Creation (unsigned)
	$signature1 = SignatureWidget::Create($doc, new Rect(110.0, 560.0, 260.0, 610.0));
	$signature1->RefreshAppearance();
	$blank_page->AnnotPushBack($signature1);

	// CheckBox Widget Creation
	// Create a check box widget that is not checked.
	$check1 = CheckBoxWidget::Create($doc, new Rect(140.0, 490.0, 170.0, 520.0));
	$check1->RefreshAppearance();
	$blank_page->AnnotPushBack($check1);
	// Create a check box widget that is checked.
	$check2 = CheckBoxWidget::Create($doc, new Rect(190.0, 490.0, 250.0, 540.0), "employee.name.check1");
	$check2->SetBackgroundColor(new ColorPt(1.0, 1.0, 1.0), 3);
	$check2->SetBorderColor(new ColorPt(0.0, 0.0, 0.0), 3);
	// Check the widget (by default it is unchecked).
	$check2->SetChecked(true);
	$check2->RefreshAppearance();
	$blank_page->AnnotPushBack($check2);

	// PushButton Widget Creation
	$pushbutton1 = PushButtonWidget::Create($doc, new Rect(380.0, 490.0, 520.0, 540.0));
	$pushbutton1->SetTextColor(new ColorPt(1.0, 1.0, 1.0), 3);
	$pushbutton1->SetFontSize(36);
	$pushbutton1->SetBackgroundColor(new ColorPt(0.0, 0.0, 0.0), 3);
	// Add a caption for the pushbutton.
	$pushbutton1->SetStaticCaptionText("PushButton");
	$pushbutton1->RefreshAppearance();
	$blank_page->AnnotPushBack($pushbutton1);

	// ComboBox Widget Creation
	$combo1 = ComboBoxWidget::Create($doc, new Rect(280.0, 560.0, 580.0, 610.0));
	// Add options to the combobox widget.
	$combo1->AddOption("Combo Box No.1");
	$combo1->AddOption("Combo Box No.2");
	$combo1->AddOption("Combo Box No.3");
	// Make one of the options in the combo box selected by default.
	$combo1->SetSelectedOption("Combo Box No.2");
	$combo1->SetTextColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$combo1->SetFontSize(28);
	$combo1->RefreshAppearance();
	$blank_page->AnnotPushBack($combo1);

	// ListBox Widget Creation
	$list1 = ListBoxWidget::Create($doc, new Rect(400.0, 620.0, 580.0, 730.0));
	// Add one option to the listbox widget.
	$list1->AddOption("List Box No.1");
	// Add multiple options to the listbox widget in a batch.
	$list_options = array("List Box No.2", "List Box No.3");		
	$list1->AddOptions($list_options);
	// Select some of the options in list box as default options
	$list1->SetSelectedOptions($list_options);
	// Enable list box to have multi-select when editing. 
	$list1->GetField()->SetFlag(Field::e_multiselect, true);
	$list1->SetFont(Font::Create($doc->GetSDFDoc(), Font::e_times_italic));
	$list1->SetTextColor(new ColorPt(1.0, 0.0, 0.0), 3);
	$list1->SetFontSize(28);
	$list1->SetBackgroundColor(new ColorPt(1.0, 1.0, 1.0), 3);
	$list1->RefreshAppearance();
	$blank_page->AnnotPushBack($list1);

	// RadioButton Widget Creation
	// Create a radio button group and add three radio buttons in it. 
	$radio_group = RadioButtonGroup::Create($doc, "RadioGroup");
	$radiobutton1 = $radio_group->Add(new Rect(140.0, 410.0, 190.0, 460.0));
	$radiobutton1->SetBackgroundColor(new ColorPt(1.0, 1.0, 0.0), 3);
	$radiobutton1->RefreshAppearance();
	$radiobutton2 = $radio_group->Add(new Rect(310.0, 410.0, 360.0, 460.0));
	$radiobutton2->SetBackgroundColor(new ColorPt(0.0, 1.0, 0.0), 3);
	$radiobutton2->RefreshAppearance();
	$radiobutton3 = $radio_group->Add(new Rect(480.0, 410.0, 530.0, 460.0));
	// Enable the third radio button. By default the first one is selected
	$radiobutton3->EnableButton();
	$radiobutton3->SetBackgroundColor(new ColorPt(0.0, 1.0, 1.0), 3);
	$radiobutton3->RefreshAppearance();
	$radio_group->AddGroupButtonsToPage($blank_page);

	// Custom push button annotation creation
	$custom_pushbutton1 = PushButtonWidget::Create($doc, new Rect(260.0, 320.0, 360.0, 360.0));
	// Set the annotation appearance.
	$custom_pushbutton1->SetAppearance(CreateCustomButtonAppearance($doc, false), Annot::e_normal);
	// Create 'SubmitForm' action. The action will be linked to the button.
	$url = FileSpec::CreateURL($doc->GetSDFDoc(), "http://www.pdftron.com");
	$button_action = Action::CreateSubmitForm($url);
	// Associate the above action with 'Down' event in annotations action dictionary.
	$annot_action = $custom_pushbutton1->GetSDFObj()->PutDict("AA");
	$annot_action->Put("D", $button_action->GetSDFObj());
	$blank_page->AnnotPushBack($custom_pushbutton1);

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
        $field_names = array();
	for(; $itr->HasNext(); $itr->Next()) 
	{
		$cur_field_name = $itr->Current()->GetName();
		// Add one to the count for this field name for later processing
		if(isset($field_names [$cur_field_name])){
			$field_names [$cur_field_name] += 1;
		}
		else{
		    $field_names [$cur_field_name] = 1;
		}
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

        foreach($field_names as $key => $val){
		RenameAllFields($doc, $key, $val);
	}

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
	if (false) {
		$doc->FlattenAnnotations();
	}
	else // Manual flattening
	{			
			
		for ($pitr = $doc->GetPageIterator(); $pitr->HasNext(); $pitr->Next())  
		{
			$page = $pitr->Current();
			for ($i = (int)($page->GetNumAnnots())-1; $i>=0; --$i)
			{
				$annot = $page->GetAnnot($i);
				if ($annot->GetType() == Annot::e_Widget)
				{
					$annot->Flatten($page); 
				}
			}
		}
	}


	$doc->Save(($output_path."forms_test1_flattened.pdf"), 0);
	echo nl2br("Done.\n");	
?>
