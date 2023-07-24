require "crorm"
require "crorm/sqlite3"

require "../../_data/_data"
require "../../_data/remote/rmcata"

require "../util/dl_chap"

require "./wn_repo"

class WN::WnSeed
  enum Type
    Chivi
    Draft
    Users
    Globs
    Other

    def read_privi(is_owner = false, base_privi = 2)
      case self
      when Draft then 1
      when Chivi then 2
      when Users then is_owner ? 1 : base_privi
      else              3
      end
    end

    def edit_privi(is_owner = false)
      case self
      when Draft then 1
      when Chivi then 3
      when Users then is_owner ? 2 : 4
      else              3
      end
    end

    def delete_privi(is_owner = false)
      case self
      when Globs then 3
      when Users then is_owner ? 2 : 4
      else            5
      end
    end

    def type_name
      case self
      when Chivi then "chính thức"
      when Draft then "tạm thời"
      when Users then "cá nhân"
      when Globs then "bên ngoài"
      else            "đặc biệt"
      end
    end

    def self.parse(sname : String)
      fchar = sname[0]
      case
      when fchar == '!'      then Globs
      when fchar == '@'      then Users
      when sname == "~chivi" then Chivi
      when sname == "~draft" then Draft
      else                        Other
      end
    end

    def self.read_privi(sname : String, uname : String, base_privi : Int32)
      parse(sname).read_privi(owner?(sname, uname), base_privi)
    end

    def self.edit_privi(sname : String, uname : String)
      parse(sname).edit_privi(owner?(sname, uname))
    end

    def self.delete_privi(sname : String, uname : String)
      parse(sname).delete_privi(owner?(sname, uname))
    end

    def self.owner?(sname : String, uname : String)
      sname == "@#{uname}"
    end
  end

  ############

  include Crorm::Model

  class_getter table = "wnseeds"
  class_getter db : DB::Database = PGDB

  field id : Int32, primary: true

  field wn_id : Int32 = 0
  field sname : String = ""
  field s_bid : Int32 = 0

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field rlink : String = "" # remote page link
  field rtime : Int64 = 0   # remote sync time

  field privi : Int16 = 0
  field _flag : Int16 = 0

  field mtime : Int64 = 0

  # field created_at : Time = Time.utc
  # field updated_at : Time = Time.utc

  @[DB::Field(ignore: true)]
  # getter chaps : Wncata { Wncata.load(@wn_id, @sname, @s_bid) }
  getter chaps : WnRepo { WnRepo.load(@sname, @s_bid, @wn_id) }

  #########

  def initialize(@wn_id, @sname, @s_bid = wn_id, @privi = 2_i16)
  end

  def mkdirs! : Nil
    Dir.mkdir_p("var/texts/rgbks/#{@sname}/#{@s_bid}")
    Dir.mkdir_p("var/texts/rzips/#{@sname}")
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @sname
      jb.field "snvid", @s_bid

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      jb.field "privi", @privi
    }
  end

  def seed_type
    Type.parse(sname)
  end

  def owner?(uname : String = "")
    @sname == "@#{uname}"
  end

  def edit_privi(uname = "")
    Type.edit_privi(@sname, uname)
  end

  def read_privi(uname = "")
    Type.read_privi(@sname, uname, privi.to_i)
  end

  def lower_read_privi_count
    chap_count = @chap_total // 2
    chap_count > 40 ? chap_count : 40
  end

  def reload_stats!(force : Bool = false)
    return unless force || @chap_avail < 0

    # TextStore.unload_zip!(@sname, @s_bid)
    self.chaps.reload_stats!(@sname, @s_bid)

    # self.upsert!
  end

  ####

  def bump_mtime(mtime : Int64, force : Bool = false)
    @mtime = mtime if mtime > 0 || force
  end

  def bump_chmax(ch_no : Int32, force : Bool = false)
    return unless force || ch_no > self.chap_total
    @chap_total = ch_no
  end

  def upsert!(db = @@db)
    stmt = <<-SQL
    insert into #{@@table} (
      wn_id, sname, s_bid, chap_total, chap_avail,
      rlink, rtime, privi, _flag, mtime
    ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    on conflict (wn_id, sname) do update set
      s_bid = excluded.s_bid,
      chap_total = excluded.chap_total, chap_avail = excluded.chap_avail,
      rlink = excluded.rlink, rtime = excluded.rtime,
      privi = excluded.privi, _flag = excluded._flag, mtime = excluded.mtime
    returning id
    SQL

    @id = db.query_one stmt,
      @wn_id, @sname, @s_bid, @chap_total, @chap_avail,
      @rlink, @rtime, @privi, @_flag, @mtime,
      as: Int32

    self
  end

  ALIVE_SEEDS = {
    "!hetushu.com",
    "!69shu.com",
    "!xbiquge.bz",
    "!uukanshu.com",
    "!ptwxz.com",
    "!133txt.com",
    "!bxwx.io",
    "!b5200.org",
    "!paoshu8.com",
    "!biqu5200.net",
  }

  def word_count(from = 1, upto = @chap_total) : Int32
    self.chaps.word_count(from, upto)
  end

  def update_from_remote!(mode : Int32 = 0)
    stale = mode > 0 ? Time.utc - 3.minutes : Time.utc - 30.minutes

    if @sname[0] == '!'
      parser = Rmcata.init(@sname, @s_bid, stale: stale)
    else
      parser = Rmcata.init(@rlink, stale: stale)
    end

    chap_list = parser.chap_list
    return if chap_list.empty?

    max_ch_no = chap_list.size

    # FIXME: check for real last_chap and offset
    # if max_ch_no > 0
    #   chap_list = chap_list[max_ch_no..]
    # end

    # @_flag = parser.status_int.to_i

    self.update_stats!(max_ch_no, parser.update_int)

    if self.sname[0] != '!'
      # do not keep remote chap id info if seed is not a remote one
      chap_list.each { |x| x.s_cid = x.ch_no }
    end

    self.chaps.upsert_chap_infos(chap_list)
    self.chaps.translate!(chap_list.first.ch_no, chap_list.last.ch_no)
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @chap_total = chmax if @chap_total < chmax
    @mtime = mtime if @mtime < mtime

    # Log.info { [@chap_total, @mtime, @id, mtime] }

    @@db.exec <<-SQL, @chap_total, @mtime, @id
      update #{@@table} set chap_total = $1, mtime = $2 where id = $3
      SQL
  end

  def reload_content!(min = 1, max = 99999)
    # TODO: smart reload translation instead of force regen
    self.chaps.translate!(min: min, max: max)
  end

  getter seed_conf : Rmconf do
    case
    when @sname[0] == '!' then Rmconf.load_known!(@sname)
    when !@rlink.empty? then RmConf.from_link!(from_link)
    else raise "not linked with remote source"
    end
  end

  private def get_fetch_url(chap : WnChap)

    if @sname[0] == '!'
      Rmconf.full_chap_link(@sname, @s_bid, chap.s_cid)

    elsif chap._path.starts_with?('!')
      bg_path = chap._path.split(':').first
      sname, s_bid, s_cid = bg_path.split('/')

      Rmconf.full_chap_link(sname, s_bid, s_cid)
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
    self.mkdirs!

    Log.info { "HIT: #{href}".colorize.magenta }

    parser = DlChap.new(href, ttl: force ? 3.minutes : 1.years)
    lines = parser.body.tap(&.unshift(parser.title))
    chap.save_body!(lines, seed: self, uname: uname)

    chap.body
  rescue ex
    Log.error(exception: ex) { ex.message }
    chap.body
  end

  #######

  def self.all(wn_id : Int32) : Array(self)
    smt = "select * from #{@@table} where wn_id = $1 order by mtime desc"
    self.db.query_all(smt, wn_id, as: self)
  end

  def self.get(wn_id : Int32, sname : String) : self | Nil
    smt = "select * from #{@@table} where wn_id = $1 and sname = $2"
    self.db.query_one?(smt, wn_id, sname, as: self)
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

  def self.find(id : Int32)
    self.find!(id) rescue nil
  end

  def self.find!(id : Int32)
    self.db.query_one "select * from #{@@table} where id = $1", id, as: self
  end

  def self.upsert!(wn_id : Int32, sname : String, s_bid = wn_id)
    self.db.exec <<-SQL, wn_id, sname, s_bid
      insert into #{@@table} (wn_id, sname, s_bid) values ($1, $2, $3)
      on conflict do update set s_bid = excluded.s_bid
    SQL
  end

  def self.soft_delete!(wn_id : Int32, sname : String)
    self.db.exec <<-SQL, wn_id, sname
      update #{@@table} set wn_id = -wn_id where wn_id = $1 and sname = $2
    SQL
  end

  ###
