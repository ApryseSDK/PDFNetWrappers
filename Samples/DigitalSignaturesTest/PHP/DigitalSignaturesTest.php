<?php
//----------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//----------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// This sample demonstrates the basic usage of the high-level digital signatures API in PDFNet.
//
// The following steps reflect typical intended usage of the digital signatures API:
//
//	0.	Start with a PDF with or without form fields in it that one would like to lock (or, one can add a field, see (1)).
//	
//	1.	EITHER: 
//		(a) Call doc.CreateDigitalSignatureField, optionally providing a name. You receive a DigitalSignatureField.
//		-OR-
//		(b) If you didn't just create the digital signature field that you want to sign/certify, find the existing one within the 
//		document by using PDFDoc.DigitalSignatureFieldIterator or by using PDFDoc.GetField to get it by its fully qualified name.
//	
//	2.	Create a signature widget annotation, and pass the DigitalSignatureField that you just created or found. 
//		If you want it to be visible, provide a Rect argument with a non-zero width or height, and don't set the
//		NoView and Hidden flags. [Optionally, add an appearance to the annotation when you wish to sign/certify.]
//		
//	[3. (OPTIONAL) Add digital signature restrictions to the document using the field modification permissions (SetFieldPermissions) 
//		or document modification permissions functions (SetDocumentPermissions) of DigitalSignatureField. These features disallow 
//		certain types of changes to be made to the document without invalidating the cryptographic digital signature once it
//		is signed.]
//		
//	4. 	Call either CertifyOnNextSave or SignOnNextSave. There are three overloads for each one (six total):
//		a.	Taking a PKCS #12 keyfile path and its password
//		b.	Taking a buffer containing a PKCS #12 private keyfile and its password
//		c.	Taking a unique identifier of a signature handler registered with the PDFDoc. This overload is to be used
//			in the following fashion: 
//			i)		Extend and implement a new SignatureHandler. The SignatureHandler will be used to add or 
//					validate/check a digital signature.
//			ii)		Create an instance of the implemented SignatureHandler and register it with PDFDoc with 
//					pdfdoc.AddSignatureHandler(). The method returns a SignatureHandlerId.
//			iii)	Call SignOnNextSaveWithCustomHandler/CertifyOnNextSaveWithCustomHandler with the SignatureHandlerId.
//		NOTE: It is only possible to sign/certify one signature per call to the Save function.
//	
//	5.	Call pdfdoc.Save(). This will also create the digital signature dictionary and write a cryptographic signature to it.
//		IMPORTANT: If there are already signed/certified digital signature(s) in the document, you must save incrementally
//		so as to not invalidate the other signature(s). 
//
// Additional processing can be done before document is signed. For example, UseSignatureHandler() returns an instance
// of SDF dictionary which represents the signature dictionary (or the /V entry of the form field). This can be used to
// add additional information to the signature dictionary (e.g. Name, Reason, Location, etc.).
//
// Although the steps above describes extending the SignatureHandler class, this sample demonstrates the use of
// StdSignatureHandler (a built-in SignatureHandler in PDFNet) to sign a PDF file.
//----------------------------------------------------------------------------------------------------------------------

include('../../../PDFNetC/Lib/PDFNetPHP.php');

function VerifySimple($in_docpath, $in_public_key_file_path)
{
	$doc = new PDFDoc($in_docpath);
	echo(nl2br("==========".PHP_EOL));
	$opts = new VerificationOptions(VerificationOptions::e_compatibility_and_archiving);

	// Add trust root to store of trusted certificates contained in VerificationOptions.
	$opts->AddTrustedCertificate($in_public_key_file_path, VerificationOptions::e_default_trust | VerificationOptions::e_certification_trust);

	$result = $doc->VerifySignedDigitalSignatures($opts);
	switch ($result)
	{
	case PDFDoc::e_unsigned:
		echo(nl2br("Document has no signed signature fields.".PHP_EOL));
		return False;
		/* e_failure == bad doc status, digest status, or permissions status
		(i.e. does not include trust issues, because those are flaky due to being network/config-related) */
	case PDFDoc::e_failure:
		echo(nl2br("Hard failure in verification on at least one signature.".PHP_EOL));
		return False;
	case PDFDoc::e_untrusted:
		echo(nl2br("Could not verify trust for at least one signature.".PHP_EOL));
		return False;
	case PDFDoc::e_unsupported:
		/* If necessary, call GetUnsupportedFeatures on VerificationResult to check which
		unsupported features were encountered (requires verification using 'detailed' APIs) */
		echo(nl2br("At least one signature contains unsupported features.".PHP_EOL));
		return False;
		// unsigned sigs skipped; parts of document may be unsigned (check GetByteRanges on signed sigs to find out)
	case PDFDoc::e_verified:
		echo(nl2br("All signed signatures in document verified.".PHP_EOL));
		return True;
	default:
		echo(nl2br("unrecognized document verification status".PHP_EOL));
		assert(False);
	}
}

