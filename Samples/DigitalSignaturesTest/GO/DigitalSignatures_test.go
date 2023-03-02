//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

////----------------------------------------------------------------------------------------------------------------------
//// This sample demonstrates the basic usage of the high-level digital signatures API in PDFNet.
////
//// The following steps reflect typical intended usage of the digital signatures API:
////
////  0.  Start with a PDF with or without form fields in it that one would like to lock (or, one can add a field, see (1)).
////  
////  1.  EITHER: 
////      (a) Call doc.CreateDigitalSignatureField, optionally providing a name. You receive a DigitalSignatureField.
////      -OR-
////      (b) If you didn't just create the digital signature field that you want to sign/certify, find the existing one within the 
////      document by using PDFDoc.DigitalSignatureFieldIterator or by using PDFDoc.GetField to get it by its fully qualified name.
////  
////  2.  Create a signature widget annotation, and pass the DigitalSignatureField that you just created or found. 
////      If you want it to be visible, provide a Rect argument with a non-zero width or height, and don't set the
////      NoView and Hidden flags. [Optionally, add an appearance to the annotation when you wish to sign/certify.]
////      
////  [3. (OPTIONAL) Add digital signature restrictions to the document using the field modification permissions (SetFieldPermissions) 
////      or document modification permissions functions (SetDocumentPermissions) of DigitalSignatureField. These features disallow 
////      certain types of changes to be made to the document without invalidating the cryptographic digital signature once it
////      is signed.]
////      
////  4.  Call either CertifyOnNextSave or SignOnNextSave. There are three overloads for each one (six total):
////      a.  Taking a PKCS //12 keyfile path and its password
////      b.  Taking a buffer containing a PKCS //12 private keyfile and its password
////      c.  Taking a unique identifier of a signature handler registered with the PDFDoc. This overload is to be used
////          in the following fashion: 
////          i)      Extend and implement a new SignatureHandler. The SignatureHandler will be used to add or 
////                  validate/check a digital signature.
////          ii)     Create an instance of the implemented SignatureHandler and register it with PDFDoc with 
////                  pdfdoc.AddSignatureHandler(). The method returns a SignatureHandlerId.
////          iii)    Call SignOnNextSaveWithCustomHandler/CertifyOnNextSaveWithCustomHandler with the SignatureHandlerId.
////      NOTE: It is only possible to sign/certify one signature per call to the Save function.
////  
////  5.  Call pdfdoc.Save(). This will also create the digital signature dictionary and write a cryptographic signature to it.
////      IMPORTANT: If there are already signed/certified digital signature(s) in the document, you must save incrementally
////      so as to not invalidate the other signature(s). 
////
//// Additional processing can be done before document is signed. For example, UseSignatureHandler() returns an instance
//// of SDF dictionary which represents the signature dictionary (or the /V entry of the form field). This can be used to
//// add additional information to the signature dictionary (e.g. Name, Reason, Location, etc.).
////
//// Although the steps above describes extending the SignatureHandler class, this sample demonstrates the use of
//// StdSignatureHandler (a built-in SignatureHandler in PDFNet) to sign a PDF file.
////----------------------------------------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "strconv"
    "flag"
    "testing"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

func VerifySimple(inDocpath string, inPublicKeyFilePath string) bool{
    doc := NewPDFDoc(inDocpath)
    fmt.Println("==========")
    opts := NewVerificationOptions(VerificationOptionsE_compatibility_and_archiving)

    // Add trust root to store of trusted certificates contained in VerificationOptions.
    opts.AddTrustedCertificate(inPublicKeyFilePath, uint16(VerificationOptionsE_default_trust | VerificationOptionsE_certification_trust))

    result := doc.VerifySignedDigitalSignatures(opts)
        
    if result == PDFDocE_unsigned{
        fmt.Println("Document has no signed signature fields.")
        return false
        // e_failure == bad doc status, digest status, or permissions status
        // (i.e. does not include trust issues, because those are flaky due to being network/config-related)
    }else if result == PDFDocE_failure{
        fmt.Println("Hard failure in verification on at least one signature.")
        return false
    }else if result == PDFDocE_untrusted{
        fmt.Println("Could not verify trust for at least one signature.")
        return false
    }else if result == PDFDocE_unsupported{
        // If necessary, call GetUnsupportedFeatures on VerificationResult to check which
        // unsupported features were encountered (requires verification using 'detailed' APIs)
        fmt.Println("At least one signature contains unsupported features.")
        return false
        // unsigned sigs skipped; parts of document may be unsigned (check GetByteRanges on signed sigs to find out)
    }else if result == PDFDocE_verified{
        fmt.Println("All signed signatures in document verified.")
        return true
    }else{
        fmt.Println("unrecognized document verification status")
        return false
    }
}

