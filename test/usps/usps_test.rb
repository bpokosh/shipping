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
    assert_in_delta 7.70, @ship.price, 1
  end
  
  def test_price_canned_response_two
    @ship.service_type = 'all'
    @ship.usps_size = 'large'
    @ship.usps_machinable = 'true'
    assert_in_delta 39.20, @ship.price, 1    
  end
  
  def test_error
    # Change one field from the canned request
    @ship.weight = 20.2
    assert_raises Shipping::ShippingError do
      @ship.price
    end
  end
end
