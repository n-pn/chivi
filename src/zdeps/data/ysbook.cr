require "crorm/model"
require "crorm/sqlite"

require "../_raw/raw_ysbook"

class ZD::Ysbook
  include Crorm::Model

  def self.init_sql
    <<-SQL
    CREATE TABLE books(
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
      shield int NOT NULL DEFAULT 0,
      origin text NOT NULL DEFAULT '',
      --
      word_count int NOT NULL DEFAULT 0,
      book_mtime bigint NOT NULL DEFAULT 0,
      --
      crit_total int NOT NULL DEFAULT 0,
      list_total int NOT NULL DEFAULT 0,
      --
      crit_count int NOT NULL DEFAULT 0,
      list_count int NOT NULL DEFAULT 0,
      -- timestamps
      rtime bigint NOT NULL DEFAULT 0,
      rhash int NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0
    );
    SQL
  end

  DB_PATH = "/2tb/var.chivi/zdeps/ysbooks.db3"

  class_getter db : DB::Database do
    unless File.file?(DB_PATH)
      Dir.mkdir_p(File.dirname(DB_PATH))
      Crorm::SQ3.init_db(DB_PATH, self.init_sql)
    end

    Crorm::SQ3.open_db(DB_PATH)
  end

  def self.open_db(&)
    Crorm::SQ3.open_db(DB_PATH) { |db| yield db }
  end

  def self.open_tx(&)
    Crorm::SQ3.open_tx(DB_PATH) { |db| yield db }
  end

  def self.load(id : Int32)
    stmt = self.schema.select_stmt { |stmt| stmt << " where id = $1" }
    open_db(&.query_one?(stmt, id, as: self)) || new(id: id)
  end

  ####

  schema "books"

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
  field shield : Int32 = 0
  field origin : String = ""

  field book_mtime : Int64 = 0_i64 # yousuu book update time
  field word_count : Int32 = 0

  field crit_total : Int32 = 0 # total reviews
  field list_total : Int32 = 0 # total book lists

  field crit_count : Int32 = 0 # fetched reviews
  field list_count : Int32 = 0 # fetched book lists

  field rtime : Int64 = 0_i64
  field rhash : Int32 = 0
  field _flag : Int32 = 0

  def initialize(@id)
  end

  def self.from_raw_json(raw_json : String,
                         rtime = Time.utc.to_unix,
                         rhash = XXHash.xxh32(raw_json))
    raw_data = RawYsbook.from_json(raw_json)
    entry = self.load(raw_data.id)

    entry.rtime = rtime
    entry.rhash = rhash.unsafe_as(Int32)

    entry.btitle = raw_data.btitle
    entry.author = raw_data.author

    entry.cover = raw_data.cover
    entry.intro = raw_data.intro

    entry.genre = raw_data.genre
    entry.xtags = raw_data.btags.join('\n')

    entry.voters = raw_data.voters
    entry.rating = raw_data.rating
    entry.status = raw_data.status
    entry.shield = raw_data.shield
    entry.origin = raw_data.sources.join('\n')

    entry.book_mtime = raw_data.book_mtime
    entry.word_count = raw_data.word_count

    entry.crit_total = raw_data.crit_total
    entry.list_total = raw_data.list_total

    entry
  end
end
