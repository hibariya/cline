# coding: utf-8

require 'pathname'
require 'socket'
require 'json'
require 'cline/monkey'

module Cline
  class Server
    class << self
      def start
        raise %(Socket file #{socket_file} already exists.) if running?

        Process.daemon

        pid_file.open 'w' do |pid|
          pid.write Process.pid
        end

        Signal.trap(:KILL) { Server.clean }

        new(socket_file).run
      end

      def stop
        raise %(Server isn't running) unless running?

        Process.kill :TERM, pid
      end

      def clean
        File.unlink pid_file
        File.unlink socket_file
      end

      def running?
        socket_file.exist?
      end

      def client_process?
        Process.pid != pid
      end

      def pid
        Integer(pid_file.read)
      end

      def pid_file
        Pathname.new(Cline.cline_dir).join('cline.pid')
      end

      def socket_file
        Pathname.new(Cline.cline_dir).join('cline.sock')
      end
    end

    def initialize(socket_file)
      @socket_file = socket_file
      @server      = UNIXServer.new(@socket_file.to_s)
    end

    def run
      loop do
        Thread.fork @server.accept do |socket|
          request = socket.recv(120)

          invoke socket, JSON.parse(request)

          socket.close

          GC.start
        end
      end
    ensure
      Server.clean
    end

    private

    def invoke(io, args)
      replace_current_io io

      Command.start args
    rescue Exception => e
      warn %(#{e.class} #{e.message}\n#{e.backtrace.join($/)})
    end

    def replace_current_io(io)
      Thread.current[:stdout] = Thread.current[:stderr] = io
    end
  end
end
