module HydroponicBean
  module Commands
    module Worker
      def reserve(stream)
        reserve_with_timeout(stream, -1)
      end

      def reserve_with_timeout(stream, seconds)
        # Mark this connection as a worker
        worker!

        if deadline_soon?
          output("DEADLINE_SOON\r\n")
          return true
        end

        seconds = seconds.to_i

        if job = wait_for_job(seconds)
          output("RESERVED #{job.id} #{job.data.length}\r\n")
          output("#{job.data}\r\n")
        else
          output("TIMED_OUT\r\n")
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
      def output_watching
        output("WATCHING #{watched_tube_names.count}\r\n")
      end
    end
  end
end
