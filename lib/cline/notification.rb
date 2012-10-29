# coding: utf-8

require 'uri'
require 'sqlite3'
require 'active_record'

module Cline
  establish_database_connection

  class Notification < ActiveRecord::Base
    validate :notified_at, presence: true
    validate :message, presence: true, uniqueness: true
    validate :display_count, presence: true, numerically: true

    default_scope -> {
      select('(id - (SELECT MIN(id) FROM notifications)) AS id_alias, *')
    }

    scope :by_alias_string, ->(alias_string) {
      where('id_alias = ?', alias_string.to_i(36))
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
        earliest(1, offset).first.display
      end

      def normalize_message(m)
        m.gsub(/[\r\n]/, '')
      end

      def clean(limit)
        order('notified_at DESC').
          order(:display_count).
          offset(limit).
          destroy_all
      end
    end

    def display
      Cline.notify_io.tap do |io|
        io.puts display_message

        io.flush if io.respond_to?(:flush)
      end

      increment! :display_count
    end

    def display_message
      display_time = notified_at.strftime('%Y/%m/%d %H:%M')

      "[#{display_time}][#{display_count}][#{id_alias_string}] #{message}"
    end

    def detect_url(protocols = %w(http https))
      regexp = URI.regexp(protocols)

      if match = message.match(regexp)
        match.to_s
      else
        nil
      end
    end

    def id_alias_string
      id_alias.to_i.to_s(36)
    end
  end
end
