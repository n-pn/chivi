class CV::Ubmark
  BMARKS = {"reading", "finished", "onhold", "dropped", "pending"}

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

  def self.migrate!(cvuser : Cvuser)
    ViMark.book_map(cvuser.uname.downcase).each do |bhash, vals|
      next unless cvbook = Cvbook.find({bhash: bhash})
      bmark = BMARKS.index(vals.first) || 1
      Ubmark.new({cvbook: cvbook, cvuser: cvuser, bmark: bmark}).save
    end
  end
end
