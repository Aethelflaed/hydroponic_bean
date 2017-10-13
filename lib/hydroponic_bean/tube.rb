module HydroponicBean
  class Tube
    attr_reader :name, :jobs, :stats

    def initialize(name)
      @name = name
      @jobs = []
      @paused_at = nil
      @stats = {
        'cmd-delete' => 0,
        'cmd-pause-tube' => 0,
        'pause' => 0,
      }
    end

    def push(job)
      @jobs.push(job)
      self
    end

    def current_jobs_urgent;    jobs.select(&:urgent?).count; end
    def current_jobs_ready;     jobs.select(&:ready?).count; end
    def current_jobs_reserved;  jobs.select(&:reserved?).count; end
    def current_jobs_delayed;   jobs.select(&:delayed?).count; end
    def current_jobs_buried;    jobs.select(&:buried?).count; end

    def current_using
      HydroponicBean.connections.select{|c| c.current_tube_name == name}.count
    end

    def current_watching
      HydroponicBean.connections.select do |c|
        c.watched_tube_names.include?(name)
      end.count
    end

    def serialize_stats
      {
        'name' => name,
        'current-jobs-urgent'   => current_jobs_urgent,
        'current-jobs-ready'    => current_jobs_ready,
        'current-jobs-reserved' => current_jobs_reserved,
        'current-jobs-delayed'  => current_jobs_delayed,
        'current-jobs-buried'   => current_jobs_buried,
        'total-jobs' => jobs.count,
        'current-using' => current_using,
        'current-waiting' => 0,
        'current-watching' => current_watching,
        'pause-time-left' => pause_time_left,
      }.merge(stats)
    end

    def pause(delay)
      delay = delay.to_i
      stats['pause'] = delay
      stats['cmd-pause-tube'] += 1
    end

    def ready_jobs;   jobs.select(&:ready?);    end
    def buried_jobs;  jobs.select(&:buried?);   end
    def delayed_jobs; jobs.select(&:delayed?).sort_by(&:time_left);  end

    def kick(bound)
      initial_bound = bound
      while bound > 0
        if buried_jobs.count > 0
          buried_jobs.first.kick
          bound -= 1
        elsif delayed_jobs.count > 0
          delayed_jobs.first.kick
          bound -= 1
        else
          return initial_bound - bound
        end
      end
      return initial_bound
    end

    def paused?
      if !@paused_at || _pause_time_left == 0
        stats['pause'] = 0
        @paused_at = nil
        return false
      else
        return true
      end
    end

    def pause_time_left
      if paused?
        return _pause_time_left
      else
        return 0
      end
    end

    def _pause_time_left
      [stats['pause'] - (Time.now.utc - @paused_at).to_i, 0].max
    end

    def job_deleted!
      stats['cmd-delete'] += 1
    end
  end
end
