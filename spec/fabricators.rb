# coding: utf-8

Fabricator(:notification, class_name: Cline::Notification) do
  message { sequence(:message) {|i| "message ##{i}" } }
  time { Time.now }
end
