module HydroponicBean
  module Commands
    module Tube
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

      def list_tubes(stream)
        tubes = HydroponicBean.tubes.keys.to_yaml
        output("OK #{tubes.length}\r\n")
        output("#{tubes}\r\n")
      end

      def stats_tube(stream, tube_name)
        if HydroponicBean.tubes.has_key?(tube_name)
          tube = HydroponicBean.tubes[tube_name]
          data = tube.serialize_stats.to_yaml
          output("OK #{data.length}\r\n")
          output("#{data}\r\n")
        else
          output(Protocol::NOT_FOUND)
          return false
        end
      end

      def pause_tube(stream, tube_name, delay)
        if HydroponicBean.tubes.has_key?(tube_name)
          tube = HydroponicBean.tubes[tube_name]
          tube.pause(delay)
          output("PAUSED\r\n")
        else
          output(Protocol::NOT_FOUND)
          return false
        end
      end
    end
  end
end
