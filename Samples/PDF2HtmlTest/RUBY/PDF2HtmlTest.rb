#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to HTML.
#
# There are two HTML modules and one of them is an optional PDFNet Add-on.
# 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
#    documents.
# 2. The optional add-on module is used to convert PDF documents to HTML documents with
#    text flowing across the browser window.
#
# The PDFTron SDK HTML add-on module can be downloaded from http://www.pdftron.com/
#
# Please contact us if you have any questions.
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
$inputPath = "../../TestFiles/"
$outputPath = "../../TestFiles/Output/"
	
def main()
	# The first step in every application using PDFNet is to initialize the 
	# library. The library is usually initialized only once, but calling 
	# Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)

	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to HTML with fixed positioning option turned on (default)
		puts "Converting PDF to HTML with fixed positioning option turned on (default)"

		$outputFile = $outputPath + "paragraphs_and_tables_fixed_positioning"

		Convert.ToHtml($inputPath + "paragraphs_and_tables.pdf", $outputFile)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to HTML, error: " + error.message
	end

	#-----------------------------------------------------------------------------------

	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

	if !StructuredOutputModule.IsModuleAvailable() then
		puts ""
		puts "Unable to run part of the sample: PDFTron SDK Structured Output module not available."
		puts "-------------------------------------------------------------------------------------"
		puts "The Structured Output module is an optional add-on, available for download"
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet::AddResourceSearchPath() function."
		puts ""
		return
	end

	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to HTML with reflow full option turned on (1)
		puts "Converting PDF to HTML with reflow full option turned on (1)"

		$outputFile = $outputPath + "paragraphs_and_tables_reflow_full.html"

		$htmlOutputOptions = Convert::HTMLOutputOptions.new()

		# Set e_reflow_full content reflow setting
		$htmlOutputOptions.SetContentReflowSetting(Convert::HTMLOutputOptions::E_reflow_full)

		Convert.ToHtml($inputPath + "paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to HTML, error: " + error.message
	end

	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to HTML with reflow full option turned on (only converting the first page) (2)
		puts "Converting PDF to HTML with reflow full option turned on (only converting the first page) (2)"

		$outputFile = $outputPath + "paragraphs_and_tables_reflow_full_first_page.html"

		$htmlOutputOptions = Convert::HTMLOutputOptions.new()

		# Set e_reflow_full content reflow setting
		$htmlOutputOptions.SetContentReflowSetting(Convert::HTMLOutputOptions::E_reflow_full)

		# Convert only the first page
		$htmlOutputOptions.SetPages(1, 1)

		Convert.ToHtml($inputPath + "paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to HTML, error: " + error.message
	end

	#-----------------------------------------------------------------------------------
	PDFNet.Terminate
	puts "Done."
end

main()
