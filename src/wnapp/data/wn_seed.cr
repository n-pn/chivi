require "crorm"

require "../../_data/_data"
require "../../zroot/html_parser/raw_rmcata"

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
      else            3
      end
    end

    def edit_privi(is_owner = false)
      case self
      when Draft then 1
      when Chivi then 3
      when Users then is_owner ? 2 : 4
      else            3
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

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "wnseeds", :postgres

  field id : Int32, auto: true

  field wn_id : Int32 = 0, pkey: true
  field sname : String = "", pkey: true
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

  def remote?
    @sname.starts_with?('!')
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
      insert into wnseeds (
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

  def word_count(from = 1, upto = @chap_total) : Int32
    self.chaps.word_count(from, upto)
  end

  def update_from_remote!(mode : Int32 = 0)
    stale = mode > 0 ? Time.utc - 3.minutes : Time.utc - 30.minutes

    if self.remote?
      parser = RawRmcata.from_seed(@sname, @s_bid, stale: stale)
      chlist = parser.chap_list(false)
    elsif !@rlink.empty?
      parser = RawRmcata.from_link(@rlink, stale: stale)
      chlist = parser.chap_list(true)
    else
      raise "not following any remote source!"
    end

    return if chlist.empty?
    max_ch_no = chlist.size

    # FIXME: check for real last_chap and offset
    # if max_ch_no > 0
    #   chap_list = chap_list[max_ch_no..]
    # end

    # @_flag = parser.status_int.to_i

    self.update_stats!(max_ch_no, parser.update_int)
    self.chaps.upsert_chap_infos(chlist)
    self.chaps.translate!(chlist.first.ch_no, chlist.last.ch_no)
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @chap_total = chmax if @chap_total < chmax
    @mtime = mtime if @mtime < mtime

    # Log.info { [@chap_total, @mtime, @id, mtime] }

    @@db.exec <<-SQL, @chap_total, @mtime, @id
      update wnseeds set chap_total = $1, mtime = $2 where id = $3
      SQL
  end

  def reload_content!(min = 1, max = 99999)
    # TODO: smart reload translation instead of force regen
    self.chaps.translate!(min: min, max: max)
  end

  getter seed_conf : Rmconf do
    case
    when @sname[0] == '!' then Rmconf.load!(@sname)
    when !@rlink.empty?   then Rmconf.from_link!(@rlink)
    else                       raise "not linked with remote source"
    end
  end

  def get_chap(ch_no : Int32)
    self.chaps.get(ch_no).try(&.set_seed(self))
  end

  def save_chap!(chap : WnChap) : Nil
    self.chaps.upsert_chap_full(chap)
  end

  #######

  def self.all(wn_id : Int32) : Array(self)
    stmt = self.schema.select_stmt(&.<< " where wn_id = $1 order by mtime desc")
    self.db.query_all(stmt, wn_id, as: self)
  end

  def self.get(wn_id : Int32, sname : String) : self | Nil
    stmt = self.schema.select_stmt(&.<< " where wn_id = $1 and sname = $2")
    self.db.query_one?(stmt, wn_id, sname, as: self)
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
    stmt = self.schema.select_stmt(&.<< " where id = $1 limit 1")
    self.db.query_all(stmt, id, as: self)
  end

  def self.upsert!(wn_id : Int32, sname : String, s_bid = wn_id)
    self.db.exec <<-SQL, wn_id, sname, s_bid
      insert into wnseeds(wn_id, sname, s_bid) values ($1, $2, $3)
      on conflict do update set s_bid = excluded.s_bid
    SQL
  end

  def self.soft_delete!(wn_id : Int32, sname : String)
    self.db.exec <<-SQL, wn_id, sname
      update wnseeds set wn_id = -wn_id where wn_id = $1 and sname = $2
    SQL
  end

  ###
end
