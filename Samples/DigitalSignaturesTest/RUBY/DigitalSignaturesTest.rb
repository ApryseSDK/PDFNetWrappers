#!/usr/bin/ruby

#-----------------------------------------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#-----------------------------------------------------------------------------------------------------------------------

##----------------------------------------------------------------------------------------------------------------------
## This sample demonstrates the basic usage of the high-level digital signatures API in PDFNet.
##
## The following steps reflect typical intended usage of the digital signatures API:
##
##	0.	Start with a PDF with or without form fields in it that one would like to lock (or, one can add a field, see (1)).
##	
##	1.	EITHER: 
##		(a) Call doc.CreateDigitalSignatureField, optionally providing a name. You receive a DigitalSignatureField.
##		-OR-
##		(b) If you didn't just create the digital signature field that you want to sign/certify, find the existing one within the 
##		document by using PDFDoc.DigitalSignatureFieldIterator or by using PDFDoc.GetField to get it by its fully qualified name.
##	
##	2.	Create a signature widget annotation, and pass the DigitalSignatureField that you just created or found. 
##		If you want it to be visible, provide a Rect argument with a non-zero width or height, and don't set the
##		NoView and Hidden flags. [Optionally, add an appearance to the annotation when you wish to sign/certify.]
##		
##	[3. (OPTIONAL) Add digital signature restrictions to the document using the field modification permissions (SetFieldPermissions) 
##		or document modification permissions functions (SetDocumentPermissions) of DigitalSignatureField. These features disallow 
##		certain types of changes to be made to the document without invalidating the cryptographic digital signature once it
##		is signed.]
##		
##	4. 	Call either CertifyOnNextSave or SignOnNextSave. There are three overloads for each one (six total):
##		a.	Taking a PKCS #12 keyfile path and its password
##		b.	Taking a buffer containing a PKCS #12 private keyfile and its password
##		c.	Taking a unique identifier of a signature handler registered with the PDFDoc. This overload is to be used
##			in the following fashion: 
##			i)		Extend and implement a new SignatureHandler. The SignatureHandler will be used to add or 
##					validate/check a digital signature.
##			ii)		Create an instance of the implemented SignatureHandler and register it with PDFDoc with 
##					pdfdoc.AddSignatureHandler(). The method returns a SignatureHandlerId.
##			iii)	Call SignOnNextSaveWithCustomHandler/CertifyOnNextSaveWithCustomHandler with the SignatureHandlerId.
##		NOTE: It is only possible to sign/certify one signature per call to the Save function.
##	
##	5.	Call pdfdoc.Save(). This will also create the digital signature dictionary and write a cryptographic signature to it.
##		IMPORTANT: If there are already signed/certified digital signature(s) in the document, you must save incrementally
##		so as to not invalidate the other signature(s). 
##
## Additional processing can be done before document is signed. For example, UseSignatureHandler() returns an instance
## of SDF dictionary which represents the signature dictionary (or the /V entry of the form field). This can be used to
## add additional information to the signature dictionary (e.g. Name, Reason, Location, etc.).
##
## Although the steps above describes extending the SignatureHandler class, this sample demonstrates the use of
## StdSignatureHandler (a built-in SignatureHandler in PDFNet) to sign a PDF file.
##----------------------------------------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
require '../../LicenseKey/RUBY/LicenseKey'

include PDFNetRuby

$stdout.sync = true
def VerifySimple(in_docpath, in_public_key_file_path)
	doc = PDFDoc.new(in_docpath)
	puts("==========")
	opts = VerificationOptions.new(VerificationOptions::E_compatibility_and_archiving)

	# Add trust root to store of trusted certificates contained in VerificationOptions.
	opts.AddTrustedCertificate(in_public_key_file_path, VerificationOptions::E_default_trust | VerificationOptions::E_certification_trust)

	result = doc.VerifySignedDigitalSignatures(opts)
	case result	
	when PDFDoc::E_unsigned
		puts("Document has no signed signature fields.")
		return false
		# e_failure == bad doc status, digest status, or permissions status
		# (i.e. does not include trust issues, because those are flaky due to being network/config-related)
	when PDFDoc::E_failure
		puts("Hard failure in verification on at least one signature.")
		return false
	when PDFDoc::E_untrusted
		puts("Could not verify trust for at least one signature.")
		return false
	when PDFDoc::E_unsupported
		# If necessary, call GetUnsupportedFeatures on VerificationResult to check which
		# unsupported features were encountered (requires verification using 'detailed' APIs)
		puts("At least one signature contains unsupported features.")
		return false
		# unsigned sigs skipped; parts of document may be unsigned (check GetByteRanges on signed sigs to find out)
	when PDFDoc::E_verified
		puts("All signed signatures in document verified.")
		return true
	else
		puts("unrecognized document verification status")
		assert(false)
	end
