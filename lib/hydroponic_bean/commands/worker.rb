module HydroponicBean
  module Commands
    module Worker
      def reserve(stream)
        reserve_with_timeout(stream, -1)
      end

      def reserve_with_timeout(stream, seconds)
        seconds = seconds.to_i
        reserver = Proc.new do
          HydroponicBean.update_time!
          # check for DEADLINE_SOON
          tubes = watched_tubes
          deadlining_job = tubes.map(&:reserved_jobs).flatten.select do |job|
            job.reserved_by == self
          end.sort_by(&:ttr_left).first
          if deadlining_job&.deadline_soon?
            output("DEADLINE_SOON\r\n")
            return true
          end

          tubes.reject!(&:paused?)
          jobs = tubes.map(&:ready_jobs).flatten.sort_by(&:created_at).sort_by(&:pri)
          if (job = jobs.first)
            job.reserve(self)
            job
          end
        end

        reserver_with_retry = Proc.new do
          while !(job = reserver.call)
            sleep 0.90
          end
          output_reserved job
        end

        if seconds == 0
          if (job = reserver.call)
            output_reserved job
          else
            output_timed_out
          end
        elsif seconds < 0
          reserver_with_retry.call
        else
          begin
            Timeout.timeout(seconds) do
              reserver_with_retry.call
            end
          rescue Timeout::Error
            output_timed_out
          end
        end
      end

      def release(stream, id, pri, delay)
        # We don't have a BURIED response here
        for_job(id) do |job|
          if job.release(self, pri, delay)
            output("RELEASED\r\n")
          end
        end
      end

      def bury(stream, id, pri)
        for_job(id) do |job|
          if job.bury(self, pri)
            output("BURIED\r\n")
          end
        end
      end

      def delete(stream, id)
        for_job(id) do |job|
          if job.delete(self)
            output("DELETED\r\n")
          end
        end
      end

      def touch(stream, id)
        for_job(id) do |job|
          if job.touch(self)
            output("TOUCHED\r\n")
          end
        end
      end

      def watch(stream, tube_name)
        watched_tube_names << tube_name
        watched_tube_names.uniq!
        output_watching
      end

      def ignore(stream, tube_name)
        watched_tube_names.delete(tube_name)
        if watched_tube_names.empty?
          watched_tube_names << tube_name
          output("NOT_IGNORED\r\n")
        else
          output_watching
        end
      end

      protected
      def output_reserved(job)
        output("RESERVED #{job.id} #{job.data.length}\r\n")
        output("#{job.data}\r\n")
      end

      def output_timed_out
        output("TIMED_OUT\r\n")
      end

      def output_watching
        output("WATCHING #{watched_tube_names.count}\r\n")
      end
    end
  end
end
