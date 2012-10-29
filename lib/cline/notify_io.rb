# coding: utf-8

module Cline
  autoload :Notify, 'notify'

  module NotifyIO
    class WithNotify
      def initialize(io = $stdout)
        @io = io
      end

      def puts(str)
        @io.puts str

        Notify.notify '', str
      end
    end

    WithGrowl = WithNotify
  end

  OutStreams = NotifyIO
end

