# coding: utf-8

require 'forwardable'

module Cline
  def self.configure(&block)
    configure = Configure.new
    block ? block.(configure) : configure
  end

  class Configure
    extend Forwardable

    def_delegators Cline, :pool_size=, :out_stream=

    def notification
      Cline::Notification
    end

    def append_collector(collector)
      Cline.collectors << collector
    end
  end
end