func VerifyAllAndPrint(inDocpath string, inPublicKeyFilePath string) bool{
    doc := NewPDFDoc(inDocpath)
    fmt.Println("==========")
    opts := NewVerificationOptions(VerificationOptionsE_compatibility_and_archiving)
    
    // Trust the public certificate we use for signing.
    trustedCertFile := NewMappedFile(inPublicKeyFilePath)
    fileSz := trustedCertFile.FileSize()
    fileReader := NewFilterReader(trustedCertFile)
    trustedCertBuf := fileReader.Read(fileSz)
    trustedCertBytes := make([]byte, int(trustedCertBuf.Size()))
    for i := 0; i < int(trustedCertBuf.Size()); i ++ {
        trustedCertBytes[i] = trustedCertBuf.Get(i)
    }
    opts.AddTrustedCertificate(&trustedCertBytes[0], int64(len(trustedCertBytes)), uint16(VerificationOptionsE_default_trust | VerificationOptionsE_certification_trust))

    // Iterate over the signatures and verify all of them.
    digsigFitr := doc.GetDigitalSignatureFieldIterator()
    verificationStatus := true
    for (digsigFitr.HasNext()){
        curr := digsigFitr.Current()
        result := curr.Verify(opts)
        if result.GetVerificationStatus(){
            fmt.Printf("Signature verified, objnum: %d\n", curr.GetSDFObj().GetObjNum())
        }else{
            fmt.Printf("Signature verification failed, objnum: %d\n", curr.GetSDFObj().GetObjNum())
            verificationStatus = false
        }
        digest_algorithm := result.GetDigestAlgorithm()
        if digest_algorithm == DigestAlgorithmE_SHA1{
            fmt.Println("Digest algorithm: SHA-1")
        }else if digest_algorithm == DigestAlgorithmE_SHA256{
            fmt.Println("Digest algorithm: SHA-256")
        }else if digest_algorithm == DigestAlgorithmE_SHA384{
            fmt.Println("Digest algorithm: SHA-384")
        }else if digest_algorithm == DigestAlgorithmE_SHA512{
            fmt.Println("Digest algorithm: SHA-512")
        }else if digest_algorithm == DigestAlgorithmE_RIPEMD160{
            fmt.Println("Digest algorithm: RIPEMD-160")
        }else if digest_algorithm == DigestAlgorithmE_unknown_digest_algorithm{
            fmt.Println("Digest algorithm: unknown")
        }else{
            //unrecognized document status
        }
        fmt.Printf("Detailed verification result: \n\t%s\n\t%s\n\t%s\n\t%s\n", 
            result.GetDocumentStatusAsString(),
            result.GetDigestStatusAsString(),
            result.GetTrustStatusAsString(),
            result.GetPermissionsStatusAsString())
            
        changes := result.GetDisallowedChanges()
        for i := 0; i < int(changes.Size()); i++ {
            fmt.Printf("\tDisallowed change: %s, objnum: %d\n", changes.Get(i).GetTypeAsString(), changes.Get(i).GetObjNum())
        }

        // Get and print all the detailed trust-related results, if they are available.
        if result.HasTrustVerificationResult(){
            trustVerificationResult := result.GetTrustVerificationResult()
            var msg string
            if trustVerificationResult.WasSuccessful(){
                msg = "Trust verified."
            } else {
                msg = "Trust not verifiable."
            }
            fmt.Println(msg)
            fmt.Println(trustVerificationResult.GetResultString())
            
            tmpTimeTv := trustVerificationResult.GetTimeOfTrustVerification()
            
            trustVerificationTimeEnum := trustVerificationResult.GetTimeOfTrustVerificationEnum()
            
            if trustVerificationTimeEnum == VerificationOptionsE_current{
                fmt.Println("Trust verification attempted with respect to current time (as epoch time): " + strconv.Itoa(int(tmpTimeTv)))
            }else if trustVerificationTimeEnum == VerificationOptionsE_signing{
                fmt.Println("Trust verification attempted with respect to signing time (as epoch time): " + strconv.Itoa(int(tmpTimeTv)))
            }else if trustVerificationTimeEnum == VerificationOptionsE_timestamp{
                fmt.Println("Trust verification attempted with respect to secure embedded timestamp (as epoch time): " + strconv.Itoa(int(tmpTimeTv)))
            }else{
                //unrecognized time enum value
            }

            if trustVerificationResult.GetCertPath().Size() == 0{
                fmt.Println("Could not print certificate path.")
            }else{
                fmt.Println("Certificate path:")
                certPath := trustVerificationResult.GetCertPath()
                for i := 0; i < int(certPath.Size()); i ++{
                    fmt.Println("\tCertificate:")
                    fmt.Println("\t\tIssuer names:")
                    issuerDn := certPath.Get(i).GetIssuerField().GetAllAttributesAndValues()
                    for j := 0; j < int(issuerDn.Size()); j ++{ 
                        fmt.Println("\t\t\t" + issuerDn.Get(j).GetStringValue())
                    }
                    fmt.Println("\t\tSubject names:")
                    subjectDn := certPath.Get(i).GetSubjectField().GetAllAttributesAndValues()
                    for k := 0; k < int(subjectDn.Size()); k ++{
                        fmt.Println("\t\t\t" + subjectDn.Get(k).GetStringValue())
                    }
                    fmt.Println("\t\tExtensions:")
                    for m := 0; m < int(certPath.Get(i).GetExtensions().Size()); m ++{
                        fmt.Println("\t\t\t" + certPath.Get(i).GetExtensions().Get(m).ToString())
                    }
                }
            }        
        }else{
            fmt.Println("No detailed trust verification result available.")
        
            unsupportedFeatures := result.GetUnsupportedFeatures()
            if unsupportedFeatures.Size() > 0 {
                fmt.Println("Unsupported features:")
                for i := 0; i < int(unsupportedFeatures.Size()); i ++{
                    fmt.Println("\t" + unsupportedFeatures.Get(i))
                }
            }
        }
        fmt.Println("==========")
        
        digsigFitr.Next()
    }
    return verificationStatus
}

