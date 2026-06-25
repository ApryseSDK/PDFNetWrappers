#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the Office.DOCXCompare utility class to
# compare two MS Word (DOCX) documents and produce a new DOCX document containing the
# differences between them as tracked changes.
#
# This comparison is performed entirely within the PDFNet and has *no* external or
# system dependencies -- Comparison results will be the same whether on Windows,
# Linux or Android.
#
# Please contact us if you have any questions.
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
$inputPath = "../../TestFiles/"
$outputPath = "../../TestFiles/Output/"

# Provide your own original and revised versions of a DOCX document here.
$original_filename = "SYH_Letter.docx"
$revised_filename = "SYH_Letter_revision2.docx"
$output_filename = "SYH_Letter_changes.docx"

def main()
    # The first step in every application using PDFNet is to initialize the
    # library. The library is usually initialized only once, but calling
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(PDFTronLicense.Key)
    PDFNet.SetResourcesPath("../../../Resources")

    begin
        options = DOCXCompareOptions.new()

        # Compare the two DOCX documents, writing the differences as tracked
        # changes into the output DOCX document.
        result = DOCXCompare.Compare($inputPath + $original_filename, $inputPath + $revised_filename, $outputPath + $output_filename, options)

        # And we're done!
        if result.DifferencesDetected()
            puts "Differences detected, saved to " + $output_filename
        else
            puts "No difference detected"
        end
    rescue => error
        puts "Unable to compare DOCX documents, error: " + error.message
    end

    PDFNet.Terminate
    puts "Done."
end

main()