end # VerifySimple()
	
def VerifyAllAndPrint(in_docpath, in_public_key_file_path)
	doc = PDFDoc.new(in_docpath)
	puts("==========")
	opts = VerificationOptions.new(VerificationOptions::E_compatibility_and_archiving)
	
	# Trust the public certificate we use for signing.
	trusted_cert_buf = []
	trusted_cert_file = MappedFile.new(in_public_key_file_path)
	file_sz = trusted_cert_file.FileSize()
	file_reader = FilterReader.new(trusted_cert_file)
	trusted_cert_buf = file_reader.Read(file_sz)
	opts.AddTrustedCertificate(trusted_cert_buf, trusted_cert_buf.length, VerificationOptions::E_default_trust | VerificationOptions::E_certification_trust)

	# Iterate over the signatures and verify all of them.
	digsig_fitr = doc.GetDigitalSignatureFieldIterator()
	verification_status = true
	while digsig_fitr.HasNext() do
		curr = digsig_fitr.Current()
		result = curr.Verify(opts)
		if result.GetVerificationStatus()
			puts("Signature verified, objnum: " + curr.GetSDFObj().GetObjNum().to_s)
		else
			puts("Signature verification failed, objnum: " + curr.GetSDFObj().GetObjNum().to_s)
			verification_status = false
		end

		case result.GetDigestAlgorithm()
		when DigestAlgorithm::E_SHA1
			puts("Digest algorithm: SHA-1")
		when DigestAlgorithm::E_SHA256
			puts("Digest algorithm: SHA-256")
		when DigestAlgorithm::E_SHA384
			puts("Digest algorithm: SHA-384")
		when DigestAlgorithm::E_SHA512
			puts("Digest algorithm: SHA-512")
		when DigestAlgorithm::E_RIPEMD160
			puts("Digest algorithm: RIPEMD-160")
		when DigestAlgorithm::E_unknown_digest_algorithm
			puts("Digest algorithm: unknown")
		else
			puts("unrecognized digest algorithm")
			assert(false)
		end
	
		puts("Detailed verification result: \n\t" +
			result.GetDocumentStatusAsString() + "\n\t" +
			result.GetDigestStatusAsString() + "\n\t" +
			result.GetTrustStatusAsString() + "\n\t" +
			result.GetPermissionsStatusAsString() )
			
		changes = result.GetDisallowedChanges()
		for it2 in changes
			puts("\tDisallowed change: " + it2.GetTypeAsString() + ", objnum: " + it2.GetObjNum().to_s)
		end
		
		# Get and print all the detailed trust-related results, if they are available.
		if result.HasTrustVerificationResult()
			trust_verification_result = result.GetTrustVerificationResult()
			if trust_verification_result.WasSuccessful()
				puts("Trust verified.")
			else
				puts("Trust not verifiable.")
			end
			puts(trust_verification_result.GetResultString())
			
			tmp_time_t = trust_verification_result.GetTimeOfTrustVerification()
			
			case trust_verification_result.GetTimeOfTrustVerificationEnum()
			when VerificationOptions::E_current
				puts("Trust verification attempted with respect to current time (as epoch time): " + tmp_time_t.to_s)
			when VerificationOptions::E_signing
				puts("Trust verification attempted with respect to signing time (as epoch time): " + tmp_time_t.to_s)
			when VerificationOptions::E_timestamp
				puts("Trust verification attempted with respect to secure embedded timestamp (as epoch time): " + tmp_time_t.to_s)
			else
				puts("unrecognized time enum value")
				assert(false)
			end
			if trust_verification_result.GetCertPath().length() == 0
				puts("Could not print certificate path.")
			else
				puts("Certificate path:")
				cert_path = trust_verification_result.GetCertPath()
				for j in 0..cert_path.length()-1
					full_cert = cert_path[j]
					puts("\tCertificate:")
					puts("\t\tIssuer names:")
					issuer_dn  = full_cert.GetIssuerField().GetAllAttributesAndValues()
					for i in 0..issuer_dn.length()-1  
						puts("\t\t\t" + issuer_dn[i].GetStringValue())
					end

					puts("\t\tSubject names:")
					subject_dn = full_cert.GetSubjectField().GetAllAttributesAndValues()
					for i in 0..subject_dn.length()-1
						puts("\t\t\t" + subject_dn[i].GetStringValue())
					end
					puts("\t\tExtensions:")
					ex = full_cert.GetExtensions()
					for i in 0..ex.length()-1
						puts("\t\t\t" + ex[i].ToString())
					end
				end
			end
		else
			puts("No detailed trust verification result available.")
		end
		
		unsupported_features = result.GetUnsupportedFeatures()
		if unsupported_features.length()>0
			puts("Unsupported features:")
			for i in 0..unsupported_features.length()-1
				puts("\t" + unsupported_features[i])		
			end
		end
	puts("==========")
		
		digsig_fitr.Next()
	end

	return verification_status