func CertifyPDF(inDocpath string,
    inCertFieldName string ,
    inPrivateKeyFilePath string,
    inKeyfilePassword string,
    inAppearanceImagePath string,
    inOutpath string){
    
    fmt.Println("================================================================================")
    fmt.Println("Certifying PDF document")

    // Open an existing PDF
    doc := NewPDFDoc(inDocpath)

    if doc.HasSignatures(){
        fmt.Println("PDFDoc has signatures")
    }else{
        fmt.Println("PDFDoc has no signatures")
    }
    page1 := doc.GetPage(1)

    // Create a text field that we can lock using the field permissions feature.
    annot1 := TextWidgetCreate(doc, NewRect(143.0, 440.0, 350.0, 460.0), "asdf_test_field")
    page1.AnnotPushBack(annot1)

    // Create a new signature form field in the PDFDoc. The name argument is optional;
    // leaving it empty causes it to be auto-generated. However, you may need the name for later.
    // Acrobat doesn"t show digsigfield in side panel if it's without a widget. Using a
    // Rect with 0 width and 0 height, or setting the NoPrint/Invisible flags makes it invisible. 
    certificationSigField := doc.CreateDigitalSignatureField(inCertFieldName)
    widgetAnnot := SignatureWidgetCreate(doc, NewRect(143.0, 287.0, 219.0, 306.0), certificationSigField)
    page1.AnnotPushBack(widgetAnnot)

    // (OPTIONAL) Add an appearance to the signature field.
    img := ImageCreate(doc.GetSDFDoc(), inAppearanceImagePath)
    widgetAnnot.CreateSignatureAppearance(img)

    // Add permissions. Lock the random text field.
    fmt.Println("Adding document permissions.")
    certificationSigField.SetDocumentPermissions(DigitalSignatureFieldE_annotating_formfilling_signing_allowed)
    
    // Prepare to lock the text field that we created earlier.
    fmt.Println("Adding field permissions.")
    testField := NewVectorString()
    testField.Add("asdf_test_field")
    certificationSigField.SetFieldPermissions(DigitalSignatureFieldE_include, testField)

    certificationSigField.CertifyOnNextSave(inPrivateKeyFilePath, inKeyfilePassword)

    // (OPTIONAL) Add more information to the signature dictionary.
    certificationSigField.SetLocation("Vancouver, BC")
    certificationSigField.SetReason("Document certification.")
    certificationSigField.SetContactInfo("www.pdftron.com")

    // Save the PDFDoc. Once the method below is called, PDFNet will also sign the document using the information provided.
    doc.Save(inOutpath, uint(0))

    fmt.Println("================================================================================")
}

