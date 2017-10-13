require 'test_helper'

class HydroponicBean::TestHelperTest < TestCase
  include HydroponicBean::TestHelper

  def before_setup
    @connection = HydroponicBean::Connection.new
  end

  def test_assert_job_put
    @assert_raised = false
    begin
      assert_job_put {}
    rescue Minitest::Assertion => e
      assert_equal "Exepected 1 job(s) to be put, but found 0", e.message
      @assert_raised = true
    ensure
      assert @assert_raised, 'assert_job_put should have raised with an empty block'
    end

    @assert_raised = false
    begin
      assert_job_put do
        HydroponicBean.jobs.push 1
      end
    rescue Minitest::Assertion => e
      @assert_raised = true
    ensure
      assert !@assert_raised, "The assertion should not have raised: #{e.message}"
    end
  end
end