end

# class WN::WnSeed
#   include Crorm::Model
#   @@table = "seeds"

#   ###

#   ###

#   #############

#   def bump_times(mtime : Int64 = 0, force : Bool = false)
#     @atime = Time.utc.to_unix

#     if mtime > 0
#       @mtime = mtime
#     elsif force
#       @mtime = @atime
#     end
#   end

#   def bump_chmax(ch_no : Int32, force : Bool = false)
#     return unless force || ch_no > self.chap_total
#     @chap_total = ch_no
#   end

#   #####

#   def save!(repo : SQ3::Repo = self.class.repo, @mtime = Time.utc.to_unix)
#     fields, values = self.db_changes
#     raise "invalid" if fields.empty? || fields.size != values.size

#     repo.insert(@@table, fields, values, "replace")
#   end

#   ####

#   def self.upsert!(wn_id : Int32, sname : String, s_bid = wn_id)
#     smt = <<-SQL
#       insert into #{@@table} (wn_id, sname, s_bid) values (?, ?, ?)
#       on conflict do update set s_bid = excluded.s_bid
#     SQL

#     self.repo.open_tx(&.exec(smt, wn_id, sname, s_bid))
#   end

#   class_getter repo : SQ3::Repo { SQ3::Repo.new(db_path, init_sql, 10.minutes) }

