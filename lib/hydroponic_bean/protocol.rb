require 'hydroponic_bean/commands'

module HydroponicBean
  module Protocol
    include HydroponicBean::Data
    include HydroponicBean::Commands

    OUT_OF_MEMORY   = "OUT_OF_MEMORY\r\n".freeze
    INTERNAL_ERROR  = "INTERNAL_ERROR\r\n".freeze
    BAD_FORMAT      = "BAD_FORMAT\r\n".freeze
    UNKNOWN_COMMAND = "UNKNOWN_COMMAND\r\n".freeze
    EXPECTED_CRLF   = "EXPECTED_CRLF\r\n".freeze
    JOB_TOO_BIG     = "JOB_TOO_BIG\r\n".freeze
    DRAINING        = "DRAINING\r\n".freeze
    NOT_FOUND       = "NOT_FOUND\r\n".freeze

    def parse(stream)
      while (line = stream.gets("\r\n")) do
        if line.slice!(-2..-1) != "\r\n"
          output(BAD_FORMAT)
          return
        end

        command, *args = line.split
        if !send(command.gsub('-', '_'), *([stream] + args))
          return
        end
      end
    end
  end
end
