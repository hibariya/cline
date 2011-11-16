# coding: utf-8

Fabricator(:notification, class_name: Cline::Notification) do
  message { sequence(:message) {|i| "message ##{i}" } }
  notified_at { Time.now }
end
