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

# ---------------------------------------------------------------------------------------
# The Barcode Module is an optional PDFNet add-on that can be used to extract
# various types of barcodes from PDF documents.
#
# The Apryse SDK Barcode Module can be downloaded from http://dev.apryse.com/
# --------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/Barcode/"
output_path = "../../TestFiles/Output/"

def WriteTextToFile(output_file, text):
    # Write the contents of text to the disk
    f = open(output_file, "w")
    try:
        f.write(text)
    finally:
        f.close()

def main():

    # The first step in every application using PDFNet is to initialize the
    # library and set the path to common PDF resources. The library is usually
    # initialized only once, but calling Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)

    # The location of the Barcode Module
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

    if not BarcodeModule.IsModuleAvailable():

        print("""
        Unable to run BarcodeTest: Apryse SDK Barcode Module not available.
        ---------------------------------------------------------------
        The Barcode Module is an optional add-on, available for download
        at https://dev.apryse.com/. If you have already downloaded this
        module, ensure that the SDK is able to find the required files
        using the PDFNet.AddResourceSearchPath() function.""")

    else:

        # Example 1) Detect and extract all barcodes from a PDF document into a JSON file
        # --------------------------------------------------------------------------------

        print("Example 1: extracting barcodes from barcodes.pdf to barcodes.json")

        # A) Open the .pdf document
        doc = PDFDoc(input_path + "barcodes.pdf")

        # B) Detect PDF barcodes with the default options
        BarcodeModule.ExtractBarcodes(doc, output_path + "barcodes.json")

        doc.Close()

        # Example 2) Limit barcode extraction to a range of pages, and retrieve the JSON into a
        # local string variable, which is then written to a file in a separate function call
        # --------------------------------------------------------------------------------

        print("Example 2: extracting barcodes from pages 1-2 to barcodes_from_pages_1-2.json")

        # A) Open the .pdf document
        doc = PDFDoc(input_path + "barcodes.pdf")

        # B) Detect PDF barcodes with custom options
        options = BarcodeOptions()

        # Convert only the first two pages
        options.SetPages("1-2")

        json = BarcodeModule.ExtractBarcodesAsString(doc, options)

        # C) Save JSON to file
        WriteTextToFile(output_path + "barcodes_from_pages_1-2.json", json)

        doc.Close()

        # Example 3) Narrow down barcode types and allow the detection of both horizontal
        # and vertical barcodes
        # --------------------------------------------------------------------------------

        print("Example 3: extracting basic horizontal and vertical barcodes")

        # A) Open the .pdf document
        doc = PDFDoc(input_path + "barcodes.pdf")

        # B) Detect only basic 1D barcodes, both horizontal and vertical
        options = BarcodeOptions()

        # Limit extraction to basic 1D barcode types, such as EAN 13, EAN 8, UPCA, UPCE,
        # Code 3 of 9, Code 128, Code 2 of 5, Code 93, Code 11 and GS1 Databar.
        options.SetBarcodeSearchTypes(BarcodeOptions.e_barcode_group_linear)

        # Search for barcodes oriented horizontally and vertically
        options.SetBarcodeOrientations(
            BarcodeOptions.e_barcode_direction_horizontal |
            BarcodeOptions.e_barcode_direction_vertical)

        BarcodeModule.ExtractBarcodes(doc, output_path + "barcodes_1D.json", options)

        doc.Close()

    PDFNet.Terminate()
    print("Done.")


if __name__ == '__main__':
    main()

