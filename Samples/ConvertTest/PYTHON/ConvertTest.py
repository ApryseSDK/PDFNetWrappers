#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *
	
import platform

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to PDF, XPS, SVG, or EMF.
#
# Certain file formats such as XPS, EMF, PDF, and raster image formats can be directly 
# converted to PDF or XPS. Other formats are converted using a virtual driver. To check 
# if ToPDF (or ToXPS) require that PDFNet printer is installed use Convert.RequiresPrinter(filename). 
# The installing application must be run as administrator. The manifest for this sample 
# specifies appropriate the UAC elevation.
#
# Note: the PDFNet printer is a virtual XPS printer supported on Vista SP1 and Windows 7.
# For Windows XP SP2 or higher, or Vista SP0 you need to install the XPS Essentials Pack (or 
# equivalent redistributables). You can download the XPS Essentials Pack from:
#        http:#www.microsoft.com/downloads/details.aspx?FamilyId=B8DCFFDD-E3A5-44CC-8021-7649FD37FFEE&displaylang=en
# Windows XP Sp2 will also need the Microsoft Core XML Services (MSXML) 6.0:
#         http:#www.microsoft.com/downloads/details.aspx?familyid=993C0BCF-3BCF-4009-BE21-27E85E1857B1&displaylang=en
#
# Note: Convert.fromEmf and Convert.toEmf will only work on Windows and require GDI+.
#
# Please contact us if you have any questions.    
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
inputPath = "../../TestFiles/"
outputPath = "../../TestFiles/Output/"


# convert from a file to PDF automatically
def ConvertToPdfFromFile():
    testfiles = [
    [ "simple-word_2007.docx","docx2pdf.pdf", True],
    [ "simple-powerpoint_2007.pptx","pptx2pdf.pdf", True],
    [ "simple-excel_2007.xlsx","xlsx2pdf.pdf", True],
    [ "simple-publisher.pub","pub2pdf.pdf", True],
    # [ "simple-visio.vsd","vsd2pdf.pdf"],# requires Microsoft Office Visio
    [ "simple-text.txt","txt2pdf.pdf", True],
    [ "simple-rtf.rtf","rtf2pdf.pdf", True],
    [ "butterfly.png","png2pdf.pdf", False],
    [ "simple-emf.emf","emf2pdf.pdf", True],
    [ "simple-xps.xps","xps2pdf.pdf", False],
    # [ "simple-webpage.mht","mht2pdf.pdf", True],
    [ "simple-webpage.html","html2pdf.pdf", True]
    ]
    ret = 0

    if platform.system() == 'Windows':
        try:
            if ConvertPrinter.IsInstalled("PDFTron PDFNet"):
                ConvertPrinter.SetPrinterName("PDFTron PDFNet")
            elif not ConvertPrinter.isInstalled():
                try:
                    print("Installing printer (requires Windows platform and administrator)")
                    ConvertPrinter.Install()
                    print("Installed printer " + ConvertPrinter.getPrinterName())
                    # the function ConvertToXpsFromFile may require the printer so leave it installed
                    # uninstallPrinterWhenDone = true;
                except:
                    print("ERROR: Unable to install printer.")
        except:
            print("ERROR: Unable to install printer.")

    for testfile in testfiles:
        if platform.system() != 'Windows':
            if testfile[2]:
                continue
        try:
            pdfdoc = PDFDoc()
            inputFile = testfile[0]
            outputFile = testfile[1]
            if Convert.RequiresPrinter(inputPath + inputFile):
                print("Using PDFNet printer to convert file " + inputFile)
            Convert.ToPdf(pdfdoc, inputPath + inputFile)
            pdfdoc.Save(outputPath + outputFile, SDFDoc.e_compatibility)
            pdfdoc.Close()
            print("Converted file: " + inputFile + "\nto: " + outputFile)
        except:
            ret = 1
    return ret

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
        
        # Convert the EMF document to PDF
        if platform.system() == 'Windows':
            s1 = inputPath + "simple-emf.emf"
            print("Converting from EMF")
            Convert.FromEmf(pdfdoc, s1)
            outputFile = "emf2pdf v2.pdf"
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
    except:
        ret = 1
    return ret
def main():
    # The first step in every application using PDFNet is to initialize the 
    # library. The library is usually initialized only once, but calling 
    # Initialize() multiple times is also fine.
    PDFNet.Initialize()
    
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

    if platform.system() == 'Windows':
        try:
            print("Uninstalling printer (requires Windows platform and administrator)")
            ConvertPrinter.Uninstall()
            print("Uninstalled printer " + ConvertPrinter.getPrinterName())
        except:
            print("Unable to uninstall printer")

    print("Done.")
    
if __name__ == '__main__':
    main()
