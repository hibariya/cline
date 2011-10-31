# coding: utf-8

module Cline
  class Command < Thor
    def self.start(*)
      Cline.boot
      super
    end

    desc 'show', 'show a latest message'
    method_options offset: :integer
    def show(offset = options[:offset] || 0)
      Notification.display offset
    end

    desc 'tick', 'rotate message'
    method_options offset: :integer, interval: :integer
    def tick(offset = options[:offset] || 0, interval = options[:interval] || 60)
      loop do
        show offset
        sleep interval.to_i
      end
    end

    desc 'status', 'show status'
    def status
      say "displayed : #{Notification.displayed.count}", :green
      say "total     : #{Notification.count}", :cyan
    end

    desc 'fetch', 'fetch sources'
    def fetch
      Cline.fetchers.each &:fetch
    end

    desc 'init', 'init database'
    def init
      ActiveRecord::Base.connection.create_table(:notifications) do |t|
        t.text    :message, null: false, default: ''
        t.integer :display_count, null: false, default: 0
        t.time    :time, null: false
      end
    end
  end
end
