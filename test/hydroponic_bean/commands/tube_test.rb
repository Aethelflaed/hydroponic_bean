require 'test_helper'

class HydroponicBean::Commands::TubeTest < Minitest::Test
  def before_setup
    @connection = HydroponicBean::Connection.new
    HydroponicBean.jobs.clear
    HydroponicBean.tubes.clear
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

  def test_list_tubes_watched
    tubes = @connection.watched_tube_names
    @connection.write("list-tubes-watched\r\n")
    assert_equal "OK #{tubes.to_yaml.length}\r\n", @connection.readline
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

  def test_kick
    tube = @connection.current_tube
    @connection.write("kick 10\r\n")
    assert_equal "KICKED 0\r\n", @connection.readline

    id1 = @connection.create_job(1024, 0, 0, 'hello world')
    id2 = @connection.create_job(1024, 0, 0, 'hello world')
    id3 = @connection.create_job(1024, 0, 0, 'hello world')
    id4 = @connection.create_job(1024, 0, 0, 'hello world')
    job1 = HydroponicBean.jobs[id1 - 1]
    job2 = HydroponicBean.jobs[id2 - 1]
    job3 = HydroponicBean.jobs[id3 - 1]
    job4 = HydroponicBean.jobs[id4 - 1]
    job1.state = HydroponicBean::Job::State.delayed
    job2.state = HydroponicBean::Job::State.delayed
    job3.state = HydroponicBean::Job::State.buried
    job4.state = HydroponicBean::Job::State.buried

    @connection.write("kick 1\r\n")
    assert_equal "KICKED 1\r\n", @connection.readline
    @connection.write("kick 1\r\n")
    assert_equal "KICKED 1\r\n", @connection.readline
    assert tube.buried_jobs.empty?
    @connection.write("kick 3\r\n")
    assert_equal "KICKED 2\r\n", @connection.readline
  end
end
