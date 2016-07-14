require 'test_helper'

class HydroponicBean::ConnectionTest < Minitest::Test
  def before_setup
    @connection = HydroponicBean::Connection.new
    @write = @connection.instance_variable_get('@_write')
  end

  def test_read
    @write.write('ab')

    assert_equal 'a', @connection.read(1)
    assert_equal 'b', @connection.read(1)
  end

  def test_readline
    @write.write("line\r\n")
    assert_equal "line\r\n", @connection.readline
  end

  def test_close
    @connection.close

    assert @write.closed?
  end

  def test_output
    @connection.send(:output, '1')
    assert_equal '1', @connection.read(1)
  end
end
