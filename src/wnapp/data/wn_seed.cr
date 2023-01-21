require "crorm"
require "crorm/sqlite3"

require "../../_data/remote/remote_text"

require "./wn_repo"
require "../../mt_v1/data/v1_dict"

require "./wnseed/seed_fetch"

class WN::WnSeed
  include Crorm::Model
  @@table = "seeds"

  field sname : String = ""
  field s_bid : Int32 = 0

  field wn_id : Int32 = 0
  field sn_id : Int32 = 0

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field _flag : Int32 = 0
  field _rank : Int32 = 0

  field mtime : Int64 = 0_i64 # last updated at
  field atime : Int64 = 0_i64 # last accessed at
  field rtime : Int64 = 0_i64 # last refreshed at

  @[DB::Field(ignore: true)]
  getter zh_chaps : WnRepo { WnRepo.load(self.sname, self.s_bid, "infos") }

  @[DB::Field(ignore: true)]
  getter vi_chaps : WnRepo { WnRepo.load_tl(zh_chaps.db_path, self.dname) }

  @[DB::Field(ignore: true)]
  getter dname : String { M1::DbDict.get_dname(-self.wn_id) }

  def initialize(@sname, @s_bid, @wn_id = 0)
    mkdir!(sname, s_bid)
  end

  def mkdir!(sname = self.sname, s_bid = self.s_bid)
    Dir.mkdir_p("var/chaps/infos/#{sname}")
    Dir.mkdir_p("var/chaps/temps/#{sname}/#{s_bid}")
  end

  def bg_seed?
    self.sname[0].in?('!', '+')
  end

  def zh_chap(ch_no : Int32)
    self.zh_chaps.get(ch_no).try(&.set_seed(self))
  end

  def vi_chap(ch_no : Int32)
    self.vi_chaps.get(ch_no).try(&.set_seed(self))
  end

  REMOTE_SEEDS = {
    "!69shu",
    "!uukanshu",
    "!xbiquge",
    "!b5200",
    "!biqugse",
    "!paoshu8",
    "!uuks",
    "!ptwxz",
    "!bxwxio",
    "!133txt",
    "!yannuozw",
    "!biqu5200",
  }

  def fetch_text!(chap : WnChap, uname : String = "", force : Bool = false) : Bool
    if REMOTE_SEEDS.includes?(self.sname)
      sname, s_bid = self.sname, self.s_bid
    elsif chap._path[0] == '!'
      sname, s_bid = chap._path.split('/')
    else
      return false
    end

    flags = force ? "-f" : ""
    body = `bin/text_fetch #{sname} #{s_bid} #{chap.s_cid} #{flags}`
    return false unless $?.success?

    chap.save_body!(body, seed: self, uname: uname)
    @vi_chaps = nil
    true
  end

  def save_chap!(chap : WnChap) : Nil
    self.zh_chaps.upsert_entry(chap)
  end

  #############

  def bump_mftime(mtime : Int64 = 0, force : Bool = false)
    @stime = Time.utc.to_unix

    if mtime > 0
      @mtime = mtime
    elsif force
      @mtime = @stime
    end
  end

  def bump_latest(ch_no : Int32, s_cid : Int32, force : Bool = false)
    return unless force || ch_no > self.chap_total

    @chap_total = ch_no
    @last_s_cid = s_cid
  end

  #####

  def save!(repo = self.class.repo, @mtime = Time.utc.to_unix)
    fields, values = self.get_changes
    repo.insert(@@table, fields, values, :replace)
  end

  ####

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/chaps/seed-infos.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_wn_seed.sql") }}
  end

  def self.all(wn_id : Int32)
    @@repo.open_db do |db|
      query = "select * from #{@@table} where wn_id = ? order by mtime desc"
      db.query_all(query, s_bid, as: self)
    end
  end

  def self.get(sname : String, s_bid : Int32)
    @@repo.open_db do |db|
      query = "select * from #{@@table} where sname = ? and s_bid = ?"
      db.query_one?(query, sname, s_bid, as: self)
    end
  end

  def self.get!(sname : String, s_bid : Int32)
    self.get(sname, s_bid) || raise "wn_seed [#{sname}/#{s_bid}] not found!"
  end

  def self.load(sname : String, s_bid : Int32)
    self.load(sname, s_bid) { new(sname, s_bid) }
  end

  def self.load(sname : String, s_bid : Int32, &)
    self.get(sname, s_bid) || yield
  end
end

# repo = WN::WnSeed.load("_hetushu", 6236)
# repo.remote_reload!
# puts repo.fetch_text(1).try(&.text_part(1))

# puts repo.vi_chaps.top.to_pretty_json
# repo = WN::WnSeed.get!("_miscs", 2)
# puts repo.vi_chaps.all(1).to_pretty_json

# puts repo.vi_chaps.top
# puts repo.vi_chaps.get(300)

# puts repo.get_chap(1).try(&.full_text)
