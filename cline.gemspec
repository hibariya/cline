# -*- encoding: utf-8 -*-

$:.push File.expand_path('../lib', __FILE__)
require 'cline/version'

Gem::Specification.new do |s|
  s.name        = 'cline'
  s.version     = Cline::VERSION
  s.authors     = ['hibariya']
  s.email       = ['celluloid.key@gmail.com']
  s.homepage    = 'https://github.com/hibariya/cline'
  s.summary     = %q{Show recently news on the terminal}
  s.description = %q{Show recently news on the terminal.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'thor',         ['~> 0.16.0']
  s.add_runtime_dependency 'activerecord', ['~> 3.1.8']
  s.add_runtime_dependency 'sqlite3',      ['~> 1.3.6']
  s.add_runtime_dependency 'feedzirra',    ['~> 0.1.3']
  s.add_runtime_dependency 'notify',       ['~> 0.4.0']
  s.add_runtime_dependency 'launchy',      ['~> 2.1.2']

  s.add_development_dependency 'rake',          ['~> 10.0.2']
  s.add_development_dependency 'tapp',          ['~> 1.4.0']
  s.add_development_dependency 'rspec',         ['~> 2.12.0']
  s.add_development_dependency 'fabrication',   ['~> 2.5.0']
  s.add_development_dependency 'fuubar',        ['~> 1.1.0']
  s.add_development_dependency 'simplecov',     ['~> 0.7.1']
  s.add_development_dependency 'activesupport', ['~> 3.1.8']
end
