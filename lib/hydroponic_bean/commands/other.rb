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
    end
  end
end
