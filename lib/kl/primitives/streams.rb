module Kl
  module Primitives
    module Streams
      define_method 'read-byte' do |stream|
        if stream.eof?
          -1
        else
          stream.readbyte
        end
      end

      define_method 'write-byte' do |byte, stream|
        stream.putc byte
        byte
      end

      def open(name, direction)
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
