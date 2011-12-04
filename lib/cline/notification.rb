# coding: utf-8

module Cline
  class Notification < ActiveRecord::Base
    validate :notified_at, presence: true
    validate :message, presence: true, uniqueness: true
    validate :display_count, presence: true, numerically: true

    scope :by_keyword, ->(word) {
      where('message like ?', "%#{word}%").order('notified_at DESC, display_count')
    }

    scope :earliest, ->(limit = 1, offset = 0) {
      order(:display_count).order(:notified_at).limit(limit).offset(offset)
    }

    scope :displayed, where('display_count > 0')

    scope :recent_notified, ->(limit = 1) {
      n = earliest.first
      where('display_count > ? AND notified_at <= ?', n.display_count, n.notified_at).
        order(:display_count).order('notified_at DESC')
    }

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
          order('notified_at DESC').
          order(:display_count).
          offset(pool_size).
          destroy_all
      end
    end

    def display
      Cline.out_stream.puts display_message

      increment! :display_count
    end

    def display_message
      "[#{notified_at}][#{display_count}] #{message}"
    end
  end
end
