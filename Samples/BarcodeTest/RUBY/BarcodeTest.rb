#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# ---------------------------------------------------------------------------------------
# The Barcode Module is an optional PDFNet add-on that can be used to extract
# various types of barcodes from PDF documents.
#
# The Apryse SDK Barcode Module can be downloaded from http://dev.apryse.com/
# --------------------------------------------------------------------------------------

# Relative path to the folder containing test files.
$input_path =  "../../TestFiles/Barcode/"
$output_path = "../../TestFiles/Output/"

def main()
	# The first step in every application using PDFNet is to initialize the 
	# library and set the path to common PDF resources. The library is usually 
	# initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)
	
	# The location of the Barcode Module
	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");
	
	begin  
		if !BarcodeModule.IsModuleAvailable

			puts 'Unable to run BarcodeTest: Apryse SDK Barcode Module not available.'
			puts '---------------------------------------------------------------'
			puts 'The Barcode Module is an optional add-on, available for download'
			puts 'at https://dev.apryse.com/. If you have already downloaded this'
			puts 'module, ensure that the SDK is able to find the required files'
			puts 'using the PDFNet.AddResourceSearchPath() function.'

		else

			# Example 1) Detect and extract all barcodes from a PDF document into a JSON file
			# --------------------------------------------------------------------------------

			# A) Open the .pdf document
			doc = PDFDoc.new($input_path + "barcodes.pdf")
	
			# B) Detect PDF barcodes with the default options
			BarcodeModule.ExtractBarcodes(doc, $output_path + "barcodes.json")

			puts "Example 1: extracting barcodes from barcodes.pdf to barcodes.json"

			doc.Close

			# Example 2) Limit barcode extraction to a range of pages, and retrieve the JSON into a
			# local string variable, which is then written to a file in a separate function call
			# --------------------------------------------------------------------------------

			# A) Open the .pdf document
			doc = PDFDoc.new($input_path + "barcodes.pdf")

			# B) Detect PDF barcodes with custom options
			options = BarcodeOptions.new

			# Convert only the first two pages
			options.SetPages("1-2")

			json = BarcodeModule.ExtractBarcodesAsString(doc, options)

			# C) Save JSON to file
			File.open($output_path + "barcodes_from_pages_1-2.json", 'w') { |file| file.write(json) }

			puts "Example 2: extracting barcodes from pages 1-2 to barcodes_from_pages_1-2.json"

			doc.Close

			# Example 3) Narrow down barcode types and allow the detection of both horizontal
			# and vertical barcodes
			# --------------------------------------------------------------------------------

			# A) Open the .pdf document
			doc = PDFDoc.new($input_path + "barcodes.pdf")

			# B) Detect only basic 1D barcodes, both horizontal and vertical
			options = BarcodeOptions.new

			# Limit extraction to basic 1D barcode types, such as EAN 13, EAN 8, UPCA, UPCE,
			# Code 3 of 9, Code 128, Code 2 of 5, Code 93, Code 11 and GS1 Databar.
			options.SetBarcodeSearchTypes(BarcodeOptions::E_barcode_group_linear)

			# Search for barcodes oriented horizontally and vertically
			options.SetBarcodeOrientations(
				BarcodeOptions::E_barcode_direction_horizontal |
				BarcodeOptions::E_barcode_direction_vertical)

			BarcodeModule.ExtractBarcodes(doc, $output_path + "barcodes_1D.json", options)

			puts "Example 3: extracting basic horizontal and vertical barcodes"

			doc.Close

		end
	rescue => error
		puts "Unable to extract barcodes, error: " + error.message

	end

	PDFNet.Terminate
	puts "Done."
end

main()
