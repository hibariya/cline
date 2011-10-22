# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cline/version"

Gem::Specification.new do |s|
  s.name        = "cline"
  s.version     = Cline::VERSION
  s.authors     = ["hibariya"]
  s.email       = ["celluloid.key@gmail.com"]
  s.homepage    = "https://github.com/hibariya/cline"
  s.summary     = %q{CLI local news}
  s.description = %q{TBA}

  #s.rubyforge_project = "cline"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