function VerifyAllAndPrint($in_docpath, $in_public_key_file_path)
{
	$doc = new PDFDoc($in_docpath);
	echo(nl2br("==========".PHP_EOL));
	$opts = new VerificationOptions(VerificationOptions::e_compatibility_and_archiving);
	
	// Trust the public certificate we use for signing.
	$trusted_cert_file = new MappedFile($in_public_key_file_path);
	$file_sz = $trusted_cert_file->FileSize();
	$file_reader = new FilterReader($trusted_cert_file);
	$trusted_cert_buf = $file_reader->Read($file_sz);
	$opts->AddTrustedCertificate($trusted_cert_buf, strlen($trusted_cert_buf), VerificationOptions::e_default_trust | VerificationOptions::e_certification_trust);

	// Iterate over the signatures and verify all of them.
	$digsig_fitr = $doc->GetDigitalSignatureFieldIterator();
	$verification_status = True;
	while ($digsig_fitr->HasNext())
	{
		$curr = $digsig_fitr->Current();
		$result = $curr->Verify($opts);
		if ($result->GetVerificationStatus())
		{
			echo(nl2br("Signature verified, objnum: ".strval($curr->GetSDFObj()->GetObjNum()).PHP_EOL));
		}
		else
		{
			echo(nl2br("Signature verification failed, objnum: ".strval($curr->GetSDFObj()->GetObjNum()).PHP_EOL));
			$verification_status = False;
		}
		
		switch($result->GetDigestAlgorithm())
		{
			case DigestAlgorithm::e_SHA1:
				echo(nl2br("Digest algorithm: SHA-1".PHP_EOL));
				break;
			case DigestAlgorithm::e_SHA256:
				echo(nl2br("Digest algorithm: SHA-256".PHP_EOL));
				break;
			case DigestAlgorithm::e_SHA384:
				echo(nl2br("Digest algorithm: SHA-384".PHP_EOL));
				break;
			case DigestAlgorithm::e_SHA512:
				echo(nl2br("Digest algorithm: SHA-512".PHP_EOL));
				break;
			case DigestAlgorithm::e_RIPEMD160:
				echo(nl2br("Digest algorithm: RIPEMD-160".PHP_EOL));
				break;
			case DigestAlgorithm::e_unknown_digest_algorithm:
				echo(nl2br("Digest algorithm: unknown".PHP_EOL));
				break;
			default:
				echo(nl2br("unrecognized digest algorithm".PHP_EOL));
				assert(False);
		}
		echo(nl2br("Detailed verification result: \n\t".$result->GetDocumentStatusAsString()."\n\t"
		.$result->GetDigestStatusAsString()."\n\t"
		.$result->GetTrustStatusAsString()."\n\t"
		.$result->GetPermissionsStatusAsString().PHP_EOL));


		$changes = $result->GetDisallowedChanges();
		for ($i = 0; $i < $changes->size(); $i++)
		{
			$change = $changes->get($i);
			echo(nl2br("\tDisallowed change: ".strval($change->GetTypeAsString()).", objnum: ".strval($change->GetObjNum()).PHP_EOL));
		}
		
		// Get and print all the detailed trust-related results, if they are available.
		if ($result->HasTrustVerificationResult())
		{
			$trust_verification_result = $result->GetTrustVerificationResult();
			if ($trust_verification_result->WasSuccessful())
			{
				echo(nl2br("Trust verified.".PHP_EOL));
			}
			else
			{
				echo(nl2br("Trust not verifiable.".PHP_EOL));
			}
			echo(nl2br($trust_verification_result->GetResultString().PHP_EOL));
			
			$tmp_time_t = $trust_verification_result->GetTimeOfTrustVerification();
			
			switch ($trust_verification_result->GetTimeOfTrustVerificationEnum())
			{
				case VerificationOptions::e_current:
					echo(nl2br("Trust verification attempted with respect to current time (as epoch time): ".$tmp_time_t.PHP_EOL));
					break;
				case VerificationOptions::e_signing:
					echo(nl2br("Trust verification attempted with respect to signing time (as epoch time): ".$tmp_time_t.PHP_EOL));
					break;
				case VerificationOptions::e_timestamp:
					echo(nl2br("Trust verification attempted with respect to secure embedded timestamp (as epoch time): ".$tmp_time_t.PHP_EOL));
					break;
				default:
					echo(nl2br('unrecognized time enum value'.PHP_EOL));
					assert(False);
			}

			if ($trust_verification_result->GetCertPath()->Size() == 0)
			{
				echo(nl2br("Could not print certificate path.\n"));
			}
			else
			{
				echo(nl2br("Certificate path:\n"));
				$cert_path = $trust_verification_result->GetCertPath();
				for ($j = 0; $j < $cert_path->Size(); $j++)
				{
					echo(nl2br("\tCertificate:\n"));
					$full_cert = $cert_path->Get($j);
					echo(nl2br("\t\tIssuer names:\n"));
										
					$issuer_dn = $full_cert->GetIssuerField()->GetAllAttributesAndValues();
					for ($i = 0; $i < $issuer_dn->Size(); $i++)
					{
						echo(nl2br("\t\t\t". $issuer_dn->Get($i)->GetStringValue()."\n"));
					}
					echo(nl2br("\t\tSubject names:\n"));
					$subject_dn = $full_cert->GetSubjectField()->GetAllAttributesAndValues();
					for ($i = 0; $i < $subject_dn->Size(); $i++)
					{
						echo(nl2br("\t\t\t".$subject_dn->Get($i)->GetStringValue()."\n"));
					}
					echo(nl2br("\t\tExtensions:\n"));
					$ex = $full_cert->GetExtensions();
					for ($i = 0; $i < $ex->Size(); $i++)
					{	
						echo(nl2br("\t\t\t".$ex->Get($i)->ToString()."\n"));
					}
				}
			}
		}	
		else
		{
			echo(nl2br("No detailed trust verification result available."));
		}

		$unsupported_features = $result->GetUnsupportedFeatures();
		if (count($unsupported_features) > 0)
		{
			echo(nl2br("Unsupported features:\n"));
			for ($i = 0; $i < count($unsupported_features); $i++)
			{
				echo(nl2br("\t".$unsupported_features[$i]."\n"));
			}
		}		
		echo(nl2br("==========".PHP_EOL));
		
		$digsig_fitr->Next();
	}

	return $verification_status;
}

