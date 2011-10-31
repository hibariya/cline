# coding: utf-8

module Cline::OutStreams
  class WithGrowl
    attr_reader:stream

    def initialize(stream = $stdout)
      @stream = stream
    end

    def puts(str)
      puts_stream str
      puts_growlnotify str
    end

    private

    def puts_stream(str)
      stream.puts str
    end

    def puts_growlnotify(str)
      `growlnotify -m '#{str}'`
    end
  end
end
