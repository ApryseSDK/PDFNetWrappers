#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2020 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# Relative path to the folder containing test files.
input_path =  "../../TestFiles/CAD/"
output_path = "../../TestFiles/Output/"

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use CAD module
#---------------------------------------------------------------------------------------

	# The first step in every application using PDFNet is to initialize the 
	# library and set the path to common PDF resources. The library is usually 
	# initialized only once, but calling Initialize multiple times is also fine.
	PDFNet.Initialize
	
	# The location of the CAD Module
	PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");
	
	begin  
		if !CADModule.IsModuleAvailable
			puts 'Unable to run CAD2PDFTest: PDFTron SDK CAD module not available.'
			puts '---------------------------------------------------------------'
			puts 'The CAD module is an optional add-on, available for download'
			puts 'at http://www.pdftron.com/. If you have already downloaded this'
			puts 'module, ensure that the SDK is able to find the required files'
			puts 'using the PDFNet::AddResourceSearchPath() function.'
		else
			inputFileName = "construction drawings color-28.05.18.dwg"
			outputFileName = inputFileName + ".pdf"
			doc = PDFDoc.new
			Convert.FromCAD(doc, input_path + inputFileName)
			doc.Save(output_path + outputFileName, 0)
			puts "CAD2PDF conversion example"
			doc.Close
		end
	rescue Exception=>e
		puts e

	end

