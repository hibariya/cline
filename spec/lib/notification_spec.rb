# coding: utf-8

require_relative '../spec_helper'

describe Cline::Notification do
  describe '.ealiest' do
    let!(:notification1) { Fabricate(:notification, time: 2.days.ago.beginning_of_day, display_count: 3) }
    let!(:notification2) { Fabricate(:notification, time: 3.days.ago.beginning_of_day, display_count: 3) }
    let!(:notification3) { Fabricate(:notification, time: 3.days.ago.beginning_of_day, display_count: 2) }

    context 'default(limit 1 offset 0)' do
      subject { Cline::Notification.earliest.all }

      it { should == [notification3] }
    end

    context 'limit 2 offset 1' do
      subject { Cline::Notification.earliest(2, 1).all }

      it { should == [notification2, notification1] }
    end
  end

  describe '.displayed' do
    let!(:notification1) { Fabricate(:notification, display_count: 0) }
    let!(:notification2) { Fabricate(:notification, display_count: 1) }

    subject { Cline::Notification.displayed.all }

    it { should == [notification2] }
  end

  describe '#message=' do
    let(:notification) { Fabricate(:notification, display_count: 0) }

    before do
      notification.message = <<-EOM
        line feed
        spoooooky
      EOM
    end

    subject { notification }

    its(:message) { should_not match /\n/ }
  end

  describe '#display' do
    let!(:notification) { Fabricate(:notification, display_count: 0) }

    specify 'display_count should incremented' do
      -> { notification.display }.should change(notification, :display_count).by(1)
    end
  end
end
