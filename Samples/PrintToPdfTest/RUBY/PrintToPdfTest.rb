#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# Relative path to the folder containing test files.
input_path =  "../../TestFiles/"
output_path = "../../TestFiles/Output/"

#---------------------------------------------------------------------------------------
# The following sample illustrates how to convert documents to PDF format by printing
# them to the Apryse PDF printer via the Windows print verb, using the
# 'PrintToPdfModule' class.
#
# The PrintToPdf module is an optional PDFNet Add-on that can be used to convert any
# printable document into a PDF.
#
# The Apryse SDK PrintToPdf module can be downloaded from http://www.apryse.com/
#
# Note: The PrintToPdf module is only available on Windows.
#---------------------------------------------------------------------------------------

	# The first step in every application using PDFNet is to initialize the
	# library and set the path to common PDF resources. The library is usually
	# initialized only once, but calling Initialize multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)

	# The location of the PrintToPdf Module
	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

	begin
		if !PrintToPdfModule.IsModuleAvailable
			puts 'Unable to run PrintToPdfTest: Apryse SDK PrintToPdf module not available.'
			puts '---------------------------------------------------------------'
			puts 'The PrintToPdf module is an optional add-on, available for download'
			puts 'at http://www.apryse.com/. If you have already downloaded this'
			puts 'module, ensure that the SDK is able to find the required files'
			puts 'using the PDFNet::AddResourceSearchPath() function.'
		else
			inputFileName = "simple-word_2007.docx"
			outputFileName = inputFileName + ".pdf"

			doc = PDFDoc.new

			# Convert the document with some user options
			opts = PrintToPdfOptions.new
			opts.SetPageOrientation("portrait")
			opts.SetHorizontalPageMargin(18)
			opts.SetVerticalPageMargin(18)
			# Page width and height in points (1/72 of an inch).
			# If both are zero (default), letter paper size is used.
			# opts.SetPageWidth(612)
			# opts.SetPageHeight(792)

			PrintToPdfModule.PrintToPdf(doc, input_path + inputFileName, opts)
			doc.Save(output_path + outputFileName, SDFDoc::E_linearized)
			puts "Printed file: " + inputFileName
			puts "to: " + outputFileName
			doc.Close
		end
	rescue Exception=>e
		puts e

	end
	PDFNet.Terminate
	puts "PrintToPdf conversion example"
