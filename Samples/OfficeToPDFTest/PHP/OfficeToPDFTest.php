<?php
//------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult legal.txt regarding legal and license information.
//------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/";
$output_path = $input_path."Output/";

//------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class 
// to convert MS Office files to PDF
//
// This conversion is performed entirely within the PDFNet and has *no* 
// external or system dependencies dependencies -- Conversion results will be
// the same whether on Windows, Linux or Android.
//
// Please contact us if you have any questions.
//------------------------------------------------------------------------------


function SimpleDocxConvert($input_filename, $output_filename)
{
	global $input_path, $output_path;

	// Start with a PDFDoc (the conversion destination)
	$pdfdoc = new PDFDoc();

	// perform the conversion with no optional parameters
	Convert::OfficeToPDF($pdfdoc, $input_path.$input_filename, NULL);

	// save the result
	$pdfdoc->Save($output_path.$output_filename, SDFDoc::e_linearized, NULL);
	
	// And we're done!
	echo nl2br("Saved ".$output_filename . "\n");
}


function FlexibleDocxConvert($input_filename, $output_filename)
{
	global $input_path, $output_path;

	// Start with a PDFDoc (the conversion destination)
	$pdfdoc = new PDFDoc();

	$options = new OfficeToPDFOptions(); //ConversionOptions();

	// set up smart font substitutions to improve conversion results
	// in situations where the original fonts are not available
	$options->SetSmartSubstitutionPluginPath($input_path);

	// create a conversion object -- this sets things up but does not yet
	// perform any conversion logic.
	// in a multithreaded environment, this object can be used to monitor
	// the conversion progress and potentially cancel it as well
	$conversion = Convert::StreamingPDFConversion($pdfdoc, $input_path.$input_filename, $options);

	// Print the progress of the conversion.
	/*
	echo "Status: "$conversion->GetProgress()*100 . "%, ".
			$conversion->GetProgressLabel();
	*/

	// actually perform the conversion
	// this particular method will not throw on conversion failure, but will
	// return an error status instead
	while ($conversion->GetConversionStatus() == DocumentConversion::eIncomplete)
	{
		$conversion->ConvertNextPage();
		// print out the progress status as we go
		/*
		echo (nl2br("Status: " . $conversion->GetProgress()*100 . "%, ".
			 $conversion->GetProgressLabel() ));
		*/
	}

 	if($conversion->GetConversionStatus() == DocumentConversion::eSuccess)
	{
		$num_warnings = $conversion->GetNumWarnings();
		
		// print information about the conversion 
		for ($i = 0; $i < $num_warnings; ++$i)
		{
			echo(nl2br("Conversion Warning: ".$conversion->GetWarningString($i) ));
		}

		// save the result
		$pdfdoc->Save($output_path . $output_filename, SDFDoc::e_linearized, NULL);
		// done
		echo(nl2br("Saved " . $output_filename ."\n"));
	}
	else
	{
		echo(nl2br("Encountered an error during conversion: " . $conversion->GetErrorString() ));
	}

}




function main()
{
	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.

	PDFNet::Initialize();
	PDFNet::SetResourcesPath("../../../Resources");

	// first the one-line conversion function
	SimpleDocxConvert("simple-word_2007.docx", "simple-word_2007.pdf");

	// then the more flexible line-by-line conversion API
	FlexibleDocxConvert("the_rime_of_the_ancient_mariner.docx", "the_rime_of_the_ancient_mariner.pdf");

	echo(nl2br("Done.\n"));
}

main()

?>
