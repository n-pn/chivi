require "./zhseed"

class CV::Ubmemo
  STATUS = {"default", "reading", "finished", "onhold", "dropped", "pending"}

  include Clear::Model

  self.table = "ubmemos"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to cvuser : Cvuser

  # bookmark types: reading, finished, onhold, dropped, pending
  column status : Int32 = 0
  column locked : Bool = false

  column access : Int64 = 0_i64 # update whenever user visit book page
  column bumped : Int64 = 0_i64 # update when new reading history saved

  column lr_zseed : Int32 = 0
  column lr_chidx : Int32 = 0
  column lr_cpart : Int32 = 0

  column lc_title : String = ""
  column lc_uslug : String = ""

  timestamps

  getter status_s : String { STATUS[status] }
  getter lr_sname : String { Zhseed.sname(lr_zseed) }

  def bump!
    update!(access: time.to_unix)
  end

  def status=(status : String)
    self.status = STATUS.index(status) || 0
    @status_s = nil
  end

  def mark!(zseed : Int32, chidx : Int32, cpart = 0, title = "", uslug = "", locked = false)
    if locked || !self.locked
      self.locked = locked
      self.lr_zseed = zseed
      self.lr_chidx = chidx
      @lr_sname = nil
    elsif self.lr_zseed != zseed || self.lr_chidx != chidx
      return
    end

    self.bumped = Time.utc.to_unix
    self.lr_cpart = cpart
    self.lc_title = title
    self.lc_uslug = uslug

    self.save!
  end

  def self.status(status_s : String)
    STATUS.index(status_s) || 0
  end

  CACHE = {} of String => self

  def self.find_or_new(cvuser_id : Int64, cvbook_id : Int64) : self
    CACHE["#{cvuser_id}-#{cvbook_id}"] ||= begin
      params = {cvuser_id: cvuser_id, cvbook_id: cvbook_id}
      find(params) || new(params)
    end
  end

  def self.find_or_new(cvuser : Cvuser, cvbook : Cvbook) : self
    find_or_new(cvuser.id, cvbook.id)
  end

  def self.upsert!(cvuser : Cvuser, cvbook : Cvbook) : self
    ubmemo = find_or_new(cvuser, cvbook)
    yield ubmemo
    ubmemo.save!
  end

  def self.upsert!(cvuser_id : Int64, cvbook_id : Int64) : self
    ubmemo = find_or_new(cvuser_id, cvbook_id)
    yield ubmemo
    ubmemo.save!
  end
end
