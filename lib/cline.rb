require "cline/version"

here = File.dirname(__FILE__)
$LOAD_PATH.unshift here unless $LOAD_PATH.include?(here)

module Cline
  require 'cline/store'
  require 'cline/command'
end
