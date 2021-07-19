#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

class PDFTronLicense
	#Enter your key here. If you don't have it, please go to https://www.pdftron.com/pws/get-key to obtain a demo license or https://www.pdftron.com/form/contact-sales to obtain a production key. 
    @key = "YOUR_PDFTRON_LICENSE_KEY"
	def self.Key
    	if @key == "YOUR_PDFTRON_LICENSE_KEY"
			raise "Please go to https://www.pdftron.com/pws/get-key to obtain a demo license or https://www.pdftron.com/form/contact-sales to obtain a production key."
		end
		@key
	end
end
