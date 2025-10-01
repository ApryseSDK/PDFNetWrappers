#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# ---------------------------------------------------------------------------------------
# The following sample illustrates how to find and replace text in a PDF document.
# --------------------------------------------------------------------------------------

# Relative path to the folder containing test files.
$input_path =  "../../TestFiles/"
$output_path = "../../TestFiles/Output/"

def main()
	# The first step in every application using PDFNet is to initialize the 
	# library and set the path to common PDF resources. The library is usually 
	# initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)
	
	begin  
		# Open a PDF document to edit
		doc = PDFDoc.new($input_path + "find-replace-test.pdf")
		options = FindReplaceOptions.new

		# Set some find/replace options
		options.SetWholeWords(true)
		options.SetMatchCase(true)
		options.SetMatchMode(FindReplaceOptions::E_exact)
		options.SetReflowMode(FindReplaceOptions::E_para)
		options.SetAlignment(FindReplaceOptions::E_left)

		# Perform a Find/Replace finding "the" with "THE INCREDIBLE"
		FindReplace.FindReplaceText(doc, "the", "THE INCREDIBLE", options)

		# Save the edited PDF
		doc.Save($output_path + "find-replace-test-replaced.pdf", SDFDoc::E_linearized)

	rescue => error
		puts "Unable to perform Find and Replace, error: " + error.message

	end

	PDFNet.Terminate
end

main()
