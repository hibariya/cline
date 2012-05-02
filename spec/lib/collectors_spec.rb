# coding: utf-8

require 'spec_helper'

describe Cline::Collectors::Base do
  describe '.create_or_pass' do
    describe '.oldest_notification' do
      let(:oldest_notified_at) { 100.days.ago }

      before do
        Cline::Collectors::Base.send :reset_oldest_notification
        Cline::Notification.create(message: 'awesome', notified_at: oldest_notified_at)
      end

      context 'too old notification' do
        before do
          flunk unless Cline::Notification.count == 1

          Cline::Collectors::Base.create_or_pass('too old', oldest_notified_at - 1.day)
        end

        subject { Cline::Notification.count }

        it { should == 1 }
      end

      context 'newly notification' do
        before do
          flunk unless Cline::Notification.count == 1

          Cline::Collectors::Base.create_or_pass('newly', oldest_notified_at + 1.day)
        end

        subject { Cline::Notification.count }

        it { should == 2 }
      end
    end

    context 'invalid(filtered) notification' do
      before do
        Cline.configure do |config|
          config.notification.validates :message, length: {maximum: 1000}
        end
      end

      subject { capture(:stdout) { Cline::Collectors::Base.create_or_pass('a'*1001, Time.now) } }

      it { should match 'ActiveRecord::RecordInvalid' }

      describe 'Cline::Notification.count' do
        subject { Cline::Notification.count }

        it { should == 0 }
      end
    end
  end
end

describe Cline::Collectors::Github do
  shared_examples_for 'created_at should present from github event json' do
    it { json['created_at'].should_not be_nil }
    it { json['created_at'].should_not be_empty }
  end

  describe '.extract_message' do
    def event_json_string(name)
      file = CLINE_ROOT.join('spec', 'fixtures', 'github', name)
      JSON.parse(file.read)
    end

    subject { Cline::Collectors::Github.new('anonymous').send :extract_message, json }

    context 'CommitCommentEvent' do
      let(:json) { event_json_string('commit_comment_event.json') }

      it { should == "CommitComment: michaelklishin  https://github.com/travis-ci/travis-ci/commit/d57b3e9b83#commitcomment-712684" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'CreateEvent' do
      let(:json) { event_json_string('create_event.json') }

      it { should == "Create: jugyo  https://github.com/jugyo/unicolor" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'FollowEvent' do
      let(:json) { event_json_string('follow_event.json') }

      it { should == "Follow: miural  https://github.com/amachang" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'ForkEvent' do
      let(:json) { event_json_string('fork_event.json') }

      it { should == "Fork: tricknotes  https://github.com/tricknotes/gollum" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'GistEvent' do
      let(:json) { event_json_string('gist_event.json') }

      it { should == "Gist: wtnabe create https://gist.github.com/1359990" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'GollumEvent' do
      let(:json) { event_json_string('gollum_event.json') }

      it { should == "Gollum: banister edited https://github.com/pry/pry/wiki/State-navigation" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'IssueCommentEvent' do
      let(:json) { event_json_string('issue_comment_event.json') }

      it { should == "IssueComment: banister created https://github.com/pry/pry/issues/335" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'IssuesEvent' do
      let(:json) { event_json_string('issues_event.json') }

      it { should == "Issues: ConradIrwin closed https://github.com/pry/pry/issues/336" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'MemberEvent' do
      let(:json) { event_json_string('member_event.json') }

      it { should == "Member: paulelliott added https://github.com/shayarnett" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'PullRequestEvent' do
      let(:json) { event_json_string('pull_request_event.json') }

      it { should == "PullRequest: sferik closed https://github.com/travis-ci/travis-ci/pull/307" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'Push' do
      let(:json) { event_json_string('push_event.json') }

      it { should == "Push: sferik  https://github.com/travis-ci/travis-ci" }

      it_should_behave_like 'created_at should present from github event json'
    end

    context 'WatchEvent' do
      let(:json) { event_json_string('watch_event.json') }

      it { should == "Watch: hsbt started https://github.com/jasonm/backbone-js-on-rails-talk" }

      it_should_behave_like 'created_at should present from github event json'
    end
  end
end
