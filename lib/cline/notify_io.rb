# coding: utf-8

autoload :Notify, 'notify'

module Cline
  module NotifyIO
    class WithNotify
      def initialize(io = $stdout)
        @io = io
      end

      def puts(str)
        @io.puts str

        Notify.notify 'cline', str
      end
    end

    WithGrowl = WithNotify
  end

  OutStreams = NotifyIO
end

