module Kl
  module Primitives
    module Streams
      def pr(s, stream)
        stream.write(s)
        s
      end
      
      define_method "read-byte" do |stream|
        if stream.eof?
          -1
        else
          stream.readbyte
        end
      end
      
      def open(stream_type, name, direction)
        unless stream_type == :file
          raise Kl::Error, "unsupported stream type: #{stream_type}"
        end
        File.open(File.expand_path(name, value(:'*home-directory*')), 
                  direction == :out ? 'w' : 'r')
      end
      
      def close(stream)
        stream.close
        :NIL
      end
    end
  end
end
