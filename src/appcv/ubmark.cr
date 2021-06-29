class CV::Ubmark
  include Clear::Model

  self.table = "ubmarks"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to cvuser : Cvuser

  # bookmark types: reading, finished, onhold, dropped, pending
  column bmark : Int32 = 0
  column zseed : Int32 = 0

  BMARKS = {"reading", "finished", "onhold", "dropped", "pending"}

  def self.bmark(label : String)
    BMARKS.index(label) || 0
  end
end
