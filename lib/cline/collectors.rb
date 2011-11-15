# coding: utf-8

module Cline::Collectors
  class Base
    class << self
      def create_or_pass(message, time)
        message = message.encode(Encoding::UTF_8)
        time    = parse_time_string_if_needed(time)

        Cline::Notification.instance_exec message, time do |message, time|
          create(message: message, time: time) unless find_by_message_and_time(message, time)
        end
      rescue ActiveRecord::StatementInvalid => e
        puts e.class, e.message
      end

      private

      def parse_time_string_if_needed(time)
        if time.is_a?(String)
          Time.parse(time)
        else
          time
        end
      end
    end
  end
end

require 'cline/collectors/feed'
require 'cline/collectors/github'