func SignPDF(inDocpath string, 
    inApprovalFieldName string, 
    inPrivateKeyFilePath string, 
    inKeyfilePassword string, 
    inAppearanceImgPath string, 
    inOutpath string){
    
    fmt.Println("================================================================================")
    fmt.Println("Signing PDF document")

    // Open an existing PDF
    doc := NewPDFDoc(inDocpath)

    // Retrieve the unsigned approval signature field.
    foundApprovalField := doc.GetField(inApprovalFieldName)
    foundApprovalSignatureDigsigField := NewDigitalSignatureField(foundApprovalField)
    
    // (OPTIONAL) Add an appearance to the signature field.
    img := ImageCreate(doc.GetSDFDoc(), inAppearanceImgPath)
    foundApprovalSignatureWidget := NewSignatureWidget(foundApprovalField.GetSDFObj())
    foundApprovalSignatureWidget.CreateSignatureAppearance(img)

    // Prepare the signature and signature handler for signing.
    foundApprovalSignatureDigsigField.SignOnNextSave(inPrivateKeyFilePath, inKeyfilePassword)

    // The actual approval signing will be done during the following incremental save operation.
    doc.Save(inOutpath, uint(SDFDocE_incremental))

    fmt.Println("================================================================================")
}

func ClearSignature(inDocpath string,
    inDigsigFieldName string,
    inOutpath string){

    fmt.Println("================================================================================")
    fmt.Println("Clearing certification signature")

    doc := NewPDFDoc(inDocpath)

    digsig := NewDigitalSignatureField(doc.GetField(inDigsigFieldName))
    
    fmt.Println("Clearing signature: " + inDigsigFieldName)
    digsig.ClearSignature()

    if !digsig.HasCryptographicSignature(){
        fmt.Println("Cryptographic signature cleared properly.")
    }
    // Save incrementally so as to not invalidate other signatures from previous saves.
    doc.Save(inOutpath, uint(SDFDocE_incremental))

    fmt.Println("================================================================================")
}

