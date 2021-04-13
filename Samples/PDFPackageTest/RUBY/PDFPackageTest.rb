#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#-----------------------------------------------------------------------------------
# This sample illustrates how to create, extract, and manipulate PDF Portfolios
# (a.k.a. PDF Packages) using PDFNet SDK.
#-----------------------------------------------------------------------------------

def AddPackage(doc, file, desc)
	files = NameTree.Create(doc.GetSDFDoc, "EmbeddedFiles")
	fs = FileSpec.Create(doc.GetSDFDoc, file, true)
	files.Put(file, file.length, fs.GetSDFObj)
	fs.SetDesc(desc)
	
	collection = doc.GetRoot.FindObj("Collection")
	if collection.nil?
		collection = doc.GetRoot.PutDict("Collection")
	end
	
	# You could here manipulate any entry in the Collection dictionary. 
	# For example, the following line sets the tile mode for initial view mode
	# Please refer to section '2.3.5 Collections' in PDF Reference for details.
	collection.PutName("View", "T")
end
	
def AddCoverPage(doc)
	# Here we dynamically generate cover page (please see ElementBuilder 
	# sample for more extensive coverage of PDF creation API).
	page = doc.PageCreate(Rect.new(0, 0, 200, 200))
	
	b = ElementBuilder.new
	w = ElementWriter.new
	
	w.Begin(page)
	font = Font.Create(doc.GetSDFDoc, Font::E_helvetica)
	w.WriteElement(b.CreateTextBegin(font, 12))
	e = b.CreateTextRun("My PDF Collection")
	e.SetTextMatrix(1, 0, 0, 1, 50, 96)
	e.GetGState.SetFillColorSpace(ColorSpace.CreateDeviceRGB)
	e.GetGState.SetFillColor(ColorPt.new(1, 0, 0))
	w.WriteElement(e)
	w.WriteElement(b.CreateTextEnd)
	w.End
	doc.PagePushBack(page)
	
	# Alternatively we could import a PDF page from a template PDF document
	# (for an example please see PDFPage sample project).
	# ...
end
	
	PDFNet.Initialize
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	# Create a PDF Package.
	doc = PDFDoc.new
	AddPackage(doc, input_path + "numbered.pdf", "My File 1")
	AddPackage(doc, input_path + "newsletter.pdf", "My Newsletter...")
	AddPackage(doc, input_path + "peppers.jpg", "An image")
	AddCoverPage(doc)
	doc.Save(output_path + "package.pdf", SDFDoc::E_linearized)
	doc.Close
	puts "Done."
	
	# Extract parts from a PDF Package
	doc = PDFDoc.new(output_path + "package.pdf")
	doc.InitSecurityHandler
	
	files = NameTree.Find(doc.GetSDFDoc, "EmbeddedFiles")
	if files.IsValid
		# Traverse the list of embedded files.
		i = files.GetIterator
		counter = 0
		while i.HasNext do
			entry_name = i.Key.GetAsPDFText
			puts "Part: " + entry_name
			file_spec = FileSpec.new(i.Value)
			stm = Filter.new(file_spec.GetFileData)
			if !stm.nil?
				stm.WriteToFile(output_path + "extract_" + counter.to_s + File.extname(entry_name), false)
			end
			i.Next
			counter = counter + 1
		end
	end
	doc.Close

	puts "Done."
