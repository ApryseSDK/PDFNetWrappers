#!/usr/bin/python

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


import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

def VerifySimple(in_docpath, in_public_key_file_path):
	doc = PDFDoc(in_docpath)
	print("==========")
	opts = VerificationOptions(VerificationOptions.e_compatibility_and_archiving)

	# Add trust root to store of trusted certificates contained in VerificationOptions.
	opts.AddTrustedCertificate(in_public_key_file_path, VerificationOptions.e_default_trust | VerificationOptions.e_certification_trust)

	result = doc.VerifySignedDigitalSignatures(opts)
		
	if result is PDFDoc.e_unsigned:
		print("Document has no signed signature fields.")
		return False
		# e_failure == bad doc status, digest status, or permissions status
		# (i.e. does not include trust issues, because those are flaky due to being network/config-related)
	elif result is PDFDoc.e_failure:
		print("Hard failure in verification on at least one signature.")
		return False
	elif result is PDFDoc.e_untrusted:
		print("Could not verify trust for at least one signature.")
		return False
	elif result is PDFDoc.e_unsupported:
		# If necessary, call GetUnsupportedFeatures on VerificationResult to check which
		# unsupported features were encountered (requires verification using 'detailed' APIs)
		print("At least one signature contains unsupported features.")
		return False
		# unsigned sigs skipped; parts of document may be unsigned (check GetByteRanges on signed sigs to find out)
	elif result is PDFDoc.e_verified:
		print("All signed signatures in document verified.")
		return True
	else:
		print("unrecognized document verification status")
		assert False, "unrecognized document status"


def VerifyAllAndPrint(in_docpath, in_public_key_file_path):
	doc = PDFDoc(in_docpath)
	print("==========")
	opts = VerificationOptions(VerificationOptions.e_compatibility_and_archiving)
	
	# Trust the public certificate we use for signing.
	trusted_cert_buf = []
	trusted_cert_file = MappedFile(in_public_key_file_path)
	file_sz = trusted_cert_file.FileSize()
	file_reader = FilterReader(trusted_cert_file)
	trusted_cert_buf = file_reader.Read(file_sz)
	opts.AddTrustedCertificate(trusted_cert_buf, len(trusted_cert_buf), VerificationOptions.e_default_trust | VerificationOptions.e_certification_trust)

	# Iterate over the signatures and verify all of them.
	digsig_fitr = doc.GetDigitalSignatureFieldIterator()
	verification_status = True
	while (digsig_fitr.HasNext()):
		curr = digsig_fitr.Current()
		result = curr.Verify(opts)
		if result.GetVerificationStatus():
			print("Signature verified, objnum: %lu" % curr.GetSDFObj().GetObjNum())
		else:
			print("Signature verification failed, objnum: %lu" % curr.GetSDFObj().GetObjNum())
			verification_status = False

		digest_algorithm = result.GetDigestAlgorithm()
		if digest_algorithm is DigestAlgorithm.e_SHA1:
			print("Digest algorithm: SHA-1")
		elif digest_algorithm is DigestAlgorithm.e_SHA256:
			print("Digest algorithm: SHA-256")
		elif digest_algorithm is DigestAlgorithm.e_SHA384:
			print("Digest algorithm: SHA-384")
		elif digest_algorithm is DigestAlgorithm.e_SHA512:
			print("Digest algorithm: SHA-512")
		elif digest_algorithm is DigestAlgorithm.e_RIPEMD160:
			print("Digest algorithm: RIPEMD-160")
		elif digest_algorithm is DigestAlgorithm.e_unknown_digest_algorithm:
			print("Digest algorithm: unknown")
		else:
			assert False, "unrecognized document status"

		print("Detailed verification result: \n\t%s\n\t%s\n\t%s\n\t%s" % ( 
			result.GetDocumentStatusAsString(),
			result.GetDigestStatusAsString(),
			result.GetTrustStatusAsString(),
			result.GetPermissionsStatusAsString()))
			
		changes = result.GetDisallowedChanges()
		for it2 in changes:
			print("\tDisallowed change: %s, objnum: %lu" % (it2.GetTypeAsString(), it2.GetObjNum()))
		
		# Get and print all the detailed trust-related results, if they are available.
		if result.HasTrustVerificationResult():
			trust_verification_result = result.GetTrustVerificationResult()
			print("Trust verified." if trust_verification_result.WasSuccessful() else "Trust not verifiable.")
			print(trust_verification_result.GetResultString())
			
			tmp_time_t = trust_verification_result.GetTimeOfTrustVerification()
			
			trust_verification_time_enum = trust_verification_result.GetTimeOfTrustVerificationEnum()
			
			if trust_verification_time_enum is VerificationOptions.e_current:
				print("Trust verification attempted with respect to current time (as epoch time): " + str(tmp_time_t))
			elif trust_verification_time_enum is VerificationOptions.e_signing:
				print("Trust verification attempted with respect to signing time (as epoch time): " + str(tmp_time_t))
			elif trust_verification_time_enum is VerificationOptions.e_timestamp:
				print("Trust verification attempted with respect to secure embedded timestamp (as epoch time): " + str(tmp_time_t))
			else:
				assert False, "unrecognized time enum value"

			if not trust_verification_result.GetCertPath():
				print("Could not print certificate path.")
			else:
				print("Certificate path:")
				cert_path = trust_verification_result.GetCertPath()
				for j in range(len(cert_path)):
					print("\tCertificate:")
					full_cert = cert_path[j]
					print("\t\tIssuer names:")
					issuer_dn  = full_cert.GetIssuerField().GetAllAttributesAndValues()
					for i in range(len(issuer_dn)):  
						print("\t\t\t" + issuer_dn[i].GetStringValue())

					print("\t\tSubject names:")
					subject_dn = full_cert.GetSubjectField().GetAllAttributesAndValues()
					for s in subject_dn:
						print("\t\t\t" + s.GetStringValue())

					print("\t\tExtensions:")
					for x in full_cert.GetExtensions():
						print("\t\t\t" + x.ToString())
					
		else:
			print("No detailed trust verification result available.")
		
			unsupported_features = result.GetUnsupportedFeatures()
			if not unsupported_features:
				print("Unsupported features:")
				for unsupported_feature in unsupported_features:
					print("\t" + unsupported_feature)
		print("==========")
		
		digsig_fitr.Next()
	return verification_status

