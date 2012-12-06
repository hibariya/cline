# coding: utf-8

require 'spec_helper'

describe Cline::Notification do
  describe '.ealiest' do
    let!(:notification1) { Fabricate(:notification, notified_at: 2.days.ago.beginning_of_day, display_count: 3) }
    let!(:notification2) { Fabricate(:notification, notified_at: 2.days.ago.beginning_of_day, display_count: 2) }
    let!(:notification3) { Fabricate(:notification, notified_at: 3.days.ago.beginning_of_day, display_count: 2) }

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

  describe '.clean' do
    let!(:notification1) { Fabricate(:notification, notified_at: 3.days.ago.beginning_of_day, display_count: 3) }
    let!(:notification2) { Fabricate(:notification, notified_at: 3.days.ago.beginning_of_day, display_count: 2) }
    let!(:notification3) { Fabricate(:notification, notified_at: 2.days.ago.beginning_of_day, display_count: 2) }

    context 'limit 2' do
      before do
        Cline::Notification.clean 2
      end

      subject { Cline::Notification.all }

      its(:length) { should == 2 }
      it { should include notification2 }
      it { should include notification3 }
    end

    context 'limit 1' do
      before do
        Cline::Notification.clean 1
      end

      subject { Cline::Notification.all }

      its(:length) { should == 1 }
      it { should include notification3 }
    end
  end

  describe '.recent_notified' do
    let!(:notification1) { Fabricate(:notification, notified_at: 3.days.ago.beginning_of_day, display_count: 0) }
    let!(:notification2) { Fabricate(:notification, notified_at: 2.days.ago.beginning_of_day, display_count: 0) }

    before do
      Cline::Notification.display! 0
    end

    subject { Cline::Notification.recent_notified(1).all }

    it { should == [notification1] }
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

  describe '.display!' do
    let!(:notification) { Fabricate(:notification, message: 'hi', notified_at: '2011-01-01 00:00:00', display_count: 0) }

    subject { Cline::Notification.display! }

    describe 'stdout' do
      it { should == '[2011/01/01 00:00][0][0] hi' }
    end

    specify 'display_count should incremented' do
      notification.display_count.should == 0
    end
  end
end
