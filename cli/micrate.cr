#! /usr/bin/env crystal

require "micrate"
require "pg"

require "../src/cv_env"

Micrate::DB.connection_url = CV_ENV.database_url
Micrate::Cli.run
