require 'test_helper'

class HydroponicBean::Commands::WorkerTest < Minitest::Test
  def before_setup
    @connection = HydroponicBean::Connection.new
    HydroponicBean.jobs.clear
    HydroponicBean.tubes.clear
  end

  def test_delete_not_found
    @connection.write("delete 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
  end

  def test_delete
    id = @connection.create_job(1024, 0, 0, 'hello world')

    @connection.write("delete #{id}\r\n")
    assert_equal "DELETED\r\n", @connection.readline
  end
end
