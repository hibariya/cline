# coding: utf-8

require 'notify'

module Cline::OutStreams
  def self.const_missing(name)
    case name
    when :WithGrowl
      WithNotify
    else
      super
    end
  end

  class WithNotify
    attr_reader:stream

    def initialize(stream = $stdout)
      @stream = stream
    end

    def puts(str)
      puts_stream str
      Notify.notify '', str
    end

    private

    def puts_stream(str)
      stream.puts str
    end
  end
end
