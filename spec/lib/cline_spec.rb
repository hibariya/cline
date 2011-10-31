# coding: utf-8

require_relative '../spec_helper'

describe Cline do
  describe '#load_config_if_exists' do
    let(:config) { Pathname.new(Cline.cline_dir).join('config') }

    before do
      config.open('w') {|f| f.puts "Cline.fetchers  << Cline::Fetchers::Feed" }

      Cline.boot
    end

    specify "config file should loaded" do
      Cline.fetchers.should include Cline::Fetchers::Feed
    end

    after do
      config.unlink
    end
  end
end
