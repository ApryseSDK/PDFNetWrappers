#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

# Relative path to the folder containing test files.
input_path = "../../TestFiles/OCR/"
output_path = "../../TestFiles/Output/"

# ---------------------------------------------------------------------------------------
# The following sample illustrates how to use OCR module
# --------------------------------------------------------------------------------------

def main():

    # The first step in every application using PDFNet is to initialize the
    # library and set the path to common PDF resources. The library is usually
    # initialized only once, but calling Initialize() multiple times is also fine.
    PDFNet.Initialize()

    # The location of the OCR Module
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/");

    if not OCRModule.IsModuleAvailable():

        print("""
        Unable to run OCRTest: PDFTron SDK OCR module not available.
        ---------------------------------------------------------------
        The OCR module is an optional add-on, available for download
        at http://www.pdftron.com/. If you have already downloaded this
        module, ensure that the SDK is able to find the required files
        using the PDFNet::AddResourceSearchPath() function.""")

    else:

        # Example 1) Process image without specifying options, default language - English - is used
        # --------------------------------------------------------------------------------

        # A) Setup empty destination doc

        doc = PDFDoc()

        # B) Run OCR on the .png with options

        OCRModule.ImageToPDF(doc, input_path + "psychomachia_excerpt.png", None)

        # C) Check the result

        doc.Save(output_path + "psychomachia_excerpt.pdf", 0)
        print("Example 1: psychomachia_excerpt.png")

        # Example 2) Process document using multiple languages
        # --------------------------------------------------------------------------------

        # A) Setup empty destination doc

        doc = PDFDoc()

        # B) Setup options with multiple target languages, English will always be considered as secondary language

        opts = OCROptions()
        opts.AddLang("rus")
        opts.AddLang("deu")

        # C) Run OCR on the .jpg with options

        OCRModule.ImageToPDF(doc, input_path + "multi_lang.jpg", opts)

        # D) Check the result

        doc.Save(output_path + "multi_lang.pdf", 0)
        print("Example 2: multi_lang.jpg")

        # Example 3) Process a .pdf specifying a language - German - and ignore zone comprising a sidebar image
        # --------------------------------------------------------------------------------

        # A) Open the .pdf document

        doc = PDFDoc(input_path + "german_kids_song.pdf")

        # B) Setup options with a single language and an ignore zone

        opts = OCROptions()
        opts.AddLang("deu")

        ignore_zones = RectCollection()
        ignore_zones.AddRect(Rect(424, 163, 493, 730))
        opts.AddIgnoreZonesForPage(ignore_zones, 1)

        # C) Run OCR on the .pdf with options

        OCRModule.ProcessPDF(doc, opts)

        # D) check the result

        doc.Save(output_path + "german_kids_song.pdf", 0)
        print("Example 3: german_kids_song.pdf")

        # Example 4) Process multi-page tiff with text/ignore zones specified for each page,
        # optionally provide English as the target language
        # --------------------------------------------------------------------------------

        # A) Setup empty destination doc

        doc = PDFDoc()

        # B) Setup options with a single language plus text/ignore zones

        opts = OCROptions()
        opts.AddLang("eng")

        ignore_zones = RectCollection()

        # ignore signature box in the first 2 pages
        ignore_zones.AddRect(Rect(1492, 56, 2236, 432))
        opts.AddIgnoreZonesForPage(ignore_zones, 1)

        opts.AddIgnoreZonesForPage(ignore_zones, 2)

        # can use a combination of ignore and text boxes to focus on the page area of interest,
        # as ignore boxes are applied first, we remove the arrows before selecting part of the diagram
        ignore_zones.Clear()
        ignore_zones.AddRect(Rect(992, 1276, 1368, 1372))
        opts.AddIgnoreZonesForPage(ignore_zones, 3)

        text_zones = RectCollection()
        # we only have text zones selected in page 3

        # select horizontal BUFFER ZONE sign
        text_zones.AddRect(Rect(900, 2384, 1236, 2480))

        # select right vertical BUFFER ZONE sign
        text_zones.AddRect(Rect(1960, 1976, 2016, 2296))
        # select Lot No.
        text_zones.AddRect(Rect(696, 1028, 1196, 1128))

        # select part of the plan inside the BUFFER ZONE
        text_zones.AddRect(Rect(428, 1484, 1784, 2344))
        text_zones.AddRect(Rect(948, 1288, 1672, 1476))
        opts.AddTextZonesForPage(text_zones, 3)

        # C) Run OCR on the .pdf with options

        OCRModule.ImageToPDF(doc, input_path + "bc_environment_protection.tif", opts)

        # D) check the result

        doc.Save(output_path + "bc_environment_protection.pdf", 0)
        print("Example 4: bc_environment_protection.tif")

        # Example 5) Alternative workflow for extracting OCR result JSON, postprocessing
        # (e.g., removing words not in the dictionary or filtering special
        # out special characters), and finally applying modified OCR JSON to the source PDF document
        # --------------------------------------------------------------------------------

        # A) Open the .pdf document

        doc = PDFDoc(input_path + "zero_value_test_no_text.pdf")

        # B) Run OCR on the .pdf with default English language

        json = OCRModule.GetOCRJsonFromPDF(doc, None)

        # C) Post-processing step (whatever it might be)

        print("Have OCR result JSON, re-applying to PDF")

        OCRModule.ApplyOCRJsonToPDF(doc, json)

        # D) Check the result

        doc.Save(output_path + "zero_value_test_no_text.pdf", 0)
        print("Example 5: extracting and applying OCR JSON from zero_value_test_no_text.pdf")

        # Example 6) The postprocessing workflow has also an option of extracting OCR results in XML format,
        # similar to the one used by TextExtractor
        # --------------------------------------------------------------------------------

        # A) Setup empty destination doc

        doc = PDFDoc()

        # B) Run OCR on the .tif with default English language, extracting OCR results in XML format. Note that
        # in the process we convert the source image into PDF.
        # We reuse this PDF document later to add hidden text layer to it.

        xml = OCRModule.GetOCRXmlFromImage(doc, input_path + "physics.tif", None)

        # C) Post-processing step (whatever it might be)

        print("Have OCR result XML, re-applying to PDF")

        OCRModule.ApplyOCRXmlToPDF(doc, xml)

        # D) Check the result

        doc.Save(output_path + "physics.pdf", 0)
        print("Example 6: extracting and applying OCR XML from physics.tif")

        # Example 7) Resolution can be manually set, when DPI missing from metadata or is wrong
        # --------------------------------------------------------------------------------

        # A) Setup empty destination doc

        doc = PDFDoc()

        # B) Setup options with a text zone

        opts = OCROptions()
        text_zones = RectCollection()
        text_zones.AddRect(Rect(140, 870, 310, 920))
        opts.AddTextZonesForPage(text_zones, 1)

        # C) Manually override DPI
        opts.AddDPI(100)

        # D) Run OCR on the .jpg with options
        OCRModule.ImageToPDF(doc, input_path + "corrupted_dpi.jpg", opts)

        # E) Check the result
        doc.Save(output_path + "corrupted_dpi.pdf", 0)
        print("Example 7: converting image with corrupted resolution metadata corrupted_dpi.jpg to pdf with searchable text")


if __name__ == '__main__':
    main()

