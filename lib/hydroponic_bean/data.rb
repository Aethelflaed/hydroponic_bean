require 'hydroponic_bean/tube'
require 'hydroponic_bean/job'

module HydroponicBean
  def self.tubes
    @tubes ||= Hash.new{|h, k| h[k] = Tube.new(k)}
  end

  def self.find_job(id)
    id = id.to_i
    if id == 0
      return nil
    else
      job = jobs[id - 1]
      job.update_time!
      return job
    end
  end

  def self.jobs
    @jobs ||= []
  end

  def self.update_time!
    jobs.each(&:update_time!)
  end

  def self.connections
    @connections ||= []
  end

  def self.add_connection(connection)
    connections.push(connection)
  end

  def self.remove_connection(connection)
    connections.delete(connection)
  end

  module Data
    def current_tube_name
      @current_tube_name ||= 'default'
    end

    def current_tube
      HydroponicBean.tubes[current_tube_name]
    end

    def watched_tube_names
      @watched_tube_names ||= ['default']
    end

    def watched_tubes
      watched_tube_names.map do |name|
        HydroponicBean.tubes[name]
      end
    end

    def create_job(pri, delay, ttr, data)
      job = Job.new(current_tube, pri, delay, ttr, data)

      HydroponicBean.jobs.push(job)

      return job.id
    end
  end
end
