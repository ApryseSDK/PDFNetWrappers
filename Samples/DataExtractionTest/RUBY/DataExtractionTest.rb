#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The Data Extraction suite is an optional PDFNet add-on collection that can be used to
# extract various types of data from PDF documents.
#
# The PDFTron SDK Data Extraction suite can be downloaded from
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

	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

	#-----------------------------------------------------------------------------------
	# The following sample illustrates how to extract tables from PDF documents.
	#-----------------------------------------------------------------------------------

	# Test if the add-on is installed
	if !DataExtractionModule.IsModuleAvailable(DataExtractionModule::E_Tabular) then
		puts ""
		puts "Unable to run Data Extraction: PDFTron SDK Tabular Data module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Data Extraction suite is an optional add-on, available for download"
		puts "at https://www.pdftron.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Extract tabular data as a JSON file
			puts "Extract tabular data as a JSON file"
	
			outputFile = $outputPath + "table.json"
			json = DataExtractionModule.ExtractData($inputPath + "table.pdf", DataExtractionModule::E_Tabular)
			File.open(outputFile, 'w') { |file| file.write(json) }
	
			puts "Result saved in " + outputFile
		rescue => error
			puts "Unable to extract tabular data, error: " + error.message
		end

		begin
			# Extract tabular data as an XLSX file
			puts "Extract tabular data as an XLSX file"
	
			outputFile = $outputPath + "table.xlsx"
			DataExtractionModule.ExtractToXSLX($inputPath + "table.pdf", outputFile)
	
			puts "Result saved in " + outputFile
		rescue => error
			puts "Unable to extract tabular data, error: " + error.message
		end

		begin
			# Extract tabular data as an XLSX stream (also known as filter)
			puts "Extract tabular data as an XLSX stream"
	
			outputFile = $outputPath + "table_streamed.xlsx"
			outputXlsxStream = Filters.MemoryFilter.new(0, false)
			options = DataExtractionOptions.new()
			options.SetPages("1") # page 1
			DataExtractionModule.ExtractToXSLX($inputPath + "table.pdf", outputXlsxStream, options)
			outputXlsxStream.SetAsInputFilter()
			outputXlsxStream.WriteToFile(outputFile, false)
	
			puts "Result saved in " + outputFile
		rescue => error
			puts "Unable to extract tabular data, error: " + error.message
		end
	end

	#-----------------------------------------------------------------------------------
	# The following sample illustrates how to extract document structure from PDF documents.
	#-----------------------------------------------------------------------------------

	# Test if the add-on is installed
	if !DataExtractionModule.IsModuleAvailable(DataExtractionModule::E_DocStructure) then
		puts ""
		puts "Unable to run Data Extraction: PDFTron SDK Structured Output module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Data Extraction suite is an optional add-on, available for download"
		puts "at https://www.pdftron.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Extract document structure as a JSON file
			puts "Extract document structure as a JSON file"
	
			outputFile = $outputPath + "paragraphs_and_tables.json"
			json = DataExtractionModule.ExtractData($inputPath + "paragraphs_and_tables.pdf", DataExtractionModule::E_DocStructure)
			File.open(outputFile, 'w') { |file| file.write(json) }
	
			puts "Result saved in " + outputFile
		rescue => error
			puts "Unable to extract document structure data, error: " + error.message
		end
	end

	#-----------------------------------------------------------------------------------
	# The following sample illustrates how to extract form fields from PDF documents.
	#-----------------------------------------------------------------------------------

	# Test if the add-on is installed
	if !DataExtractionModule.IsModuleAvailable(DataExtractionModule::E_Form) then
		puts ""
		puts "Unable to run Data Extraction: PDFTron SDK AIFormFieldExtractor module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Data Extraction suite is an optional add-on, available for download"
		puts "at https://www.pdftron.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Extract form fields as a JSON file
			puts "Extract form fields as a JSON file"
	
			outputFile = $outputPath + "formfield.json"
			json = DataExtractionModule.ExtractData($inputPath + "formfield.pdf", DataExtractionModule::E_Form)
			File.open(outputFile, 'w') { |file| file.write(json) }
	
			puts "Result saved in " + outputFile
		rescue => error
			puts "Unable to extract form fields data, error: " + error.message
		end
	end

	#-----------------------------------------------------------------------------------

	PDFNet.Terminate
	puts "Done."
end

main()
