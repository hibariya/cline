# coding: utf-8

require 'tapp'
require 'simplecov'
require 'fabrication'

SimpleCov.start

CLINE_ROOT = Pathname.new(File.dirname(__FILE__) + '/../').realpath
require_relative '../lib/cline'

Dir[File.dirname(__FILE__) + '/support/*'].each {|f| require f }
require_relative 'fabricators'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.mock_with :rr

  config.before(:suite) do
    home = CLINE_ROOT.join('spec', 'tmp')
    ENV['HOME'] = home.to_s

    cline_dir = Pathname.new(Cline.cline_dir)
    cline_dir.rmtree if cline_dir.directory?

    Cline.boot
    Cline::Command.new.invoke :init
  end

  config.before(:each) do
    Cline.boot
    Cline.out_stream = StringIO.new
    Cline::Notification.delete_all
  end
end
