require 'test_helper'

class HydroponicBean::Commands::Test < Minitest::Test
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

  def test_list_tubes
    HydroponicBean.tubes['default']
    HydroponicBean.tubes['test']
    @connection.write("list-tubes\r\n")
    tubes = ['default', 'test'].to_yaml
    result = "#{tubes}\r\n"
    assert_equal "OK 21\r\n", @connection.readline
    assert_equal result, result.count("\n").times.map{@connection.readline}.join
  end

  def test_stats_tube_not_found
    @connection.write("stats-tube X\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
  end

  def test_stats_tube
    tube = HydroponicBean.tubes['default']
    @connection.write("stats-tube default\r\n")
    data  = tube.serialize_stats.to_yaml
    assert_equal "OK #{data.length}\r\n", @connection.readline
  end

  def test_pause_tube_not_found
    @connection.write("pause-tube X 10\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
  end

  def test_pause_tube
    tube = HydroponicBean.tubes['default']
    @connection.write("pause-tube default 10\r\n")
    assert_equal "PAUSED\r\n", @connection.readline
    assert_equal 1, tube.stats['cmd-pause-tube']
  end
end
