require "../_data"
require "./wncata"
require "crorm"

class CV::Wnseed
  enum Type
    Chivi
    Draft
    Users
    Globs
    Other

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
  end

  ############

  include Crorm::Model
  schema "wnseeds", :postgres

  class_getter db : DB::Database = PGDB

  field id : Int32, pkey: true, auto: true

  field wn_id : Int32 = 0
  field sname : String = ""
  field s_bid : Int32 = 0

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field rlink : String = "" # remote page link
  field rtime : Int64 = 0   # remote sync time

  field privi : Int16 = 0
  field _flag : Int16 = 0

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  @[DB::Field(ignore: true)]
  getter chaps : Wncata { Wncata.load(@wn_id, @sname, @s_bid) }

  #########

  def initialize(@wn_id, @sname, @s_bid = wn_id, @privi = 1)
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
    case self.seed_type
    when Draft then 1
    when Chivi then 3
    when User  then owner?(uname) ? 2 : 4
    else            3
    end
  end

  def read_privi(uname = "")
    case @sname
    when Draft then 1
    when Chivi then 2
    when User  then owner?(uname) ? 1 : 2
    else            3
    end
  end

  def lower_read_privi_count
    chap_count = self.chap_total // 3
    chap_count > 20 ? chap_count : 20
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
      wn_id, sname, s_bid,
      chap_total, chap_avail,
      rlink, rtime, privi, _flag,
      created_at, updated_at
    ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    on conflict (wn_id, sname) do update set
      s_bid = excluded.s_bid,
      chap_total = excluded.chap_total,
      chap_avail = excluded.chap_avail,
      rlink = excluded.rlink, rtime = excluded.rtime,
      privi = excluded.privi, _flag = excluded._flag,
      updated_at = excluded.updated_at
    SQL

    db.exec stmt,
      @wn_id, @sname, @s_bid, @chap_total, @chap_avail,
      @rlink, @rtime, @privi, @_flag, @created_at, @updated_at
  end

  ###

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
end
