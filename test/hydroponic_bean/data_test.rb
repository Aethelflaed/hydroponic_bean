require 'test_helper'

class HydroponicBean::DataTest < TestCase
  include HydroponicBean::Data

  def test_tubes
    assert_kind_of Hash, HydroponicBean.tubes

    assert_kind_of HydroponicBean::Tube, HydroponicBean.tubes[Time.now]
  end

  def test_current_tube_name
    assert_equal 'default', current_tube_name

    @current_tube_name = 'test'
    assert_equal 'test', current_tube_name
  end

  def test_current_tube
    assert_kind_of HydroponicBean::Tube, current_tube
  end

  def test_jobs
    assert_kind_of Array, HydroponicBean.jobs
  end

  def test_next_id
    id = HydroponicBean::Job.next_id
    HydroponicBean.jobs.push(1)
    assert_equal id + 1, HydroponicBean::Job.next_id
  end

  def test_create_job
    count = HydroponicBean.jobs.count

    job = create_job(1, 2, 3, 'abc')

    assert_equal count + 1, job.id
    assert_equal count + 1, HydroponicBean.jobs.count

    assert_equal current_tube_name, job.tube_name
  end
end
