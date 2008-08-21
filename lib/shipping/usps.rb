# Author::    Sean Harper  (mailto:harper.sean@gmail.com)
# Copyright:: Copyright (c) 2008 Sean Harper
# License::   LGPL

module Shipping
  

	class USPS < Base

		API_VERSION = "1.0001"
		
		
		def price
			@required = [:zip, :country, :sender_zip, :weight]
			@required += [:usps_account]
			@country ||= 'US'
			@data = String.new			
			
      shipping_pounds = @weight.floor
      shipping_ounces = (16 * (@weight - shipping_pounds)).round
			
			b = Builder::XmlMarkup.new(:target => @data)
			b.instruct!
      b.RateV3Request('USERID'=>@usps_account){ |b|
        b.Package('ID'=>'1ST'){ |b|
          b.Service ServiceTypes[@service_type] || ServiceTypes['priority']
          b.ZipOrigination @sender_zip
          b.ZipDestination @zip
          b.Pounds shipping_pounds.to_i
          b.Ounces shipping_ounces.to_i
          b.Size "Regular"
        }
      }
      get_get_response 'http://production.shippingapis.com/shippingapi.dll'
      r = REXML::XPath.first(@response, "//RateV3Response/Package/Postage/Rate").text.to_f
			return r
		rescue
		  raise ShippingError, get_error
		end
		
		private
		
		def get_error
			code = REXML::XPath.first(@response, "//Error/Number").text
			message = REXML::XPath.first(@response, "//Error/Description").text
      debugger
			return "Error #{code}: #{message} \n Sent: #{@req}"
		end
		
		ServiceTypes = {
			"priority" => "PRIORITY",
			"express" => "EXPRESS"
		}
		
	end
end