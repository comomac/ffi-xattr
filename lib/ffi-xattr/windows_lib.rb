# encoding: utf-8
require 'ffi-xattr'

class Xattr # :nodoc: all
  module Lib
    class << self

      def list(path, no_follow)
        lines = `dir /r "#{path}"`.split("\n")

        xattrs = []
        for line in lines
          if line =~ /\:\$DATA$/
            size = line.split(' ')[0].gsub(/[^0-9]/,'').to_i

            if size > 0
              xattrs << line.split(':')[1]
            end
          end
        end

        xattrs
      end

      def get(path, no_follow, key)
        fp = "#{path}:#{key}"
        if FileTest.exists?(fp)
          File.binread(fp)
        else
          raise "No such key. #{key}. #{path}"
        end
      end

      def set(path, no_follow, key, value)
        f = File.new("#{path}:#{key}",'wb')
        f.write(value)
        f.close
      end

      def remove(path, no_follow, key)
        # done this way because Windows have no function to remove Alternate Data Stream
        # quickest way is to set the value to 0 byte length instead of trying to create another file then apply the attributes, especially when dealing with a big file
        self.set(path, false, key, '')
      end
    end

  end
end
