<?php
//------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult legal.txt regarding legal and license information.
//------------------------------------------------------------------------------
if(file_exists("../../../PDFNetC/Lib/PDFNetPHP.php"))
include("../../../PDFNetC/Lib/PDFNetPHP.php");
include("../../LicenseKey/PHP/LicenseKey.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

// Provide your own original and revised versions of a DOCX document here.
$original_filename = "SYH_Letter.docx";
$revised_filename = "SYH_Letter_revision2.docx";
$output_filename = "SYH_Letter_changes.docx";

//------------------------------------------------------------------------------
// The following sample illustrates how to use the Office::DOCXCompare utility class
// to compare two MS Word (DOCX) documents and produce a new DOCX document containing
// the differences between them as tracked changes.
//
// This comparison is performed entirely within the PDFNet and has *no* external or
// system dependencies -- Comparison results will be the same whether on Windows,
// Linux or Android.
//
// Please contact us if you have any questions.
//------------------------------------------------------------------------------

function main()
{
        global $input_path, $output_path, $original_filename, $revised_filename, $output_filename;

        // The first step in every application using PDFNet is to initialize the
        // library. The library is usually initialized only once, but calling
        // Initialize() multiple times is also fine.
        global $LicenseKey;
        PDFNet::Initialize($LicenseKey);
        PDFNet::SetResourcesPath("../../../Resources");

        try
        {
                $options = new DOCXCompareOptions();

                // Compare the two DOCX documents, writing the differences as tracked
                // changes into the output DOCX document.
                $result = DOCXCompare::Compare($input_path.$original_filename, $input_path.$revised_filename, $output_path.$output_filename, $options);

                // And we're done!
                if($result->DifferencesDetected())
                {
                        echo nl2br("Differences detected, saved to ".$output_filename."\n");
                }
                else
                {
                        echo nl2br("No difference detected\n");
                }
        }
        catch(Exception $e)
        {
                echo nl2br("Unable to compare DOCX documents, error: ".$e->getMessage()."\n");
        }

        PDFNet::Terminate();
        echo(nl2br("Done.\n"));
}

main()

?>

