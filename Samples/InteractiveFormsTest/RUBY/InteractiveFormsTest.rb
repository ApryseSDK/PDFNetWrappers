#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

#---------------------------------------------------------------------------------------
# This sample illustrates basic PDFNet capabilities related to interactive 
# forms (also known as AcroForms). 
#---------------------------------------------------------------------------------------

# field_nums has to be greater than 0.
def RenameAllFields(doc, name, field_nums = 1)
	itr = doc.GetFieldIterator(name)
	counter = 1
	while itr.HasNext do
		f = itr.Current
		radio_counter = ((counter*1.0/field_nums).ceil).to_i
		f.Rename(name + "-" + radio_counter.to_s)

		itr = doc.GetFieldIterator(name)
		counter = counter + 1
	end
end


def CreateCustomButtonAppearance(doc, button_down)
	# Create a button appearance stream ------------------------------------
	build = ElementBuilder.new
	writer = ElementWriter.new
	writer.Begin(doc.GetSDFDoc)
	
	# Draw background
	element = build.CreateRect(0, 0, 101, 37)
	element.SetPathFill(true)
	element.SetPathStroke(false)
	element.GetGState.SetFillColorSpace(ColorSpace.CreateDeviceGray)
	element.GetGState.SetFillColor(ColorPt.new(0.75, 0, 0))
	writer.WriteElement(element)
	
	# Draw 'Submit' text
	writer.WriteElement(build.CreateTextBegin)
	text = "Submit"
	element = build.CreateTextRun(text, Font.Create(doc.GetSDFDoc, Font::E_helvetica_bold), 12)
	element.GetGState.SetFillColor(ColorPt.new(0, 0, 0))
	
	if button_down
		element.SetTextMatrix(1, 0, 0, 1, 33, 10)
	else
		element.SetTextMatrix(1, 0, 0, 1, 30, 13)
	end
	writer.WriteElement(element)
	
	writer.WritePlacedElement(build.CreateTextEnd)
	
	stm = writer.End
	
	# Set the bounding box
	stm.PutRect("BBox", 0, 0, 101, 37)
	stm.PutName("Subtype","Form")
	return stm
