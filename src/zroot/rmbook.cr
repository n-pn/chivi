require "crorm/model"
require "crorm/sqlite"

require "../_util/book_util"
require "./html_parser/raw_rmbook"

class ZR::Rmbook
  def self.db_path(sname : String)
    "var/zroot/seeds/#{sname}.db3"
  end

  class_getter init_sql = <<-SQL
    CREATE TABLE zhbooks(
      id text NOT NULL PRIMARY KEY,
      wn_id int not null default 0,
      --
      btitle text NOT NULL DEFAULT '',
      author text NOT NULL DEFAULT '',
      --
      cover text NOT NULL DEFAULT '',
      intro text NOT NULL DEFAULT '',
      --
      genre text NOT NULL DEFAULT '',
      xtags text NOT NULL DEFAULT '',
      --
      voters int NOT NULL DEFAULT 0,
      rating int NOT NULL DEFAULT 0,
      --
      status_str text NOT NULL DEFAULT 0,
      update_str text NOT NULL DEFAULT 0,
      latest_cid text not null default '',
      --
      chap_count int NOT NULL DEFAULT 0,
      chap_avail int NOT NULL DEFAULT 0,
      --
      rtime bigint NOT NULL DEFAULT 0,
      rhash int NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0
    );
    SQL

  def self.db
    raise "you should provide seedname to db"
  end

  def self.db(sname : String)
    open_db(self.db_path(sname))
  end

  def self.load(sname : String, id : String)
    open_db(db_path(sname)) { |db| get(id, db: db) || new(id: id) }
  end

  ####

  include Crorm::Model
  schema "zhbooks", :sqlite

  field id : String, pkey: true
  field wn_id : Int32 = 0 # official chivi id

  field btitle : String = ""
  field author : String = ""

  field cover : String = ""
  field intro : String = ""

  field genre : String = ""
  field xtags : String = ""

  field status_str : String = ""
  field update_str : String = ""
  field latest_cid : String = ""

  field chap_count : Int32 = 0
  field chap_avail : Int32 = 0

  field rtime : Int64 = 0_i64
  field rhash : String = ""
  field _flag : Int32 = 0

  def initialize(@id)
  end

  ###

  def self.from_html_file(file_path : String,
                          sname = File.basename(File.dirname(file_path)),
                          sb_id = File.basename(file_path, ".htm"))
    html = File.read(file_path)
    time = File.info(file_path).modification_time

    from_html(html, sname: sname, sb_id: sb_id, rtime: time)
  end

  def self.from_html(html : String, sname : String, sb_id : String,
                     rtime = Time.utc.to_unix, rhash = XXHash.xxh32(html))
    raw_data = RawRmbook.new(html, sname: sname)

    entry = self.load(sb_id)

    entry.rtime = rtime
    entry.rhash = rhash.unsafe_as(Int32)

    entry.btitle = raw_data.btitle
    entry.author = raw_data.author

    entry.cover = raw_data.cover
    entry.intro = raw_data.intro

    entry.genre = raw_data.genre
    entry.xtags = raw_data.xtags

    entry.status_str = raw_data.status_str
    entry.update_str = raw_data.update_str

    entry.latest_cid = raw_data.latest_cid
    entry.chap_count = raw_data.chap_count

    entry
  end
end
