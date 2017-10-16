require 'test_helper'

class HydroponicBean::Commands::WorkerTest < TestCase
  def before_setup
    @connection = HydroponicBean::Connection.new
  end

  def test_reserve
    job = @connection.create_job(1024, 0, 0, 'Hello World')

    @connection.write("reserve\r\n")
    assert_equal "RESERVED #{job.id} #{job.data.length}\r\n", @connection.readline
  end

  def test_reserve_deadline_soon
    job = @connection.create_job(1024, 0, 1, 'Hello World')

    job.reserve(@connection)

    @connection.write("reserve\r\n")
    assert_equal "DEADLINE_SOON\r\n", @connection.readline
  end

  def test_reserve_with_timeout
    job = @connection.create_job(1024, 10, 1, 'Hello World')

    @connection.write("reserve-with-timeout 0\r\n")
    assert_equal "TIMED_OUT\r\n", @connection.readline

    Timecop.travel(10) do
      @connection.write("reserve-with-timeout 0\r\n")
      assert_equal "RESERVED #{job.id} #{job.data.length}\r\n", @connection.readline
    end
  end

  def test_release
    @connection.write("release 1 1024 0\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    job = @connection.create_job(1024, 0, 10, 'Hello World')
    job.reserve(@connection)

    @connection.write("release #{job.id} 1024 0\r\n")
    assert_equal HydroponicBean::Job::State.ready, job.state
    assert_equal "RELEASED\r\n", @connection.readline

    job.reserve(@connection)

    @connection.write("release #{job.id} 1024 10\r\n")
    assert_equal HydroponicBean::Job::State.delayed, job.state
  end

  def test_bury
    @connection.write("bury 1 1024\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    job = @connection.create_job(1024, 0, 10, 'Hello World')
    job.reserve(@connection)

    @connection.write("bury #{job.id} 256\r\n")
    assert_equal HydroponicBean::Job::State.buried, job.state
    assert_equal 256, job.pri
    assert_equal "BURIED\r\n", @connection.readline
  end

  def test_delete
    @connection.write("delete 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    job = @connection.create_job(1024, 0, 0, 'hello world')

    @connection.write("delete #{job.id}\r\n")
    assert_equal "DELETED\r\n", @connection.readline
  end

  def test_touch
    @connection.write("touch 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    job = @connection.create_job(1024, 0, 2, 'Hello World')

    @connection.write("touch #{job.id}\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline

    job.reserve(@connection)
    Timecop.travel(1) do
      assert @connection.deadline_soon?

      @connection.write("touch #{job.id}\r\n")
      assert_equal "TOUCHED\r\n", @connection.readline
      assert !@connection.deadline_soon?
    end
  end

  def test_watch
    @connection.write("watch test\r\n")
    assert_equal "WATCHING 2\r\n", @connection.readline

    @connection.write("watch test\r\n")
    assert_equal "WATCHING 2\r\n", @connection.readline

    @connection.write("watch default\r\n")
    assert_equal "WATCHING 2\r\n", @connection.readline
  end

  def test_ignore
    @connection.watched_tube_names << 'hello'
    first, *rest = @connection.watched_tube_names.dup
    rest.each do |tube|
      @connection.write("ignore #{tube}\r\n")
      assert_equal "WATCHING #{rest.count}\r\n", @connection.readline
    end

    @connection.write("ignore #{first}\r\n")
    assert_equal "NOT_IGNORED\r\n", @connection.readline
  end
end