end # VerifyAllAndPrint

def CertifyPDF(in_docpath,
	in_cert_field_name,
	in_private_key_file_path,
	in_keyfile_password,
	in_appearance_image_path,
	in_outpath)
	
	puts('================================================================================');
	puts('Certifying PDF document');

	# Open an existing PDF
	doc = PDFDoc.new(in_docpath);

	if (doc.HasSignatures())
		puts('PDFDoc has signatures');
	else
		puts('PDFDoc has no signatures');
	end

	page1 = doc.GetPage(1);

	# Create a text field that we can lock using the field permissions feature.
	annot1 = TextWidget.Create(doc, Rect.new(143, 440, 350, 460), "asdf_test_field");
	page1.AnnotPushBack(annot1);

	# Create a new signature form field in the PDFDoc. The name argument is optional;
	# leaving it empty causes it to be auto-generated. However, you may need the name for later.
	# Acrobat doesn't show digsigfield in side panel if it's without a widget. Using a
	# Rect with 0 width and 0 height, or setting the NoPrint/Invisible flags makes it invisible. 
	certification_sig_field = doc.CreateDigitalSignatureField(in_cert_field_name);
	widgetAnnot = SignatureWidget.Create(doc, Rect.new(143, 287, 219, 306), certification_sig_field);
	page1.AnnotPushBack(widgetAnnot);

	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc, in_appearance_image_path);
	widgetAnnot.CreateSignatureAppearance(img);

	# Add permissions. Lock the random text field.
	puts('Adding document permissions.');
	certification_sig_field.SetDocumentPermissions(DigitalSignatureField::E_annotating_formfilling_signing_allowed);
	
	# Prepare to lock the text field that we created earlier.
	puts('Adding field permissions.');
	certification_sig_field.SetFieldPermissions(DigitalSignatureField::E_include, ['asdf_test_field']);

	certification_sig_field.CertifyOnNextSave(in_private_key_file_path, in_keyfile_password);

	# (OPTIONAL) Add more information to the signature dictionary.
	certification_sig_field.SetLocation('Vancouver, BC');
	certification_sig_field.SetReason('Document certification.');
	certification_sig_field.SetContactInfo('www.pdftron.com');

	# Save the PDFDoc. Once the method below is called, PDFNet will also sign the document using the information provided.
	doc.Save(in_outpath, 0);

	puts('================================================================================');
end # def CertifyPDF

def SignPDF(in_docpath,	
	in_approval_field_name,	
	in_private_key_file_path, 
	in_keyfile_password, 
	in_appearance_img_path, 
	in_outpath)
	
	puts('================================================================================');
	puts('Signing PDF document');

	# Open an existing PDF
	doc = PDFDoc.new(in_docpath);

	# Retrieve the unsigned approval signature field.
	found_approval_field = doc.GetField(in_approval_field_name);
	found_approval_signature_digsig_field = DigitalSignatureField.new(found_approval_field);
	
	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc, in_appearance_img_path);
	found_approval_signature_widget = SignatureWidget.new(found_approval_field.GetSDFObj());
	found_approval_signature_widget.CreateSignatureAppearance(img);

	# Prepare the signature and signature handler for signing.
	found_approval_signature_digsig_field.SignOnNextSave(in_private_key_file_path, in_keyfile_password);

	# The actual approval signing will be done during the following incremental save operation.
	doc.Save(in_outpath, SDFDoc::E_incremental);

	puts('================================================================================');
	
