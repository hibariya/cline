# coding: utf-8

module Cline
  class Notification < ActiveRecord::Base
    validate :time, presence: true
    validate :message, presence: true, uniqueness: true
    validate :display_count, presence: true, numerically: true

    scope :by_keyword, ->(word) {
      where('message like ?', "%#{word}%").order('time DESC, display_count')
    }

    scope :earliest, ->(limit = 1, offset = 0) {
      order_by_default_priority_for_display.order('time ASC').limit(limit).offset(offset)
    }

    scope :order_by_default_priority_for_display, order(:display_count)

    scope :displayed, where('display_count > 0')

    def message=(m)
      super Notification.normalize_message(m)
    end

    class << self
      def display(offset)
        earliest(1, offset).first.display
      end

      def normalize_message(m)
        m.gsub(/[\r\n]/, '')
      end

      def clean(pool_size)
        order_by_default_priority_for_display.
          order('time DESC').
          offset(pool_size).
          destroy_all
      end
    end

    def display
      Cline.out_stream.puts display_message

      increment! :display_count
    end

    def display_message
      "[#{time}][#{display_count}] #{message}"
    end
  end
end
