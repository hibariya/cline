# coding: utf-8

module Cline::Collectors
  class Feed < Base
    class << self
      def collect
        new(opml_path.read).entries.each do |entry|
          message = Cline::Notification.normalize_message("#{entry.title} #{entry.url}").encode(Encoding::UTF_8)
          create_or_pass message, entry.published
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

    def entries
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
