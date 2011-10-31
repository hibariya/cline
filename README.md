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

## Usage

in ~/.screenrc

~~~~
backtick 0 0 0 cline tick 0 60
~~~~