end


	PDFNet.Initialize	
	
	#----------------------------------------------------------------------------------
	# Example 1: Programatically create new Form Fields and Widget Annotations.
	#----------------------------------------------------------------------------------
	
	doc = PDFDoc.new

	# Create a blank new page and Add some form fields.
	blank_page = doc.PageCreate

	# Text Widget Creation 
	# Create an empty text widget with black text.
	text1 = TextWidget.Create(doc, Rect.new(110, 700, 380, 730))
	text1.SetText("Basic Text Field")
	text1.RefreshAppearance
	blank_page.AnnotPushBack(text1)
	# Create a vertical text widget with blue text and a yellow background.
	text2 = TextWidget.Create(doc, Rect.new(50, 400, 90, 730))
	text2.SetRotation(90)
	# Set the text content.
	text2.SetText("    ****Lucky Stars!****");
	# Set the font type, text color, font size, border color and background color.
	text2.SetFont(Font.Create(doc.GetSDFDoc, Font::E_helvetica_oblique))
	text2.SetFontSize(28)
	text2.SetTextColor(ColorPt.new(0, 0, 1), 3)
	text2.SetBorderColor(ColorPt.new(0, 0, 0), 3)
	text2.SetBackgroundColor(ColorPt.new(1, 1, 0), 3)
	text2.RefreshAppearance
	# Add the annotation to the page.
	blank_page.AnnotPushBack(text2)
	# Create two new text widget with Field names employee.name.first and employee.name.last
	# This logic shows how these widgets can be created using either a field name string or
	# a Field object
	text3 = TextWidget.Create(doc, Rect.new(110, 660, 380, 690), "employee.name.first")
	text3.SetText("Levi")
	text3.SetFont(Font.Create(doc.GetSDFDoc, Font::E_times_bold))
	text3.RefreshAppearance
	blank_page.AnnotPushBack(text3)
	emp_last_name = doc.FieldCreate("employee.name.last", Field::E_text, "Ackerman")
	text4 = TextWidget.Create(doc, Rect.new(110, 620, 380, 650), emp_last_name)
	text4.SetFont(Font.Create(doc.GetSDFDoc, Font::E_times_bold))
	text4.RefreshAppearance
	blank_page.AnnotPushBack(text4)

	# Signature Widget Creation (unsigned)
	signature1 = SignatureWidget.Create(doc, Rect.new(110, 560, 260, 610))
	signature1.RefreshAppearance
	blank_page.AnnotPushBack(signature1)

	# CheckBox Widget Creation
	# Create a check box widget that is not checked.
	check1 = CheckBoxWidget.Create(doc, Rect.new(140, 490, 170, 520))
	check1.RefreshAppearance
	blank_page.AnnotPushBack(check1)
	# Create a check box widget that is checked.
	check2 = CheckBoxWidget.Create(doc, Rect.new(190, 490, 250, 540), "employee.name.check1")
	check2.SetBackgroundColor(ColorPt.new(1, 1, 1), 3)
	check2.SetBorderColor(ColorPt.new(0, 0, 0), 3)
	# Check the widget (by default it is unchecked).
	check2.SetChecked(true)
	check2.RefreshAppearance
	blank_page.AnnotPushBack(check2)

	# PushButton Widget Creation
	pushbutton1 = PushButtonWidget.Create(doc, Rect.new(380, 490, 520, 540))
	pushbutton1.SetTextColor(ColorPt.new(1, 1, 1), 3)
	pushbutton1.SetFontSize(36)
	pushbutton1.SetBackgroundColor(ColorPt.new(0, 0, 0), 3)
	# Add a caption for the pushbutton.
	pushbutton1.SetStaticCaptionText("PushButton")
	pushbutton1.RefreshAppearance
	blank_page.AnnotPushBack(pushbutton1)

	# ComboBox Widget Creation
	combo1 = ComboBoxWidget.Create(doc, Rect.new(280, 560, 580, 610));
	# Add options to the combobox widget.
	combo1.AddOption("Combo Box No.1")
	combo1.AddOption("Combo Box No.2")
	combo1.AddOption("Combo Box No.3")
	# Make one of the options in the combo box selected by default.
	combo1.SetSelectedOption("Combo Box No.2")
	combo1.SetTextColor(ColorPt.new(1, 0, 0), 3)
	combo1.SetFontSize(28)
	combo1.RefreshAppearance
	blank_page.AnnotPushBack(combo1)

	# ListBox Widget Creation
	list1 = ListBoxWidget.Create(doc, Rect.new(400, 620, 580, 730))
	# Add one option to the listbox widget.
	list1.AddOption("List Box No.1")
	# Add multiple options to the listbox widget in a batch.
	list_options = ["List Box No.2", "List Box No.3"]
	list1.AddOptions(list_options)
	# Select some of the options in list box as default options
	list1.SetSelectedOptions(list_options)
	# Enable list box to have multi-select when editing. 
	list1.GetField().SetFlag(Field::E_multiselect, true)
	list1.SetFont(Font.Create(doc.GetSDFDoc,Font::E_times_italic))
	list1.SetTextColor(ColorPt.new(1, 0, 0), 3)
	list1.SetFontSize(28)
	list1.SetBackgroundColor(ColorPt.new(1, 1, 1), 3)
	list1.RefreshAppearance
	blank_page.AnnotPushBack(list1)

	# RadioButton Widget Creation
	# Create a radio button group and Add three radio buttons in it. 
	radio_group = RadioButtonGroup.Create(doc, "RadioGroup")
	radiobutton1 = radio_group.Add(Rect.new(140, 410, 190, 460))
	radiobutton1.SetBackgroundColor(ColorPt.new(1, 1, 0), 3)
	radiobutton1.RefreshAppearance
	radiobutton2 = radio_group.Add(Rect.new(310, 410, 360, 460))
	radiobutton2.SetBackgroundColor(ColorPt.new(0, 1, 0), 3)
	radiobutton2.RefreshAppearance
	radiobutton3 = radio_group.Add(Rect.new(480, 410, 530, 460))
	# Enable the third radio button. By default the first one is selected
	radiobutton3.EnableButton
	radiobutton3.SetBackgroundColor(ColorPt.new(0, 1, 1), 3)
	radiobutton3.RefreshAppearance
	radio_group.AddGroupButtonsToPage(blank_page)

	# Custom push button annotation creation
	custom_pushbutton1 = PushButtonWidget.Create(doc, Rect.new(260, 320, 360, 360))
	# Set the annotation appearance.
	custom_pushbutton1.SetAppearance(CreateCustomButtonAppearance(doc, false), Annot::E_normal)
	# Create 'SubmitForm' action. The action will be linked to the button.
	url = FileSpec.CreateURL(doc.GetSDFDoc, "http://www.pdftron.com")
	button_action = Action.CreateSubmitForm(url)
	# Associate the above action with 'Down' event in annotations action dictionary.
	annot_action = custom_pushbutton1.GetSDFObj.PutDict("AA")
	annot_action.Put("D", button_action.GetSDFObj)
	blank_page.AnnotPushBack(custom_pushbutton1)


	# Add the page as the last page in the document.
	doc.PagePushBack(blank_page)		
									 
	# If you are not satisfied with the look of default auto-generated appearance 
	# streams you can delete "AP" entry from the Widget annotation and set 
	# "NeedAppearances" flag in AcroForm dictionary:
	#	doc.GetAcroForm.PutBool("NeedAppearances", true);
	# This will force the viewer application to auto-generate new appearance streams 
	# every time the document is opened.
	#
	# Alternatively you can generate custom annotation appearance using ElementWriter 
	# and then set the "AP" entry in the widget dictionary to the new appearance
	# stream.
	#
	# Yet another option is to pre-populate field entries with dummy text. When 
	# you edit the field values using PDFNet the new field appearances will match 
	# the old ones.

	#doc.GetAcroForm.PutBool("NeedAppearances", true)
	doc.RefreshFieldAppearances
	
	doc.Save(output_path + "forms_test1.pdf", 0)
	doc.Close
	puts "Done."
	
	#----------------------------------------------------------------------------------
	# Example 2: 
	# Fill-in forms / Modify values of existing fields.
	# Traverse all form fields in the document (and  puts out their names). 
	# Search for specific fields in the document.
	#----------------------------------------------------------------------------------
	
	doc = PDFDoc.new(output_path + "forms_test1.pdf")
	doc.InitSecurityHandler
	
	itr = doc.GetFieldIterator
	field_names = Hash.new
	while itr.HasNext do

		cur_field_name = itr.Current.GetName
        	# Add one to the count for this field name for later processing
        	field_names[cur_field_name] = field_names.has_key?(cur_field_name) ? field_names[cur_field_name] + 1 : 1

		puts "Field name: " + itr.Current.GetName
		puts "Field partial name: " + itr.Current.GetPartialName
		
		print "Field type: "
		type = itr.Current.GetType
		str_val = itr.Current.GetValueAsString
		if type == Field::E_button
			puts "Button"
		elsif type == Field::E_radio
			puts "Radio button: Value = " + str_val
		elsif type == Field::E_check
			itr.Current.SetValue(true)
			puts "Check box: Value = " + str_val
		elsif type == Field::E_text
			puts "Text"
			# Edit all variable text in the document
			itr.Current.SetValue("This is a new value. The old one was: " + str_val)
		elsif type == Field::E_choice
			puts "Choice"
		elsif type == Field::E_signature
			puts "Signature"
		end
		puts "------------------------------"
		itr.Next
	end

	# Search for a specific field
	f = doc.GetField("employee.name.first")
	if !f.nil?
		puts "Field search for " + f.GetName + " was successful"
	else
		puts "Field search failed"
	end
		
	# Regenerate field appearances.
	doc.RefreshFieldAppearances
	doc.Save(output_path + "forms_test_edit.pdf", 0)
	doc.Close
	puts "Done."
	
	#----------------------------------------------------------------------------------
	# Sample: Form templating
	# Replicate pages and form data within a document. Then rename field names to make 
	# them unique.
	#----------------------------------------------------------------------------------
	
	# Sample: Copying the page with forms within the same document
	doc = PDFDoc.new(output_path + "forms_test1.pdf")
	doc.InitSecurityHandler
	
	src_page = doc.GetPage(1)
	doc.PagePushBack(src_page) # Append several copies of the first page
	doc.PagePushBack(src_page) # Note that forms are successfully copied
	doc.PagePushBack(src_page)
	doc.PagePushBack(src_page)
	
	# Now we rename fields in order to make every field unique.
	# You can use this technique for dynamic template filling where you have a 'master'
	# form page that should be replicated, but with unique field names on every page. 
	field_names.each do | key, val |
  		RenameAllFields(doc, key, val) 
	end
	doc.Save(output_path + "forms_test1_cloned.pdf", 0)
	doc.Close
	puts "Done."
	
	#----------------------------------------------------------------------------------
	# Sample: 
	# Flatten all form fields in a document.
	# Note that this sample is intended to show that it is possible to flatten
	# individual fields. PDFNet provides a utility function PDFDoc.FlattenAnnotations
	# that will automatically flatten all fields.
	#----------------------------------------------------------------------------------
	doc = PDFDoc.new(output_path + "forms_test1.pdf")
	doc.InitSecurityHandler
	 
	# Traverse all pages
	if false
		doc.FlattenAnnotations
	else # Manual flattening
		pitr = doc.GetPageIterator
		while pitr.HasNext do
			page = pitr.Current
			i = page.GetNumAnnots - 1
			while i >= 0
				annot = page.GetAnnot(i)
				if annot.GetType == Annot::E_Widget
					annot.Flatten(page)
				end
				i = i - 1
			end
			pitr.Next
		end
	end

	doc.Save(output_path + "forms_test1_flattened.pdf", 0)
	doc.Close
	puts "Done."
