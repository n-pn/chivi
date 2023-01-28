require "crorm"
require "crorm/sqlite3"

require "../../_util/site_link"
require "../../mt_v1/data/v1_dict"

require "./wn_repo"
require "./wnseed/seed_fetch"

class WN::WnSeed
  include Crorm::Model
  @@table = "seeds"

  field wn_id : Int32 = 0
  field sname : String = ""
  field s_bid : Int32 = 0

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  # field rm_link : String = ""   # link to remote catalog page
  # field rm_kind : String = ""   # parser type
  # field rm_time : Int64 = 0_i64 # last remote refreshed at

  # field rm_last_s_cid : Int32 = 0 # the last remote chap id crawled
  # field rm_last_ch_no : Int32 = 0 # matching remote last chap with ch_no position

  field mtime : Int64 = Time.utc.to_unix # last updated at
  field atime : Int64 = Time.utc.to_unix # last accessed at

  field rm_links : String = "[]" # remote catalog links associated with this seed
  field rm_stime : Int64 = 0

  field _flag : Int32 = 0

  @[DB::Field(ignore: true)]
  getter zh_chaps : WnRepo { WnRepo.load(self.sname, self.s_bid, "infos") }

  @[DB::Field(ignore: true)]
  getter vi_chaps : WnRepo { WnRepo.load_tl(zh_chaps.db_path, self.dname, force: false) }

  @[DB::Field(ignore: true)]
  getter dname : String { M1::DbDict.get_dname(-self.wn_id) }

  getter remotes : Array(String) { Array(String).from_json(self.rm_links) }

  def initialize(@wn_id, @sname, @s_bid = wn_id)
  end

  def mkdirs!(sname = self.sname, s_bid = self.s_bid)
    Dir.mkdir_p("var/chaps/infos/#{sname}")
    Dir.mkdir_p("var/chaps/texts-zip/#{sname}")
    Dir.mkdir_p("var/chaps/texts-gbk/#{sname}/#{s_bid}")

    self
  end

  def regen_vi_chaps!
    @vi_chaps = WnRepo.load_tl(zh_chaps.db_path, self.dname, force: true)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @sname
      jb.field "snvid", @s_bid

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      jb.field "stype", self.class.stype(self.sname)
    }
  end

  def min_privi(owner : String = "")
    case self.sname[0]
    when '_' then 1
    when '@' then 2
    when '+' then @sname == owner ? 2 : 3
    else          3
    end
  end

  def self.stype(sname : String)
    case sname[0]
    when '_' then 0  # base user seed
    when '@' then 1  # foreground user seed
    when '+' then -1 # background user seed
    else
      sname.in?(REMOTE_SEEDS) ? 3 : 2 # dead remote seed
    end
  end

  def slink
    sname = self.sname
    sname = sname[1..] if sname[0] == '!'
    SiteLink.info_url(sname, self.s_bid)
  end

  ###

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

  def self.remote?(sname : String)
    REMOTE_SEEDS.includes?(sname)
  end

  def remote_reload!(ttl : Time::Span = 3.minutes)
  end

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

  def self.upsert!(wn_id : Int32, sname : String, s_bid = wn_id)
    @@repo.open_tx do |db|
      db.exec <<-SQL, wn_id, sname, s_bid
        insert into #{@@table} (wn_id, sname) values (?, ?, ?)
        on conflict do update set s_bid = excluded.s_bid
      SQL
    end
  end

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/chaps/seed-infos.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_wn_seed.sql") }}
  end

  def self.all(wn_id : Int32) : Array(self)
    @@repo.open_db do |db|
      query = "select * from #{@@table} where wn_id = ? order by mtime desc"
      db.query_all(query, wn_id, as: self)
    end
  end

  def self.get(wn_id : Int32, sname : String) : self | Nil
    @@repo.open_db do |db|
      query = "select * from #{@@table} where wn_id = ? and sname = ?"
      db.db.query_one?(query, wn_id, sname, as: WnSeed)
    end
  end

  def self.get!(wn_id : Int32, sname : String) : self
    self.get(wn_id, sname) || raise "wn_seed [#{wn_id}/#{sname}] not found!"
  end

  def self.load(wn_id : Int32, sname : String)
    self.load(wn_id, sname) { new(wn_id, sname) }
  end

  def self.load(wn_id : Int32, sname : String, &)
    self.get(wn_id, sname) || yield
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
