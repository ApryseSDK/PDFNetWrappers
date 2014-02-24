<?php
//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//----------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// This sample demonstrates the basic usage of high-level digital signature API in PDFNet.
//
// The following steps are typically used to add a digital signature to a PDF:
//
//     1. Extend and implement a new SignatureHandler. The SignatureHandler will be used to add or validate/check a
//        digital signature.
//     2. Create an instance of the implemented SignatureHandler and register it with PDFDoc with
//        pdfdoc.AddSignatureHandler(). The method returns an ID that can be used later to associate a SignatureHandler
//        with a field.
//     3. Find the required 'e_signature' field in the existing document or create a new field.
//     4. Call field.UseSignatureHandler() with the ID of your handler.
//     5. Call pdfdoc.Save()
//
// Additional processing can be done before document is signed. For example, UseSignatureHandler() returns an instance
// of SDF dictionary which represents the signature dictionary (or the /V entry of the form field). This can be used to
// add additional information to the signature dictionary (e.g. Name, Reason, Location, etc.).
//
// Although the steps above describes extending the SignatureHandler class, this sample demonstrates the use of
// StdSignatureHandler (a built-in SignatureHandler in PDFNet) to sign a PDF file.
//----------------------------------------------------------------------------------------------------------------------

include('../../../PDFNetC/Lib/PDFNetPHP.php');

