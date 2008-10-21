require File.dirname(__FILE__) + '/../test_helper'
class USPSTest < Test::Unit::TestCase
  def setup
    @ship = Shipping::USPS.new(
                                :zip => 97202,
                                :state => "OR",
                                :sender_zip => 10001,
                                :sender_state => "New York",
                                :weight => 2
                                )
    
  end
end
