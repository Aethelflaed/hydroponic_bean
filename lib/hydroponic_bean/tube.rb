module HydroponicBean
  class Tube
    attr_reader :name, :jobs, :stats

    def initialize(name)
      @name = name
      @jobs = []
      @stats = {
        'cmd-delete' => 0,
        'cmd-pause-tube' => 0,
        'pause' => 0,
        'pause-time-left' => 0,
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

    def serialize_stats
      {
        'name' => name,
        'current-jobs-urgent'   => current_jobs_urgent,
        'current-jobs-ready'    => current_jobs_ready,
        'current-jobs-reserved' => current_jobs_reserved,
        'current-jobs-delayed'  => current_jobs_delayed,
        'current-jobs-buried'   => current_jobs_buried,
        'total-jobs' => jobs.count,
        'current-using' => 0,
        'current-waiting' => 0,
        'current-watching' => 0,
      }.merge(stats)
    end

    def job_deleted
      stats['cmd-delete'] += 1
    end
  end
end