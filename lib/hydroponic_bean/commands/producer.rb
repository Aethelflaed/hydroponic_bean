module HydroponicBean
  module Commands
    module Producer
      def use(stream, tube)
        @current_tube_name = tube
        output("USING #{current_tube_name}\r\n")
      end

      def put(stream, pri, delay, ttr, bytes)
        bytes = bytes.to_i
        data = stream.read(bytes)

        if data.length < bytes
          output(Protocol::BAD_FORMAT)
          return false
        end

        if stream.read(2) != "\r\n"
          output(Protocol::EXPECTED_CRLF)
          return false
        end

        job = create_job(pri, delay, ttr, data)
        output("INSERTED #{job.id}\r\n")
      end
    end
  end
end
