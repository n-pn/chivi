require "./vp_term"

class CV::VMatch
  def self.init(query)
    # TODO: add more filters
    key = query["key"]?.try { |k| Regex.new(k) }
    val = query["val"]?.try { |v| Regex.new(v) }

    attr = query["ptag"]?.try { |a| Regex.new(a) }
    rank = query["rank"]?.try { |x| VpTerm.parse_rank(x) }

    uname = query["uname"]?

    new(key, val, rank, attr, uname)
  end

  def initialize(@key : Regex? = nil, @val : Regex? = nil,
                 @rank : Int32? = nil, @attr : String? = nil,
                 @uname : String? = nil)
  end

  def match?(term : VpTerm)
    return false if term._flag > 1

    @key.try { |re| return false unless term.key.matches?(re) }
    @val.try { |re| return false unless term.val.any?(&.matches?(re)) }

    @attr.try { |re| return false unless term.attr.matches?(re) }
    @rank.try { |rank| return false unless term.rank == rank }

    @uname.try { |uname| return false unless term.uname == uname }

    true
  end
end
