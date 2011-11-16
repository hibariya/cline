# Cline - CLI Line Notifier

## **Important** Data schema has changed on version 0.2.3

Please try following commands:

In shell:

~~~~
  $ sqlite3 ~/.cline/cline.sqlite3
~~~~

In sqlite3 prompt:

~~~~
  BEGIN TRANSACTION;
  CREATE TABLE "tmp_notifications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "message" text DEFAULT '' NOT NULL, "display_count" integer DEFAULT 0 NOT NULL, "notified_at" datetime NOT NULL);
  INSERT INTO tmp_notifications SELECT id, message, display_count, time as notified_at FROM notifications;
  DROP TABLE notifications;
  ALTER TABLE tmp_notifications RENAME TO notifications;
  COMMIT;
  .q
~~~~

## Installation

~~~~
  gem install cline
  cline init
  echo "Cline.out_stream = Cline::OutStreams::WithGrowl.new($stdout)" > ~/.cline/config # growlnotify required
  echo "Cline.collectors  << Cline::Collector::Feed" >> ~/.cline/config
  echo "Cline.pool_size   << 2000" >> ~/.cline/config
  curl http://foo.examle.com/url/to/opml.xml > ~/.cline/feeds.xml

  cline collect
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

`collect`command collect new notifications from `Cline.collectors`.

~~~~
  cline collect
~~~~

### Custom Collector

*collector* required `collect` method.

example:

~~~~ruby
  class MyCollector
    def self.collect
      new.sources.each do |source|
        Cline::Notification.find_by_message(source.body) || Cline::Notification.create!(message: source.body, notified_at: source.created_at)
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
  require 'path/to/my_collector'
  Cline.collectors << MyCollector
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