function CertifyPDF($in_docpath,
	$in_cert_field_name,
	$in_private_key_file_path,
	$in_keyfile_password,
	$in_appearance_image_path,
	$in_outpath)
{
	
	echo(nl2br('================================================================================'.PHP_EOL));
	echo(nl2br('Certifying PDF document'.PHP_EOL));

	// Open an existing PDF
	$doc = new PDFDoc($in_docpath);

	if ($doc->HasSignatures())
	{
		echo(nl2br('PDFDoc has signatures'.PHP_EOL));
	}
	else
	{
		echo(nl2br('PDFDoc has no signatures'.PHP_EOL));
	}

	$page1 = $doc->GetPage(1);

	// Create a text field that we can lock using the field permissions feature.
	$annot1 = TextWidget::Create($doc, new Rect(50.0, 550.0, 350.0, 600.0), "asdf_test_field");
	$page1->AnnotPushBack($annot1);

	// Create a new signature form field in the PDFDoc. The name argument is optional;
	// leaving it empty causes it to be auto-generated. However, you may need the name for later.
	// Acrobat doesn't show digsigfield in side panel if it's without a widget. Using a
	// Rect with 0 width and 0 height, or setting the NoPrint/Invisible flags makes it invisible. 
	$certification_sig_field = $doc->CreateDigitalSignatureField($in_cert_field_name);
	$widgetAnnot = SignatureWidget::Create($doc, new Rect(0.0, 100.0, 200.0, 150.0), $certification_sig_field);
	$page1->AnnotPushBack($widgetAnnot);

	// (OPTIONAL) Add an appearance to the signature field.
	$img = Image::Create($doc->GetSDFDoc(), $in_appearance_image_path);
	$widgetAnnot->CreateSignatureAppearance($img);

	// Prepare the document locking permission level. It will be applied upon document certification.
	echo(nl2br('Adding document permissions.'.PHP_EOL));
	$certification_sig_field->SetDocumentPermissions(DigitalSignatureField::e_annotating_formfilling_signing_allowed);
	
	// Prepare to lock the text field that we created earlier.
	echo(nl2br('Adding field permissions.'.PHP_EOL));
	$certification_sig_field->SetFieldPermissions(DigitalSignatureField::e_include, array('asdf_test_field'));

	$certification_sig_field->CertifyOnNextSave($in_private_key_file_path, $in_keyfile_password);

	// (OPTIONAL) Add more information to the signature dictionary.
	$certification_sig_field->SetLocation('Vancouver, BC');
	$certification_sig_field->SetReason('Document certification.');
	$certification_sig_field->SetContactInfo('www.pdftron.com');

	// Save the PDFDoc. Once the method below is called, PDFNet will also sign the document using the information provided.
	$doc->Save($in_outpath, 0);

	echo(nl2br('================================================================================'.PHP_EOL));
}