#   @[AlwaysInline]
#   def self.db_path
#     "var/chaps/seed-infos.db"
#   end

#   def self.init_sql
#     {{ read_file("#{__DIR__}/sql/init_wn_seed.sql") }}
#   end

#   def self.all(wn_id : Int32) : Array(self)
#     smt = "select * from #{@@table} where wn_id = ? order by mtime desc"
#     self.repo.open_db(&.query_all(smt, wn_id, as: self))
#   end

#   def self.get(wn_id : Int32, sname : String) : self | Nil
#     smt = "select * from #{@@table} where wn_id = ? and sname = ?"
#     self.repo.open_db(&.query_one?(smt, wn_id, sname, as: self))
#   end

#   def self.get!(wn_id : Int32, sname : String) : self
#     self.get(wn_id, sname) || raise "wn_seed [#{wn_id}/#{sname}] not found!"
#   end

#   def self.load(wn_id : Int32, sname : String)
#     self.load(wn_id, sname) { new(wn_id, sname) }
#   end

#   def self.load(wn_id : Int32, sname : String, &)
#     self.get(wn_id, sname) || yield
#   end

#   def self.soft_delete!(wn_id : Int32, sname : String)
#     smt = <<-SQL
#       update #{@@table}
#       set wn_id = -wn_id, s_bid = -s_bid
#       where wn_id = ? and sname = ?
#     SQL

#     self.repo.open_db(&.exec smt, wn_id, sname)
#   end
# end

# repo = WN::WnSeed.load("_hetushu", 6236)
# repo.remote_reload!
# puts repo.fetch_text(1).try(&.text_part(1))

# puts repo.vi_chaps.top.to_pretty_json
# repo = WN::WnSeed.get!("_miscs", 2)
# puts repo.vi_chaps.all(1).to_pretty_json

# puts repo.vi_chaps.top
# puts repo.vi_chaps.get(300)

# puts repo.get_chap(1).try(&.full_text)
