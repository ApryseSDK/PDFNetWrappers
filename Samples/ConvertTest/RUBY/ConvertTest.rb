#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF::Convert utility class to convert 
# documents and files to PDF, XPS, or SVG, or EMF. The sample also shows how to convert MS Office files 
# using our built in conversion.
#
# Certain file formats such as XPS, EMF, PDF, and raster image formats can be directly 
# converted to PDF or XPS. 
#
# Please contact us if you have any questions.	
#
# Please contact us if you have any questions.    
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
$inputPath = "../../TestFiles/"
$outputPath = "../../TestFiles/Output/"


def ConvertSpecificFormats()
	ret = 0
	begin
		# Start with a PDFDoc to collect the converted documents
		pdfdoc = PDFDoc.new()
		s1 = $inputPath + "simple-xps.xps"
		
		puts "Converting from XPS"
		Convert.FromXps(pdfdoc, s1)
		outputFile = "xps2pdf v2.pdf"
		pdfdoc.Save($outputPath + outputFile, SDFDoc::E_remove_unused)
		puts "Saved " + outputFile

		# Convert the TXT document to PDF
		set =  ObjSet.new
		options = set.CreateDict()
		# Put options
		options.PutNumber("FontSize", 15)
		options.PutBool("UseSourceCodeFormatting", true)
		options.PutNumber("PageWidth", 12)
		options.PutNumber("PageHeight", 6)

		s1 = $inputPath + "simple-text.txt"
		puts "Converting from txt"
		Convert.FromText(pdfdoc, s1)
		outputFile = "simple-text.pdf"
		pdfdoc.Save($outputPath + outputFile, SDFDoc::E_remove_unused)
		puts("Saved " + outputFile)

		# Convert the two page PDF document to SVG
		outputFile = "pdf2svg v2.svg"
		pdfdoc = PDFDoc.new($inputPath + "newsletter.pdf")
		puts "Converting pdfdoc to SVG"
		Convert.ToSvg(pdfdoc, $outputPath + outputFile)
		puts "Saved " + outputFile
		
		# Convert the PNG image to XPS
		puts "Converting PNG to XPS"
		outputFile = "butterfly.xps"
		Convert.ToXps($inputPath + "butterfly.png", $outputPath + outputFile)
		puts "Saved " + outputFile
		
		# Convert PDF document to XPS
		puts "Converting PDF to XPS"
		outputFile = "newsletter.xps"
		Convert.ToXps($inputPath + "newsletter.pdf", $outputPath + outputFile)
		puts "Saved " + outputFile

		# Convert PDF document to HTML
		puts "Converting PDF to HTML"
		outputFile = "newsletter"
		Convert.ToHtml($inputPath + "newsletter.pdf", $outputPath + outputFile)
		puts "Saved newsletter as HTML"

		# Convert PDF document to EPUB
		puts "Converting PDF to EPUB"
		outputFile = "newsletter.epub"
		Convert.ToEpub($inputPath + "newsletter.pdf", $outputPath + outputFile)
		puts "Saved " + outputFile
		
		puts "Converting PDF to multipage TIFF"
		tiff_options = TiffOutputOptions.new
		tiff_options.SetDPI(200)
		tiff_options.SetDither(true)
		tiff_options.SetMono(true)
		Convert.ToTiff($inputPath + "newsletter.pdf", $outputPath + "newsletter.tiff", tiff_options)
		puts "Saved newsletter.tiff"

		pdfdoc = PDFDoc.new()
		puts "Converting SVG to PDF"
		Convert.FromSVG(pdfdoc, $inputPath + "tiger.svg")
		pdfdoc.Save($outputPath + "svg2pdf.pdf", SDFDoc::E_remove_unused)
		puts "Saved svg2pdf.pdf"
	rescue
		ret = 1
	end
	return ret
end

# convert from a file to PDF automatically
def ConvertToPdfFromFile()
	testfiles = [
		["simple-word_2007.docx","docx2pdf.pdf"],
		["simple-powerpoint_2007.pptx","pptx2pdf.pdf"],
		["simple-excel_2007.xlsx","xlsx2pdf.pdf"],
		["simple-text.txt","txt2pdf.pdf"],
		["butterfly.png", "png2pdf.pdf"],
		["simple-xps.xps", "xps2pdf.pdf"]
	]
	

	
	ret = 0
	for testfile in testfiles
		begin
			pdfdoc = PDFDoc.new()
			inputFile = testfile[0]
			outputFile = testfile[1]
			Printer.SetMode(Printer::E_prefer_builtin_converter)
			Convert.ToPdf(pdfdoc,  $inputPath + inputFile)
			pdfdoc.Save($outputPath + outputFile, SDFDoc::E_compatibility)
			pdfdoc.Close()
			puts "Converted file: " + inputFile + "\nto: " + outputFile
		rescue
			ret = 1
		end
	end
	
	return ret
end

	
def main()
	# The first step in every application using PDFNet is to initialize the 
	# library. The library is usually initialized only once, but calling 
	# Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)
	
	# Demonstrate Convert.ToPdf and Convert.Printer
	err = ConvertToPdfFromFile()
	if err == 1
		puts "ConvertFile failed"
	else
		puts "ConvertFile succeeded"
	end
	# Demonstrate Convert.[FromEmf, FromXps, ToEmf, ToSVG, ToXPS]
	err = ConvertSpecificFormats()
	if err == 1
		puts "ConvertSpecificFormats failed"
	else
		puts "ConvertSpecificFormats succeeded"
	end
	PDFNet.Terminate
	puts "Done."
end

main()