func PrintSignaturesInfo(inDocpath string){
    fmt.Println("================================================================================")
    fmt.Println("Reading and printing digital signature information")

    doc := NewPDFDoc(inDocpath)
    if !doc.HasSignatures(){
        fmt.Println("Doc has no signatures.")
        fmt.Println("================================================================================")
        return
    }else{
        fmt.Println("Doc has signatures.")
    }

    fitr := doc.GetFieldIterator()
    for fitr.HasNext(){
        current := fitr.Current()
        if (current.IsLockedByDigitalSignature()){
            fmt.Println("==========\nField locked by a digital signature")
        }else{
            fmt.Println("==========\nField not locked by a digital signature")
        }
        fmt.Println("Field name: " + current.GetName())
        fmt.Println("==========")
        
        fitr.Next()
    }

    fmt.Println("====================\nNow iterating over digital signatures only.\n====================")

    digsigFitr := doc.GetDigitalSignatureFieldIterator()
    for digsigFitr.HasNext(){
        current := digsigFitr.Current()
        fmt.Println("==========")
        fmt.Println("Field name of digital signature: " + NewField(current.GetSDFObj()).GetName())

        digsigfield := current
        if !digsigfield.HasCryptographicSignature(){
            fmt.Println("Either digital signature field lacks a digital signature dictionary, " +
                "or digital signature dictionary lacks a cryptographic Contents entry. " +
                "Digital signature field is not presently considered signed.\n" +
                "==========")
            digsigFitr.Next()
            continue
        }
        certCount := digsigfield.GetCertCount()
        fmt.Println("Cert count: " + strconv.Itoa(int(certCount)))
        for i := uint(0); i < certCount; i ++{
            cert := digsigfield.GetCert(i)
            fmt.Println("Cert //" + strconv.Itoa(int(i)) + " size: " + strconv.Itoa(int(cert.Size())))
        }
        subfilter := digsigfield.GetSubFilter()

        fmt.Println("Subfilter type: " + strconv.Itoa(int(subfilter)))

        if subfilter != DigitalSignatureFieldE_ETSI_RFC3161{
            fmt.Println("Signature's signer: " + digsigfield.GetSignatureName())

            signingTime := digsigfield.GetSigningTime()
            if signingTime.IsValid(){
                fmt.Println("Signing time is valid.")
            }
            fmt.Println("Location: " + digsigfield.GetLocation())
            fmt.Println("Reason: " + digsigfield.GetReason())
            fmt.Println("Contact info: " + digsigfield.GetContactInfo())
        }else{
            fmt.Println("SubFilter == e_ETSI_RFC3161 (DocTimeStamp; no signing info)")
        }
        if digsigfield.HasVisibleAppearance(){
            fmt.Println("Visible")
        }else{
            fmt.Println("Not visible")
        }
        digsigDocPerms := digsigfield.GetDocumentPermissions()
        lockedFields := digsigfield.GetLockedFields()
        for i := 0; i < int(lockedFields.Size()); i ++{
            fmt.Println("This digital signature locks a field named: " + lockedFields.Get(i))
        }
        if digsigDocPerms == DigitalSignatureFieldE_no_changes_allowed{
            fmt.Println("No changes to the document can be made without invalidating this digital signature.")
        }else if digsigDocPerms == DigitalSignatureFieldE_formfilling_signing_allowed{
            fmt.Println("Page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.")
        }else if digsigDocPerms == DigitalSignatureFieldE_annotating_formfilling_signing_allowed{
            fmt.Println("Annotating, page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.")
        }else if digsigDocPerms == DigitalSignatureFieldE_unrestricted{
            fmt.Println("Document not restricted by this digital signature.")
        }else{
            fmt.Println("Unrecognized digital signature document permission level.")
        }
        fmt.Println("==========")
        digsigFitr.Next()
    }

    fmt.Println("================================================================================")
}

func TimestampAndEnableLTV(inDocpath string, 
    inTrustedCertPath string, 
    inAppearanceImgPath string,
    inOutpath string) bool{
    doc := NewPDFDoc(inDocpath)
    doctimestampSignatureField := doc.CreateDigitalSignatureField()
    tstConfig := NewTimestampingConfiguration("http://rfc3161timestamp.globalsign.com/advanced")
    opts := NewVerificationOptions(VerificationOptionsE_compatibility_and_archiving)
//   It is necessary to add to the VerificationOptions a trusted root certificate corresponding to 
//   the chain used by the timestamp authority to sign the timestamp token, in order for the timestamp
//   response to be verifiable during DocTimeStamp signing. It is also necessary in the context of this 
//   function to do this for the later LTV section, because one needs to be able to verify the DocTimeStamp 
//   in order to enable LTV for it, and we re-use the VerificationOptions opts object in that part.

    opts.AddTrustedCertificate(inTrustedCertPath)
//       By default, we only check online for revocation of certificates using the newer and lighter 
//   OCSP protocol as opposed to CRL, due to lower resource usage and greater reliability. However, 
//   it may be necessary to enable online CRL revocation checking in order to verify some timestamps
//   (i.e. those that do not have an OCSP responder URL for all non-trusted certificates).

    opts.EnableOnlineCRLRevocationChecking(true)

    widgetAnnot := SignatureWidgetCreate(doc, NewRect(0.0, 100.0, 200.0, 150.0), doctimestampSignatureField)
    doc.GetPage(1).AnnotPushBack(widgetAnnot)

    // (OPTIONAL) Add an appearance to the signature field.
    img := ImageCreate(doc.GetSDFDoc(), inAppearanceImgPath)
    widgetAnnot.CreateSignatureAppearance(img)

    fmt.Println("Testing timestamping configuration.")
    configResult := tstConfig.TestConfiguration(opts)
    if configResult.GetStatus(){
        fmt.Println("Success: timestamping configuration usable. Attempting to timestamp.")
    }else{
        // Print details of timestamping failure.
        fmt.Println(configResult.GetString())
        if configResult.HasResponseVerificationResult(){
            tstResult := configResult.GetResponseVerificationResult()
            fmt.Println("CMS digest status: "+ tstResult.GetCMSDigestStatusAsString())
            fmt.Println("Message digest status: " + tstResult.GetMessageImprintDigestStatusAsString())
            fmt.Println("Trust status: " + tstResult.GetTrustStatusAsString())
        }
        return false
    }

    doctimestampSignatureField.TimestampOnNextSave(tstConfig, opts)

    // Save/signing throws if timestamping fails.
    doc.Save(inOutpath, uint(SDFDocE_incremental))

    fmt.Println("Timestamping successful. Adding LTV information for DocTimeStamp signature.")

    // Add LTV information for timestamp signature to document.
    timestampVerificationResult := doctimestampSignatureField.Verify(opts)
    if !doctimestampSignatureField.EnableLTVOfflineVerification(timestampVerificationResult){
        fmt.Println("Could not enable LTV for DocTimeStamp.")
        return false
    }
    doc.Save(inOutpath, uint(SDFDocE_incremental))
    fmt.Println("Added LTV information for DocTimeStamp signature successfully.")

    return true
}

