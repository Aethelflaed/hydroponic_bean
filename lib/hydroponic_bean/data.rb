require 'hydroponic_bean/tube'
require 'hydroponic_bean/job'

module HydroponicBean
  def self.tubes
    @tubes ||= Hash.new{|h, k| h[k] = Tube.new(k)}
  end

  def self.jobs
    @jobs ||= []
  end

  module Data
    def current_tube_name
      @current_tube_name ||= 'default'
    end

    def current_tube
      HydroponicBean.tubes[current_tube_name]
    end

    def create_job(pri, delay, ttr, data)
      job = Job.new(current_tube, pri, delay, ttr, data)

      HydroponicBean.jobs.push(job)

      return job.id
    end
  end
end
