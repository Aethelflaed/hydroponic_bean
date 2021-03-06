module HydroponicBean
  class Job
    def self.next_id
      HydroponicBean.jobs.length + 1
    end

    attr_accessor :id, :pri, :delay, :ttr, :data, :created_at,
      :reserved_at, :reserved_by, :state, :tube, :stats

    def initialize(tube, pri, delay, ttr, data)
      @id = self.class.next_id
      @created_at = Time.now.utc
      @tube = tube
      @pri = pri.to_i
      @delay = delay.to_i
      @reserved_at = nil
      @ttr = ttr.to_i
      @state = @delay > 0 ? State.delayed : State.ready
      @data = data
      @deleted = false
      @stats = {
        'reserves' => 0,
        'timeouts' => 0,
        'releases' => 0,
        'buries' => 0,
        'kicks' => 0,
      }

      @tube.push(self)
    end

    def update_time!
      if (delayed? || reserved?) && time_left == 0
        if reserved?
          stats['timeouts'] += 1
        end
        @state = State.ready
      end
    end

    def age
      (Time.now.utc - created_at).to_i
    end

    def tube_name
      @tube.name
    end

    def urgent?;   exists? && pri <= 1024; end
    def ready?;    exists? && state == State.ready; end
    def reserved?; exists? && state == State.reserved; end
    def delayed?;  exists? && state == State.delayed; end
    def buried?;   exists? && state == State.buried; end

    def reserved_by?(connection)
      reserved? && reserved_by == connection
    end

    def reserve(connection)
      if ready?
        stats['reserves'] += 1
        @state = State.reserved
        @reserved_by = connection
        @reserved_at = Time.now.utc
        # For convenience and one-liners
        return self
      end
    end

    def release(connection, pri, delay)
      if reserved_by?(connection)
        stats['releases'] += 1
        @pri = pri.to_i
        @delay = delay.to_i
        @reserved_at = nil
        @reserved_by = nil
        @state = @delay > 0 ? State.delayed : State.ready
      end
    end

    def bury(connection, pri)
      if reserved_by?(connection)
        stats['buries'] += 1
        @pri = pri.to_i
        @reserved_at = nil
        @reserved_by = nil
        @state = State.buried
      end
    end

    def delete(connection)
      if exists? && (!reserved? || reserved_by?(connection))
        @tube.job_deleted!
        @deleted = true
      end
    end

    def touch(connection)
      if reserved_by?(connection)
        @reserved_at = Time.now.utc
      end
    end

    def kick
      if buried? || delayed?
        stats['kicks'] += 1
        @state = State.ready
      end
    end

    def ttr_left
      [ttr - (Time.now.utc - reserved_at).to_i, 0].max
    end

    def time_left
      reserved? ? ttr_left : [delay - age, 0].max
    end

    def deadline_soon?
      ttr_left <= 1
    end

    def serialize_stats
      {
        'id' => id,
        'tube' => tube.name,
        'state' => state.to_s,
        'pri' => pri,
        'age' => age,
        'delay' => delay,
        'ttr' => ttr,
        'time-left' => time_left,
        'file' => 0,
      }.merge(stats)
    end

    def deleted?; @deleted; end
    def exists?; !@deleted; end

    module State
      def self.ready;     :ready;    end
      def self.reserved;  :reserved; end
      def self.delayed;   :delayed;  end
      def self.buried;    :buried;   end
    end
  end
end
