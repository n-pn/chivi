require "../_util/char_util"
require "./ner_core"
require "./qt_core/*"

class MT::QtCore
  def self.new(d_id : Int32, user : String = "")
    new(QtDict.new(d_id, user))
  end

  def initialize(@dict : QtDict, @ner_core = NerCore.base)
  end

  def tokenize(input : String)
    # TODO: make two version of chars, one for dic lookup, one for ner task
    chars = input.chars.map! do |char|
      char = CharUtil.normalize(char)
      char == '､' ? ',' : char
    end

    bests = Array(QtNode).new(chars.size) do |index|
      @dict.find_best(chars, start: index)
    end

    @ner_core.fetch_all(chars) do |idx, len, mark, vstr|
      wgt = CwsCost.node_cost(len, 2) &- 1
      next if wgt < bests.unsafe_fetch(idx).wgt

      fmt = mark.link? || mark.frag? ? FmtFlag::Frozen : FmtFlag::None
      zstr = chars[idx, len].join
      bests[idx] = QtNode.new(zstr, vstr, dic: 1, idx: idx, fmt: fmt)
    end

    cursor = 0
    output = QtData.new

    while cursor < bests.size
      node = bests.unsafe_fetch(cursor)
      output << node
      cursor &+= node.zlen
    end

    output
  end
end
