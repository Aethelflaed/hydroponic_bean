require 'test_helper'

class HydroponicBeanTest < Minitest::Test
  include HydroponicBean

  def test_hydroponic!
    Beaneater.hydroponic!
    assert Beaneater::Connection < HydroponicBean, "Beaneater::Connection should be an HydroponicBean"
  end

  def address
    @address ||= ['localhost:900']
  end
  def test_establish_connection
    establish_connection
    assert_equal 'localhost', @host
    assert_equal 900, @port

    assert_kind_of HydroponicBean::Connection, @connection
  end
end
