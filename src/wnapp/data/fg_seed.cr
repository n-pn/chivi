require "crorm"
require "crorm/sqlite3"

require "./ch_repo"
require "./zh_text"

class WN::FgSeed
  include Crorm::Model

  @@table = "seeds"

  field s_bid : Int32 # equivalent to book id
  field sname : String = "-"

  field stype : Int32 = 0 # usually the user id, or 0 if `-`
  field _flag : Int32 = 0 # user priority

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field feed_sname : String = ""
  field feed_s_bid : Int32 = 0
  field feed_s_cid : Int32 = 0
  field feed_stime : Int64 = 0_i64

  field atime : Int64 = 0_i64 # last access time
  field mtime : Int64 = 0_i64 # modification time

  def initialize(@s_bid, @sname = "", @stype = 0)
  end

  @[DB::Field(ignore: true)]
  getter zh_chaps : ChRepo { ChRepo.load(self.sname, self.s_bid, "fg", "infos") }

  @[DB::Field(ignore: true)]
  getter vi_chaps : ChRepo { ChRepo.load_tl(zh_chaps.db_path, self.dname) }

  @[DB::Field(ignore: true)]
  getter dname : String { M1::DbDict.get_dname(-self.s_bid) }

  def chap_text(ch_no : Int32) : ZhText?
    return unless info = self.chap_info(ch_no)

    path = info._path
    path = "#{@sname}:#{@s_bid}:#{info.ch_no}:#{info.s_cid}:#{info.p_len}" if path.empty?

    ZhText.new("bg/#{@sname}/#{@s_bid}/#{info.s_cid}", path)
  end

  ####

  def save!(repo = @@repo, @mftime = Time.utc.to_unix)
    fields, values = self.get_changes
    repos.insert(@@table, fields, values, :replace)
  end

  ####

  class_getter repo = Crorm::Sqlite3::Repo.new(self.db_path, self.init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/chaps/fg-seeds.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_fg_seed.sql") }}
  end

  def self.all(s_bid : Int32)
    @@repo.open_db do |db|
      query = "select * from #{@@table} where s_bid = ? order by stype asc"
      db.query_all(query, s_bid, as: self)
    end
  end

  def self.get(s_bid : Int32, sname : String = "")
    @@repo.open_db do |db|
      query = "select * from #{@@table} where s_bid = ? && sname = ?"
      db.query_one?(query, sname, sbid, as: self)
    end
  end

  def self.get!(s_bid : Int32, sname : String = "")
    get(sname, s_bid) || raise "fg_seed [#{sname}/#{s_bid}] not found!"
  end

  def self.load(sname : String, s_bid : Int32)
    self.load(sname, s_bid) { new(sname, s_bid) }
  end

  def self.load(s_bid : Int32, name : String, &)
    self.get(s_bid, sname) || yield
  end
end
