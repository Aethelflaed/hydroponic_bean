module HydroponicBean
  module Commands
    module Other
      def peek(stream, id = nil)
        id = id.to_i
        job = HydroponicBean.jobs[id - 1]
        if id == 0 || !job
          output(Protocol::NOT_FOUND)
          return false
        else
          output("FOUND #{job.id} #{job.data.length}\r\n")
          output("#{job.data}\r\n")
        end
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
    end
  end
end
