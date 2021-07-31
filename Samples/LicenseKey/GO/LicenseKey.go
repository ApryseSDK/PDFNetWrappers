//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package PDFTronLicense

// Enter your license key here. Please go to https://www.pdftron.com/pws/get-key to obtain a demo key or https://www.pdftron.com/form/contact-sales to obtain a production key.
var Key = "YOUR_PDFTRON_LICENSE_KEY"
func init() {
	if (Key == "YOUR_PDFTRON_LICENSE_KEY"){
		panic("Please go to https://www.pdftron.com/pws/get-key to obtain a demo key or https://www.pdftron.com/form/contact-sales to obtain a production key.")
	}
}