function SignPDF($in_docpath,	
	$in_approval_field_name,	
	$in_private_key_file_path, 
	$in_keyfile_password, 
	$in_appearance_img_path, 
	$in_outpath)
{
	echo(nl2br('================================================================================'.PHP_EOL));
	echo(nl2br('Signing PDF document'.PHP_EOL));

	// Open an existing PDF
	$doc = new PDFDoc($in_docpath);

	// Retrieve the unsigned approval signature field.
	$found_approval_field = $doc->GetField($in_approval_field_name);
	$found_approval_signature_digsig_field = new DigitalSignatureField($found_approval_field);
	
	// (OPTIONAL) Add an appearance to the signature field.
	$img = Image::Create($doc->GetSDFDoc(), $in_appearance_img_path);
	$found_approval_signature_widget = new SignatureWidget($found_approval_field->GetSDFObj());
	$found_approval_signature_widget->CreateSignatureAppearance($img);

	// Prepare the signature and signature handler for signing.
	$found_approval_signature_digsig_field->SignOnNextSave($in_private_key_file_path, $in_keyfile_password);

	// The actual approval signing will be done during the following incremental save operation.
	$doc->Save($in_outpath, SDFDoc::e_incremental);

	echo(nl2br('================================================================================'.PHP_EOL));
}

function ClearSignature($in_docpath,
	$in_digsig_field_name,
	$in_outpath)
{
	echo(nl2br('================================================================================'.PHP_EOL));
	echo(nl2br('Clearing certification signature'.PHP_EOL));

	$doc = new PDFDoc($in_docpath);

	$digsig = new DigitalSignatureField($doc->GetField($in_digsig_field_name));
	
	echo(nl2br('Clearing signature: '.$in_digsig_field_name.PHP_EOL));
	$digsig->ClearSignature();

	if (!$digsig->HasCryptographicSignature())
	{
		echo(nl2br('Cryptographic signature cleared properly.'.PHP_EOL));
	}

	// Save incrementally so as to not invalidate other signatures from previous saves.
	$doc->Save($in_outpath, SDFDoc::e_incremental);

	echo(nl2br('================================================================================'.PHP_EOL));
}

