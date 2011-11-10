# coding: utf-8

module Cline
  class Notification < ActiveRecord::Base
    validate :time, presence: true
    validate :message, presence: true, uniqueness: true
    validate :display_count, presence: true, numerically: true

    scope :earliest, ->(limit = 1, offset = 0) {
      order('display_count, time').limit(limit).offset(offset)
    }

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
