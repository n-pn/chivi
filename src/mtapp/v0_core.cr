require "../_util/char_util"
require "./data/v0_dict"
require "./core/v0_data"
require "./ner_core"

class MT::SpCore
  def initialize(@dict : V0Dict, @ner_core = NerCore.translit)
  end

  def tokenize(input : String)
    # TODO: make two version of chars, one for dic lookup, one for ner task
    chars = input.chars.map! do |char|
      char = CharUtil.normalize(char)
      char == '､' ? ',' : char
    end

    bests = Array(V0Node).new(chars.size) do |index|
      @dict.find_best(chars, start: index) || begin
        char = chars.unsafe_fetch(index)
        V0Node.new(char, idx: index)
      end
    end

    @ner_core.fetch_all(chars) do |idx, len, mark, vstr|
      cost = CwsCost.node_cost(len, 2) &- 1
      next if cost < bests.unsafe_fetch(idx).cost

      fmt = mark.link? || mark.frag? ? FmtFlag::Frozen : FmtFlag::None
      bests[idx] = V0Node.new(vstr, len, idx, fmt: fmt)
    end

    cursor = 0
    output = V0Data.new

    while cursor < bests.size
      node = bests.unsafe_fetch(cursor)
      output << node
      cursor &+= node.len
    end

    output
  end
end
