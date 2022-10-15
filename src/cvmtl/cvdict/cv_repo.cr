require "db"
require "log"
require "crorm"
require "sqlite3"
require "colorize"

module MT::CvRepo
  DICT_PATH = "var/dicts/cvdicts.db"
  class_getter repo = Crorm::Adapter.new("sqlite3://./#{DICT_PATH}")
end
