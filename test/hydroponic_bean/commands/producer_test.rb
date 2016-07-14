require 'test_helper'

class HydroponicBean::Commands::ProducerTest < Minitest::Test
  def before_setup
    @connection = HydroponicBean::Connection.new
  end

  def test_use
    @connection.write("use HydroponicBean::Commands::ProducerTest\r\n")
    assert_equal "USING HydroponicBean::Commands::ProducerTest\r\n", @connection.readline
    assert_equal 'HydroponicBean::Commands::ProducerTest', @connection.current_tube_name
  end

  def test_put
    @connection.write("put 65536 0 120 3\r\nab")
    assert_equal HydroponicBean::Protocol::BAD_FORMAT, @connection.readline

    @connection.write("put 65536 0 120 3\r\nabc")
    assert_equal HydroponicBean::Protocol::EXPECTED_CRLF, @connection.readline

    count = HydroponicBean.jobs.count
    @connection.write("put 65536 0 120 3\r\nabc\r\n")
    assert_equal "INSERTED #{count + 1}\r\n", @connection.readline
    assert_equal count + 1, HydroponicBean.jobs.count
  end
end

