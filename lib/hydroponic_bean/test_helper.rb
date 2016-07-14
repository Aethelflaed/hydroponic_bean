module HydroponicBean
  module TestHelper
    def assert_job_put(count = 1)
      current_count = HydroponicBean.jobs.count
      result = yield
      assert current_count + count == HydroponicBean.jobs.count, "Exepected #{count} job(s) to be put, but found #{HydroponicBean.jobs.count - current_count}"
      return result
    end
  end
end
