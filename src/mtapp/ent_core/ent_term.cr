require "./ent_flag"

struct MT::EntTerm
  getter zstr : String
  getter vstr : String

  getter type : Symbol
  getter flag : EntFlag

  getter _idx : Int32

  def initialize(@zstr, @vstr, @type, @flag, @_idx)
  end
end
