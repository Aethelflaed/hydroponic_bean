require 'test_helper'

class HydroponicBean::Commands::WorkerTest < TestCase
  def before_setup
    @connection = HydroponicBean::Connection.new
  end

  def test_delete_not_found
    @connection.write("delete 1\r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
  end

  def test_delete
    job = @connection.create_job(1024, 0, 0, 'hello world')

    @connection.write("delete #{job.id}\r\n")
    assert_equal "DELETED\r\n", @connection.readline
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
