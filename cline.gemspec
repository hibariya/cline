# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cline/version"

Gem::Specification.new do |s|
  s.name        = "cline"
  s.version     = Cline::VERSION
  s.authors     = ["hibariya"]
  s.email       = ["celluloid.key@gmail.com"]
  s.homepage    = "https://github.com/hibariya/cline"
  s.summary     = %q{CLI Line Notifier}
  s.description = %q{Cline - CLI Line Notifier}

  s.post_install_message = <<-EOM
    **Important** Some features were added.

    * New collector (GitHub News Feed) is available.
      $ echo "Cline.collectors << Cline::Collectors::Github" >> ~/.cline/config
      $ echo "Cline::Collectors::Github.login_name = 'your_github_login'" >> ~/.cline/config

    * `search` command is available.
      usage:
        $ cline search [keyword]

    * Garbage collector is available.
      Garbage collector will work after `cline collect`.
      It requires Cline.pool_size.

      example:
        $ echo "Cline.pool_size = 2000" >> ~/.cline/config

    * Data schema has changed!
      Please try following commands:

      $ sqlite3 ~/.cline/cline.sqlite3
      > BEGIN TRANSACTION;
      > CREATE TABLE "tmp_notifications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "message" text DEFAULT '' NOT NULL, "display_count" integer DEFAULT 0 NOT NULL, "notified_at" datetime NOT NULL);
      > INSERT INTO tmp_notifications SELECT id, message, display_count, time as notified_at FROM notifications;
      > DROP TABLE notifications;
      > ALTER TABLE tmp_notifications RENAME TO notifications;
      > COMMIT;
      > .q
  EOM

  #s.rubyforge_project = "cline"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_runtime_dependency 'thor', ['>= 0.14.6']
  s.add_runtime_dependency 'activerecord', ['>= 3.1.1']
  s.add_runtime_dependency 'sqlite3', ['>= 1.3.4']
  s.add_runtime_dependency 'feedzirra', ['~> 0.0.31'] # FIXME builder dependency workaround...
  s.add_runtime_dependency 'notify', ['>= 0.3.0']

  s.add_development_dependency 'rake', ['>= 0.9.2']
  s.add_development_dependency 'ir_b', ['>= 1.4.0']
  s.add_development_dependency 'tapp', ['>= 1.1.0']
  s.add_development_dependency 'rspec', ['>= 2.6.0']
  s.add_development_dependency 'rr', ['>= 1.0.4']
  s.add_development_dependency 'fabrication', ['>= 1.2.0']
  s.add_development_dependency 'fuubar', ['>= 0.0.6']
  s.add_development_dependency 'simplecov', ['>= 0.5.3']
  s.add_development_dependency 'activesupport', ['>= 3.1.1']
end
