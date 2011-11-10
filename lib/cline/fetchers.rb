# coding: utf-8

module Cline::Fetchers
  class Feed
    class << self
      def fetch
        entries = new(opml_path.read).fetch

        entries.each do |entry|
          begin
            Cline::Notification.instance_exec entry do |entry|
              message = normalize_message("#{entry.title} #{entry.url}").encode(Encoding::UTF_8)

              find_by_message(message) || create(message: message, time: entry.published)
            end
          rescue ActiveRecord::StatementInvalid => e
            puts e.class, e.message
          end
        end
      end

      def opml_path
        opml = Pathname.new("#{Cline.cline_dir}/feeds.xml")
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
        Thread.fork {
          begin
            feed = Feedzirra::Feed.fetch_and_parse(feed_url)

            if feed.is_a?(Feedzirra::FeedUtilities)
              feed.entries.each { |entry| entries << entry }
            end
          rescue
            puts $!.class, $!.message
          ensure
            Thread.pass
          end
        }
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
