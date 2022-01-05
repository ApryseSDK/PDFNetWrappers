#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to PowerPoint.
#
# The Structured Output module is an optional PDFNet Add-on that can be used to convert PDF
# and other documents into Word, Excel, PowerPoint and HTML format.
#
# The PDFTron SDK Structured Output module can be downloaded from
# https://www.pdftron.com/documentation/core/info/modules/
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

	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

	if !StructuredOutputModule.IsModuleAvailable() then
		puts ""
		puts "Unable to run the sample: PDFTron SDK Structured Output module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Structured Output module is an optional add-on, available for download"
		puts "at https://www.pdftron.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet::AddResourceSearchPath() function."
		puts ""
		return
	end
	
	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to PowerPoint
		puts "Converting PDF to PowerPoint"

		$outputFile = $outputPath + "paragraphs_and_tables.pptx"

		Convert.ToPowerPoint($inputPath + "paragraphs_and_tables.pdf", $outputFile)

		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to PowerPoint, error: " + error.message
	end

	#-----------------------------------------------------------------------------------
	
	begin
		# Convert PDF document to PowerPoint with options
		puts "Converting PDF to PowerPoint with options"

		$outputFile = $outputPath + "paragraphs_and_tables_first_page.pptx"

		$powerPointOutputOptions = Convert::PowerPointOutputOptions.new()

		# Convert only the first page
		$powerPointOutputOptions.SetPages(1, 1);

		Convert.ToPowerPoint($inputPath + "paragraphs_and_tables.pdf", $outputFile, $powerPointOutputOptions)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to PowerPoint, error: " + error.message
	end

	#-----------------------------------------------------------------------------------
	PDFNet.Terminate
	puts "Done."
end

main()
