module HydroponicBean
  class Job
    def self.next_id
      HydroponicBean.jobs.length + 1
    end

    attr_accessor :id, :pri, :delay, :ttr, :data, :created_at,
      :state, :tube

    attr_reader :deleted

    def initialize(tube, pri, delay, ttr, data)
      @id = self.class.next_id
      @created_at = Time.now.utc
      @tube = tube
      @pri = pri.to_i
      @delay = delay.to_i
      @ttr = ttr.to_i
      @state = @delay > 0 ? State.delayed : State.ready
      @data = data
      @deleted = false

      @tube.push(self)
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

    def exists?; !deleted; end
    def delete
      if @deleted == false
        @tube.job_deleted
        @deleted = true
      end
    end

    module State
      def self.ready;     :ready;    end
      def self.reserved;  :reserved; end
      def self.delayed;   :delayed;  end
      def self.buried;    :buried;   end
    end
  end
end