function PrintSignaturesInfo($in_docpath)
{
	echo(nl2br('================================================================================'.PHP_EOL));
	echo(nl2br('Reading and printing digital signature information'.PHP_EOL));

	$doc = new PDFDoc($in_docpath);
	if (!$doc->HasSignatures())
	{
		echo(nl2br('Doc has no signatures.'.PHP_EOL));
		echo(nl2br('================================================================================'.PHP_EOL));
		return;
	}
	else
	{
		echo(nl2br('Doc has signatures.'.PHP_EOL));
	}

	$fitr = $doc->GetFieldIterator();
	while ($fitr->HasNext())
	{
		$current = $fitr->Current();
		if ($current->IsLockedByDigitalSignature())
		{
			echo(nl2br("==========\nField locked by a digital signature".PHP_EOL));
		}
		else
		{
			echo(nl2br("==========\nField not locked by a digital signature".PHP_EOL));
		}

		echo(nl2br('Field name: '.$current->GetName().PHP_EOL));
		echo(nl2br('=========='.PHP_EOL));
		
		$fitr->Next();
	}

	echo(nl2br("====================\nNow iterating over digital signatures only.\n====================".PHP_EOL));

	$digsig_fitr = $doc->GetDigitalSignatureFieldIterator();
	while ($digsig_fitr->HasNext())
	{
		$current = $digsig_fitr->Current();
		echo(nl2br('=========='.PHP_EOL));
		$fld = new Field($current->GetSDFObj());
		$fname = $fld->GetName();
		echo(nl2br('Field name of digital signature: '.$fname.PHP_EOL));

		$digsigfield = $current;
		if (!$digsigfield->HasCryptographicSignature())
		{
			echo(nl2br("Either digital signature field lacks a digital signature dictionary, ".
				"or digital signature dictionary lacks a cryptographic Contents entry. ".
				"Digital signature field is not presently considered signed.\n".
				"==========".PHP_EOL));
			$digsig_fitr->Next();
			continue;
		}

		$cert_count = $digsigfield->GetCertCount();
		echo(nl2br('Cert count: '.strval($cert_count).PHP_EOL));
		for ($i = 0; $i<$cert_count; ++$i) 
		{
			$cert = $digsigfield->GetCert(i);
			echo(nl2br('Cert #'.i.' size: '.$cert.length.PHP_EOL));
		}

		$subfilter = $digsigfield->GetSubFilter();

		echo(nl2br('Subfilter type: '.strval($subfilter).PHP_EOL));

		if ($subfilter !== DigitalSignatureField::e_ETSI_RFC3161)
		{
			echo(nl2br('Signature\'s signer: '.$digsigfield->GetSignatureName().PHP_EOL));

			$signing_time = $digsigfield->GetSigningTime();
			if ($signing_time->IsValid())
			{
				echo(nl2br('Signing time is valid.'.PHP_EOL));
			}

			echo(nl2br('Location: '.$digsigfield->GetLocation().PHP_EOL));
			echo(nl2br('Reason: '.$digsigfield->GetReason().PHP_EOL));
			echo(nl2br('Contact info: '.$digsigfield->GetContactInfo().PHP_EOL));
		}
		else
		{
			echo(nl2br('SubFilter == e_ETSI_RFC3161 (DocTimeStamp; no signing info)'.PHP_EOL));
		}

		if ($digsigfield->HasVisibleAppearance())
		{
			echo(nl2br('Visible'.PHP_EOL));
		}
		else
		{
			echo(nl2br('Not visible'.PHP_EOL));
		}

		$digsig_doc_perms = $digsigfield->GetDocumentPermissions();
		$locked_fields = $digsigfield->GetLockedFields();
		foreach ($locked_fields as $locked_field)
		{
			echo(nl2br('This digital signature locks a field named: '.$locked_field.PHP_EOL));
		}

		switch ($digsig_doc_perms)
		{
			case DigitalSignatureField::e_no_changes_allowed:
				echo(nl2br('No changes to the document can be made without invalidating this digital signature.'.PHP_EOL));
				break;
			case DigitalSignatureField::e_formfilling_signing_allowed:
				echo(nl2br('Page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.'.PHP_EOL));
				break;
			case DigitalSignatureField::e_annotating_formfilling_signing_allowed:
				echo(nl2br('Annotating, page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.'.PHP_EOL));
				break;
			case DigitalSignatureField::e_unrestricted:
				echo(nl2br('Document not restricted by this digital signature.'.PHP_EOL));
				break;
			default:
				echo(nl2br('Unrecognized digital signature document permission level.'.PHP_EOL));
				assert(false);
		}
		
		echo(nl2br('=========='.PHP_EOL));
		$digsig_fitr->Next();
	}

	echo(nl2br('================================================================================'.PHP_EOL));
}

