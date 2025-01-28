#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# ---------------------------------------------------------------------------------------
# The following sample illustrates how to use Advanced Imaging module
# --------------------------------------------------------------------------------------

def main()

  # Relative path to the folder containing the test files.
  inputPath = "../../TestFiles/AdvancedImaging/"
  outputPath = "../../TestFiles/Output/"

  # The first step in every application using PDFNet is to initialize the
  # library and set the path to common PDF resources. The library is usually
  # initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)
	
  # The location of the Advanced Imaging Module
  PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

  if !AdvancedImagingModule.IsModuleAvailable()
    puts ""
    puts "Unable to run AdvancedImagingTest: Apryse SDK Advanced Imaging module not available."
    puts "-----------------------------------------------------------------------------"
    puts "The Advanced Imaging module is an optional add-on, available for download"
    puts "at https://docs.apryse.com/documentation/core/info/modules/. If you have already"
    puts "downloaded this module, ensure that the SDK is able to find the required files"
    puts "using the PDFNet.AddResourceSearchPath() function."
    puts ""
  else
    begin
      inputFileName1 = "xray.dcm"
      outputFileName1 = inputFileName1 + ".pdf"
      doc1 = PDFDoc.new()
      Convert.FromDICOM(doc1, inputPath + inputFileName1, nil)
      doc1.Save(outputPath + outputFileName1, 0)
    rescue => error
      puts "Unable to convert DICOM test file, error: " + error.message
    end

    begin
      inputFileName2 = "jasper.heic"
      outputFileName2 = inputFileName2 + ".pdf"
      doc2 = PDFDoc.new()
      Convert.ToPdf(doc2, inputPath + inputFileName2)
      doc2.Save(outputPath + outputFileName2, 0)
    rescue => error
      puts "Unable to convert DICOM test file, error: " + error.message
    end

    begin
      inputFileName3 = "tiger.psd"
      outputFileName3 = inputFileName3 + ".pdf"
      doc3 = PDFDoc.new()
      Convert.ToPdf(doc3, inputPath + inputFileName3)
      doc3.Save(outputPath + outputFileName3, 0)
    rescue => error
      puts "Unable to convert the PSD test file, error: " + error.message
    end
        
    print("Done.")
  end

  PDFNet.Terminate
end

main()
