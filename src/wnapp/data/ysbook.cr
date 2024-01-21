require "crorm"

require "../../_util/book_util"
require "../_raw/raw_ysbook"

# require "./author"
# require "./btitle"

class WN::Ysbook
  class_getter db_path = "var/zroot/ysbooks.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE ysbooks(
      id int NOT NULL PRIMARY KEY,
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
      status int NOT NULL DEFAULT 0,
      shield int NOT NULL DEFAULT 0,
      origin text NOT NULL DEFAULT '',
      --
      word_count int NOT NULL DEFAULT 0,
      book_mtime bigint NOT NULL DEFAULT 0,
      --
      crit_count int NOT NULL DEFAULT 0,
      list_count int NOT NULL DEFAULT 0,
      --
      crit_avail int NOT NULL DEFAULT 0,
      list_avail int NOT NULL DEFAULT 0,
      -- timestamps
      rtime bigint NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0
    );
    SQL

  def self.load(id : Int32)
    get(id) || new(id: id)
  end

  ####

  include Crorm::Model
  schema "ysbooks", :sqlite

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

  field crit_count : Int32 = 0 # fetched reviews
  field list_count : Int32 = 0 # fetched book lists

  field crit_avail : Int32 = 0 # avail reviews
  field list_avail : Int32 = 0 # avail book lists

  field rtime : Int64 = 0_i64
  field _flag : Int32 = 0

  def initialize(@id)
  end

  def upsert_wninfo!
    wninfo = CV::Wninfo.upsert!(author_zh: @author, btitle_zh: @btitle)

    # TODO: update in wnstats instead
    wninfo.set_zscores!(@voters, @rating) if @voters > wninfo.zvoters
    wninfo.scover = @cover if wninfo.bcover.empty?

    wninfo.set_utime(@book_mtime)
    wninfo.set_status(@status)

    genres = [@genre].concat(@xtags.split('\t')).reject!(&.empty?).uniq!
    wninfo.set_genres(genres)

    wninfo.save!

    wninfo
  end

  def self.from_raw_json_file(file_path : String, db = self.db)
    json = File.read(file_path)
    time = File.info(file_path).modification_time.to_unix
    from_raw_json(json, rtime: time, db: db)
  end

  def self.load(id : Int32, db = self.db)
    find(id, db: db) || new(id)
  end

  def self.from_raw_json(raw_json : String,
                         rtime = Time.utc.to_unix,
                         db = self.db)
    input = RawYsbook.from_json(raw_json)

    entry = self.load(id: input.id, db: db)
    entry.rtime = rtime

    entry.btitle = input.btitle
    entry.author = input.author

    entry.cover = input.cover
    entry.intro = input.intro

    entry.genre = input.genre
    entry.xtags = input.btags.join('\t')

    entry.voters = input.voters
    entry.rating = input.rating
    entry.status = input.status
    entry.shield = input.shield
    entry.origin = input.sources.join('\n')

    entry.book_mtime = input.book_mtime
    entry.word_count = input.word_count

    entry.crit_count = input.crit_count
    entry.list_count = input.list_count

    entry
  end
end
