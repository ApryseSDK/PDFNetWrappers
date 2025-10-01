#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# ---------------------------------------------------------------------------------------
# The following sample illustrates how to extract xlf from a PDF document for translation.
# It then applies a pre-prepared translated xlf file to the PDF to produce a translated PDF.
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

		# Open a PDF document to translate
		doc = PDFDoc.new($input_path + "find-replace-test.pdf")
		options = TransPDFOptions.new

		# Set the source language in the options
		options.SetSourceLanguage("en")

		# Set the number of pages to process in each batch
		options.SetBatchSize(20)

		# Optionally, subset the pages to process
		# This PDF only has a single page, but you can specify a subset of pages like this
		# options.SetPages("-2,5-6,9,11-")

		# Extract the xlf to file and field the PDF for translation
		TransPDF.ExtractXLIFF(doc, $output_path + "find-replace-test.xlf", options)

		# Save the fielded PDF
		doc.Save($output_path + "find-replace-test-fielded.pdf", SDFDoc::E_linearized)

		# The extracted xlf can be translated in a system of your choice.
		# In this sample a pre-prepared translated file is used - find-replace-test_(en_to_fr).xlf

		# Perform the translation using the pre-prepared translated xliff
		TransPDF.ApplyXLIFF(doc, $input_path + "find-replace-test_(en_to_fr).xlf", options)

		# Save the translated PDF
		doc.Save($output_path + "find-replace-test-fr.pdf", SDFDoc::E_linearized)
		doc.Close

	rescue => error
		puts "Unable to translate PDF document, error: " + error.message

	end

	PDFNet.Terminate
end

main()
