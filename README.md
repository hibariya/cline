# Cline - CLI Line Notifier [![Build Status](https://secure.travis-ci.org/hibariya/retter.png?branch=master)](http://travis-ci.org/hibariya/retter)

Cline is a simple notification tool.

~~~~
 +------------+              +-----------+              +-----------+
 | Collectors |  ----------> | Cline     |  ----------> | OutStream |
 +------------+              +-----------+              +-----------+
 Collect any notifications   Pool notifications         Put anywhere
~~~~

## Installation and Setting

~~~~
  $ gem install cline
  $ cline init
~~~~

In ~/.cline/config:

~~~~ruby
  Cline.configure do |config|
    config.pool_size = 2000

    config.out_stream = Cline::OutStreams::WithGrowl.new($stdout)
    # Or
    # config.out_stream = $stdout

    config.append_collector Cline::Collectors::Feed
  end
~~~~

Write your RSS feeds OPML file:

~~~~
  $ curl http://foo.examle.com/url/to/opml.xml > ~/.cline/feeds.xml
~~~~

Collect notifications:

~~~~
  $ cline collect
~~~~

Show notifications:

~~~~
  $ cline tick --offset 0 --interval 5
~~~~

## Use case

in ~/.screenrc

~~~~
  backtick 0 0 0 cline tick 0 60
~~~~

## initialize Database

`init` command initialize new sqlite3 database.

~~~~
  $ cline init
~~~~

## Collect

`collect` command collect new notifications from `Cline.collectors`.

~~~~
  $ cline collect
~~~~

### Custom Collector

*collector* required `collect` method.

example:

~~~~ruby
  class MyCollector < Cline::Collectors::Base
    def self.collect
      new.sources.each do |source|
        create_or_pass source.body, source.created_at
      end
    end

    def sources
      # get new sources...
    end
  end
~~~~

Cline::Collectors::Base class provides create_or_pass method.
It create a new unique notification.

### Registration

in ~/.cline/config

~~~~ruby
  require 'path/to/my_collector'

  Cline.configure do |config|
    # ...
    config.append_collector MyCollector
  end
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

  Cline.configure do |config|
    # ...
    config.out_stream = MyNotifier.new
  end
~~~~
