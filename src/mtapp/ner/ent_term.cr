require "./ner_mark"

struct MT::EntTerm
  getter zstr : String
  getter vstr : String

  getter type : Symbol
  getter mark : EntMark

  getter _idx : Int32

  def initialize(@zstr, @vstr, @type, @mark, @_idx)
  end
end
