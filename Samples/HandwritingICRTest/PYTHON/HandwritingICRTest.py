#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

# Relative path to the folder containing test files.
input_path = "../../TestFiles/HandwritingICR/"
output_path = "../../TestFiles/Output/"

def WriteTextToFile(outputFile, text):
    # Write the contents of text to the disk
    f = open(outputFile, "w")
    try:
        f.write(text)
    finally:
        f.close()

# ---------------------------------------------------------------------------------------
# The Handwriting ICR Module is an optional PDFNet add-on that can be used to extract
# handwriting from image-based pages and apply them as hidden text.
#
# The Apryse SDK Handwriting ICR Module can be downloaded from https://dev.apryse.com/
# --------------------------------------------------------------------------------------

def main():

    # The first step in every application using PDFNet is to initialize the
    # library and set the path to common PDF resources. The library is usually
    # initialized only once, but calling Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)

    # The location of the Handwriting ICR Module
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

    # Test if the add-on is installed
    if not HandwritingICRModule.IsModuleAvailable():

        print("""
        Unable to run HandwritingICRTest: Apryse SDK Handwriting ICR Module
        not available.
        ---------------------------------------------------------------
        The Handwriting ICR Module is an optional add-on, available for download
        at https://dev.apryse.com/. If you have already downloaded this
        module, ensure that the SDK is able to find the required files
        using the PDFNet.AddResourceSearchPath() function.""")

    else:

        # --------------------------------------------------------------------------------
        # Example 1) Process a PDF without specifying options
        print("Example 1: processing icr.pdf")

        # Open the .pdf document
        doc = PDFDoc(input_path + "icr.pdf")

        # Run ICR on the .pdf with the default options
        HandwritingICRModule.ProcessPDF(doc)

        # Save the result with hidden text applied
        doc.Save(output_path + "icr-simple.pdf", SDFDoc.e_linearized)
        doc.Close()

        # --------------------------------------------------------------------------------
        # Example 2) Process a subset of PDF pages
        print("Example 2: processing pages from icr.pdf")

        # Open the .pdf document
        doc = PDFDoc(input_path + "icr.pdf")

        # Process handwriting with custom options
        options = HandwritingICROptions()
        
        # Optionally, process a subset of pages
        options.SetPages("2-3")

        # Run ICR on the .pdf
        HandwritingICRModule.ProcessPDF(doc, options)

        # Save the result with hidden text applied
        doc.Save(output_path + "icr-pages.pdf", SDFDoc.e_linearized)
        doc.Close()

        # --------------------------------------------------------------------------------
        # Example 3) Ignore zones specified for each page
        print("Example 3: processing & ignoring zones")

        # Open the .pdf document
        doc = PDFDoc(input_path + "icr.pdf")

        # Process handwriting with custom options
        options = HandwritingICROptions()
        
        # Process page 2 by ignoring the signature area on the bottom
        options.SetPages("2")
        ignore_zones_page2 = RectCollection()
        # These coordinates are in PDF user space, with the origin at the bottom left corner of the page.
        # Coordinates rotate with the page, if it has rotation applied.
        ignore_zones_page2.AddRect(Rect(78, 850.1 - 770, 340, 850.1 - 676))
        options.AddIgnoreZonesForPage(ignore_zones_page2, 2)

        # Run ICR on the .pdf
        HandwritingICRModule.ProcessPDF(doc, options)

        # Save the result with hidden text applied
        doc.Save(output_path + "icr-ignore.pdf", SDFDoc.e_linearized)
        doc.Close()

        # --------------------------------------------------------------------------------
        # Example 4) The postprocessing workflow has also an option of extracting ICR results
        # in JSON format, similar to the one used by the OCR Module
        print("Example 4: extract & apply")

        # Open the .pdf document
        doc = PDFDoc(input_path + "icr.pdf")

        # Extract ICR results in JSON format
        json = HandwritingICRModule.GetICRJsonFromPDF(doc)
        WriteTextToFile(output_path + "icr-get.json", json)

        # Insert your post-processing step (whatever it might be)
        # ...

        # Apply potentially modified ICR JSON to the PDF
        HandwritingICRModule.ApplyICRJsonToPDF(doc, json)

        # Save the result with hidden text applied
        doc.Save(output_path + "icr-get-apply.pdf", SDFDoc.e_linearized)
        doc.Close()

        print("Done.")

        PDFNet.Terminate()


if __name__ == '__main__':
    main()

