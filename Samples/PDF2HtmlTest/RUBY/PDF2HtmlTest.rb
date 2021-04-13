#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to HTML.
#
# There are two HTML modules and one of them is an optional PDFNet Add-on.
# 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
#    documents.
# 2. The optional add-on module is used to convert PDF documents to HTML documents with
#    text flowing within paragraphs.
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
	PDFNet.Initialize()

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

	if !PDF2HtmlReflowParagraphsModule.IsModuleAvailable() then
		puts ""
		puts "Unable to run part of the sample: PDFTron SDK HTML reflow paragraphs module not available."
		puts "---------------------------------------------------------------"
		puts "The HTML reflow paragraphs module is an optional add-on, available for download"
		puts "at http://www.pdftron.com/. If you have already downloaded this"
		puts "module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet::AddResourceSearchPath() function."
		puts ""
		return
	end

	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to HTML with reflow paragraphs option turned on (1)
		puts "Converting PDF to HTML with reflow paragraphs option turned on (1)"

		$outputFile = $outputPath + "paragraphs_and_tables_reflow_paragraphs.html"

		$htmlOutputOptions = Convert::HTMLOutputOptions.new()

		# Set e_reflow_paragraphs content reflow setting
		$htmlOutputOptions.SetContentReflowSetting(Convert::HTMLOutputOptions::E_reflow_paragraphs)

		Convert.ToHtml($inputPath + "paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to HTML, error: " + error.message
	end

	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to HTML with reflow paragraphs option turned on (2)
		puts "Converting PDF to HTML with reflow paragraphs option turned on (2)"

		$outputFile = $outputPath + "paragraphs_and_tables_reflow_paragraphs_no_page_width.html"

		$htmlOutputOptions = Convert::HTMLOutputOptions.new()

		# Set e_reflow_paragraphs content reflow setting
		$htmlOutputOptions.SetContentReflowSetting(Convert::HTMLOutputOptions::E_reflow_paragraphs)

		# Set to flow paragraphs across the entire browser window.
		$htmlOutputOptions.SetNoPageWidth(true)

		Convert.ToHtml($inputPath + "paragraphs_and_tables.pdf", $outputFile, $htmlOutputOptions)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to HTML, error: " + error.message
	end

	#-----------------------------------------------------------------------------------

	puts "Done."
end

main()
