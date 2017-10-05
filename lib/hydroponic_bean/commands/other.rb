module HydroponicBean
  module Commands
    module Other
      def peek(stream, id = nil)
        id = id.to_i
        job = (id == 0) ? nil : HydroponicBean.jobs[id - 1]
        peek_output(job)
      end

      def peek_ready(stream)
        peek_output current_tube.ready_jobs.first
      end

      def peek_buried(stream)
        peek_output current_tube.buried_jobs.first
      end

      def peek_delayed(stream)
        peek_output current_tube.delayed_jobs.first
      end

      def stats_job(stream, id)
        id = id.to_i
        job = (id == 0) ? nil : HydroponicBean.jobs[id - 1]
        if !job
          output(Protocol::NOT_FOUND)
          return false
        end

        stats = job.serialize_stats.to_yaml
        output("OK #{stats.length}\r\n")
        output("#{stats}\r\n")
      end

      def kick_job(stream, id)
        id = id.to_i
        job = (id == 0) ? nil : HydroponicBean.jobs[id - 1]
        if !job || !job.kick
          output(Protocol::NOT_FOUND)
          return false
        end
        job.kick
        output("KICKED\r\n")
      end

      def watch(stream, tube_name)
        watched_tube_names << tube_name
        watched_tube_names.uniq!
        output("WATCHING #{watched_tube_names.count}\r\n")
      end

      def ignore(stream, tube_name)
        watched_tube_names.delete(tube_name)
        if watched_tube_names.empty?
          watched_tube_names << tube_name
          output("NOT_IGNORED\r\n")
        else
          output("WATCHING #{watched_tube_names.count}\r\n")
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
