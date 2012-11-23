# coding: utf-8

module Cline::Collectors
  class Base
    class << self
      def create_or_pass(message, notified_at)
        return unless notified_at

        message     = message.encode(Encoding::UTF_8)
        notified_at = parse_time_string_if_needed(notified_at)

        return if oldest_notification && oldest_notification.notified_at.to_time > notified_at

        Cline::Notification.instance_exec message, notified_at do |message, notified_at|
          create!(message: message, notified_at: notified_at) unless find_by_message_and_notified_at(message, notified_at)
        end
      rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid => e
        error = [e.class, e.message].join(' ')

        puts error
        Cline.logger.error error
      end

      private

      def parse_time_string_if_needed(time)
        if time.is_a?(String)
          Time.parse(time)
        else
          time
        end
      end

      def oldest_notification
        @oldest_notification ||= Cline::Notification.order(:notified_at).limit(1).first
      end

      def reset_oldest_notification
        @oldest_notification = nil
      end
    end
  end
end

require 'cline/collectors/feed'
require 'cline/collectors/github'
