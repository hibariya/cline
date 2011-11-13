# coding: utf-8

module Cline::Collectors
  class Base
    def self.create_or_pass(message, time)
      Cline::Notification.instance_exec message, time do |message, time|
        create(message: message, time: time) unless find_by_message_and_time(message, time)
      end
    rescue ActiveRecord::StatementInvalid => e
      puts e.class, e.message
    end
  end

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

  class Github < Base
    class << self
      def collect
        new(login_name).activities.each do |message, time|
          create_or_pass message, time
        end
      end

      def login_name=(name)
        @login_name = name
      end

      def login_name
        @login_name
      end
    end

    Activity = Struct.new(:type, :actor, :action, :url)

    def initialize(name)
      require 'open-uri'
      require 'uri'

      @api_url = URI.parse("https://api.github.com/users/#{name}/received_events")
    end

    def activities
      events = JSON.parse(@api_url.read)

      events.map { |event|
        [extract_message(event), event['created_at']]
      }
    end

    private

    def extract_message(event)
      act = extract_activity(event)
      return unless act

      event_string = act.type.gsub(/Event/i, '')
      message      = Cline::Notification.normalize_message("#{event_string}: #{act.actor} #{act.action} #{act.url}")
      message.encode(Encoding::UTF_8)
    end

    def extract_activity(event)
      activity = Activity.new(
        event['type'],
        event['actor']['login']
      )

      apply_method = "apply_for_#{event_name_to_underscore(event['type'])}"

      if respond_to?(apply_method, true)
        payload  = event['payload']
        send apply_method, activity, event, payload
      else
        return nil
      end
    end

    def base_url
      @base_url ||= URI.parse('https://github.com/')
    end

    def event_name_to_underscore(str)
      str.chars.inject([]) {|r, c| # XXX 難しい
        r << (r.empty? ? c.downcase : (c.match(/[A-Z]/) ? "_#{c.downcase}" : c))
      }.join
    end

    def apply_for_commit_comment_event(activity, event, payload)
      activity.url = payload['comment']['html_url']
      activity
    end

    def apply_for_create_event(activity, event, payload)
      activity.url = base_url + event['repo']['name']
      activity
    end

    def apply_for_follow_event(activity, event, payload)
      activity.url = payload['target']['html_url']
      activity
    end

    def apply_for_fork_event(activity, event, payload)
      activity.url = payload['forkee']['html_url']
      activity
    end

    def apply_for_gist_event(activity, event, payload)
      activity.action = payload['action']
      activity.url    = payload['gist']['html_url']
      activity
    end

    def apply_for_gollum_event(activity, event, payload)
      page = payload['pages'].first # TODO pages contain some pages information
      activity.action = page['action']
      activity.url    = page['html_url']
      activity
    end

    def apply_for_issue_comment_event(activity, event, payload)
      activity.action = payload['action']
      activity.url    = payload['issue']['html_url']
      activity
    end

    alias_method :apply_for_issues_event, :apply_for_issue_comment_event

    def apply_for_member_event(activity, event, payload)
      activity.action = payload['action']
      activity.url    = base_url + payload['member']['login']
      activity
    end

    def apply_for_pull_request_event(activity, event, payload)
      activity.action = payload['action']
      activity.url    = payload['pull_request']['_links']['html']['href']
      activity
    end

    def apply_for_push_event(activity, event, payload)
      activity.url = base_url + event['repo']['name']
      activity
    end

    def apply_for_watch_event(activity, event, payload)
      activity.action = payload['action'] # WatchEvent
      activity.url    = base_url + event['repo']['name']
      activity
    end
  end
end