end # def SignPDF

def ClearSignature(in_docpath,
	in_digsig_field_name,
	in_outpath)

	puts('================================================================================');
	puts('Clearing certification signature');

	doc = PDFDoc.new(in_docpath);

	digsig = DigitalSignatureField.new(doc.GetField(in_digsig_field_name));
	
	puts('Clearing signature: ' + in_digsig_field_name);
	digsig.ClearSignature();

	if (!digsig.HasCryptographicSignature())
		puts('Cryptographic signature cleared properly.');
	end

	# Save incrementally so as to not invalidate other signatures from previous saves.
	doc.Save(in_outpath, SDFDoc::E_incremental);

	puts('================================================================================');

end # def ClearSignature

def PrintSignaturesInfo(in_docpath)
	puts('================================================================================');
	puts('Reading and printing digital signature information');

	doc = PDFDoc.new(in_docpath);
	if (!doc.HasSignatures())
		puts('Doc has no signatures.');
		puts('================================================================================');
		return;
	else
		puts('Doc has signatures.');
	end

	fitr = doc.GetFieldIterator()
	while fitr.HasNext() do
		current = fitr.Current();
		if (current.IsLockedByDigitalSignature())
			puts("==========\nField locked by a digital signature");
		else
			puts("==========\nField not locked by a digital signature");
		end

		puts('Field name: ' + current.GetName());
		puts('==========');
		
		fitr.Next()
	end

	puts("====================\nNow iterating over digital signatures only.\n====================");

	digsig_fitr = doc.GetDigitalSignatureFieldIterator();
	while digsig_fitr.HasNext() do
		current = digsig_fitr.Current();
		puts('==========');
		puts('Field name of digital signature: ' + Field.new(current.GetSDFObj()).GetName());

		digsigfield = current;
		if (!digsigfield.HasCryptographicSignature())
			puts("Either digital signature field lacks a digital signature dictionary, " +
				"or digital signature dictionary lacks a cryptographic Contents entry. " +
				"Digital signature field is not presently considered signed.\n" +
				"==========");
			digsig_fitr.Next()
			next;
		end

		cert_count = digsigfield.GetCertCount();
		puts('Cert count: ' + cert_count.to_s);
		for i in 0...cert_count
			cert = digsigfield.GetCert(i);
			puts('Cert #' + i + ' size: ' + cert.length);
		end

		subfilter = digsigfield.GetSubFilter();

		puts('Subfilter type: ' + subfilter.to_s);

		if (subfilter != DigitalSignatureField::E_ETSI_RFC3161)
			puts('Signature\'s signer: ' + digsigfield.GetSignatureName());

			signing_time = digsigfield.GetSigningTime();
			if (signing_time.IsValid())
				puts('Signing time is valid.');
			end

			puts('Location: ' + digsigfield.GetLocation());
			puts('Reason: ' + digsigfield.GetReason());
			puts('Contact info: ' + digsigfield.GetContactInfo());
		else
			puts('SubFilter == e_ETSI_RFC3161 (DocTimeStamp; no signing info)');
		end

		if (digsigfield.HasVisibleAppearance())
			puts('Visible');
		else
			puts('Not visible');
		end

		digsig_doc_perms = digsigfield.GetDocumentPermissions();
		locked_fields = digsigfield.GetLockedFields();
		for it in locked_fields
			puts('This digital signature locks a field named: ' + it);
		end

		case digsig_doc_perms
		when DigitalSignatureField::E_no_changes_allowed
			puts('No changes to the document can be made without invalidating this digital signature.');
		when DigitalSignatureField::E_formfilling_signing_allowed
			puts('Page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.');
		when DigitalSignatureField::E_annotating_formfilling_signing_allowed
			puts('Annotating, page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.');
		when DigitalSignatureField::E_unrestricted
			puts('Document not restricted by this digital signature.');
		else
			puts('Unrecognized digital signature document permission level.');
			assert(false);
		end
		puts('==========');
		digsig_fitr.Next()
	end

	puts('================================================================================');
end # def PrintSignaturesInfo

