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
    @connection.create_job(1024, 0, 0, 'hello world')

    @connection.write("peek 1\r\n")
    assert_equal "FOUND 1 11\r\n", @connection.readline
    assert_equal "hello world\r\n", @connection.readline
  end

  def test_peek_no_id
    @connection.write("peek \r\n")
    assert_equal HydroponicBean::Protocol::NOT_FOUND, @connection.readline
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