def CertifyPDF(in_docpath,
	in_cert_field_name,
	in_private_key_file_path,
	in_keyfile_password,
	in_appearance_image_path,
	in_outpath):
	
	print('================================================================================')
	print('Certifying PDF document')

	# Open an existing PDF
	doc = PDFDoc(in_docpath)

	if doc.HasSignatures():
		print('PDFDoc has signatures')
	else:
		print('PDFDoc has no signatures')

	page1 = doc.GetPage(1)

	# Create a text field that we can lock using the field permissions feature.
	annot1 = TextWidget.Create(doc, Rect(143, 440, 350, 460), "asdf_test_field")
	page1.AnnotPushBack(annot1)

	# Create a new signature form field in the PDFDoc. The name argument is optional;
	# leaving it empty causes it to be auto-generated. However, you may need the name for later.
	# Acrobat doesn't show digsigfield in side panel if it's without a widget. Using a
	# Rect with 0 width and 0 height, or setting the NoPrint/Invisible flags makes it invisible. 
	certification_sig_field = doc.CreateDigitalSignatureField(in_cert_field_name)
	widgetAnnot = SignatureWidget.Create(doc, Rect(143, 287, 219, 306), certification_sig_field)
	page1.AnnotPushBack(widgetAnnot)

	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc(), in_appearance_image_path)
	widgetAnnot.CreateSignatureAppearance(img)

	# Add permissions. Lock the random text field.
	print('Adding document permissions.')
	certification_sig_field.SetDocumentPermissions(DigitalSignatureField.e_annotating_formfilling_signing_allowed)
	
	# Prepare to lock the text field that we created earlier.
	print('Adding field permissions.')
	certification_sig_field.SetFieldPermissions(DigitalSignatureField.e_include, ['asdf_test_field'])

	certification_sig_field.CertifyOnNextSave(in_private_key_file_path, in_keyfile_password)

	# (OPTIONAL) Add more information to the signature dictionary.
	certification_sig_field.SetLocation('Vancouver, BC')
	certification_sig_field.SetReason('Document certification.')
	certification_sig_field.SetContactInfo('www.pdftron.com')

	# Save the PDFDoc. Once the method below is called, PDFNet will also sign the document using the information provided.
	doc.Save(in_outpath, 0)

	print('================================================================================')

