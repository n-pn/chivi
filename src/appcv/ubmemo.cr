class CV::Ubmemo
  STATUS = {"default", "reading", "finished", "onhold", "dropped", "pending"}

  include Clear::Model

  self.table = "ubmemos"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to cvuser : Cvuser

  # bookmark types: reading, finished, onhold, dropped, pending
  column status : Int32 = 0

  column bumped : Int64 = 0_i64
  column locked : Bool = false

  column lr_zseed : Int32 = 0
  column lr_chidx : Int32 = 0

  column lc_title : String = ""
  column lc_uslug : String = ""

  timestamps

  getter status_s : String { STATUS[status] }
  getter lr_sname : String { Zhseed.sname(lr_zseed) }

  def self.status(status_s : String)
    STATUS.index(status_s) || 0
  end

  def self.dummy_find(cvuser : Cvuser, cvbook : Cvbook) : self
    find({cvuser_id: cvuser.id, cvbook_id: cvbook.id}) || new({cvuser: cvuser, cvbook: cvbook})
  end

  def self.upsert!(cvuser : Cvuser, cvbook : Cvbook) : self
    ubmemo = dummy_find(cvuser, cvbook)
    yield ubmemo
    ubmemo.save!
  end

  def self.upsert!(cvuser_id : Int64, cvbook_id : Int64) : self
    params = {cvuser_id: cvuser_id, cvbook_id: cvbook_id}
    ubmemo = find(params) || new(params)

    yield ubmemo
    ubmemo.save!
  end
end
