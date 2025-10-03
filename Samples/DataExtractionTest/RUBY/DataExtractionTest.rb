#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
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
# https://docs.apryse.com/documentation/core/info/modules/
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
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Extract tabular data as a JSON file
			puts "Extract tabular data as a JSON file"
	
			outputFile = $outputPath + "table.json"
			DataExtractionModule.ExtractData($inputPath + "table.pdf", outputFile, DataExtractionModule::E_Tabular)

			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Extract tabular data as a JSON string
			puts "Extract tabular data as a JSON string"
	
			outputFile = $outputPath + "financial.json"
			json = DataExtractionModule.ExtractData($inputPath + "financial.pdf", DataExtractionModule::E_Tabular)
			File.open(outputFile, 'w') { |file| file.write(json) }
	
			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Extract tabular data as an XLSX file
			puts "Extract tabular data as an XLSX file"
	
			outputFile = $outputPath + "table.xlsx"
			DataExtractionModule.ExtractToXLSX($inputPath + "table.pdf", outputFile)
	
			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Extract tabular data as an XLSX stream (also known as filter)
			puts "Extract tabular data as an XLSX stream"
	
			outputFile = $outputPath + "financial.xlsx"
			outputXlsxStream = MemoryFilter.new(0, false)
			options = DataExtractionOptions.new()
			options.SetPages("1") # page 1
			DataExtractionModule.ExtractToXLSX($inputPath + "financial.pdf", outputXlsxStream, options)
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
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Extract document structure as a JSON file
			puts "Extract document structure as a JSON file"
	
			outputFile = $outputPath + "paragraphs_and_tables.json"
			DataExtractionModule.ExtractData($inputPath + "paragraphs_and_tables.pdf", outputFile, DataExtractionModule::E_DocStructure)

			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Extract document structure as a JSON string
			puts "Extract document structure as a JSON string"
	
			outputFile = $outputPath + "tagged.json"
			json = DataExtractionModule.ExtractData($inputPath + "tagged.pdf", DataExtractionModule::E_DocStructure)
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
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Extract form fields as a JSON file
			puts "Extract form fields as a JSON file"
	
			outputFile = $outputPath + "formfields-scanned.json"
			DataExtractionModule.ExtractData($inputPath + "formfields-scanned.pdf", outputFile, DataExtractionModule::E_Form)

			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Extract form fields as a JSON string
			puts "Extract form fields as a JSON string"
	
			outputFile = $outputPath + "formfields.json"
			json = DataExtractionModule.ExtractData($inputPath + "formfields.pdf", DataExtractionModule::E_Form)
			File.open(outputFile, 'w') { |file| file.write(json) }
	
			puts "Result saved in " + outputFile
			
			#-----------------------------------------------------------------------------------
			# Detect and add form fields to a PDF document.
			# PDF document already has form fields, and this sample will update to the new fields.
			puts "Extract document structure as a PDF file"
			doc = PDFDoc.new($inputPath + "formfields-scanned-withfields.pdf")
	
			outputFile = $outputPath + "formfields-scanned-fields-new.pdf"
			
			DataExtractionModule.DetectAndAddFormFieldsToPDF(doc)
			doc.Save(outputFile, SDFDoc::E_linearized);
			doc.Close

			puts "Result saved in " + outputFile

			#-----------------------------------------------------------------------------------
			# Detect and add form fields to a PDF document.
			# PDF document already has form fields, and this sample will keep the original fields.
			puts "Extract document structure as a PDF file"
			doc = PDFDoc.new($inputPath + "formfields-scanned-withfields.pdf")
	
			outputFile = $outputPath + "formfields-scanned-fields-old.pdf"
			
			options = DataExtractionOptions.new()
			options.SetOverlappingFormFieldBehavior("KeepOld")
			DataExtractionModule.DetectAndAddFormFieldsToPDF(doc, options)
			doc.Save(outputFile, SDFDoc::E_linearized);
			doc.Close

			puts "Result saved in " + outputFile


		rescue => error
			puts "Unable to extract form fields data, error: " + error.message
		end
	end

	#-----------------------------------------------------------------------------------
	# The following sample illustrates how to extract key-value pairs from PDF documents.
	#-----------------------------------------------------------------------------------

	# Test if the add-on is installed
	if !DataExtractionModule.IsModuleAvailable(DataExtractionModule::E_GenericKeyValue) then
		puts ""
		puts "Unable to run Data Extraction: PDFTron SDK AIFormFieldExtractor module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Data Extraction suite is an optional add-on, available for download"
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
        	puts "Extract key-value pairs from a PDF"
			# Simple example: Extract Keys & Values as a JSON file
			DataExtractionModule.ExtractData($inputPath + "newsletter.pdf", $outputPath + "newsletter_key_val.json", DataExtractionModule::E_GenericKeyValue)
			puts "Result saved in " + $outputPath + "newsletter_key_val.json"

			# Example with customized options:
			# Extract Keys & Values from pages 2-4, excluding ads
			options = DataExtractionOptions.new()
			options.SetPages("2-4")

			p2_exclusion_zones = RectCollection.new()
			# Exclude the ad on page 2
			# These coordinates are in PDF user space, with the origin at the bottom left corner of the page
			# Coordinates rotate with the page, if it has rotation applied.
			p2_exclusion_zones.AddRect(Rect.new(166, 47, 562, 222))
			options.AddExclusionZonesForPage(p2_exclusion_zones, 2)

			p4_inclusion_zones = RectCollection.new()
			p4_exclusion_zones = RectCollection.new()
			# Only include the article text for page 4, exclude ads and headings
			p4_inclusion_zones.AddRect(Rect.new(30, 432, 562, 684))
			p4_exclusion_zones.AddRect(Rect.new(30, 657, 295, 684))
			options.AddInclusionZonesForPage(p4_inclusion_zones, 4)
			options.AddExclusionZonesForPage(p4_exclusion_zones, 4)
			puts "Extract Key-Value pairs from specific pages and zones as a JSON file"
			DataExtractionModule.ExtractData($inputPath + "newsletter.pdf", $outputPath + "newsletter_key_val_with_zones.json", DataExtractionModule::E_GenericKeyValue, options)
			puts "Result saved in " + $outputPath + "newsletter_key_val_with_zones.json"

		rescue => error
			puts "Unable to extract form fields data, error: " + error.message
		end
	end

	#-----------------------------------------------------------------------------------
	# The following sample illustrates how to extract document classes from PDF documents.
	#-----------------------------------------------------------------------------------

	# Test if the add-on is installed
	if !DataExtractionModule.IsModuleAvailable(DataExtractionModule::E_DocClassification) then
		puts ""
		puts "Unable to run Data Extraction: PDFTron SDK Structured Output module not available."
		puts "-----------------------------------------------------------------------------"
		puts "The Data Extraction suite is an optional add-on, available for download"
		puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
		puts "downloaded this module, ensure that the SDK is able to find the required files"
		puts "using the PDFNet.AddResourceSearchPath() function."
		puts ""
	else
		begin
			# Simple example: classify pages as a JSON file
			puts "Classify pages as a JSON file"
	
			outputFile = $outputPath + "Invoice_Classified.json"
			DataExtractionModule.ExtractData($inputPath + "Invoice.pdf", outputFile, DataExtractionModule::E_DocClassification)

			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Classify pages as a JSON string
			puts "Classify pages as a JSON string"
	
			outputFile = $outputPath + "Scientific_Publication_Classified.json"
			json = DataExtractionModule.ExtractData($inputPath + "Scientific_Publication.pdf", DataExtractionModule::E_DocClassification)
			File.open(outputFile, 'w') { |file| file.write(json) }
	
			puts "Result saved in " + outputFile

			#------------------------------------------------------
			# Example with customized options:
			puts "Classify pages with customized options"
	
			options = DataExtractionOptions.new()
			# Classes that don't meet the minimum confidence threshold of 70% will not be listed in the output JSON
			options.SetMinimumConfidenceThreshold(0.7)
			outputFile = $outputPath + "Email_Classified.json"
			DataExtractionModule.ExtractData($inputPath + "Email.pdf", outputFile, DataExtractionModule::E_DocClassification, options)

			puts "Result saved in " + outputFile
			
		rescue => error
			puts "Unable to extract document structure data, error: " + error.message
		end
	end

	#-----------------------------------------------------------------------------------

	PDFNet.Terminate
	puts "Done."
end

main()
