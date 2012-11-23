# coding: utf-8

require 'fileutils'
require 'logger'
require 'cline/configure'
require 'cline/version'

module Cline
  autoload :Collectors,   'cline/collectors'
  autoload :Command,      'cline/command'
  autoload :Notification, 'cline/notification'
  autoload :Server,       'cline/server'
  autoload :Client,       'cline/client'
  autoload :NotifyIO,     'cline/notify_io'
  autoload :ScheduledJob, 'cline/scheduled_job'

  autoload :OutStreams,   'cline/notify_io' # obsolete

  class << self
    attr_accessor :logger, :notifications_limit
    attr_writer   :collectors, :notify_io, :jobs

    def cline_dir
      "#{ENV['HOME']}/.cline"
    end

    def boot
      mkdir_if_needed
      load_config_if_exists
      load_default_config

      self
    end

    def collectors
      @collectors ||= []
    end

    def jobs
      @jobs ||= []
    end

    def establish_database_connection
      require 'active_record'

      ActiveRecord::Base.logger = logger
      ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: %(#{cline_dir}/cline.sqlite3), timeout: 10000
    end

    def stdout
      Thread.current[:stdout] || $stdout
    end

    def stderr
      Thread.current[:stderr] || $stderr
    end

    def notify_io
      @notify_io == $stdout ? stdout : @notify_io
    end

    private

    def mkdir_if_needed
      FileUtils.mkdir_p cline_dir
    end

    def load_default_config
      @logger              ||= default_logger
      @notify_io           ||= stdout
      @notifications_limit ||= nil
    end

    def load_config_if_exists
      config_file = "#{cline_dir}/config"

      load config_file if File.exist?(config_file)
    end

    def default_logger
      Logger.new("#{cline_dir}/log").tap {|l| l.level = Logger::WARN }
    end

    public

    # obsoletes
    [%w(out_stream notify_io), %w(pool_size notifications_limit)].each do |obsolete, original|
      alias_method obsolete,        original
      alias_method %(#{obsolete}=), %(#{original}=)
    end
  end
end
