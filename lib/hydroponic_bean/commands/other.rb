module HydroponicBean
  module Commands
    module Other
      def peek(stream, id = nil)
        for_job(id) do |job|
          peek_output(job)
        end
      end

      def peek_ready(stream)
        HydroponicBean.update_time!
        peek_output current_tube.ready_jobs.first
      end

      def peek_buried(stream)
        peek_output current_tube.buried_jobs.first
      end

      def peek_delayed(stream)
        HydroponicBean.update_time!
        peek_output current_tube.delayed_jobs.first
      end

      def stats_job(stream, id)
        for_job(id) do |job|
          stats = job.serialize_stats.to_yaml
          output("OK #{stats.length}\r\n")
          output("#{stats}\r\n")
        end
      end

      def kick_job(stream, id)
        for_job(id) do |job|
          if job.kick
            output("KICKED\r\n")
          end
        end
      end

      protected
      def peek_output(job)
        if job
          output("FOUND #{job.id} #{job.data.length}\r\n")
          output("#{job.data}\r\n")
        else
          output(Protocol::NOT_FOUND)
          return false
        end
      end
    end
  end
end
