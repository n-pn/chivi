class CV::Ubmark < Granite::Base
  connection pg
  table ubmarks

  column id : Int64, primary: true
  timestamps

  belongs_to :btitle
  belongs_to :cvuser

  # bookmark types: reading, finished, onhold, dropped, pending
  column bmark : Int32 = 0
  column zseed : Int32 = 0

  BMARKS = {"reading", "finished", "onhold", "dropped", "pending"}

  def self.bmark(label : String)
    BMARKS.index(label) || 0
  end
end
