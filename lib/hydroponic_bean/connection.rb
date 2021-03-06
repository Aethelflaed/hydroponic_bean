require 'hydroponic_bean/protocol'

module HydroponicBean
  class Connection
    include HydroponicBean::Protocol

    attr_accessor :waiting
    alias_method :waiting?, :waiting

    def initialize
      @_read, @_write = IO.pipe
      @worker, @producer = false
      @waiting = false
      HydroponicBean.add_connection(self)
    end

    def worker?;   @worker;          end
    def worker!;   @worker = true;   end
    def producer?; @producer;        end
    def producer!; @producer = true; end

    def closed?
      @_write.closed?
    end

    # Necessary interface used by beaneater
    def write(command)
      parse(StringIO.new(command))
    end

    def read(bytes)
      @_read.read(bytes)
    end

    def readline
      @_read.readline
    end

    def close
      @_read.close
      @_write.close
      HydroponicBean.remove_connection(self)
    end

    protected
    def output(data)
      @_write.write(data)
    end
  end
end