def SignPDF(in_docpath,	
	in_approval_field_name,	
	in_private_key_file_path, 
	in_keyfile_password, 
	in_appearance_img_path, 
	in_outpath):
	
	print('================================================================================')
	print('Signing PDF document')

	# Open an existing PDF
	doc = PDFDoc(in_docpath)

	# Retrieve the unsigned approval signature field.
	found_approval_field = doc.GetField(in_approval_field_name)
	found_approval_signature_digsig_field = DigitalSignatureField(found_approval_field)
	
	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc(), in_appearance_img_path)
	found_approval_signature_widget = SignatureWidget(found_approval_field.GetSDFObj())
	found_approval_signature_widget.CreateSignatureAppearance(img)

	# Prepare the signature and signature handler for signing.
	found_approval_signature_digsig_field.SignOnNextSave(in_private_key_file_path, in_keyfile_password)

	# The actual approval signing will be done during the following incremental save operation.
	doc.Save(in_outpath, SDFDoc.e_incremental)

	print('================================================================================')

def ClearSignature(in_docpath,
	in_digsig_field_name,
	in_outpath):

	print('================================================================================')
	print('Clearing certification signature')

	doc = PDFDoc(in_docpath)

	digsig = DigitalSignatureField(doc.GetField(in_digsig_field_name))
	
	print('Clearing signature: ' + in_digsig_field_name)
	digsig.ClearSignature()

	if not digsig.HasCryptographicSignature():
		print('Cryptographic signature cleared properly.')

	# Save incrementally so as to not invalidate other signatures from previous saves.
	doc.Save(in_outpath, SDFDoc.e_incremental)

	print('================================================================================')

def PrintSignaturesInfo(in_docpath):
	print('================================================================================')
	print('Reading and printing digital signature information')

	doc = PDFDoc(in_docpath)
	if not doc.HasSignatures():
		print('Doc has no signatures.')
		print('================================================================================')
		return
	else:
		print('Doc has signatures.')

	fitr = doc.GetFieldIterator()
	while fitr.HasNext():
		current = fitr.Current()
		if (current.IsLockedByDigitalSignature()):
			print("==========\nField locked by a digital signature")
		else:
			print("==========\nField not locked by a digital signature")

		print('Field name: ' + current.GetName())
		print('==========')
		
		fitr.Next()

	print("====================\nNow iterating over digital signatures only.\n====================")

	digsig_fitr = doc.GetDigitalSignatureFieldIterator()
	while digsig_fitr.HasNext():
		current = digsig_fitr.Current()
		print('==========')
		print('Field name of digital signature: ' + Field(current.GetSDFObj()).GetName())

		digsigfield = current
		if not digsigfield.HasCryptographicSignature():
			print("Either digital signature field lacks a digital signature dictionary, " +
				"or digital signature dictionary lacks a cryptographic Contents entry. " +
				"Digital signature field is not presently considered signed.\n" +
				"==========")
			digsig_fitr.Next()
			continue

		cert_count = digsigfield.GetCertCount()
		print('Cert count: ' + str(cert_count))
		for i in range(cert_count):
			cert = digsigfield.GetCert(i)
			print('Cert #' + i + ' size: ' + cert.length)

		subfilter = digsigfield.GetSubFilter()

		print('Subfilter type: ' + str(subfilter))

		if subfilter is not DigitalSignatureField.e_ETSI_RFC3161:
			print('Signature\'s signer: ' + digsigfield.GetSignatureName())

			signing_time = digsigfield.GetSigningTime()
			if signing_time.IsValid():
				print('Signing time is valid.')

			print('Location: ' + digsigfield.GetLocation())
			print('Reason: ' + digsigfield.GetReason())
			print('Contact info: ' + digsigfield.GetContactInfo())
		else:
			print('SubFilter == e_ETSI_RFC3161 (DocTimeStamp; no signing info)')

		if digsigfield.HasVisibleAppearance():
			print('Visible')
		else:
			print('Not visible')

		digsig_doc_perms = digsigfield.GetDocumentPermissions()
		locked_fields = digsigfield.GetLockedFields()
		for it in locked_fields:
			print('This digital signature locks a field named: ' + it)

		if digsig_doc_perms is DigitalSignatureField.e_no_changes_allowed:
			print('No changes to the document can be made without invalidating this digital signature.')
		elif digsig_doc_perms is DigitalSignatureField.e_formfilling_signing_allowed:
			print('Page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.')
		elif digsig_doc_perms is DigitalSignatureField.e_annotating_formfilling_signing_allowed:
			print('Annotating, page template instantiation, form filling, and signing digital signatures are allowed without invalidating this digital signature.')
		elif digsig_doc_perms is DigitalSignatureField.e_unrestricted:
			print('Document not restricted by this digital signature.')
		else:
			print('Unrecognized digital signature document permission level.')
			assert(False)
		print('==========')
		digsig_fitr.Next()

	print('================================================================================')

