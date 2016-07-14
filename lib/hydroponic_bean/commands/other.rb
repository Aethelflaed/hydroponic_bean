module HydroponicBean
  module Commands
    module Other
      def peek(stream, id)
        peek_output(HydroponicBean.jobs[id.to_i - 1])
      end

      protected
      def peek_output(job)
        if job
          output("FOUND #{job[:id]} #{job[:data].length}\r\n")
          output("#{job[:data]}\r\n")
        else
          output(Protocol::NOT_FOUND)
          return false
        end
      end
    end
  end
end
