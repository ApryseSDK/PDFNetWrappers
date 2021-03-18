#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#-----------------------------------------------------------------------------------
# The sample illustrates how to work with PDF page labels.
#
# PDF page labels can be used to describe a page. This is used to 
# allow for non-sequential page numbering or the addition of arbitrary 
# labels for a page (such as the inclusion of Roman numerals at the 
# beginning of a book). PDFNet PageLabel object can be used to specify 
# the numbering style to use (for example, upper- or lower-case Roman, 
# decimal, and so forth), the starting number for the first page,
# and an arbitrary prefix to be pre-appended to each number (for 
# example, "A-" to generate "A-1", "A-2", "A-3", and so forth.)
#-----------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

	# Initialize PDFNet
	PDFNet.Initialize
	
	#-----------------------------------------------------------
	# Example 1: Add page labels to an existing or newly created PDF
	# document.
	#-----------------------------------------------------------
	
	doc = PDFDoc.new(input_path + "newsletter.pdf")
	doc.InitSecurityHandler
	
	# Create a page labeling scheme that starts with the first page in 
	# the document (page 1) and is using uppercase roman numbering 
	# style. 
	L1 = PageLabel.Create(doc.GetSDFDoc, PageLabel::E_roman_uppercase, "My Prefix ", 1)
	doc.SetPageLabel(1, L1)
	
	# Create a page labeling scheme that starts with the fourth page in 
	# the document and is using decimal arabic numbering style. 
	# Also the numeric portion of the first label should start with number 
	# 4 (otherwise the first label would be "My Prefix 1").
	L2 = PageLabel.Create(doc.GetSDFDoc, PageLabel::E_decimal, "My Prefix ", 4)
	doc.SetPageLabel(4, L2)
	
	# Create a page labeling scheme that starts with the seventh page in 
	# the document and is using alphabetic numbering style. The numeric 
	# portion of the first label should start with number 1. 
	L3 = PageLabel.Create(doc.GetSDFDoc, PageLabel::E_alphabetic_uppercase, "My Prefix ", 1)
	doc.SetPageLabel(7, L3)
	
	doc.Save(output_path + "newsletter_with_pagelabels.pdf", SDFDoc::E_linearized)
	doc.Close
	puts "Done. Result saved in newsletter_with_pagelabels.pdf..."
	
	#-----------------------------------------------------------
	# Example 2: Read page labels from an existing PDF document.
	#-----------------------------------------------------------
	
	doc = PDFDoc.new(output_path + "newsletter_with_pagelabels.pdf")
	doc.InitSecurityHandler
	
	label = PageLabel.new
	page_num = doc.GetPageCount
	
	i = 1
	while i <= page_num do
		puts "Page number: " + i.to_s
		label = doc.GetPageLabel(i)
		
		if label.IsValid
			puts "Label: " + label.GetLabelTitle(i)
		else
			puts "No Label."
		end
		i = i + 1
	end
	
	doc.Close
			
	#-----------------------------------------------------------
	# Example 3: Modify page labels from an existing PDF document.
	#-----------------------------------------------------------
	
	doc = PDFDoc.new(output_path + "newsletter_with_pagelabels.pdf")
	doc.InitSecurityHandler
	
	# Remove the alphabetic labels from example i.
	doc.RemovePageLabel(7)
	
	# Replace the Prefix in the decimal labels (from example 1).
	label = doc.GetPageLabel(4)
	if label.IsValid
		label.SetPrefix("A")
		label.SetStart(1)
	end
		
	# Add a new label
	new_label = PageLabel.Create(doc.GetSDFDoc, PageLabel::E_decimal, "B", 1)
	doc.SetPageLabel(10, new_label)	# starting from page 10
	
	doc.Save(output_path + "newsletter_with_pagelabels_modified.pdf", SDFDoc::E_linearized)
	puts "Done. Result saved in newsletter_with_pagelabels_modified.pdf..."
	
	page_num = doc.GetPageCount
	i = 1
	while i <= page_num do
		puts "Page number: " + i.to_s
		label = doc.GetPageLabel(i)
		if label.IsValid
			puts "Label: " + label.GetLabelTitle(i)
		else
			puts "No Label."
		end
		i = i + 1
	end
	
	doc.Close
		
	#-----------------------------------------------------------
	# Example 4: Delete all page labels in an existing PDF document.
	#----------------------------------------------------------- 
	
	doc = PDFDoc.new(output_path + "newsletter_with_pagelabels.pdf")
	doc.GetRoot.Erase("PageLabels")
	doc.Save(output_path + "newsletter_with_pagelabels_removed.pdf", SDFDoc::E_linearized)
	
	doc.Close
