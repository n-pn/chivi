require "./vp_term"

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  property term : VpTerm? = nil
  getter edits = [] of VpTerm
  getter _next = Trie.new

  def find!(key : String) : VpTrie
    node = self
    key.each_char { |c| node = node._next[c] ||= VpTrie.new }
    node
  end

  def find(key : String) : VpTrie?
    node = self
    key.each_char { |c| return unless node = node._next[c]? }
    node
  end

  def scan(chars : Array(Char), idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._next[char]?
      node.term.try { |x| yield x }
    end
  end

  def each : Nil
    queue = [self]

    while last = queue.pop?
      last._next.each_value do |node|
        queue << node
        yield node unless node.edits.empty?
      end
    end
  end

  def to_a : Array(VpTerm)
    res = [] of VpTerm
    each { |term| res << term }
    res
  end

  def prune!
    map = {} of String => VpTerm
    @edits.sort_by(&.mtime).each { |term| map[term.uname] = term }
    @edits = map.values
  end

  class Filter
    def self.init(query)
      # TODO: add more filters
      key = query["key"]?.try { |key| Regex.new(key) }
      val = query["val"]?.try { |val| Regex.new(val) }

      wgt = query["wgt"]?.try { |wgt| wgt.to_i? || 3 }
      tag = query["tag"]?.try { |tag| PosTag.from_str(tag) }

      uname = query["uname"]?
      privi = query["privi"]?.try { |str| str.to_i? || 0 }

      new(key, val, wgt, tag, uname, privi)
    end

    def initialize(@key : Regex? = nil, @val : Regex? = nil,
                   @wgt : Int32? = nil, @tag : PosTag? = nil,
                   @uname : String? = nil, @privi : Int32? = nil)
    end

    def match?(term : VpTerm)
      @key.try { |re| return false unless term.key.matches?(re) }
      @val.try { |re| return false unless term.val.any?(&.matches?(re)) }

      @wgt.try { |wgt| return false unless term.wgt == wgt }
      @tag.try { |tag| return false unless term.tag == tag }

      @uname.try { |uname| return false unless term.uname == uname }
      @privi.try { |privi| return false unless term.privi == privi }

      true
    end
  end
end
