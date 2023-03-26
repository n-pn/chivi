#! /usr/bin/env crystal

require "micrate"
require "pg"

require "../src/cv_env"

module Micreate
  def self.migrations_dir
    File.join("privs", "migrations")
  end
end

Micrate::DB.connection_url = CV_ENV.database_url
Micrate::Cli.run
