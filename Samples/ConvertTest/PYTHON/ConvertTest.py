#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *
	
import platform

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

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
inputPath = "../../TestFiles/"
outputPath = "../../TestFiles/Output/"



def ConvertSpecificFormats():
    ret = 0
    try: 
        # Start with a PDFDoc to collect the converted documents
        pdfdoc = PDFDoc()
        s1 = inputPath + "simple-xps.xps"
        
        # Convert the XPS document to PDF
        print("Converting from XPS")
        Convert.FromXps(pdfdoc, s1)
        outputFile = "xps2pdf v2.pdf"
        pdfdoc.Save(outputPath + outputFile, SDFDoc.e_remove_unused)
        print("Saved " + outputFile)
        

        # Convert the TXT document to PDF
        set =  ObjSet()
        options = set.CreateDict()
        # Put options
        options.PutNumber("FontSize", 15)
        options.PutBool("UseSourceCodeFormatting", True)
        options.PutNumber("PageWidth", 12)
        options.PutNumber("PageHeight", 6)
        s1 = inputPath + "simple-text.txt"
        print("Converting from txt")
        Convert.FromText(pdfdoc, s1)
        outputFile = "simple-text.pdf"
        pdfdoc.Save(outputPath + outputFile, SDFDoc.e_remove_unused)
        print("Saved " + outputFile)
        
        # Convert the two page PDF document to SVG
        outputFile = "pdf2svg v2.svg"
        pdfdoc = PDFDoc(inputPath + "newsletter.pdf")
        print("Converting pdfdoc to SVG")
        Convert.ToSvg(pdfdoc, outputPath + outputFile)
        print("Saved " + outputFile)
        
        # Convert the PNG image to XPS
        print("Converting PNG to XPS")
        outputFile = "butterfly.xps"
        Convert.ToXps(inputPath + "butterfly.png", outputPath +outputFile)
        print("Saved " + outputFile)
            
        # Convert PDF document to XPS
        print("Converting PDF to XPS")
        outputFile = "newsletter.xps"
        Convert.ToXps(inputPath + "newsletter.pdf", outputPath + outputFile)
        print("Saved " + outputFile)
        
        # Convert PDF document to HTML
        print("Converting PDF to HTML")
        outputFile = "newsletter"
        Convert.ToHtml(inputPath + "newsletter.pdf", outputPath + outputFile)
        print("Saved newsletter as HTML")

        # Convert PDF document to EPUB
        print("Converting PDF to EPUB")
        outputFile = "newsletter.epub"
        Convert.ToEpub(inputPath + "newsletter.pdf", outputPath + outputFile)
        print("Saved " + outputFile)

        print("Converting PDF to multipage TIFF")
        tiff_options = TiffOutputOptions()
        tiff_options.SetDPI(200)
        tiff_options.SetDither(True)
        tiff_options.SetMono(True)
        Convert.ToTiff(inputPath + "newsletter.pdf", outputPath + "newsletter.tiff", tiff_options)
        print("Saved newsletter.tiff")

        # Convert SVG file to PDF
        print("Converting SVG to PDF")
        pdfdoc = PDFDoc()
        Convert.FromSVG(pdfdoc, inputPath + "tiger.svg")
        pdfdoc.Save(outputPath + "svg2pdf.pdf", SDFDoc.e_remove_unused)
        print("Saved svg2pdf.pdf")

    except:
        ret = 1
    return ret

# convert from a file to PDF automatically
def ConvertToPdfFromFile():
    testfiles = [
    [ "simple-word_2007.docx","docx2pdf.pdf"],
    [ "simple-powerpoint_2007.pptx","pptx2pdf.pdf"],
    [ "simple-excel_2007.xlsx","xlsx2pdf.pdf"],
    [ "simple-text.txt","txt2pdf.pdf"],
    [ "butterfly.png","png2pdf.pdf"],
    [ "simple-xps.xps","xps2pdf.pdf"],
    ]
    ret = 0


    for testfile in testfiles:
        try:
            pdfdoc = PDFDoc()
            inputFile = testfile[0]
            outputFile = testfile[1]
            Printer.SetMode(Printer.e_prefer_builtin_converter);

            Convert.ToPdf(pdfdoc, inputPath + inputFile)
            pdfdoc.Save(outputPath + outputFile, SDFDoc.e_linearized)
            pdfdoc.Close()
            print("Converted file: " + inputFile + "\nto: " + outputFile)
        except:
            ret = 1
            print("ERROR: on input file " + inputFile)
    return ret


def main():
    # The first step in every application using PDFNet is to initialize the 
    # library. The library is usually initialized only once, but calling 
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)
    
    # Demonstrate Convert.ToPdf and Convert.Printer
    err = ConvertToPdfFromFile()
    if err:
        print("ConvertFile failed")
    else:
        print("ConvertFile succeeded")

    # Demonstrate Convert.[FromEmf, FromXps, ToEmf, ToSVG, ToXPS]
    err = ConvertSpecificFormats()
    if err:
        print("ConvertSpecificFormats failed")
    else:
        print("ConvertSpecificFormats succeeded")


    PDFNet.Terminate()
    print("Done.")
    
if __name__ == '__main__':
    main()
