module HydroponicBean
  module Commands
    module Worker
      def delete(stream, id)
        job = HydroponicBean.jobs[id.to_i - 1]
        if job
          job.delete
          output("DELETED\r\n")
        else
          output(Protocol::NOT_FOUND)
          return false
        end
      end
    end
  end
end
