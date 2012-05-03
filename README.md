# Cline - CLI Line Notifier [![Build Status](https://secure.travis-ci.org/hibariya/cline.png?branch=master)](http://travis-ci.org/hibariya/cline)

Cline is a simple notification tool.

```
 +------------+              +-----------+              +-----------+
 | Collectors |  ----------> | Cline     |  ----------> | OutStream |
 +------------+              +-----------+              +-----------+
 Collect any notifications   Pool notifications         Put anywhere
```

## Installation and Setting

```
  $ gem install cline
  $ cline init
```

In ~/.cline/config:

```ruby
  Cline.configure do |config|
    config.pool_size = 2000

    config.out_stream = Cline::OutStreams::WithNotify.new($stdout)
    ## Or
    # config.out_stream = $stdout

    config.append_collector Cline::Collectors::Feed
    ## Github:
    # config.append_collector Cline::Collectors::Github
    # Cline::Collectors::Github.login_name = 'hibariya'
  end
```

Write your RSS feeds OPML file:

```
  $ curl http://foo.examle.com/url/to/opml.xml > ~/.cline/feeds.xml
```

Collect notifications:

```
  $ cline collect
```

Show notifications:

```
  $ cline tick 0 5 # Or: cline tick --offset 0 --interval 5
  [2012/05/02 02:34][9][$w6] Introducing DuckDuckHack - Gabriel Weinberg's Blog http://www.gabrielweinberg.com/blog/2012/05/introducing-duckduckhack.html
  ...
```

Open URL in the message:

```
  $ cline open $w6
```

## Use case

in ~/.screenrc

```
  backtick 0 0 0 cline tick 0 60
```

## initialize Database

`init` command initialize new sqlite3 database.

```
  $ cline init
```

## Collect

`collect` command collect new notifications from `Cline.collectors`.

```
  $ cline collect
```

### Custom Collector

*collector* required `collect` method.

example:

```ruby
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
```

Cline::Collectors::Base class provides `create_or_pass` method.
It create a new unique notification.

### Registration

in ~/.cline/config

```ruby
  require 'path/to/my_collector'

  Cline.configure do |config|
    # ...
    config.append_collector MyCollector
  end
```

## Notifier

`show` and `tick` command uses Cline's notifier.
Default notifier is STDOUT.

### Custom Notifyer

Cline's notifier required `puts` instance method.

example:

```ruby
  class MyNotifier
    def puts(str)
      # implement notifier behaviour...
    end
  end
```

### Registration

in ~/.cline/config

```ruby
  require 'path/to/my_notifier'

  Cline.configure do |config|
    # ...
    config.out_stream = MyNotifier.new
  end
```

## Filtering

Use ActiveRecord validators.

```ruby
  Cline.configure do |config|
    # ...
    config.notification.validates :message, length: {maximum: 100}
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