def CustomSigningAPI(doc_path,
		cert_field_name,
		private_key_file_path,
		keyfile_password,
		public_key_file_path,
		appearance_image_path,
		digest_algorithm_type,
		PAdES_signing_mode,
		output_path):
	print('================================================================================')
	print('Custom signing PDF document')

	doc = PDFDoc(doc_path)

	page1 = doc.GetPage(1)

	digsig_field = doc.CreateDigitalSignatureField(cert_field_name)
	widgetAnnot = SignatureWidget.Create(doc, Rect(143, 287, 219, 306), digsig_field)
	page1.AnnotPushBack(widgetAnnot)

	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc(), appearance_image_path)
	widgetAnnot.CreateSignatureAppearance(img)

	# Create a digital signature dictionary inside the digital signature field, in preparation for signing.
	digsig_field.CreateSigDictForCustomSigning('Adobe.PPKLite',
		DigitalSignatureField.e_ETSI_CAdES_detached if PAdES_signing_mode else DigitalSignatureField.e_adbe_pkcs7_detached,
		7500) # For security reasons, set the contents size to a value greater than but as close as possible to the size you expect your final signature to be, in bytes.
				# ... or, if you want to apply a certification signature, use CreateSigDictForCustomCertification instead.

	# (OPTIONAL) Set the signing time in the signature dictionary, if no secure embedded timestamping support is available from your signing provider.
	current_date = Date()
	current_date.SetCurrentTime()
	digsig_field.SetSigDictTimeOfSigning(current_date)

	doc.Save(output_path, SDFDoc.e_incremental)

	# Digest the relevant bytes of the document in accordance with ByteRanges surrounding the signature.
	pdf_digest = digsig_field.CalculateDigest(digest_algorithm_type)

	signer_cert = X509Certificate(public_key_file_path)

	# Optionally, you can add a custom signed attribute at this point, such as one of the PAdES ESS attributes.
	# The function we provide takes care of generating the correct PAdES ESS attribute depending on your digest algorithm.
	pades_versioned_ess_signing_cert_attribute = DigitalSignatureField.GenerateESSSigningCertPAdESAttribute(signer_cert, digest_algorithm_type)

	# Generate the signedAttrs component of CMS, passing any optional custom signedAttrs (e.g. PAdES ESS).
	# The signedAttrs are certain attributes that become protected by their inclusion in the signature.
	signedAttrs = DigitalSignatureField.GenerateCMSSignedAttributes(pdf_digest, pades_versioned_ess_signing_cert_attribute)

	# Calculate the digest of the signedAttrs (i.e. not the PDF digest, this time).
	signedAttrs_digest = DigestAlgorithm.CalculateDigest(digest_algorithm_type, signedAttrs)

	############################ custom digest signing starts ############################
	# At this point, you can sign the digest (for example, with HSM). We use our own SignDigest function instead here as an example,
	# which you can also use for your purposes if necessary as an alternative to the handler/callback APIs (i.e. Certify/SignOnNextSave).
	signature_value = DigestAlgorithm.SignDigest(
		signedAttrs_digest,
		digest_algorithm_type,
		private_key_file_path,
		keyfile_password)
	############################ custom digest signing ends ##############################

	# Then, load all your chain certificates into a container of X509Certificate.
	chain_certs = []

	# Then, create ObjectIdentifiers for the algorithms you have used.
	# Here we use digest_algorithm_type (SHA256) for hashing, and RSAES-PKCS1-v1_5 (specified in the private key) for signing.
	digest_algorithm_oid = ObjectIdentifier(ObjectIdentifier.e_SHA256)
	signature_algorithm_oid = ObjectIdentifier(ObjectIdentifier.e_RSA_encryption_PKCS1)

	# Then, put the CMS signature components together.
	cms_signature = DigitalSignatureField.GenerateCMSSignature(
		signer_cert, chain_certs, digest_algorithm_oid, signature_algorithm_oid,
		signature_value, signedAttrs)

	# Write the signature to the document.
	doc.SaveCustomSignature(cms_signature, digsig_field, output_path)

	print('================================================================================')

