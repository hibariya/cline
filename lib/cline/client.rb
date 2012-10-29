# coding: utf-8

require 'socket'

module Cline
  class Client
    def self.exec(*args)
      new(*args).invoke

      exit
    end

    def initialize(*args)
      @args = args
    end

    def invoke
      $stdout.sync = true

      UNIXSocket.open Server.socket_file.to_path do |socket|
        socket.puts @args.join(' ')

        while line = socket.gets
          puts line
        end
      end
    end
  end
end
