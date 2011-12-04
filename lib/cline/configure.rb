# coding: utf-8

module Cline
  def self.configure(&config)
    config.call Configure.new
  end

  class Configure
    def pool_size=(size)
      Cline.pool_size = size
    end

    def out_stream=(stream)
      Cline.out_stream = stream
    end

    def append_collector(collector)
      Cline.collectors << collector
    end
  end
end
