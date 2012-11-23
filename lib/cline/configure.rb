# coding: utf-8

require 'forwardable'

module Cline
  def self.configure(&block)
    configure = Configure.new
    block ? block[configure] : configure
  end

  class Configure
    extend Forwardable

    def_delegators Cline,
      :logger, :logger=, :notify_io, :notify_io=, :notifications_limit, :notifications_limit=, :collectors, :collectors=, :jobs, :jobs=,
      :pool_size=, :out_stream= # obsoletes

    def notification
      Cline::Notification
    end

    def append_collector(collector)
      Cline.collectors << collector
    end
  end
end
