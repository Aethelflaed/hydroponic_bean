require 'test_helper'

class HydroponicBean::Commands::OtherTest < TestCase
  def before_setup
    @connection = HydroponicBean::Connection.new
  end

  def test_peek
    @connection.write("peek 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    @connection.create_job(1024, 0, 0, 'hello world')

    @connection.write("peek 1\r\n")
    assert_equal "FOUND 1 11\r\n", @connection.readline
    assert_equal "hello world\r\n", @connection.readline

    @connection.write("peek \r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
  end

  def test_peek_ready
    @connection.write("peek-ready\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    @connection.create_job(1024, 0, 0, 'hello world')
    @connection.write("peek-ready\r\n")
    assert_equal "FOUND 1 11\r\n", @connection.readline
    assert_equal "hello world\r\n", @connection.readline
  end

  def test_peek_buried
    @connection.write("peek-buried\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    @connection.create_job(1024, 0, 0, 'hello world')
    HydroponicBean.jobs[0].state = HydroponicBean::Job::State.buried
    @connection.write("peek-buried\r\n")
    assert_equal "FOUND 1 11\r\n", @connection.readline
    assert_equal "hello world\r\n", @connection.readline
  end

  def test_peek_delayed
    @connection.write("peek-delayed\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    @connection.create_job(1024, 10, 0, 'hello world')
    @connection.create_job(1024, 5, 0, 'hello world')
    @connection.write("peek-delayed\r\n")
    assert_equal "FOUND 2 11\r\n", @connection.readline
    assert_equal "hello world\r\n", @connection.readline
  end

  def test_stats_job
    @connection.write("stats-job 0\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    @connection.create_job(1024, 10, 0, 'hello world')
    job = HydroponicBean.jobs[0]
    @connection.write("stats-job 1\r\n")
    data = job.serialize_stats.to_yaml
    assert_equal "OK #{data.length}\r\n", @connection.readline
  end

  def test_kick_job
    @connection.write("kick-job 0\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    @connection.create_job(1024, 0, 0, 'hello world')
    @connection.write("kick-job 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    job = HydroponicBean.jobs[0]
    job.state = HydroponicBean::Job::State.buried
    @connection.write("kick-job 1\r\n")
    assert_equal "KICKED\r\n", @connection.readline
  end
end
