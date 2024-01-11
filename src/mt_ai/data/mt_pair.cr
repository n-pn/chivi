require "../enum/*"

struct MT::MtPair
  getter a_vstr : String
  getter a_attr : MtAttr?

  getter b_vstr : String?
  getter b_attr : MtAttr = MtAttr::None

  def initialize(@a_vstr, a_attr : String?, @b_vstr = nil, b_attr : String? = nil)
    @a_attr = MtAttr.parse_list(a_attr) if a_attr
    @b_attr = MtAttr.parse_list(b_attr) if b_attr
  end
end
