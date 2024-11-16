#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

class PDFTronLicense
	#Enter your key here. If you don't have it, please go to https://www.pdftron.com/pws/get-key to obtain a demo license or https://www.pdftron.com/form/contact-sales to obtain a production key. 
    @key = "YOUR_PDFTRON_LICENSE_KEY"
	def self.Key
    	if @key == "YOUR_PDFTRON_LICENSE_KEY"
			raise "Please enter your license key by replacing \"YOUR_PDFTRON_LICENSE_KEY\" that is assigned to the key variable in Samples/LicenseKey/RUBY/LicenseKey.rb. If you do not have a license key, please go to https://www.pdftron.com/pws/get-key to obtain a demo license or https://www.pdftron.com/form/contact-sales to obtain a production key."
		end
		@key
	end
end
