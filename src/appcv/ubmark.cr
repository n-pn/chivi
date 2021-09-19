class CV::Ubmark
  BMARKS = {"default", "reading", "finished", "onhold", "dropped", "pending"}

  include Clear::Model

  self.table = "ubmarks"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to cvuser : Cvuser

  # bookmark types: reading, finished, onhold, dropped, pending
  column bmark : Int32 = 0
  column zseed : Int32 = 0

  getter label : String { BMARKS[bmark] }

  def self.bmark(label : String)
    BMARKS.index(label) || 0
  end

  def self.upsert!(cvuser : Cvuser, cvbook : Cvbook, bmark : Int32) : self
    if ubmark = Ubmark.find({cvuser_id: cvuser.id, cvbook_id: cvbook.id})
      ubmark.tap(&.update!({bmark: bmark}))
    else
      Ubmark.create!({cvuser_id: cvuser.id, cvbook_id: cvbook.id, bmark: bmark})
    end
  end
end
