require "./vp_term"

class CV::VMatch
  def self.init(query)
    # TODO: add more filters
    key = query["key"]?.try { |k| Regex.new(k) }
    val = query["val"]?.try { |v| Regex.new(v) }

    ptag = query["ptag"]?.try { |a| Regex.new(a) }
    prio = query["prio"]?.try { |x| VpTerm.parse_prio(x) }

    uname = query["uname"]?

    new(key, val, prio, ptag, uname)
  end

  def initialize(@key : Regex? = nil, @val : Regex? = nil,
                 @prio : Int8? = nil, @ptag : Regex? = nil,
                 @uname : String? = nil)
  end

  def match?(term : VpTerm)
    return false if term._flag > 1

    @key.try { |re| return false unless term.key.matches?(re) }
    @val.try { |re| return false unless term.vals.any?(&.matches?(re)) }
    @ptag.try { |re| return false unless term.tags.first.matches?(re) }
    @prio.try { |prio| return false unless term.prio == prio }
    @uname.try { |uname| return false unless term.uname == uname }

    true
  end
end
