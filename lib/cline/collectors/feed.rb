# coding: utf-8

require 'pathname'

module Cline::Collectors
  class Feed < Base
    class << self
      def collect
        new(opml_path.read).entries.each do |entry|
          message = Cline::Notification.normalize_message("#{entry.title} #{entry.url}")

          create_or_pass message, entry.published
        end
      end

      def opml_path
        opml = Pathname.new("#{Cline.cline_dir}/feeds.xml")
      end
    end

    def initialize(opml_str)
      require 'rexml/document'
      require 'active_support/deprecation'
      require 'feedzirra'

      @opml = REXML::Document.new(opml_str)
    end

    def entries
      feed_urls = parse_opml(@opml.elements['opml/body'])
      entries   = []

      3.times.map { Thread.fork {
        while url = feed_urls.pop
          entries += fetch_entries(url)
        end

        Thread.pass
      } }.map(&:join)

      entries
    end

    private

    def parse_opml(opml_node)
      urls = []

      opml_node.elements.each('outline') do |el|
        unless el.elements.size.zero?
          urls += parse_opml(el)
        else
          url = el.attributes['xmlUrl']
          urls << url if url
        end
      end

      urls
    end

    def fetch_entries(feed_url)
      feed = Feedzirra::Feed.fetch_and_parse(feed_url)

      feed.is_a?(Feedzirra::FeedUtilities) ? feed.entries : []
    rescue => e
      Cline.logger.error [e.class, e.message].join(' ')
    end
  end
end
