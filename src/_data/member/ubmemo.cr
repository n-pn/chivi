require "../_base"
require "../wnovel/wninfo"
require "./viuser"

class CV::Ubmemo
  include Clear::Model

  self.table = "ubmemos"
  primary_key type: :serial

  column viuser_id : Int32 = 0

  # column nvinfo_id : Int32 = 0
  belongs_to nvinfo : Wninfo, foreign_key: "nvinfo_id", foreign_key_type: Int32

  # bookmark types: default, reading, finished, onhold, dropped, pending
  column status : Int32 = 0
  column locked : Bool = false

  column atime : Int64 = 0_i64 # update whenever user visit book page
  column utime : Int64 = 0_i64 # update when new reading history saved

  column lr_sname : String = ""
  # column lr_zseed : Int32 = 0
  column lr_chidx : Int16 = 0_i16
  column lr_cpart : Int16 = 0_i16

  column lc_title : String = ""
  column lc_uslug : String = ""

  timestamps

  STATUS = {"default", "reading", "finished", "onhold", "dropped", "pending"}
  getter status_s : String { STATUS[status] }

  def bump!
    update!(atime: time.to_unix)
  end

  def status=(status : String)
    self.status = STATUS.index(status) || 0
    @status_s = nil
  end

  def mark!(sname : String, chidx : Int16, cpart : Int16 = 0_i16,
            title = "", uslug = "", tolock = -1)
    if tolock >= 0
      self.locked = tolock > 0
    elsif self.locked
      return if self.lr_sname != sname || self.lr_chidx != chidx
    end

    self.utime = Time.utc.to_unix

    self.lr_sname = sname
    self.lr_chidx = chidx
    self.lr_cpart = cpart

    self.lc_title = title
    self.lc_uslug = uslug

    self.save!
  end

  def mark_chap!(chinfo : Chinfo, sname : String, cpart : Int16 = 0_i16)
    mark!(sname, chinfo.ch_no!.to_i16, cpart, chinfo.trans.title, chinfo.trans.uslug)
  end

  def self.status(status_s : String)
    STATUS.index(status_s) || 0
  end

  CACHE = {} of String => self

  def self.find_or_new(viuser_id : Int64, nvinfo_id : Int64) : self
    CACHE["#{viuser_id}-#{nvinfo_id}"] ||= begin
      params = {viuser_id: viuser_id, nvinfo_id: nvinfo_id}
      find(params) || new(params)
    end
  end

  def self.find_or_new(viuser : Viuser, wninfo : Wninfo) : self
    find_or_new(viuser.id, wninfo.id)
  end

  def self.upsert!(viuser : Viuser, wninfo : Wninfo, &) : self
    ubmemo = find_or_new(viuser, wninfo)
    yield ubmemo
    ubmemo.save!
  end

  def self.upsert!(viuser_id : Int32, wninfo_id : Int32, &) : self
    ubmemo = find_or_new(viuser_id, wninfo_id)
    yield ubmemo
    ubmemo.save!
  end

  record BookUser, uname : String, privi : Int32, umark : Int32, ch_no : Int32 do
    include DB::Serializable
    include JSON::Serializable
  end

  def self.book_users(wninfo_id : Int32)
    PGDB.query_all <<-SQL, wninfo_id, as: BookUser
      select
        u.uname as uname, u.privi as privi,
        m.status as "umark", m.lr_chidx as ch_no
      from ubmemos as m
        inner join viusers as u
        on u.id = m.viuser_id
      where m.nvinfo_id = $1
        and u.privi >= 0
        and (m.status > 0)
      order by m.status desc, m.utime desc
    SQL
  end
end
