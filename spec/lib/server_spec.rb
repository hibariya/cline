# coding: utf-8

require 'spec_helper'

describe 'Server' do
  describe 'request from client' do
    before do
      Process.fork { Cline::Command.start(%w(server start)) }
      wait_for_server

      #Cline::Command.any_instance.should_not_receive(:status)
    end

    after do
      Cline::Command.start(%w(server stop))
    end

    subject { capture(:stdout) { Cline::Command.start(%w(server status)) } }

    it { should =~ /Socket file exists/ }
  end
end
