#! /usr/bin/env crystal

require "micrate"
require "pg"

def load_env(file : String = ".env")
  File.each_line(file) do |line|
    next unless line =~ /^\s*(\w+)\s*=\s*(.+?)\s*$/
    ENV[$1] ||= $2
  end
end

load_env(".env.production") if ENV["CV_ENV"]? == "production"
load_env(".env")

Micrate::DB.connection_url = ENV["CV_DATABASE_URL"]
Micrate::Cli.run
