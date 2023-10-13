require "crorm"

struct MT::ViPair
  DIR = "var/mtdic/mt_ai"

  include Crorm::Model
  schema "vipairs", :sqlite, multi: true

  field a_vstr : String
  field a_attr : String? = nil

  field b_vstr : String? = nil
  field b_attr : String? = nil

  def initialize(@a_vstr, @a_attr, @b_vstr, @b_attr)
  end

  def self.new(cols : Array(String))
    new(
      a_vstr: cols[0],
      a_attr: cols[1]?.try { |x| MtAttr.parse_list(x) },
      b_vstr: cols[2]?.try { |x| x.empty? ? nil : x },
      b_attr: cols[3]?.try { |x| MtAttr.parse_list(x) },
    )
  end
end
