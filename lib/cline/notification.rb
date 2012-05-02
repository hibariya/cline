# coding: utf-8

module Cline
  class Notification < ActiveRecord::Base
    validate :notified_at, presence: true
    validate :message, presence: true, uniqueness: true
    validate :display_count, presence: true, numerically: true

    scope :with_volatile_id, -> {
      select('(id - (SELECT MIN(id) FROM notifications)) AS volatile_id, *')
    }

    scope :by_keyword, ->(word) {
      where('message like ?', "%#{word}%").order('notified_at DESC, display_count')
    }

    scope :earliest, ->(limit = 1, offset = 0) {
      order(:display_count).order(:notified_at).limit(limit).offset(offset)
    }

    scope :displayed, -> { where('display_count > 0') }

    scope :recent_notified, ->(limit = 1) {
      n = earliest.first
      where('display_count > ? AND notified_at <= ?', n.display_count, n.notified_at).
        order(:display_count).order('notified_at DESC')
    }

    def message=(m)
      super Notification.normalize_message(m)
    end

    class << self
      def display(offset = 0)
        with_volatile_id.
          earliest(1, offset).
          first.
          display
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
      display_time = notified_at.strftime('%Y/%m/%d %H:%M')
      alias_id     = volatile_id.to_i.to_s(36)

      "[#{display_time}][#{display_count}][$#{alias_id}] #{message}"
    end
  end
end
