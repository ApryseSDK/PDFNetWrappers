#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# Relative path to the folder containing test files.
$input_path = "../../TestFiles/HandwritingICR/"
$output_path = "../../TestFiles/Output/"

#---------------------------------------------------------------------------------------
# The Handwriting ICR Module is an optional PDFNet add-on that can be used to extract
# handwriting from image-based pages and apply them as hidden text.
#
# The Apryse SDK Handwriting ICR Module can be downloaded from https://dev.apryse.com/
#---------------------------------------------------------------------------------------

# The first step in every application using PDFNet is to initialize the 
# library and set the path to common PDF resources. The library is usually 
# initialized only once, but calling Initialize multiple times is also fine.
PDFNet.Initialize(PDFTronLicense.Key)

# The location of the Handwriting ICR Module
PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

begin

	# Test if the add-on is installed
	if !HandwritingICRModule.IsModuleAvailable
		puts 'Unable to run HandwritingICRTest: Apryse SDK Handwriting ICR Module'
		puts 'not available.'
		puts '---------------------------------------------------------------'
		puts 'The Handwriting ICR Module is an optional add-on, available for download'
		puts 'at https://dev.apryse.com/. If you have already downloaded this'
		puts 'module, ensure that the SDK is able to find the required files'
		puts 'using the PDFNet.AddResourceSearchPath() function.'

	else

		# --------------------------------------------------------------------------------
		# Example 1) Process a PDF without specifying options
		puts "Example 1: processing icr.pdf"

		# Open the .pdf document
		doc = PDFDoc.new($input_path + "icr.pdf")

		# Run ICR on the .pdf with the default options
		HandwritingICRModule.ProcessPDF(doc)

		# Save the result with hidden text applied
		doc.Save($output_path + "icr-simple.pdf", SDFDoc::E_linearized)
		doc.Close

		# --------------------------------------------------------------------------------
		# Example 2) Process a subset of PDF pages
		puts "Example 2: processing pages from icr.pdf"

		# Open the .pdf document
		doc = PDFDoc.new($input_path + "icr.pdf")

		# Process handwriting with custom options
		options = HandwritingICROptions.new

		# Optionally, process a subset of pages
		options.SetPages("2-3")

		# Run ICR on the .pdf
		HandwritingICRModule.ProcessPDF(doc, options)

		# Save the result with hidden text applied
		doc.Save($output_path + "icr-pages.pdf", SDFDoc::E_linearized)
		doc.Close

		# --------------------------------------------------------------------------------
		# Example 3) Ignore zones specified for each page
		puts "Example 3: processing & ignoring zones"

		# Open the .pdf document
		doc = PDFDoc.new($input_path + "icr.pdf")

		# Process handwriting with custom options
		options = HandwritingICROptions.new

		# Process page 2 by ignoring the signature area on the bottom
		options.SetPages("2")
		ignore_zones_page2 = RectCollection.new
		# These coordinates are in PDF user space, with the origin at the bottom left corner of the page.
		# Coordinates rotate with the page, if it has rotation applied.
		ignore_zones_page2.AddRect(Rect.new(78, 850.1 - 770, 340, 850.1 - 676))
		options.AddIgnoreZonesForPage(ignore_zones_page2, 2)

		# Run ICR on the .pdf
		HandwritingICRModule.ProcessPDF(doc, options)

		# Save the result with hidden text applied
		doc.Save($output_path + "icr-ignore.pdf", SDFDoc::E_linearized)
		doc.Close

		# --------------------------------------------------------------------------------
		# Example 4) The postprocessing workflow has also an option of extracting ICR results
		# in JSON format, similar to the one used by the OCR Module
		puts "Example 4: extract & apply"

		# Open the .pdf document
		doc = PDFDoc.new($input_path + "icr.pdf")

		# Extract ICR results in JSON format
		json = HandwritingICRModule.GetICRJsonFromPDF(doc)
		File.open($output_path + "icr-get.json", 'w') { |file| file.write(json) }

		# Insert your post-processing step (whatever it might be)
		# ...

		# Apply potentially modified ICR JSON to the PDF
		HandwritingICRModule.ApplyICRJsonToPDF(doc, json)

		# Save the result with hidden text applied
		doc.Save($output_path + "icr-get-apply.pdf", SDFDoc::E_linearized)
		doc.Close

		print("Done.")
	end

rescue => error
	puts "Unable to extract handwriting, error: " + error.message
end

PDFNet.Terminate
