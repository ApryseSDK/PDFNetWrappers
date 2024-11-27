#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
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
# The following sample illustrates how to convert to PDF with virtual printer on Windows.
# It supports several input formats like docx, xlsx, rtf, txt, html, pub, emf, etc. For more details, visit 
# https://docs.apryse.com/documentation/windows/guides/features/conversion/convert-other/
#
# To check if ToPDF (or ToXPS) require that PDFNet printer is installed use Convert::RequiresPrinter(filename). 
# The installing application must be run as administrator. The manifest for this sample 
# specifies appropriate the UAC elevation.
#
# Note: the PDFNet printer is a virtual XPS printer supported on Vista SP1 and Windows 7.
# For Windows XP SP2 or higher, or Vista SP0 you need to install the XPS Essentials Pack (or 
# equivalent redistributables). You can download the XPS Essentials Pack from:
#		http://www.microsoft.com/downloads/details.aspx?FamilyId=B8DCFFDD-E3A5-44CC-8021-7649FD37FFEE&displaylang=en
# Windows XP Sp2 will also need the Microsoft Core XML Services (MSXML) 6.0:
# 		http://www.microsoft.com/downloads/details.aspx?familyid=993C0BCF-3BCF-4009-BE21-27E85E1857B1&displaylang=en
#
# Note: Convert.fromEmf and Convert.toEmf will only work on Windows and require GDI+.
#
# Please contact us if you have any questions.	
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
inputPath = "../../TestFiles/"
outputPath = "../../TestFiles/Output/"



def ConvertSpecificFormats():
    ret = 0
    try:
        # Convert MSWord document to XPS
        print("Converting DOCX to XPS")
        outputFile = "simple-word_2007.xps"
        Convert.ToXps(inputPath + "simple-word_2007.docx", outputPath + outputFile)
        print("Saved " + outputFile)
    except:
        ret = 1

    try:
        # Start with a PDFDoc to collect the converted documents
        pdfdoc = PDFDoc() 
        # Convert the EMF document to PDF
        s1 = inputPath + "simple-emf.emf"
        print("Converting from EMF")
        Convert.FromEmf(pdfdoc, s1)
        outputFile = "emf2pdf v2.pdf"
        pdfdoc.Save(outputPath + outputFile, SDFDoc.e_remove_unused)
        print("Saved " + outputFile)
    except:
        ret = 1
    return ret

# convert from a file to PDF automatically
def ConvertToPdfFromFile():
    testfiles = [
    [ "simple-word_2007.docx","docx2pdf.pdf"],
    [ "simple-powerpoint_2007.pptx","pptx2pdf.pdf"],
    [ "simple-excel_2007.xlsx","xlsx2pdf.pdf"],
    [ "simple-publisher.pub","pub2pdf.pdf"],
    [ "simple-text.txt","txt2pdf.pdf"],
    [ "simple-rtf.rtf","rtf2pdf.pdf"],
    [ "simple-emf.emf","emf2pdf.pdf"],
    [ "simple-webpage.mht","mht2pdf.pdf"],
    [ "simple-webpage.html","html2pdf.pdf"]
    ]
    ret = 0

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
            print("ERROR: on input file " + inputFile)
    return ret


def main():
    if platform.system() == 'Windows':
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

        try:
            print("Uninstalling printer (requires Windows platform and administrator)")
            ConvertPrinter.Uninstall()
            print("Uninstalled printer " + ConvertPrinter.getPrinterName())
        except:
            print("Unable to uninstall printer")

        PDFNet.Terminate()
        print("Done.")
    else:
        print("ConvertPrintTest only available on Windows")

if __name__ == '__main__':
    main()
