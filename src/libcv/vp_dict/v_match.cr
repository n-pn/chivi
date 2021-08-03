require "./vp_term"

class CV::VMatch
  def self.init(query)
    # TODO: add more filters
    key = query["key"]?.try { |key| Regex.new(key) }
    val = query["val"]?.try { |val| Regex.new(val) }

    rank = query["rank"]?.try { |rank| rank.to_i? || 3 }
    ptag = query["ptag"]?.try { |ptag| PosTag.from_str(ptag) }

    uname = query["uname"]?
    privi = query["privi"]?.try { |str| str.to_i? || 0 }

    new(key, val, rank, ptag, uname, privi)
  end

  def initialize(@key : Regex? = nil, @val : Regex? = nil,
                 @rank : Int32? = nil, @ptag : PosTag? = nil,
                 @uname : String? = nil, @privi : Int32? = nil)
  end

  def match?(term : VpTerm)
    @key.try { |re| return false unless term.key.matches?(re) }
    @val.try { |re| return false unless term.val.any?(&.matches?(re)) }

    @rank.try { |rank| return false unless term.rank == rank }
    @ptag.try { |ptag| return false unless term.ptag == ptag }

    @uname.try { |uname| return false unless term.uname == uname }
    @privi.try { |privi| return false unless term.privi == privi }

    true
  end
end
