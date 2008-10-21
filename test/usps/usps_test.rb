require File.dirname(__FILE__) + '/../test_helper'
class USPSTest < Test::Unit::TestCase
  def setup
    # USPS only allow specific canned requests and responses with it's test system:
    #
    #   http://www.usps.com/webtools/htm/Rates-Calculatorsv1-0.htm
    #
    @ship = Shipping::USPS.new(
                                :zip => 20008,
                                :state => "WASHINGTON, DC",
                                :sender_zip => 10022,
                                :sender_state => "New York",
                                :weight => 10.3,
                                :container => "Flat Rate Box"
                                )

    # use testing environment for tests
    @ship.usps_url = 'http://testing.shippingapis.com/ShippingAPITest.dll'
    
  end

  def test_price_canned_response_one
    # Canned price response
    assert_in_delta 7.70, @ship.price, 1
  end
  
end
