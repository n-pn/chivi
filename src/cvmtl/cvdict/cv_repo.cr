require "db"
require "log"
require "crorm"
require "sqlite3"
require "colorize"

module MT::CvRepo
  DICT_PATH = "var/dicts/cvdicts.db"

  CORE_DICT = "var/dicts/cv_core.db"
  BOOK_DICT = "var/dicts/cv_book.db"
  USER_DICT = "var/dicts/cv_user.db"

  class_getter repo = Crorm::Adapter.new("sqlite3://./#{DICT_PATH}")

  class_getter core = Crorm::Adapter.new("sqlite3://./#{CORE_DICT}")
  class_getter book = Crorm::Adapter.new("sqlite3://./#{BOOK_DICT}")
  class_getter user = Crorm::Adapter.new("sqlite3://./#{USER_DICT}")
end
