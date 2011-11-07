# Cline - CLI Line Notifier

## Installation

~~~~
  gem install cline
  cline init
  echo "Cline.out_stream = Cline::OutStreams::WithGrowl.new($stdout)" > ~/.cline/config # growlnotify required
  echo "Cline.fetchers  << Cline::Fetchers::Feed" >> ~/.cline/config
  curl http://foo.examle.com/url/to/opml.xml > ~/.cline/feeds.xml

  cline fetch
  cline tick --offset 0 --interval 5
~~~~

## Use case

in ~/.screenrc

~~~~
  backtick 0 0 0 cline tick 0 60
~~~~

## initialize Database

`init`command initialize new sqlite3 database.

~~~~
  cline init
~~~~

## Reload

`fetch`command fetch new notifications from `Cline.fetchers`.

~~~~
  cline fetch
~~~~

### Custom Fetcher

*fetcher* required `fetch` method.

example:

~~~~ruby
  class MyFetcher
    def self.fetch
      new.sources.each do |source|
        Cline::Notification.find_by_message(source.body) || Cline::Notification.create!(message: source.body, time: source.created_at)
      end
    end

    def sources
      # get new sources...
    end
  end
~~~~

### Registration

in ~/.cline/config

~~~~ruby
  require 'path/to/my_fetcher'
  Cline.fetchers << MyFetcher
~~~~

## Notifier

`show` and `tick` command uses Cline's notifier.
Default notifier is STDOUT.

### Custom Notifyer

Cline's notifier required `puts` instance method.

example:

~~~~ruby
  class MyNotifier
    def puts(str)
      # implement notifier behaviour...
    end
  end
~~~~

### Registration

in ~/.cline/config

~~~~ruby
  require 'path/to/my_notifier'
  Cline.out_stream = MyNotifier.new
~~~~
