#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to make sure a file meets the PDF/UA standard, using the PDFUAConformance class object.
# Note: this feature is currently experimental and subject to change
#
# DataExtractionModule is required (Mac users can use StructuredOutputModule instead)
# https://docs.apryse.com/documentation/core/info/modules/#data-extraction-module
# https://docs.apryse.com/documentation/core/info/modules/#structured-output-module (Mac)
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

# DataExtraction library location, replace if desired, should point to a folder that includes the contents of <DataExtractionModuleRoot>/Lib.
# If using default, unzip the DataExtraction zip to the parent folder of Samples, and merge with existing "Lib" folder.
extraction_module_path = "../../../PDFNetC/Lib/"

def main()
	input_file1 = $input_path + "autotag_input.pdf"
	input_file2 = $input_path + "table.pdf"
	output_file1 = $output_path + "autotag_pdfua.pdf"
	output_file2 = $output_path + "table_pdfua_linearized.pdf"

	PDFNet.Initialize(PDFTronLicense.Key)

	puts "AutoConverting..."

	PDFNet.AddResourceSearchPath($extraction_module_path)

	if !DataExtractionModule.IsModuleAvailable(DataExtractionModule::e_DocStructure) then
		puts ""
		puts "Unable to run Data Extraction: PDFTron SDK Tabular Data module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Data Extraction suite is an optional add-on, available for download"
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
		PDFNet.Terminate
		return
	end

	begin
		pdf_ua = PDFUAConformance.new()

		puts "Simple Conversion..."

		# Perform conversion using default options
		pdf_ua.AutoConvert(input_file1, output_file1)

		puts "Converting With Options..."

		pdf_ua_opts = PDFUAOptions.new()
		pdf_ua_opts.SetSaveLinearized(true) # Linearize when saving output
		# Note: if file is password protected, you can use pdf_ua_opts.SetPassword()

		# Perform conversion using the options we specify
		pdf_ua.AutoConvert(input_file2, output_file2, pdf_ua_opts)

	rescue => error
		puts error.message
	end

	PDFNet.Terminate
	puts ""
	puts "PDFUAConformance test completed."
end

main()