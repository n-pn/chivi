require "crorm/model"
require "crorm/sqlite"

require "../../_util/book_util"
require "../_raw/raw_tubook"

class ZR::Tubook
  class_getter db_path = "var/zroot/tubooks.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE tubooks(
      id int NOT NULL PRIMARY KEY,
      wn_id int not null default 0,
      --
      btitle text NOT NULL DEFAULT '',
      author text NOT NULL DEFAULT '',
      --
      cover text NOT NULL DEFAULT '',
      intro text NOT NULL DEFAULT '',
      genre text NOT NULL DEFAULT '',
      xtags text NOT NULL DEFAULT '',
      --
      voters int NOT NULL DEFAULT 0,
      rating int NOT NULL DEFAULT 0,
      status int NOT NULL DEFAULT 0,
      origin text NOT NULL DEFAULT '',
      --
      word_count int NOT NULL DEFAULT 0,
      chap_count int NOT NULL DEFAULT 0,
      --
      crit_total int NOT NULL DEFAULT 0,
      list_total int NOT NULL DEFAULT 0,
      --
      crit_count int NOT NULL DEFAULT 0,
      list_count int NOT NULL DEFAULT 0,
      -- timestamps
      rtime bigint NOT NULL DEFAULT 0,
      rhash text NOT NULL DEFAULT "",
      _flag int NOT NULL DEFAULT 0
    );
    SQL

  def self.load(id : Int32)
    get(id) || new(id: id)
  end

  ####

  include Crorm::Model
  schema "tubooks", :sqlite

  field id : Int32, pkey: true
  field wn_id : Int32 = 0 # official chivi id

  field btitle : String = ""
  field author : String = ""

  field cover : String = ""
  field intro : String = ""
  field genre : String = ""
  field xtags : String = ""

  field voters : Int32 = 0
  field rating : Int32 = 0

  field status : Int32 = 0
  field origin : String = ""

  field word_count : Int32 = 0
  field chap_count : Int32 = 0

  field crit_total : Int32 = 0 # total reviews
  field list_total : Int32 = 0 # total book lists

  field crit_count : Int32 = 0 # fetched reviews
  field list_count : Int32 = 0 # fetched book lists

  field rtime : Int64 = 0_i64
  field rhash : String = ""
  field _flag : Int32 = 0

  def initialize(@id)
  end

  def self.from_raw(raw_data : RawTubook,
                    rtime = Time.utc.to_unix,
                    rhash : UInt32 = 0)
    entry = self.load(raw_data.id)

    entry.btitle = raw_data.btitle
    entry.author = raw_data.author

    entry.cover = raw_data.cover
    entry.intro = raw_data.intro

    entry.genre = raw_data.genre
    entry.xtags = raw_data.btags.join('\t')

    entry.voters = raw_data.voters
    entry.rating = raw_data.rating

    entry.status = raw_data.status
    entry.origin = raw_data.origin_name

    entry.word_count = raw_data.word_count
    entry.chap_count = raw_data.chap_count

    entry.rtime = rtime
    entry.rhash = rhash > 0 ? rhash.to_s(base: 36) : ""
    entry._flag = 0

    entry
  end
end
