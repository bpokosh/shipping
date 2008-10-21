# Author::    Sean Harper  (mailto:harper.sean@gmail.com)
# Copyright:: Copyright (c) 2008 Sean Harper
# License::   LGPL

# Provides shipping rates for USPS mail.
#
# Note: This uses the older V2 rate API, since the V3 rate API isn't setup on the
# testing server.  V2 is stable and will be around for some time.
# 
module Shipping
  

  class USPS < Base

    API_VERSION = "1.0001"
    
    
    def price
      @required = [:zip, :country, :sender_zip, :weight]
      @required += [:usps_account, :usps_password]
      @country ||= 'US'
      @data = String.new            
      
      shipping_pounds = @weight.floor
      shipping_ounces = (16 * (@weight - shipping_pounds)).round
      
      b = Builder::XmlMarkup.new(:target => @data)
      b.instruct!
      b.RateV2Request('USERID'=>@usps_account){ |b|
        b.Package('ID'=>'1ST'){ |b|
          b.Service ServiceTypes[@service_type] || ServiceTypes['priority']
          b.ZipOrigination @sender_zip
          b.ZipDestination @zip
          b.Pounds shipping_pounds.to_i
          b.Ounces shipping_ounces.to_i
          b.Container @container || "Flat Rate Box"
          b.Size @usps_size || "Regular"
          b.Machinable @usps_machinable unless @usps_machinable.nil?
        }
      }

      get_get_response get_url
      if r = REXML::XPath.first(@response, "//RateV2Response/Package/Postage/Rate")
        return r.text.to_f
      else
        raise ShippingError, get_error
      end
    rescue
      raise ShippingError, get_error
    end
    
    private

    # Returns a formatter error message string.
    #
    def get_error
      code = REXML::XPath.first(@response, "//Error/Number").text
      message = REXML::XPath.first(@response, "//Error/Description").text
      return "Error #{code}: #{message} \n Sent: #{@req}"
    end
    
    def get_url
      @usps_url || 'http://production.shippingapis.com/shippingapi.dll'
    end
    
    ServiceTypes = {
      "priority" => "PRIORITY",
      "express" => "EXPRESS",
      "all" => "ALL"
    }
    
  end
end
