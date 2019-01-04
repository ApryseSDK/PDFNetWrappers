<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to parse and check if a PDF document meets the
//	PDFA standard, using the PDFACompliance class object. 
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

function PrintResults($pdf_a, $filename) 
{
	$err_cnt = $pdf_a->GetErrorCount();
	if ($err_cnt == 0) 
	{
		echo nl2br($filename." OK.\n");
	}
	else 
	{
		echo nl2br($filename." is NOT a valid PDFA.\n");
		for ($i=0; $i<$err_cnt; ++$i) 
		{
			$c = $pdf_a->GetError($i);
			echo " - e_PDFA ".$c.": ".PDFACompliance::GetPDFAErrorMessage($c).".";
			if (true) 
			{
				$num_refs = $pdf_a->GetRefObjCount($c);
				if ($num_refs > 0)  
				{
					echo nl2br("   Objects:\n");
					for ($j=0; $j<$num_refs; ++$j) 
					{
						echo $pdf_a->GetRefObj($c, $j);
						if ($j<$num_refs-1) 
							echo ", ";
					}
					echo nl2br("\n");
				}
			}
		}
		echo nl2br("\n");
	}
}

	PDFNet::Initialize();
	PDFNet::SetColorManagement();  // Enable color management (required for PDFA validation).

	//-----------------------------------------------------------
	// Example 1: PDF/A Validation
	//-----------------------------------------------------------
	echo nl2br("Performing PDF/A validation on newsletter.pdf\n");
	$input_filename = $input_path."newsletter.pdf";
	// The max_ref_objs parameter to the PDFACompliance constructor controls the maximum number 
	// of object numbers that are collected for particular error codes. The default value is 10 
	// in order to prevent spam. If you need all the object numbers, pass 0 for max_ref_objs.
	$pdf_a = new PDFACompliance(false, $input_filename, "0", PDFACompliance::e_Level1B, 0, 10);
	PrintResults($pdf_a, "newsletter.pdf");
	$pdf_a->Destroy();

	//-----------------------------------------------------------
	// Example 2: PDF/A Conversion
	//-----------------------------------------------------------
	echo nl2br("Performing PDF/A conversion on newsletter.pdf\n");
	$input_filename = $input_path."newsletter.pdf";
	$converted_filename = $output_path."newsletter_pdfa.pdf";
	$pdf_a = new PDFACompliance(true, $input_filename, "0", PDFACompliance::e_Level1B, 0, 10);
	$pdf_a->SaveAs($converted_filename, true);
	$pdf_a->Destroy();

	// Re-validate the document after the conversion...
    echo nl2br("Performing PDF/A validation on converted newsletter_pdfa.pdf\n");
	$pdf_a = new PDFACompliance(false, $converted_filename, "0", PDFACompliance::e_Level1B, 0, 10);		
	PrintResults($pdf_a, "newsletter_pdfa.pdf");
	$pdf_a->Destroy();
	echo "Done.";
?>
