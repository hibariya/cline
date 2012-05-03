# coding: utf-8

require 'launchy'

module Cline
  class Command < Thor
    def self.start(*)
      Cline.boot
      super
    end

    map '-s'  => :show,
        '-t'  => :tick,
        '-sr' => :search,
        '-st' => :status,
        '-c'  => :collect,
        '-i'  => :init,
        '-v'  => :version

    desc 'show', 'Show a latest message'
    method_options offset: :integer
    def show(offset = options[:offset] || 0)
      Notification.display offset
    end

    desc 'tick', 'Rotate message'
    method_options offset: :integer, interval: :integer
    def tick(offset = options[:offset] || 0, interval = options[:interval] || 60)
      loop do
        show offset
        sleep interval.to_i
      end
    end

    desc 'search', 'Search by query'
    method_options query: :string
    def search(keyword = optoins[:query])
      Notification.by_keyword(keyword).each do |notification|
        say notification.display_message
      end
    end

    desc 'open', 'Open the URL in the message if exists'
    method_options hint: :string
    def open(hint = options[:hint])
      alias_string = hint.sub(/\$/, '')
      notification = Notification.by_alias_string(alias_string).last

      if notification && url = notification.detect_url
        Launchy.open url
      else
        say 'No URL found', :red
      end
    end

    desc 'status', 'Show status'
    def status
      say "displayed : #{Notification.displayed.count}", :green
      say "total     : #{Notification.count}", :cyan
    end

    desc 'collect', 'Collect sources'
    def collect
      Cline.collectors.each &:collect

      clean_obsoletes
    end

    desc 'init', 'Init database'
    def init
      ActiveRecord::Base.connection.create_table(:notifications) do |t|
        t.text     :message, null: false, default: ''
        t.integer  :display_count, null: false, default: 0
        t.datetime :notified_at, null: false
      end
    end

    desc 'recent', 'Show recent notification'
    method_options limit: :integer
    def recent(limit = options[:limit] || 1)
      Notification.recent_notified.limit(limit).each do |notification|
        say notification.display_message
      end
    end

    desc 'version', 'Show version.'
    def version
      say "cline version #{Cline::VERSION}"
    end

    private

    def clean_obsoletes
      Notification.clean(Cline.pool_size) if Cline.pool_size
    end
  end
end
