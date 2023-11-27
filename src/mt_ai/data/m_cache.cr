require "crorm"
require "../../_util/hash_util"
require "../../_util/char_util"

class MT::MCache
  DIR = ENV.fetch("MC_DIR", "var/cache/mdata")
  Dir.mkdir_p(DIR)

  DB_CACHE = {} of String => Crorm::SQ3

  def self.load_db(char : Char, type : String)
    DB_CACHE["#{char}-#{type}"] ||= self.db(char, type)
  end

  def self.db_path(word : String, type : String)
    "#{DIR}/#{word[0]}-#{type}.db3"
  end

  def self.db_path(char : Char, type : String)
    "#{DIR}/#{char}-#{type}.db3"
  end

  class_getter init_sql = <<-SQL
    create table mtdata(
      rid int not null,
      tok text not null,
      con text not null,
      ner text not null default '',
      pos text not null default '',
      dep text not null default '',
      uname text not null default '',
      mtime int not null default 0,
      primary key (rid, tok)
    ) strict, without rowid;
    SQL

  ###

  include Crorm::Model

  schema "mtdata", :sqlite, multi: true

  field rid : Int64, pkey: true
  field tok : String, pkey: true
  field con : String = ""
  field ner : String = "" # both onnonote and msra as json array list
  field pos : String = "" # CTB9 part of speed
  field dep : String = "" # universal dependency

  field uname : String = "" # last modified by
  field mtime : Int64 = 0   # last modified at

  def initialize(@rid, @tok,
                 @con = "", @ner = "",
                 @pos = "", @dep = "",
                 @uname = "", @mtime = Time.unix.to_utc)
  end
end
