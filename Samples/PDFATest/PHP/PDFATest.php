<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

//---------------------------------------------------------------------------------------
// The following sample illustrates how to parse and check if a PDF document meets the
//	PDFA standard, using the PDFACompliance class object. 
//---------------------------------------------------------------------------------------


function PrintResults($pdf_a, $filename) 
{
	$err_cnt = $pdf_a->GetErrorCount();
	if ($err_cnt == 0) 
	{
		echo nl2br($filename.": OK.\n");
	}
	else 
	{
		echo nl2br($filename." is NOT a valid PDFA.\n");
		for ($i=0; $i<$err_cnt; ++$i) 
		{
			$c = $pdf_a->GetError($i);
			$str1 = " - e_PDFA ".$c.": ".PDFACompliance::GetPDFAErrorMessage($c).".";
			if (true) 
			{
				$num_refs = $pdf_a->GetRefObjCount($c);
				if ($num_refs > 0)  
				{
					$str1 = $str1."\n   Objects: ";
					for ($j=0; $j<$num_refs; ++$j) 
					{
						$str1 = $str1.$pdf_a->GetRefObj($c, $j);
						if ($j<$num_refs-1) 
							$str1 = $str1. ", ";
					}
				}
			}
			echo nl2br($str1."\n");
		}
		echo nl2br("\n");
	}
}

	// Relative path to the folder containing the test files.
	$input_path = getcwd()."/../../TestFiles/";
	$output_path = getcwd()."/../../TestFiles/Output/";

	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.
	PDFNet::SetColorManagement();  // Enable color management (required for PDFA validation).

	//-----------------------------------------------------------
	// Example 1: PDF/A Validation
	//-----------------------------------------------------------
	$filename = "newsletter.pdf";
	// The max_ref_objs parameter to the PDFACompliance constructor controls the maximum number 
	// of object numbers that are collected for particular error codes. The default value is 10 
	// in order to prevent spam. If you need all the object numbers, pass 0 for max_ref_objs.
	$pdf_a = new PDFACompliance(false, $input_path.$filename, "", PDFACompliance::e_Level2B, 0, 0, 10);
	PrintResults($pdf_a, $filename);
	$pdf_a->Destroy();

	//-----------------------------------------------------------
	// Example 2: PDF/A Conversion
	//-----------------------------------------------------------
	$filename = "fish.pdf";
	
	$pdf_a = new PDFACompliance(true, $input_path.$filename, "", PDFACompliance::e_Level2B, 0, 0, 10);
	$filename = "pdfa.pdf";
	$pdf_a->SaveAs($output_path.$filename, false);
	$pdf_a->Destroy();

	// Re-validate the document after the conversion...
	$pdf_a = new PDFACompliance(false, $output_path.$filename, "", PDFACompliance::e_Level2B, 0, 0, 10);		
	PrintResults($pdf_a, $filename);
	$pdf_a->Destroy();
	
	echo nl2br("PDFACompliance test completed.\n");
?>
