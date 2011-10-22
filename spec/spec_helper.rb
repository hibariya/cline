# coding: utf-8

require 'tapp'
require 'simplecov'

SimpleCov.start

RETTER_ROOT = Pathname.new(File.dirname(__FILE__) + '/../').realpath

Dir[File.dirname(__FILE__) + '/support/*'].each {|f| require f }

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