def CustomSigningAPI(doc_path,
		cert_field_name,
		private_key_file_path,
		keyfile_password,
		public_key_file_path,
		appearance_image_path,
		digest_algorithm_type,
		pades_signing_mode,
		output_path)
	puts('================================================================================');
	puts('Custom signing PDF document');

	doc = PDFDoc.new(doc_path);

	page1 = doc.GetPage(1);

	digsig_field = doc.CreateDigitalSignatureField(cert_field_name);
	widgetAnnot = SignatureWidget.Create(doc, Rect.new(143, 287, 219, 306), digsig_field);
	page1.AnnotPushBack(widgetAnnot);

	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc(), appearance_image_path);
	widgetAnnot.CreateSignatureAppearance(img);

	# Create a digital signature dictionary inside the digital signature field, in preparation for signing.
	digsig_field.CreateSigDictForCustomSigning("Adobe.PPKLite",
		pades_signing_mode ? DigitalSignatureField::E_ETSI_CAdES_detached : DigitalSignatureField::E_adbe_pkcs7_detached,
		7500); # For security reasons, set the contents size to a value greater than but as close as possible to the size you expect your final signature to be, in bytes.
				# ... or, if you want to apply a certification signature, use CreateSigDictForCustomCertification instead.

	# (OPTIONAL) Set the signing time in the signature dictionary, if no secure embedded timestamping support is available from your signing provider.
	current_date = Date.new();
	current_date.SetCurrentTime();
	digsig_field.SetSigDictTimeOfSigning(current_date);

	doc.Save(output_path, SDFDoc::E_incremental);

	# Digest the relevant bytes of the document in accordance with ByteRanges surrounding the signature.
	pdf_digest = digsig_field.CalculateDigest(digest_algorithm_type);

	signer_cert = X509Certificate.new(public_key_file_path);

	# Optionally, you can add a custom signed attribute at this point, such as one of the PAdES ESS attributes.
	# The function we provide takes care of generating the correct PAdES ESS attribute depending on your digest algorithm.
	pades_versioned_ess_signing_cert_attribute = DigitalSignatureField.GenerateESSSigningCertPAdESAttribute(signer_cert, digest_algorithm_type);

	# Generate the signedAttrs component of CMS, passing any optional custom signedAttrs (e.g. PAdES ESS).
	# The signedAttrs are certain attributes that become protected by their inclusion in the signature.
	signedAttrs = DigitalSignatureField.GenerateCMSSignedAttributes(pdf_digest, pades_versioned_ess_signing_cert_attribute);

	# Calculate the digest of the signedAttrs (i.e. not the PDF digest, this time).
	signedAttrs_digest = DigestAlgorithm.CalculateDigest(digest_algorithm_type, signedAttrs);

	############################ custom digest signing starts ############################
	# At this point, you can sign the digest (for example, with HSM). We use our own SignDigest function instead here as an example,
	# which you can also use for your purposes if necessary as an alternative to the handler/callback APIs (i.e. Certify/SignOnNextSave).
	signature_value = DigestAlgorithm.SignDigest(
		signedAttrs_digest,
		digest_algorithm_type,
		private_key_file_path,
		keyfile_password);
	############################ custom digest signing ends ##############################

	# Then, load all your chain certificates into a container of X509Certificate.
	chain_certs = VectorX509Certificate.new();

	# Then, create ObjectIdentifiers for the algorithms you have used.
	# Here we use digest_algorithm_type (SHA256) for hashing, and RSAES-PKCS1-v1_5 (specified in the private key) for signing.
	digest_algorithm_oid = ObjectIdentifier.new(ObjectIdentifier::E_SHA256);
	signature_algorithm_oid = ObjectIdentifier.new(ObjectIdentifier::E_RSA_encryption_PKCS1);

	# Then, put the CMS signature components together.
	cms_signature = DigitalSignatureField.GenerateCMSSignature(
		signer_cert, chain_certs, digest_algorithm_oid, signature_algorithm_oid,
		signature_value, signedAttrs);

	# Write the signature to the document.
	doc.SaveCustomSignature(cms_signature, digsig_field, output_path);

	puts('================================================================================');
end # def CustomSigningAPI

def TimestampAndEnableLTV(in_docpath,
	in_tsa_url,
	in_trusted_cert_path,
	in_appearance_img_path,
	in_outpath)
	doc = PDFDoc.new(in_docpath);
	doctimestamp_signature_field = doc.CreateDigitalSignatureField();
	tst_config = TimestampingConfiguration.new(in_tsa_url);
	opts = VerificationOptions.new(VerificationOptions::E_compatibility_and_archiving);
