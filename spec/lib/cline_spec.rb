# coding: utf-8

require 'spec_helper'

describe Cline do
  describe '#load_config_if_exists' do
    let(:config) { Pathname.new(Cline.cline_dir).join('config') }

    before do
      config.open('w') {|f| f.puts "Cline.collectors  << Cline::Collectors::Feed" }

      Cline.boot
    end

    specify "config file should loaded" do
      Cline.collectors.should include Cline::Collectors::Feed
    end

    after do
      config.unlink
    end
  end
end
