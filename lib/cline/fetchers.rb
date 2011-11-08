# coding: utf-8

module Cline::Fetchers
  class Feed
    def self.fetch
      opml = Pathname.new("#{Cline.cline_dir}/feeds.xml")
      entries = new(opml.read).fetch

      entries.each do |entry|
        message = "#{entry.title} #{entry.url}"

        begin
          Cline::Notification.tap {|n| n.find_by_message(message) || n.create(message: message, time: entry.published) }
        rescue ActiveRecord::StatementInvalid => e
          puts e.class, e.message
        end
      end
    end

    def initialize(opml_str)
      require 'rexml/document'
      require 'feedzirra'

      @opml = REXML::Document.new(opml_str)
      @feeds = parse_opml(@opml.elements['opml/body'])
    end

    def fetch
      entries = []

      @feeds.map { |feed_url|
        Thread.fork do
          begin
            feed = Feedzirra::Feed.fetch_and_parse(feed_url)
            entries += feed.entries if feed.is_a? Feedzirra::FeedUtilities
          rescue
            puts $!.class, $!.message
          end
        end
      }.map(&:join)

      entries
    end

    def parse_opml(opml_node)
      feeds = []

      opml_node.elements.each('outline') do |el|
        unless el.elements.size.zero?
          feeds += parse_opml(el) 
        else
          url = el.attributes['xmlUrl']
          feeds << url if url
        end
      end

      feeds
    end
  end
end
