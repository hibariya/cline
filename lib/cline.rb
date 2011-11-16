# coding: utf-8

here = File.dirname(__FILE__)
$LOAD_PATH.unshift here unless $LOAD_PATH.include?(here)

module Cline
  class << self
    def cline_dir
      "#{ENV['HOME']}/.cline"
    end

    def boot
      mkdir_if_needed
      setup_logger
      establish_connection
      load_config_if_exists
    end

    def mkdir_if_needed
      path = Pathname.new(cline_dir)
      path.mkdir unless path.directory?
    end

    def setup_logger
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Base.logger.level = Logger::WARN
    end

    def establish_connection
      ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: "#{cline_dir}/cline.sqlite3", timeout: 10000
    end

    def load_config_if_exists
      config = Pathname.new("#{cline_dir}/config")
      load config if config.exist?
    end

    def out_stream
      @out_stream || STDOUT
    end

    def out_stream=(stream)
      @out_stream = stream
    end

    def pool_size
      @pool_size
    end

    def pool_size=(pool_size)
      @pool_size = pool_size
    end

    collectors = []
    define_method(:collectors) { collectors }
  end
end

require 'logger'
require 'pathname'
require 'thor'
require 'sqlite3'
require 'active_record'

require "cline/version"
require "cline/notification"
require "cline/command"
require "cline/collectors"
require "cline/out_streams"
