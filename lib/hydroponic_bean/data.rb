module HydroponicBean
  class Tube
    attr_reader :name, :jobs, :stats

    def initialize(name)
      @name = name
      @jobs = []
      @stats = OpenStruct.new
    end

    def push(job)
      @jobs.push(job)
      self
    end
  end

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

    def next_id
      HydroponicBean.jobs.length + 1
    end

    def create_job(pri, delay, ttr, data)
      job = {
        id: next_id,
        tube: current_tube_name,
        pri: pri.to_i,
        delay: delay.to_i,
        ttr: ttr.to_i,
        data: data,
      }
      job[:state] = (job[:delay] == 0) ? :ready : :delayed

      HydroponicBean.jobs.push(job)
      current_tube.push(job)

      return job[:id]
    end
  end
end
