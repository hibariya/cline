# coding: utf-8

require 'thor'
require 'launchy'

module Cline
  class Command < Thor
    class << self
      def start(args = ARGV, *)
        return super unless server_available?(args)

        Cline::Client.start args
      rescue => e
        Cline.logger.fatal :cline do
          %(#{e.class} #{e.message}\n#{e.backtrace.join($/)})
        end

        raise
      end

      private

      def server_available?(args)
        return false if client_command?(args)
        return false unless Cline::Server.running?
        return false unless Cline::Server.client_process?

        true
      end

      def client_command?(args)
        %w(collect open).include? args.first
      end
    end

    map '-s'  => :show,
        '-t'  => :tick,
        '-sr' => :search,
        '-st' => :status,
        '-c'  => :collect,
        '-i'  => :init,
        '-d'  => :server,
        '-v'  => :version

    desc :show, 'Show a latest message'
    method_options offset: :integer
    def show(offset = options[:offset] || 0)
      Notification.display offset
    end

    desc :tick, 'Rotate message'
    method_options offset: :integer, interval: :integer
    def tick(interval = options[:interval] || 5, offset = options[:offset] || 0)
      loop do
        show offset

        sleep Integer(interval)
      end
    end

    desc :search, 'Search by query'
    method_options query: :string
    def search(keyword = optoins[:query])
      Notification.by_keyword(keyword).each do |notification|
        say notification.display_message
      end
    end

    desc :open, 'Open the URL in the message if exists'
    method_options hint: :string
    def open(alias_string = options[:hint])
      notification = Notification.by_alias_string(alias_string).last

      if notification && url = notification.detect_url
        Launchy.open url
      else
        say 'No URL found', :red
      end
    end

    desc :status, 'Show status'
    def status
      say "displayed : #{Notification.displayed.count}", :green
      say "total     : #{Notification.count}", :cyan

      server :status
    end

    desc :collect, 'Collect sources'
    def collect
      pid = Process.fork {
        Cline.collectors.each &:collect

        Notification.clean(Cline.notifications_limit) if Cline.notifications_limit
      }

      Process.waitpid pid
    end

    desc :init, 'Init database'
    def init
      Cline.establish_database_connection

      ActiveRecord::Base.connection.create_table(:notifications) do |t|
        t.text     :message, null: false, default: ''
        t.integer  :display_count, null: false, default: 0
        t.datetime :notified_at, null: false
      end
    end

    desc :recent, 'Show recent notification'
    method_options limit: :integer
    def recent(limit = options[:limit] || 1)
      Notification.recent_notified.limit(limit).each do |notification|
        say notification.display_message
      end
    end

    desc :version, 'Show version'
    def version
      say "cline version #{Cline::VERSION}"
    end

    desc :server, 'start or stop server'
    def server(command = :start)
      case command.intern
      when :start
        Server.start
      when :stop
        Server.stop
      when :status
        if Server.running?
          say "Socket file exists"
          say "But server isn't responding" if Server.client_process?
        else
          say "Server isn't running"
        end
      else
        say 'Usage: cline server (start|stop)'
      end
    end
  end
end