#	It is necessary to add to the VerificationOptions a trusted root certificate corresponding to 
#	the chain used by the timestamp authority to sign the timestamp token, in order for the timestamp
#	response to be verifiable during DocTimeStamp signing. It is also necessary in the context of this 
#	function to do this for the later LTV section, because one needs to be able to verify the DocTimeStamp 
#	in order to enable LTV for it, and we re-use the VerificationOptions opts object in that part.

	opts.AddTrustedCertificate(in_trusted_cert_path);
#   	By default, we only check online for revocation of certificates using the newer and lighter 
#	OCSP protocol as opposed to CRL, due to lower resource usage and greater reliability. However, 
#	it may be necessary to enable online CRL revocation checking in order to verify some timestamps
#	(i.e. those that do not have an OCSP responder URL for all non-trusted certificates).

	opts.EnableOnlineCRLRevocationChecking(true);

	widgetAnnot = SignatureWidget.Create(doc, Rect.new(0.0, 100.0, 200.0, 150.0), doctimestamp_signature_field);
	doc.GetPage(1).AnnotPushBack(widgetAnnot);

	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc(), in_appearance_img_path);
	widgetAnnot.CreateSignatureAppearance(img);

	puts('Testing timestamping configuration.');
	config_result = tst_config.TestConfiguration(opts);
	if (config_result.GetStatus())
		puts('Success: timestamping configuration usable. Attempting to timestamp.');
	else
		# Print details of timestamping failure.
		puts(config_result.GetString());
		if config_result.HasResponseVerificationResult()
			tst_result = config_result.GetResponseVerificationResult();
			puts('CMS digest status: '+ tst_result.GetCMSDigestStatusAsString());
			puts('Message digest status: ' + tst_result.GetMessageImprintDigestStatusAsString());
			puts('Trust status: ' + tst_result.GetTrustStatusAsString());
		end
		return false;
	end

	doctimestamp_signature_field.TimestampOnNextSave(tst_config, opts);

	# Save/signing throws if timestamping fails.
	doc.Save(in_outpath, SDFDoc::E_incremental);

	puts('Timestamping successful. Adding LTV information for DocTimeStamp signature.');

	# Add LTV information for timestamp signature to document.
	timestamp_verification_result = doctimestamp_signature_field.Verify(opts);
	if !doctimestamp_signature_field.EnableLTVOfflineVerification(timestamp_verification_result)
		puts('Could not enable LTV for DocTimeStamp.');
		return false;
	end
	doc.Save(in_outpath, SDFDoc::E_incremental);
	puts('Added LTV information for DocTimeStamp signature successfully.');

	return true;
end

