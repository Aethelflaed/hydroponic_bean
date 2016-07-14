require 'test_helper'

class HydroponicBean::ProtocolTest < Minitest::Test
  def before_setup
    @connection = HydroponicBean::Connection.new

    def @connection.test(stream)
      output("test_called\r\n")
    end

    def @connection.test_hyphen(stream)
      output("test_hyphen works\r\n")
    end
  end

  def test_parse_bad_format
    @connection.write('test')
    assert_equal HydroponicBean::Protocol::BAD_FORMAT, @connection.readline
  end

  def test_parse
    @connection.write("test\r\n")
    assert_equal "test_called\r\n", @connection.readline
  end

  def test_bulk_writing
    @connection.write("test\r\nfail")
    assert_equal "test_called\r\n", @connection.readline
    assert_equal HydroponicBean::Protocol::BAD_FORMAT, @connection.readline
  end

  def test_parsing_hyphenated_command
    @connection.write("test-hyphen\r\n")
    assert_equal "test_hyphen works\r\n", @connection.readline
  end
end
