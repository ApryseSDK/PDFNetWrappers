#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to Word.
#
# The Word module is an optional PDFNet Add-on that can be used to convert PDF
# documents into Word documents.
#
# The PDFTron SDK Word module can be downloaded from http://www.pdftron.com/
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

	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

	if !PDF2WordModule.IsModuleAvailable() then
		puts ""
		puts "Unable to run the sample: PDFTron SDK Word module not available."
		puts "---------------------------------------------------------------"
		puts "The Word module is an optional add-on, available for download"
		puts "at http://www.pdftron.com/. If you have already downloaded this"
		puts "module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet::AddResourceSearchPath() function."
		puts ""
		return
	end
	
	#-----------------------------------------------------------------------------------

	begin
		# Convert PDF document to Word
		puts "Converting PDF to Word"

		$outputFile = $outputPath + "paragraphs_and_tables.docx"

		Convert.ToWord($inputPath + "paragraphs_and_tables.pdf", $outputFile)

		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to Word, error: " + error.message
	end

	#-----------------------------------------------------------------------------------
	
	begin
		# Convert PDF document to Word with options
		puts "Converting PDF to Word with options"

		$outputFile = $outputPath + "paragraphs_and_tables_first_page.docx"

		$wordOutputOptions = Convert::WordOutputOptions.new()

		# Convert only the first page
		$wordOutputOptions.SetPages(1, 1);

		Convert.ToWord($inputPath + "paragraphs_and_tables.pdf", $outputFile, $wordOutputOptions)
		puts "Result saved in " + $outputFile
	rescue => error
		puts "Unable to convert PDF document to Word, error: " + error.message
	end

	#-----------------------------------------------------------------------------------

	puts "Done."
end

main()