func TestDigitalSignatures(t *testing.T){
    // Initialize PDFNet
    PDFNetInitialize(licenseKey)
    
    result := true
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    //////////////////////////////////////// TEST 0:
    // Create an approval signature field that we can sign after certifying.
    // (Must be done before calling CertifyOnNextSave/SignOnNextSave/WithCustomHandler.)
    // Open an existing PDF
    doc := NewPDFDoc(inputPath + "waiver.pdf")
    widgetAnnotApproval := SignatureWidgetCreate(doc, NewRect(300.0, 287.0, 376.0, 306.0), "PDFTronApprovalSig")
    page1 := doc.GetPage(1)
    page1.AnnotPushBack(widgetAnnotApproval)
    doc.Save(outputPath + "waiver_withApprovalField_output.pdf", uint(SDFDocE_remove_unused))

    //////////////////////////////////////// TEST 1: certify a PDF.
    CertifyPDF(inputPath + "waiver_withApprovalField.pdf",
            "PDFTronCertificationSig",
            inputPath + "pdftron.pfx",
            "password",
            inputPath + "pdftron.bmp",
            outputPath + "waiver_withApprovalField_certified_output.pdf")
    PrintSignaturesInfo(outputPath + "waiver_withApprovalField_certified_output.pdf")

    //////////////////////////////////////// TEST 2: approval-sign an existing, unsigned signature field in a PDF that already has a certified signature field.
    SignPDF(inputPath + "waiver_withApprovalField_certified.pdf",
            "PDFTronApprovalSig",
            inputPath + "pdftron.pfx",
            "password",
            inputPath + "signature.jpg",
            outputPath + "waiver_withApprovalField_certified_approved_output.pdf")
    PrintSignaturesInfo(outputPath + "waiver_withApprovalField_certified_approved_output.pdf")

    //////////////////////////////////////// TEST 3: Clear a certification from a document that is certified and has an approval signature.
    ClearSignature(inputPath + "waiver_withApprovalField_certified_approved.pdf",
            "PDFTronCertificationSig",
            outputPath + "waiver_withApprovalField_certified_approved_certcleared_output.pdf")
    PrintSignaturesInfo(outputPath + "waiver_withApprovalField_certified_approved_certcleared_output.pdf")

    //////////////////////////////////////// TEST 4: Verify a document's digital signatures.
    if !VerifyAllAndPrint(inputPath + "waiver_withApprovalField_certified_approved.pdf", inputPath + "pdftron.cer"){
        result = false
    }

    //////////////////////////////////////// TEST 5: Verify a document's digital signatures in a simple fashion using the document API.
    if !VerifySimple(inputPath + "waiver_withApprovalField_certified_approved.pdf", inputPath + "pdftron.cer"){
       result = false
    }

    //////////////////////////////////////// TEST 6: Timestamp a document, then add Long Term Validation (LTV) information for the DocTimeStamp.
    //if !TimestampAndEnableLTV(inputPath + "waiver.pdf",
    //    inputPath + "GlobalSignRootForTST.cer",
    //    inputPath + "signature.jpg",
    //    outputPath + "waiver_DocTimeStamp_LTV.pdf"){
    //    result = false
    //}
     
    //////////////////////////////////////// End of tests. ////////////////////////////////////////

    if !result{
        fmt.Println("Tests FAILED!!!\n==========")
        PDFNetTerminate()
        return
    }
    PDFNetTerminate()
    fmt.Println("Tests successful.\n==========")
}
