require "./vp_term"

class CV::Vtrie
  alias Trie = Hash(Char, Vtrie)

  property term : VpTerm? = nil
  getter edits = [] of VpTerm
  getter _next = Trie.new

  def find!(key : String) : Vtrie
    node = self
    key.each_char { |c| node = node._next[c] ||= Vtrie.new }
    node
  end

  def find(key : String) : Vtrie?
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
      key_re = query["key"]?.try { |re| Regex.new(re) }
      val_re = query["val"]?.try { |re| Regex.new(re) }

      prio = query["prio"]?.try { |str| VpTerm.parse_prio(str) }
      attr = query["attr"]?.try { |str| VpTerm.parse_attr(str) }

      uname = query["uname"]?
      power = query["power"]?.try { |str| str.to_i? || 0 }

      new(key_re, val_re, prio, attr, uname, power)
    end

    def initialize(@key_re : Regex? = nil, @val_re : Regex? = nil,
                   @prio : Int32? = nil, @attr : Int32? = nil,
                   @uname : String? = nil, @power : Int32? = nil)
    end

    def match?(term : VpTerm)
      @key_re.try { |re| return false unless term.key.matches?(re) }
      @val_re.try { |re| return false unless term.vals.any?(&.matches?(re)) }

      @prio.try { |int| return false unless term.prio == int }
      @attr.try { |int| return false unless term.attr & int == int }

      @uname.try { |str| return false unless term.uname == str }
      @power.try { |int| return false unless term.power == int }

      true
    end
  end
end
