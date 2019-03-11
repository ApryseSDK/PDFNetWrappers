#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
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

def RenameAllFields(doc, name)
	itr = doc.GetFieldIterator(name)
	counter = 0
	while itr.HasNext do
		f = itr.Current
		f.Rename(name + counter.to_s)
		itr = doc.GetFieldIterator(name)
		counter = counter + 1
	end
end

# Note: The visual appearance of check-marks and radio-buttons in PDF documents is 
# not limited to CheckStyle-s. It is possible to create a visual appearance using 
# arbitrary glyph, text, raster image, or path object. Although most PDF producers 
# limit the options to the above 'standard' styles, using PDFNet you can generate 
# arbitrary appearances.
def CreateCheckmarkAppearance(doc)
	# Create a checkmark appearance stream ------------------------------------
	build = ElementBuilder.new
	writer = ElementWriter.new
	writer.Begin(doc.GetSDFDoc)
	writer.WriteElement(build.CreateTextBegin)
	
	symbol = "4"
	# other options are circle ("l"), diamond ("H"), cross ("\x35")
	# See section D.4 "ZapfDingbats Set and Encoding" in PDF Reference Manual for 
	# the complete graphical map for ZapfDingbats font.
	checkmark = build.CreateTextRun(symbol, Font.Create(doc.GetSDFDoc, Font::E_zapf_dingbats), 1)
	writer.WriteElement(checkmark)
	writer.WriteElement(build.CreateTextEnd)
	
	stm = writer.End
	
	# Set the bounding box
	stm.PutRect("BBox", -0.2, -0.2, 1, 1)
	stm.PutName("Subtype","Form")
	return stm
end

def CreateButtonAppearance(doc, button_down)
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
	blank_page = doc.PageCreate  # Create a blank new page and add some form fields.
	
	# Create new fields.
	emp_first_name = doc.FieldCreate("employee.name.first", Field::E_text, "John", "")
	emp_last_name = doc.FieldCreate("employee.name.last", Field::E_text, "Doe", "")
	emp_last_check1 = doc.FieldCreate("employee.name.check1", Field::E_check, "Yes", "")
	
	submit = doc.FieldCreate("submit", Field::E_button)
	
	# Create page annotations for the above fields.
	
	# Create text annotations
	annot1 = Widget.Create(doc.GetSDFDoc, Rect.new(50, 550, 350, 600), emp_first_name)
	annot2 = Widget.Create(doc.GetSDFDoc, Rect.new(50, 450, 350, 500), emp_last_name)
	
	# Create a check-box annotation
	annot3 = Widget.Create(doc.GetSDFDoc, Rect.new(64, 356, 120, 410), emp_last_check1)
	# Set the annotation appearance for the "yes" state...
	annot3.SetAppearance(CreateCheckmarkAppearance(doc), Annot::E_normal, "Yes")
	
	# Create button annotation
	annot4 = Widget.Create(doc.GetSDFDoc, Rect.new(64, 284, 163, 320), submit)
	
	# Set the annotation appearances for the down and up state...
	annot4.SetAppearance(CreateButtonAppearance(doc, false), Annot::E_normal)
	annot4.SetAppearance(CreateButtonAppearance(doc, true), Annot::E_down)
	
	# Create 'SubmitForm' action. The action will be linked to the button.
	url = FileSpec.CreateURL(doc.GetSDFDoc, "http://www.pdftron.com")
	button_action = Action.CreateSubmitForm(url)
	
	# Associate the above action with 'Down' event in annotations action dictionary.
	annot_action = annot4.GetSDFObj.PutDict("AA")
	annot_action.Put("D", button_action.GetSDFObj)
	
	blank_page.AnnotPushBack(annot1) # Add annotations to the page
	blank_page.AnnotPushBack(annot2)
	blank_page.AnnotPushBack(annot3)
	blank_page.AnnotPushBack(annot4)  
	
	doc.PagePushBack(blank_page)	# Add the page as the last page in the document.					
									 
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
	# Traverse all form fields in the document (and print(out their names). 
	# Search for specific fields in the document.
	#----------------------------------------------------------------------------------
	
	doc = PDFDoc.new(output_path + "forms_test1.pdf")
	doc.InitSecurityHandler
	
	itr = doc.GetFieldIterator
	while itr.HasNext do
		puts "Field name:" + itr.Current.GetName
		puts "Field partial name: " + itr.Current.GetPartialName
		
		puts "Field type: "
		type = itr.Current.GetType
		str_val = itr.Current.GetValueAsString
		if type == Field::E_button
			puts "Button"
		elsif type == Field::E_radio
			puts " Radio button: Value = " + str_val
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
			puts "Signiture"
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
	RenameAllFields(doc, "employee.name.first")
	RenameAllFields(doc, "employee.name.last")
	RenameAllFields(doc, "employee.name.check1")
	RenameAllFields(doc, "submit")
	
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
			annots = page.GetAnnots
			if !annots.nil?
				# Look for all widget annotations (in reverse order)
				i = annots.Size- 1
				while i >= 0 do
					if annots.GetAt(i).Get("Subtype").Value.GetName == "Widget"
						field = Field.new(annots.GetAt(i))
						field.Flatten(page)
						
						# Another way of making a read only field is by modifying 
						# field's e_read_only flag: 
						# field.SetFlag(Field::E_read_only, true)
					end
					i = i - 1
				end
			end
			pitr.Next
		end
	end

	doc.Save(output_path + "forms_test1_flattened.pdf", 0)
	doc.Close
	puts "Done."
