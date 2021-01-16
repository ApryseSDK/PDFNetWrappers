<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2020 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("../../../PDFNetC/Lib/PDFNetPHP.php");

// Relative path to the folder containing the test files.
$input_path = getcwd()."/../../TestFiles/CAD/";
$output_path = getcwd()."/../../TestFiles/Output/";

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use CAD module
//---------------------------------------------------------------------------------------
	
	// The first step in every application using PDFNet is to initialize the 
	// library and set the path to common PDF resources. The library is usually 
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet::Initialize();
	PDFNet::GetSystemFontList();    // Wait for fonts to be loaded if they haven't already. This is done because PHP can run into errors when shutting down if font loading is still in progress.

	// The location of the CAD Module
	PDFNet::AddResourceSearchPath("../../../Lib/");
	if(!CADModule::IsModuleAvailable()) {
		echo "Unable to run CAD2PDFTest: PDFTron SDK CAD module not available.\n
			---------------------------------------------------------------\n
			The CAD module is an optional add-on, available for download\n
			at http://www.pdftron.com/. If you have already downloaded this\n
			module, ensure that the SDK is able to find the required files\n
			using the PDFNet::AddResourceSearchPath() function.\n";
	} else
	{
		$doc = new PDFDoc();
		Convert::FromCAD($doc, $input_path."construction drawings color-28.05.18.dwg");
		$doc->Save($output_path."construction drawings color-28.05.18.dwg.pdf", 0);
		echo "CAD2PDF conversion example \n";
	}

?>
