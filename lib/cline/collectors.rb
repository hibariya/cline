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
end

require 'cline/collectors/feed'
require 'cline/collectors/github'
