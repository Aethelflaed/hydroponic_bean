require 'test_helper'

class HydroponicBean::Commands::OtherTest < Minitest::Test
  def before_setup
    @connection = HydroponicBean::Connection.new
    HydroponicBean.jobs.clear
    HydroponicBean.tubes.clear
  end

  def test_peek_not_found
    @connection.write("peek 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
  end

  def test_peek
    job = {
      id: 1, data: 'hello world'
    }
    HydroponicBean.jobs.push(job)

    @connection.write("peek 1\r\n")
    assert_equal "FOUND 1 11\r\n", @connection.readline
    assert_equal "hello world\r\n", @connection.readline
  end

  def test_list_tubes
    HydroponicBean.tubes['default']
    HydroponicBean.tubes['test']
    @connection.write("list-tubes\r\n")
    tubes = ['default', 'test'].to_yaml
    result = "#{tubes}\r\n"
    assert_equal "OK 21\r\n", @connection.readline
    assert_equal result, result.count("\n").times.map{@connection.readline}.join
  end
end
