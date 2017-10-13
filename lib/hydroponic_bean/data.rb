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
      job&.update_time!
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

  def self.worker_count
    connections.select(&:worker?).count
  end

  def self.producer_count
    connections.select(&:producer?).count
  end

  # Keep track of commands for stats
  def self.commands
    @commands ||= Hash.new{|h, k| h[k] = 0}
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

      return job
    end

    def deadline_soon?
      HydroponicBean.update_time!
      watched_tubes.map(&:reserved_jobs).flatten.select do |job|
        job.reserved_by == self
      end.sort_by(&:ttr_left).first&.deadline_soon?
    end

    def reserve_job
      HydroponicBean.update_time!
      reservable_jobs.first&.reserve(self)
    end

    def reservable_jobs
      watched_tubes.reject(&:paused?).map(&:ready_jobs).flatten.sort_by(&:created_at).sort_by(&:pri)
    end

    def wait_for_job(timeout)
      self.waiting = true
      if timeout >= 0
        Timeout.timeout(timeout) do
          _wait_for_job
        end
      else
        _wait_for_job
      end
    rescue Timeout::Error
      return nil
    ensure
      self.waiting = false
    end

    private
    def _wait_for_job
      while !(job = reserve_job)
        sleep 0.49
      end
      return job
    end
  end
end
