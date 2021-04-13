#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class 
# to convert MS Office files to PDF
#
# This conversion is performed entirely within the PDFNet and has *no* 
# external or system dependencies dependencies -- Conversion results will be
# the same whether on Windows, Linux or Android.
#
# Please contact us if you have any questions.
#------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
$inputPath = "../../TestFiles/"
$outputPath = "../../TestFiles/Output/"

def SimpleDocxConvert(input_filename, output_filename)
    # Start with a PDFDoc (the conversion destination)
    pdfdoc = PDFDoc.new()

    # perform the conversion with no optional parameters
    inputFile = $inputPath + input_filename
    Convert.OfficeToPDF(pdfdoc, inputFile, nil)

    # save the result
    outputFile = $outputPath + output_filename
    pdfdoc.Save(outputFile, SDFDoc::E_linearized)

    # And we're done!
    puts "Saved " + output_filename
end

def FlexibleDocxConvert(input_filename, output_filename)
    # Start with a PDFDoc (the conversion destination)
    pdfdoc = PDFDoc.new()

    options = OfficeToPDFOptions.new() 

    # set up smart font substitutions to improve conversion results
    # in situations where the original fonts are not available
    inputFile = $inputPath 
    options.SetSmartSubstitutionPluginPath(inputFile)

    # create a conversion object -- this sets things up but does not yet
    # perform any conversion logic.
    # in a multithreaded environment, this object can be used to monitor
    # the conversion progress and potentially cancel it as well
    inputFile = $inputPath + input_filename
    conversion = Convert.StreamingPDFConversion(pdfdoc, inputFile, options)

    # Print the progress of the conversion.
    # puts  "Status " + (conversion.GetProgress()*100).to_s + "%, " +
    #        conversion.GetProgressLabel()

    # actually perform the conversion
    # this particular method will not throw on conversion failure, but will
    # return an error status instead
    while (conversion.GetConversionStatus() == DocumentConversion::EIncomplete)
        conversion.ConvertNextPage()
        # print out the progress status as we go
        # puts "Status " + (conversion.GetProgress()*100).to_s + "%, " +
        #     conversion.GetProgressLabel()
    end

    if(conversion.GetConversionStatus() == DocumentConversion::ESuccess)
        num_warnings = conversion.GetNumWarnings()
        # print information about the conversion
        for i in 0..num_warnings-1 
            puts "Conversion Warning " + conversion.GetWarningString(i)
        end

        # save the result
        outputFile = $outputPath + output_filename
        pdfdoc.Save(outputFile, SDFDoc::E_linearized)
        # done
        puts "Saved " + output_filename 
    else
        puts "Encountered an error during conversion " + conversion.GetErrorString()
    end
    
end


def main()
    # The first step in every application using PDFNet is to initialize the 
    # library. The library is usually initialized only once, but calling 
    # Initialize() multiple times is also fine.
    PDFNet.Initialize()
    PDFNet.SetResourcesPath("../../../Resources")

    # first the one-line conversion function
    SimpleDocxConvert("simple-word_2007.docx", "simple-word_2007.pdf")

    # then the more flexible line-by-line conversion API
    FlexibleDocxConvert("the_rime_of_the_ancient_mariner.docx", "the_rime_of_the_ancient_mariner.pdf")

    puts "Done."
end

main()
