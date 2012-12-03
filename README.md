# Cline - CLI lazy notifier [![Build Status](https://secure.travis-ci.org/hibariya/cline.png?branch=master)](http://travis-ci.org/hibariya/cline)

```
 +-------------------------+        +-------+              +--------------------------------------+
 | Notification Collectors |     -> | Cline |           -> | IO (STDOUT, File and Other notifier) |
 +-------------------------+        +-------+              +--------------------------------------+
 Collect any notifications       Store notifications    Put anywhere
```

Cline is a simple and lazy notification tool for CLI.
This tool collects automatically any Feeds and GitHub activities and those notifications shown on stdout or anywhere at some time.

Like this:

```
$ cline show
[2012/11/27 01:18][5][184] TED: Ideas worth spreading http://icio.us/+a922037eaf9bb
```

A notification is structured by below contents:

* published date of the entry and activity
* displayed count
* alias number for specify from CLI ([0-9a-z]+)
* title or summary (includes source URL)

In most cases Cline used for backtick of screen. Like this:

```
[2012/12/01 23:12][9][1bt] Amazon Redshift http://aws.amazon.com/redshift/
[2012/12/01 23:12][9][1bu] My eBook build process and some PDF, EPUB and MOBI tips - Pat Shaughnessy http://patshaughnessy.net/2012/11/27/my-ebook-build-process-and-some-pdf-epub-and-mobi-tips
[2012/12/01 23:12][9][1bs] How to Clean Up Your Online Presence and Make a Great First Impression http://lifehacker.com/5963864/how-to-clean-up-your-online-presence-and-make-a-great-first-impression
```

Cline decides priority of each notification with 'displayed count' and 'published date'.
You can't control priority of Cline's output (remember that cline is lazy ;).

## Installation and Setting

```
  $ gem install cline
  $ cline init        # database and config file will created under ~/.cline directory
```

Customize configuration file in ~/.cline/config:

```ruby
  Cline.configure do |config|
    config.notifications_limit = 2000 # old notifications will be removed automatically

    config.notify_io = Cline::NotifyIO::WithNotify.new
    # Default is:
    # config.notify_io = $stdout

    config.collectors << Cline::Collectors::Feed

    # Github:
    config.collectors << Cline::Collectors::Github
    Cline::Collectors::Github.login_name = 'hibariya'

    # When server is running then collectors will run every hours.
    config.jobs << Cline::ScheduledJob.new(-> { Time.now.min.zero? }, &:collect)
  end
```

Write OPML file of your RSS feeds:

```
  $ curl http://foo.examle.com/url/to/opml.xml > ~/.cline/feeds.xml
```

Collect notifications:

```
  $ cline collect
```

Show notifications:

```
  $ cline tick 5
  [2012/05/02 02:34][9][w6] Introducing DuckDuckHack - Gabriel Weinberg's Blog http://www.gabrielweinberg.com/blog/2012/05/introducing-duckduckhack.html
          |          |  |
          `-- time   |  `-- alias
                     `----- display count
```

How to open a URL in the message: Use open command and specify notification alias.

```
  $ cline open w6
```

## Use case

In most cases Cline used for backtick of screen.

In ~/.screenrc:

```
  backtick 0 0 0 cline tick 5
```

## Cline daemon

When server is running then cline uses server process.
Using server is faster and less memory.

```
  $ cline server start  # start server
  $ cline server reload # reload ~/.cline/config file
  $ cline server stop   # stop server
  $ cline server status # show server status
```

## Customize

### Custom collector

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
It create a new (unique) notification.

In ~/.cline/config:

```ruby
  require 'path/to/my_collector'

  Cline.configure do |config|
    # ...
    config.collectors << MyCollector
  end
```

## Notifier

`show` and `tick` command uses Cline's notifier.
Default notifier is $stdout.

### Custom Notifyer

Cline's notifier required `puts` method.

example:

```ruby
  class MyNotifier
    def puts(str)
      # implement notifier behaviour...
    end
  end
```

In ~/.cline/config

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