def main()
    # Initialize PDFNet
    PDFNet.Initialize(PDFTronLicense.Key)
	
    result = true
	input_path = '../../TestFiles/';
	output_path = '../../TestFiles/Output/';
	
	#################### TEST 0:
	# Create an approval signature field that we can sign after certifying.
	# (Must be done before calling CertifyOnNextSave/SignOnNextSave/WithCustomHandler.)
	# Open an existing PDF
	begin
		doc = PDFDoc.new(input_path + 'waiver.pdf');
		
		widgetAnnotApproval = SignatureWidget.Create(doc, Rect.new(300, 287, 376, 306), 'PDFTronApprovalSig');
		page1 = doc.GetPage(1);
		page1.AnnotPushBack(widgetAnnotApproval);
		doc.Save(output_path + 'waiver_withApprovalField_output.pdf', SDFDoc::E_remove_unused);
	rescue Exception => e
        puts(e.message)
        puts(e.backtrace.inspect)
		result = false
    end
	
	#################### TEST 1: certify a PDF.
	begin
		CertifyPDF(input_path + 'waiver_withApprovalField.pdf',
			'PDFTronCertificationSig',
			input_path + 'pdftron.pfx',
			'password',
			input_path + 'pdftron.bmp',
			output_path + 'waiver_withApprovalField_certified_output.pdf');
		PrintSignaturesInfo(output_path + 'waiver_withApprovalField_certified_output.pdf');
	rescue Exception => e
        puts(e.message)
        puts(e.backtrace.inspect)
		result = false
    end
	#################### TEST 2: approval-sign an existing, unsigned signature field in a PDF that already has a certified signature field.
	begin
		SignPDF(input_path + 'waiver_withApprovalField_certified.pdf',
			'PDFTronApprovalSig',
			input_path + 'pdftron.pfx',
			'password',
			input_path + 'signature.jpg',
			output_path + 'waiver_withApprovalField_certified_approved_output.pdf');
		PrintSignaturesInfo(output_path + 'waiver_withApprovalField_certified_approved_output.pdf');
	rescue Exception => e
        puts(e.message)
        puts(e.backtrace.inspect)
		result = false
    end

	#################### TEST 3: Clear a certification from a document that is certified and has an approval signature.
	begin
		ClearSignature(input_path + 'waiver_withApprovalField_certified_approved.pdf',
			'PDFTronCertificationSig',
			output_path + 'waiver_withApprovalField_certified_approved_certcleared_output.pdf');
		PrintSignaturesInfo(output_path + 'waiver_withApprovalField_certified_approved_certcleared_output.pdf');
	rescue Exception => e
        puts(e.message)
        puts(e.backtrace.inspect)
		result = false
    end

	#################### TEST 4: Verify a document's digital signatures.
	begin
		if !VerifyAllAndPrint(input_path + "waiver_withApprovalField_certified_approved.pdf", input_path + "pdftron.cer")
			return false;
		end
	rescue Exception => e
        puts(e.message);
        puts(e.backtrace.inspect);
	end

	#################### TEST 5: Verify a document's digital signatures in a simple fashion using the document API.
	begin
		if !VerifySimple(input_path + 'waiver_withApprovalField_certified_approved.pdf', input_path + 'pdftron.cer')
			result = false;
		end
	rescue Exception => e
        puts(e.message);
        puts(e.backtrace.inspect);
	end
	
	#################### TEST 6: Custom signing API.
	# The Apryse custom signing API is a set of APIs related to cryptographic digital signatures
	# which allows users to customize the process of signing documents. Among other things, this
	# includes the capability to allow for easy integration of PDF-specific signing-related operations
	# with access to Hardware Security Module (HSM) tokens/devices, access to cloud keystores, access
	# to system keystores, etc.
	begin
		CustomSigningAPI(input_path + "waiver.pdf",
			"PDFTronApprovalSig",
			input_path + "pdftron.pfx",
			"password",
			input_path + "pdftron.cer",
			input_path + "signature.jpg",
			DigestAlgorithm::E_SHA256,
			true,
			output_path + "waiver_custom_signed.pdf")
	rescue Exception => e
		puts(e.message);
		puts(e.backtrace.inspect);
	end

	#################### TEST 7: Timestamp a document, then add Long Term Validation (LTV) information for the DocTimeStamp.
	# begin
	# 	# Replace YOUR_URL_OF_TSA with the timestamp authority (TSA) URL to use during timestamping.
	# 	# For example, as of July 2024, http://timestamp.globalsign.com/tsa/r6advanced1 was usable.
	# 	# Note that this url may not work in the future. A reliable solution requires using your own TSA.
	# 	tsa_url = 'YOUR_URL_OF_TSA';
	# 	if tsa_url == 'YOUR_URL_OF_TSA'
	# 		raise 'Error: The URL of your timestamp authority was not specified.';
	# 	end
	#
	# 	# Replace YOUR_CERTIFICATE with the trusted root certificate corresponding to the chain used by the timestamp authority.
	# 	# For example, as of July 2024, https://secure.globalsign.com/cacert/gstsacasha384g4.crt was usable.
	# 	# Note that this certificate may not work in the future. A reliable solution requires using your own TSA certificate.
	# 	trusted_cert_path = 'YOUR_CERTIFICATE';
	# 	if trusted_cert_path == 'YOUR_CERTIFICATE'
	# 		raise 'Error: The path to your timestamp authority trusted root certificate was not specified.';
	# 	end
	#
	# 	if !TimestampAndEnableLTV(input_path + 'waiver.pdf',
	# 		tsa_url,
	# 		trusted_cert_path,
	# 		input_path + 'signature.jpg',
	# 		output_path+ 'waiver_DocTimeStamp_LTV.pdf')
	# 		result = false;
	# 	end
	# rescue Exception => e
	# 	puts(e.message);
	# 	puts(e.backtrace.inspect);
	# 	result = false;
	# end

	#################### End of tests. ####################
	PDFNet.Terminate
	if (!result)
        	puts("Tests FAILED!!!\n==========")
        	return
	end # if (!result)
	
	puts("Tests successful.\n==========")

end # def main()

main()