def TimestampAndEnableLTV(in_docpath, 
	in_tsa_url,
	in_trusted_cert_path, 
	in_appearance_img_path,
	in_outpath):
	doc = PDFDoc(in_docpath)
	doctimestamp_signature_field = doc.CreateDigitalSignatureField()
	tst_config = TimestampingConfiguration(in_tsa_url)
	opts = VerificationOptions(VerificationOptions.e_compatibility_and_archiving)
#	It is necessary to add to the VerificationOptions a trusted root certificate corresponding to 
#	the chain used by the timestamp authority to sign the timestamp token, in order for the timestamp
#	response to be verifiable during DocTimeStamp signing. It is also necessary in the context of this 
#	function to do this for the later LTV section, because one needs to be able to verify the DocTimeStamp 
#	in order to enable LTV for it, and we re-use the VerificationOptions opts object in that part.

	opts.AddTrustedCertificate(in_trusted_cert_path)
#   	By default, we only check online for revocation of certificates using the newer and lighter 
#	OCSP protocol as opposed to CRL, due to lower resource usage and greater reliability. However, 
#	it may be necessary to enable online CRL revocation checking in order to verify some timestamps
#	(i.e. those that do not have an OCSP responder URL for all non-trusted certificates).

	opts.EnableOnlineCRLRevocationChecking(True)

	widgetAnnot = SignatureWidget.Create(doc, Rect(0.0, 100.0, 200.0, 150.0), doctimestamp_signature_field)
	doc.GetPage(1).AnnotPushBack(widgetAnnot)

	# (OPTIONAL) Add an appearance to the signature field.
	img = Image.Create(doc.GetSDFDoc(), in_appearance_img_path)
	widgetAnnot.CreateSignatureAppearance(img)

	print('Testing timestamping configuration.')
	config_result = tst_config.TestConfiguration(opts)
	if config_result.GetStatus():
		print('Success: timestamping configuration usable. Attempting to timestamp.')
	else:
		# Print details of timestamping failure.
		print(config_result.GetString())
		if config_result.HasResponseVerificationResult():
			tst_result = config_result.GetResponseVerificationResult()
			print('CMS digest status: '+ tst_result.GetCMSDigestStatusAsString())
			print('Message digest status: ' + tst_result.GetMessageImprintDigestStatusAsString())
			print('Trust status: ' + tst_result.GetTrustStatusAsString())
		return False
	

	doctimestamp_signature_field.TimestampOnNextSave(tst_config, opts)

	# Save/signing throws if timestamping fails.
	doc.Save(in_outpath, SDFDoc.e_incremental)

	print('Timestamping successful. Adding LTV information for DocTimeStamp signature.')

	# Add LTV information for timestamp signature to document.
	timestamp_verification_result = doctimestamp_signature_field.Verify(opts)
	if not doctimestamp_signature_field.EnableLTVOfflineVerification(timestamp_verification_result):
		print('Could not enable LTV for DocTimeStamp.')
		return False
	doc.Save(in_outpath, SDFDoc.e_incremental)
	print('Added LTV information for DocTimeStamp signature successfully.')

	return True

