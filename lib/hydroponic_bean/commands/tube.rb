module HydroponicBean
  module Commands
    module Tube
      def list_tubes(stream)
        tubes = HydroponicBean.tubes.keys.to_yaml
        output("OK #{tubes.length}\r\n")
        output("#{tubes}\r\n")
      end

      def list_tubes_watched(stream)
        tubes = watched_tube_names.to_yaml
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

      def kick(stream, bound)
        HydroponicBean.update_time!
        bound = bound.to_i
        tube = current_tube
        output("KICKED #{tube.kick(bound)}\r\n")
      end
    end
  end
end
