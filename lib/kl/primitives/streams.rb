module Kl
  module Primitives
    module Streams
      define_method 'pr', lambda { |s, stream|
        stream.write(s)
        s
      }.curry
      
      define_method 'read-byte', lambda { |stream|
        if stream.eof?
          -1
        else
          stream.readbyte
        end
      }.curry

      # Curried after inclusion
      def open(stream_type, name, direction)
        unless stream_type == :file
          raise Kl::Error, "unsupported stream type: #{stream_type}"
        end
        File.open(File.expand_path(name, value(:'*home-directory*')),
                  direction == :out ? 'w' : 'r')
      end
      
      define_method 'close', lambda { |stream|
        stream.close
        :NIL
      }.curry
    end
  end
end