//
// This functions add an approval signature to the PDF document. The original PDF document contains a blank form field
// that is prepared for a user to sign. The following code demonstrate how to sign this document using PDFNet.
//
function SignPDF()
{
    $infile = '../../TestFiles/doc_to_sign.pdf';
    $outfile = '../../TestFiles/Output/signed_doc.pdf';
    $certfile = '../../TestFiles/pdftron.pfx';
    $imagefile = '../../TestFiles/signature.jpg';
    $result = true;
    try {
        echo(nl2br('Signing PDF document: "'.$infile.'".'.PHP_EOL));
        
        // Open an existing PDF
        $doc = new PDFDoc($infile);
        
        // Add an StdSignatureHandler instance to PDFDoc, making sure to keep track of it using the ID returned.
        $sigHandlerId = $doc->AddStdSignatureHandler($certfile, "password");
        
        // Obtain the signature form field from the PDFDoc via Annotation.
        $sigField = $doc->GetField('Signature1');
        $widgetAnnot = new Widget($sigField->GetSDFObj());
        
        # Tell PDFNetC to use the SignatureHandler created to sign the new signature form field.
        $sigDict = $sigField->UseSignatureHandler($sigHandlerId);
        
        // Add more information to the signature dictionary.
        $sigDict->PutName('SubFilter', 'adbe.pkcs7.detached');
        $sigDict->PutString('Name', 'PDFTron');
        $sigDict->PutString('Location', 'Vancouver, BC');
        $sigDict->PutString('Reason', 'Document verification.');
        
        // Create a signature appearance
        $apWriter = new ElementWriter();
        $apBuilder = new ElementBuilder();
        $apWriter->Begin($doc->GetSDFDoc());
        $sigImg = Image::Create($doc->GetSDFDoc(), $imagefile);
        $w = floatval($sigImg->GetImageWidth());
        $h = floatval($sigImg->GetImageHeight());
        $apElement = $apBuilder->CreateImage($sigImg, 0.0, 0.0, $w, $h);
        $apWriter->WritePlacedElement($apElement);
        $apObj = $apWriter->End();
        $apObj->PutRect('BBox', 0.0, 0.0, $w, $h);
        $apObj->PutName('Subtype', 'Form');
        $apObj->PutName('Type', 'XObject');
        $apWriter->Begin($doc->GetSDFDoc());
        $apElement = $apBuilder->CreateForm($apObj);
        $apWriter->WritePlacedElement($apElement);
        $apObj = $apWriter->End();
        $apObj->PutRect('BBox', 0.0, 0.0, $w, $h);
        $apObj->PutName('Subtype', 'Form');
        $apObj->PutName('Type', 'XObject');
        $widgetAnnot->SetAppearance($apObj);
        $widgetAnnot->RefreshAppearance();

        // Save the PDFDoc. Once the method below is called, PDFNetC will also sign the document using the information
        // provided.
        $doc->Save($outfile, 0);

        echo(nl2br('Finished signing PDF document'.PHP_EOL));
        
        $doc->Close();
    }
    catch (Exception $e) {
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
    
    return $result;
}

function CertifyPDF()
{
    $infile = '../../TestFiles/newsletter.pdf';
    $outfile = '../../TestFiles/Output/newsletter_certified.pdf';
    $certfile = '../../TestFiles/pdftron.pfx';
    $result = true;
    try {
        echo(nl2br('Certifying PDF document: "'.$infile.'".'.PHP_EOL));
        
        // Open an existing PDF
        $doc = new PDFDoc($infile);
        
        // Add an StdSignatureHandler instance to PDFDoc, making sure to keep track of it using the ID returned.
        $sigHandlerId = $doc->AddStdSignatureHandler($certfile, "password");
        
        // Create a new signature form field in the PDFDoc.
        $sigField = $doc->FieldCreate('Signature1', Field::e_signature);
        
        // Assign the form field as an annotation widget to the PDFDoc so that a signature appearance can be added.
        $page1 = $doc->GetPage(1);
        $widgetAnnot = Widget::Create($doc->GetSDFDoc(), new Rect(0.0, 0.0, 0.0, 0.0), $sigField);
        $page1->AnnotPushBack($widgetAnnot);
        $widgetAnnot->SetPage($page1);
        $widgetObj = $widgetAnnot->GetSDFObj();
        $widgetObj->PutNumber('F', 132.0);
        $widgetObj->PutName('Type', 'Annot');
        
        // Tell PDFNetC to use the SignatureHandler created to sign the new signature form field.
        $sigDict = $sigField->UseSignatureHandler($sigHandlerId);
        
        // Add more information to the signature dictionary.
        $sigDict->PutName('SubFilter', 'adbe.pkcs7.detached');
        $sigDict->PutString('Name', 'PDFTron');
        $sigDict->PutString('Location', 'Vancouver, BC');
        $sigDict->PutString('Reason', 'Document verification.');

        // Appearance can be added to the widget annotation. Please see the "SignPDF()" function for details.

        // Add this sigDict as DocMDP in Perms dictionary from root
        $root = $doc->GetRoot();
        $perms = $root->PutDict('Perms');
        // add the sigDict as DocMDP (indirect) in Perms
        $perms->Put('DocMDP', $sigDict);
        
        // add the additional DocMDP transform params
        $refObj = $sigDict->PutArray("Reference");
        $transform = $refObj->PushBackDict();
        $transform->PutName("TransformMethod", "DocMDP");
        $transform->PutName("Type", "SigRef");
        $transformParams = $transform->PutDict("TransformParams");
        $transformParams->PutNumber("P", 1); // Set permissions as necessary.
        $transformParams->PutName("Type", "TransformParams");
        $transformParams->PutName("V", "1.2");

        // Save the PDFDoc. Once the method below is called, PDFNetC will also sign the document using the information
        // provided.
        $doc->Save($outfile, 0);

        echo(nl2br('Finished certifying PDF document'.PHP_EOL));
        
        $doc->Close();
    }
    catch (Exception $e) {
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
    
    return $result;
}

function main()
{
    // Initialize PDFNetC
    PDFNet::Initialize();

    $result = true;
    
    if (!SignPDF())
        $result = false;

    if (!CertifyPDF())
        $result = false;

    if (!$result) {
        echo(nl2br('Tests failed.'.PHP_EOL));
        return;
    }

    echo(nl2br('All tests passed.'.PHP_EOL));
}

main();

?>