function TimestampAndEnableLTV($in_docpath, 
	$in_trusted_cert_path, 
	$in_appearance_img_path,
	$in_outpath)
{
	$doc = new PDFDoc($in_docpath);
	$doctimestamp_signature_field = $doc->CreateDigitalSignatureField();
	$tst_config = new TimestampingConfiguration("http://rfc3161timestamp.globalsign.com/advanced");
	$opts = new VerificationOptions(VerificationOptions::e_compatibility_and_archiving);
	/* It is necessary to add to the VerificationOptions a trusted root certificate corresponding to 
	the chain used by the timestamp authority to sign the timestamp token, in order for the timestamp
	response to be verifiable during DocTimeStamp signing. It is also necessary in the context of this 
	function to do this for the later LTV section, because one needs to be able to verify the DocTimeStamp 
	in order to enable LTV for it, and we re-use the VerificationOptions opts object in that part. */
	$opts->AddTrustedCertificate($in_trusted_cert_path);
	/* By default, we only check online for revocation of certificates using the newer and lighter 
	OCSP protocol as opposed to CRL, due to lower resource usage and greater reliability. However, 
	it may be necessary to enable online CRL revocation checking in order to verify some timestamps
	(i.e. those that do not have an OCSP responder URL for all non-trusted certificates). */
	$opts->EnableOnlineCRLRevocationChecking(true);

	$widgetAnnot = SignatureWidget::Create($doc, new Rect(0.0, 100.0, 200.0, 150.0), $doctimestamp_signature_field);
	$doc->GetPage(1)->AnnotPushBack($widgetAnnot);

	// (OPTIONAL) Add an appearance to the signature field.
	$img = Image::Create($doc->GetSDFDoc(), $in_appearance_img_path);
	$widgetAnnot->CreateSignatureAppearance($img);

	echo(nl2br('Testing timestamping configuration.'.PHP_EOL));
	$config_result = $tst_config->TestConfiguration($opts);
	if ($config_result->GetStatus())
	{
		echo(nl2br('Success: timestamping configuration usable. Attempting to timestamp.'.PHP_EOL));
	}
	else
	{
		// Print details of timestamping failure.
		echo(nl2br($config_result->GetString().PHP_EOL));
		if ($config_result->HasResponseVerificationResult())
		{
			$tst_result = $config_result->GetResponseVerificationResult();
			echo(nl2br('CMS digest status: '.$tst_result->GetCMSDigestStatusAsString().PHP_EOL));
			echo(nl2br('Message digest status: '.$tst_result->GetMessageImprintDigestStatusAsString().PHP_EOL));
			echo(nl2br('Trust status: '.$tst_result->GetTrustStatusAsString().PHP_EOL));
		}
		return false;
	}

	$doctimestamp_signature_field->TimestampOnNextSave($tst_config, $opts);

	// Save/signing throws if timestamping fails.
	$doc->Save($in_outpath, SDFDoc::e_incremental);

	echo(nl2br('Timestamping successful. Adding LTV information for DocTimeStamp signature.'.PHP_EOL));

	// Add LTV information for timestamp signature to document.
	$timestamp_verification_result = $doctimestamp_signature_field->Verify($opts);
	if (!$doctimestamp_signature_field->EnableLTVOfflineVerification($timestamp_verification_result))
	{
		echo(nl2br('Could not enable LTV for DocTimeStamp.'.PHP_EOL));
		return false;
	}
	$doc->Save($in_outpath, SDFDoc::e_incremental);
	echo(nl2br('Added LTV information for DocTimeStamp signature successfully.'.PHP_EOL));

	return true;
}
function main()
{
	// Initialize PDFNet
	PDFNet::Initialize();
	
	$result = true;
	$input_path = '../../TestFiles/';
	$output_path = '../../TestFiles/Output/';
	
	//////////////////// TEST 0:
	// Create an approval signature field that we can sign after certifying.
	// (Must be done before calling CertifyOnNextSave/SignOnNextSave/WithCustomHandler.)
	// Open an existing PDF
	try
	{
		$doc = new PDFDoc($input_path.'tiger.pdf');
		$widgetAnnotApproval = SignatureWidget::Create($doc, new Rect(300.0, 300.0, 500.0, 200.0), 'PDFTronApprovalSig');
		$page1 = $doc->GetPage(1);
		$page1->AnnotPushBack($widgetAnnotApproval);
		$doc->Save($output_path.'tiger_withApprovalField_output.pdf', SDFDoc::e_remove_unused);
	}
	catch (Exception $e)
	{
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
	//////////////////// TEST 1: certify a PDF.
	try
	{
		CertifyPDF($input_path.'tiger_withApprovalField.pdf',
			'PDFTronCertificationSig',
			$input_path.'pdftron.pfx',
			'password',
			$input_path.'pdftron.bmp',
			$output_path.'tiger_withApprovalField_certified_output.pdf');
		PrintSignaturesInfo($output_path.'tiger_withApprovalField_certified_output.pdf');
	}
	catch (Exception $e)
	{
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
	//////////////////// TEST 2: sign a PDF with a certification and an unsigned signature field in it.
	try
	{
		SignPDF($input_path.'tiger_withApprovalField_certified.pdf',
			'PDFTronApprovalSig',
			$input_path.'pdftron.pfx',
			'password',
			$input_path.'signature.jpg',
			$output_path.'tiger_withApprovalField_certified_approved_output.pdf');
		PrintSignaturesInfo($output_path.'tiger_withApprovalField_certified_approved_output.pdf');
	}
	catch (Exception $e)
	{
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
	//////////////////// TEST 3: Clear a certification from a document that is certified and has an approval signature.
	try
	{
		ClearSignature($input_path.'tiger_withApprovalField_certified_approved.pdf',
			'PDFTronCertificationSig',
			$output_path.'tiger_withApprovalField_certified_approved_certcleared_output.pdf');
		PrintSignaturesInfo($output_path.'tiger_withApprovalField_certified_approved_certcleared_output.pdf');
	}
	catch (Exception $e)
	{
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
	//////////////////// TEST 4: Verify a document's digital signatures.
	try
	{
		if (!VerifyAllAndPrint($input_path.'tiger_withApprovalField_certified_approved.pdf', $input_path.'pdftron.cer'))
		{
			$result = false;
		}
	}
	catch (Exception $e)
	{
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }
	//////////////////// TEST 5: Verify a document's digital signatures in a simple fashion using the document API.
	try
	{
		if (!VerifySimple($input_path.'tiger_withApprovalField_certified_approved.pdf', $input_path.'pdftron.cer'))
		{
			$result = false;
		}
	}
	catch (Exception $e)
	{
        echo(nl2br($e->getMessage().PHP_EOL));
        echo(nl2br($e->getTraceAsString().PHP_EOL));
        $result = false;
    }

	//////////////////// TEST 6: Timestamp a document, then add Long Term Validation (LTV) information for the DocTimeStamp.
	//try
	//{
	//	if(!TimestampAndEnableLTV($input_path.'tiger.pdf',
	//				$input_path.'GlobalSignRootForTST.cer',
	//				$input_path.'signature.jpg',
	//				$output_path.'tiger_DocTimeStamp_LTV.pdf'))
	//	{
	//		$result = false;
	//	}
	//}
	//catch (Exception $e)
	//{
    //    echo(nl2br($e->getMessage().PHP_EOL));
    //    echo(nl2br($e->getTraceAsString().PHP_EOL));
    //    $result = false;
    //}

	//////////////////// End of tests. ////////////////////

	if (!$result)
	{
		echo(nl2br("Tests FAILED!!!\n==========".PHP_EOL));
		return;
	}
	
	echo(nl2br("Tests successful.\n==========".PHP_EOL));
}

main();

?>
