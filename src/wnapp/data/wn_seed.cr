require "crorm"
require "crorm/sqlite3"

require "../../_util/site_link"
require "../../mt_v1/data/v1_dict"

require "./wn_repo"
require "../remote/rm_cata"
require "../remote/rm_text"

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

  field edit_privi : Int32 = 1
  field read_privi : Int32 = 1

  field _flag : Int32 = 0

  @[DB::Field(ignore: true)]
  getter remotes : Array(String) { Array(String).from_json(self.rm_links) }

  @[DB::Field(ignore: true)]
  getter dname : String { M1::DbDict.get_dname(-self.wn_id) }

  @[DB::Field(ignore: true)]
  getter chaps : WnRepo { WnRepo.load(self.sname, self.s_bid, self.dname) }

  def initialize(@wn_id, @sname, @s_bid = wn_id, privi = 1)
    @read_privi = @edit_privi = privi
  end

  def mkdirs!(sname = self.sname, s_bid = self.s_bid) : self
    Dir.mkdir_p("var/chaps/infos/#{sname}")
    Dir.mkdir_p("var/texts/rzips/#{sname}")
    Dir.mkdir_p("var/texts/rgbks/#{sname}/#{s_bid}")

    self
  end

  def rm_links=(@remotes : Array(String))
    @rm_links = remotes.to_json
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @sname
      jb.field "snvid", @s_bid

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      # jb.field "stype", self.class.stype(self.sname)

      jb.field "edit_privi", @edit_privi
      jb.field "read_privi", @read_privi
    }
  end

  def edit_privi(owner : String)
    return self.edit_privi if self.sname[0] != '@'
    @sname == owner ? 2 : 4
  end

  def gift_chaps
    gift = self.chap_total // 3
    gift > 20 ? gift : 20
  end

  def reload_stats!(force : Bool = false)
    return unless force || self.chap_avail < 0

    query = "select ch_no, s_cid from chaps"
    input = self.chaps.open_db(&.query_all(query, as: {Int32, Int32}))

    output = [] of {Int32, Int32}

    TextStore.unload_zip!(self.sname, self.s_bid)

    chap_avail = 0

    input.each do |ch_no, s_cid|
      txt_path = TextStore.gen_txt_path(self.sname, self.s_bid, s_cid)

      if File.file?(txt_path)
        c_len = File.read(txt_path, encoding: "GB18030").size
        chap_avail += 1 if c_len > 0
      else
        c_len = 0
      end

      output << {c_len, ch_no}
    end

    self.chaps.open_tx do |db|
      query = "update chaps set c_len = ? where ch_no = ?"
      output.each { |c_len, ch_no| db.exec query, c_len, ch_no }
    end

    @chap_avail = chap_avail
    self.save!
  end

  def word_count(from = 1, upto = self.chap_total) : Int32
    self.chaps.open_db do |db|
      query = "select sum(c_len) from chaps where ch_no >= ? and ch_no <= ?"
      db.query_one(query, from, upto, as: Int32?) || 0
    end
  end

  REMOTES = {
    "!hetushu.com",
    "!69shu.com",
    "!xbiquge.so",
    "!uukanshu.com",
    "!ptwxz.com",
    "!133txt.com",
    "!bxwx.io",
    "!b5200.org",
    "!paoshu8.com",
    "!biqu5200.net",
  }

  # def self.stype(sname : String)
  #   case sname[0]
  #   when '_' then 0 # base user seed
  #   when '@' then 1 # foreground user seed
  #   else
  #     sname.in?(REMOTES) ? 3 : 2 # dead remote seed
  #   end
  # end

  ###

  ###

  def update_from_remote!(slink = self.remotes.first, mode : Int32 = 0)
    parser = RmCata.new(slink, ttl: mode > 0 ? 3.minutes : 30.minutes)

    raw_chaps = parser.parse!
    # return if raw_chaps.empty?

    last_ch_no = raw_chaps.size

    if last_ch_no > self.chap_total
      self.chap_total = last_ch_no
      # last_ch_no = self.chap_total
    end

    # FIXME: check for real last_chap and offset
    # if last_ch_no > 0
    #   raw_chaps = raw_chaps[last_ch_no..]
    # end

    # @_flag = parser.status_int.to_i

    self.bump_times(parser.last_mtime, force: true)
    self.save!(self.class.repo)

    if self.sname[0] == '!'
      # _path can be generated from `s_cid` field
      raw_chaps.each(&._path = "")
    else
      # do not keep remote chap id info if seed is not a remote one
      raw_chaps.each { |x| x.s_cid = x.ch_no }
    end

    self.chaps.upsert_chap_infos(raw_chaps)
  end

  def update_stats!(chmax : Int32, @mtime : Int64 = Time.utc.to_unix)
    @chap_total = chmax if chmax > self.chap_total
    self.save!
  end

  def reload_content!(min = 1, max = 99999)
    # TODO: smart reload translation instead of force regen
    self.chaps.translate!(min: min, max: max)
  end

  private def get_fetch_url(chap : WnChap)
    if self.sname[0] == '!'
      SiteLink.text_url(self.sname, self.s_bid, chap.s_cid)
    elsif chap._path.starts_with?('!')
      bg_path = chap._path.split(':').first

      sname, s_bid, s_cid = bg_path.split('/')
      SiteLink.text_url(sname, s_bid.to_i, s_cid.to_i)
    else
      chap._path
    end
  end

  def get_chap(ch_no : Int32)
    self.chaps.get(ch_no).try(&.set_seed(self))
  end

  def save_chap!(chap : WnChap) : Nil
    self.chaps.upsert_chap_full(chap)
  end

  def fetch_text!(chap : WnChap, uname : String = "", force : Bool = false) : Array(String)
    href = get_fetch_url(chap)
    return chap.body if href.empty?

    Log.info { "HIT: #{href}".colorize.blue }
    parser = RmText.new(href, ttl: force ? 3.minutes : 1.years)

    lines = parser.body.tap(&.unshift(parser.title))
    chap.save_body!(lines, seed: self, uname: uname)

    chap.body
  rescue ex
    Log.error(exception: ex) { ex.message }
    chap.body
  end

  #############

  def bump_times(mtime : Int64 = 0, force : Bool = false)
    @atime = Time.utc.to_unix

    if mtime > 0
      @mtime = mtime
    elsif force
      @mtime = @atime
    end
  end

  def bump_chmax(ch_no : Int32, force : Bool = false)
    return unless force || ch_no > self.chap_total
    @chap_total = ch_no
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
        insert into #{@@table} (wn_id, sname, s_bid) values (?, ?, ?)
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

  def self.soft_delete!(wn_id : Int32, sname : String)
    self.repo.open_db do |db|
      query = <<-SQL
        update #{@@table}
        set wn_id = -wn_id, s_bid = -s_bid
        where wn_id = ? and sname = ?
      SQL

      db.exec query, wn_id, sname
    end
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
