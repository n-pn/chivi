require "./lexicon/vp_item"

class Chivi::History
  def initialize(@dir : String)
  end

  def upsert!(file : String, new_item : VpItem, old_item : VpItem?, ctx = "")
    # TODO!
  end
end
