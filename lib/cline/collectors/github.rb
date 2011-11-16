# coding: utf-8

module Cline::Collectors
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
        message = extract_message(event)
        next unless message

        [message, event['created_at']]
      }.compact
    end

    private

    def extract_message(event)
      act = extract_activity(event)
      return unless act

      event_string = act.type.gsub(/Event/i, '')
      Cline::Notification.normalize_message("#{event_string}: #{act.actor} #{act.action} #{act.url}")
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
