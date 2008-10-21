# Author::    Sean Harper  (mailto:harper.sean@gmail.com)
# Copyright:: Copyright (c) 2008 Sean Harper
# License::   LGPL

# Provides shipping rates for USPS mail.
#
# Note: This uses the older V2 rate API, since the V3 rate API isn't setup on the
# testing server
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
      b.RateV2Request('USERID'=>@usps_account){ |b| # , 'PASSWORD' => @usps_password){ |b|
        b.Package('ID'=>'1ST'){ |b|
          b.Service ServiceTypes[@service_type] || ServiceTypes['priority']
          b.ZipOrigination @sender_zip
          b.ZipDestination @zip
          b.Pounds shipping_pounds.to_i
          b.Ounces shipping_ounces.to_i
          b.Container @container || "Flat Rate Box"
          b.Size "Regular"
          b.Machinable @machinable unless @machinable.nil?
        }
      }

      get_get_response get_url
      if r = REXML::XPath.first(@response, "//RateV2Response/Package/Postage/Rate").text.to_f
        return r
      elsif r = REXML::XPath.first(@response, "//RateV2Response/Package/Postage/Rate").text.to_f
        raise ShippingError, get_error
      end
    rescue
      raise ShippingError, get_error
    end
    
    private
    
    def get_error
      debugger
      xml = REXML::Document.new(@response)
      code = REXML::XPath.first(xml, "//Error/Number").text
      message = REXML::XPath.first(xml, "//Error/Description").text
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
