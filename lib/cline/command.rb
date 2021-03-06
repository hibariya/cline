# coding: utf-8

require 'thor'

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
      notify Notification.display!(offset)
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
        puts notification.display_message
      end
    end

    desc :open, 'Open the URL in the message if exists'
    method_options hint: :string
    def open(alias_string = options[:hint])
      require 'launchy'

      notification = Notification.by_alias_string(alias_string).last

      if notification && url = notification.detect_url
        Launchy.open url
      else
        say 'No URL found', :red
      end
    end

    desc :status, 'Show status'
    def status
      puts "displayed : #{Notification.displayed.count}"
      puts "total     : #{Notification.count}"

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
    def recent(limit = options[:limit] || 10)
      Notification.recent_notified.limit(limit).each do |notification|
        puts notification.display_message
      end
    end

    desc :version, 'Show version'
    def version
      puts "cline version #{Cline::VERSION}"
    end

    desc :server, 'start or stop server'
    def server(command = :start)
      case command.intern
      when :start
        puts 'starting cline server'

        Server.start
      when :stop
        puts 'stopping cline server'

        Server.stop
      when :reload
        puts 'reloading configuration'

        Cline.tap do |c|
          c.load_config_if_exists
          c.load_default_config
        end
      when :status
        if Server.running?
          puts "Socket file exists"
          puts "But server isn't responding" if Server.client_process?
        else
          puts "Server isn't running"
        end
      else
        puts 'Usage: cline server (start|stop)'
      end
    end

    private

    def notify(str)
      Cline.notify_io.tap do |io|
        io.puts str
        io.flush if io.respond_to?(:flush)
      end

      Thread.current[:stdout].tap do |stdout|
        stdout.puts str if stdout
      end
    end

    def puts(str)
      Cline.stdout.puts str
    end
  end
end
