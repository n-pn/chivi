require "json"

class CV::ChItem
  include JSON::Serializable

  getter _idx : Int32
  getter scid : String

  getter title : String
  getter label : String
  getter uslug : String

  def initialize(@_idx, @scid, @title, @label, @uslug)
  end
end
