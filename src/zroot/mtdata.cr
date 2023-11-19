require "crorm"
require "../_util/hash_util"
require "../_util/char_util"

class ZR::Mtdata
  ###

  DIR = "var/zroot/mtdata"
  Dir.mkdir_p(DIR)

  def self.db_path(zname : String)
    "#{DIR}/#{zname}.db3"
  end

  class_getter init_sql = <<-SQL
    create table mtdata(
      rid int not null,
      tok text not null,
      con text not null,
      pos text not null default '',
      ner text not null default '',
      dep text not null default '',
      uname text not null default '',
      mtime int not null default 0,
      primary key (rid, tok)
    ) strict, without rowid;
    SQL

  include Crorm::Model
  schema "mtdata", :sqlite, multi: true

  field rid : Int64, pkey: true
  field tok : String, pkey: true
  field con : String = ""
  field pos : String = "" # CTB9 part of speed
  field ner : String = "" # both onnonote and msra as json array list
  field dep : String = "" # universal dependency

  field uname : String = "" # last modified by
  field mtime : Int64 = 0   # last modified at

  def initialize(@rid, @tok,
                 @con = "", @pos = "",
                 @ner = "", @dep = "",
                 @uname = "", @mtime = Time.unix.to_utc)
  end
end