def main():
	# Initialize PDFNet
	PDFNet.Initialize(LicenseKey)
	
	result = True
	input_path = '../../TestFiles/'
	output_path = '../../TestFiles/Output/'
	
	#################### TEST 0:
	# Create an approval signature field that we can sign after certifying.
	# (Must be done before calling CertifyOnNextSave/SignOnNextSave/WithCustomHandler.)
	# Open an existing PDF
	try:
		doc = PDFDoc(input_path + 'waiver.pdf')
		
		widgetAnnotApproval = SignatureWidget.Create(doc, Rect(300, 287, 376, 306), 'PDFTronApprovalSig')
		page1 = doc.GetPage(1)
		page1.AnnotPushBack(widgetAnnotApproval)
		doc.Save(output_path + 'waiver_withApprovalField_output.pdf', SDFDoc.e_remove_unused)
	except Exception as e:
		print(e.args)
		result = False
	#################### TEST 1: certify a PDF.
	try:
		CertifyPDF(input_path + 'waiver_withApprovalField.pdf',
			'PDFTronCertificationSig',
			input_path + 'pdftron.pfx',
			'password',
			input_path + 'pdftron.bmp',
			output_path + 'waiver_withApprovalField_certified_output.pdf')
		PrintSignaturesInfo(output_path + 'waiver_withApprovalField_certified_output.pdf')
	except Exception as e:
		print(e.args)
		result = False
	#################### TEST 2: approval-sign an existing, unsigned signature field in a PDF that already has a certified signature field.
	try:
		SignPDF(input_path + 'waiver_withApprovalField_certified.pdf',
			'PDFTronApprovalSig',
			input_path + 'pdftron.pfx',
			'password',
			input_path + 'signature.jpg',
			output_path + 'waiver_withApprovalField_certified_approved_output.pdf')
		PrintSignaturesInfo(output_path + 'waiver_withApprovalField_certified_approved_output.pdf')
	except Exception as e:
		print(e.args)
		result = False
	#################### TEST 3: Clear a certification from a document that is certified and has an approval signature.
	try:
		ClearSignature(input_path + 'waiver_withApprovalField_certified_approved.pdf',
			'PDFTronCertificationSig',
			output_path + 'waiver_withApprovalField_certified_approved_certcleared_output.pdf')
		PrintSignaturesInfo(output_path + 'waiver_withApprovalField_certified_approved_certcleared_output.pdf')
	except Exception as e:
		print(e.args)
		result = False

	#################### TEST 4: Verify a document's digital signatures.
	try:
		if not VerifyAllAndPrint(input_path + "waiver_withApprovalField_certified_approved.pdf", input_path + "pdftron.cer"):
			result = False
	except Exception as e:
		print(e.args)
		result = False

	#################### TEST 5: Verify a document's digital signatures in a simple fashion using the document API.
	try:
		if not VerifySimple(input_path + 'waiver_withApprovalField_certified_approved.pdf', input_path + 'pdftron.cer'):
			result = False
	except Exception as e:
		print(e.args)
		result = False

	#################### TEST 6: Custom signing API.
	# The Apryse custom signing API is a set of APIs related to cryptographic digital signatures
	# which allows users to customize the process of signing documents. Among other things, this
	# includes the capability to allow for easy integration of PDF-specific signing-related operations
	# with access to Hardware Security Module (HSM) tokens/devices, access to cloud keystores, access
	# to system keystores, etc.
	try:
		CustomSigningAPI(input_path + "waiver.pdf",
			"PDFTronApprovalSig",
			input_path + "pdftron.pfx",
			"password",
			input_path + "pdftron.cer",
			input_path + "signature.jpg",
			DigestAlgorithm.e_SHA256,
			True,
			output_path + "waiver_custom_signed.pdf")
	except Exception as e:
		print(e.args)
		result = False

	#################### TEST 7: Timestamp a document, then add Long Term Validation (LTV) information for the DocTimeStamp.
	# try:
	# 	# Replace YOUR_URL_OF_TSA with the timestamp authority (TSA) URL to use during timestamping.
	# 	# For example, as of July 2024, http://timestamp.globalsign.com/tsa/r6advanced1 was usable.
	# 	# Note that this url may not work in the future. A reliable solution requires using your own TSA.
	# 	tsa_url = 'YOUR_URL_OF_TSA'
	# 	if tsa_url == 'YOUR_URL_OF_TSA':
	# 		raise Exception('Error: The URL of your timestamp authority was not specified.')
	#
	# 	# Replace YOUR_CERTIFICATE with the trusted root certificate corresponding to the chain used by the timestamp authority.
	# 	# For example, as of July 2024, https://secure.globalsign.com/cacert/gstsacasha384g4.crt was usable.
	# 	# Note that this certificate may not work in the future. A reliable solution requires using your own TSA certificate.
	# 	trusted_cert_path = 'YOUR_CERTIFICATE'
	# 	if trusted_cert_path == 'YOUR_CERTIFICATE':
	# 		raise Exception('Error: The path to your timestamp authority trusted root certificate was not specified.')
	#
	# 	if not TimestampAndEnableLTV(input_path + 'waiver.pdf',
	# 		tsa_url,
	# 		trusted_cert_path,
	# 		input_path + 'signature.jpg',
	# 		output_path+ 'waiver_DocTimeStamp_LTV.pdf'):
	# 		result = False
	# except Exception as e:
	# 	print(e.args)
	# 	result = False
	
	#################### End of tests. #####################

	if not result:
		print("Tests FAILED!!!\n==========")
		PDFNet.Terminate()
		return
	PDFNet.Terminate()
	print("Tests successful.\n==========")

if __name__ == '__main__':
	main()
# end if __name__ == '__main__'
