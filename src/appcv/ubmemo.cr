class CV::Ubmemo
  include Clear::Model

  self.table = "ubmemos"
  primary_key

  belongs_to cvuser : Cvuser, foreign_key: "cvuser_id"
  belongs_to nvinfo : Nvinfo, foreign_key: "nvinfo_id"

  # bookmark types: default, reading, finished, onhold, dropped, pending
  column status : Int32 = 0
  column locked : Bool = false

  column atime : Int64 = 0_i64 # update whenever user visit book page
  column utime : Int64 = 0_i64 # update when new reading history saved

  column lr_sname : String = ""
  column lr_zseed : Int32 = 0
  column lr_chidx : Int32 = 0
  column lr_cpart : Int32 = 0

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

  def mark!(sname : String, chidx : Int32, cpart = 0, title = "", uslug = "", lock = -1)
    if lock >= 0
      self.locked = lock > 0
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

  def self.status(status_s : String)
    STATUS.index(status_s) || 0
  end

  CACHE = {} of String => self

  def self.find_or_new(cvuser_id : Int64, nvinfo_id : Int64) : self
    CACHE["#{cvuser_id}-#{nvinfo_id}"] ||= begin
      params = {cvuser_id: cvuser_id, nvinfo_id: nvinfo_id}
      find(params) || new(params)
    end
  end

  def self.find_or_new(cvuser : Cvuser, nvinfo : Nvinfo) : self
    find_or_new(cvuser.id, nvinfo.id)
  end

  def self.upsert!(cvuser : Cvuser, nvinfo : Nvinfo) : self
    ubmemo = find_or_new(cvuser, nvinfo)
    yield ubmemo
    ubmemo.save!
  end

  def self.upsert!(cvuser_id : Int64, nvinfo_id : Int64) : self
    ubmemo = find_or_new(cvuser_id, nvinfo_id)
    yield ubmemo
    ubmemo.save!
  end
end
