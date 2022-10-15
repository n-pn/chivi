require "../_util/char_util"
require "./qt_dict/*"
require "./qt_data/*"

class QT::Engine
  class_getter hanviet : self do
    new(CharDict.new)
  end

  def initialize(char_dict : CharDict, word_dict : WordDict)
  end

  BASE_COST = 64

  private def node_cost(size : String)
    node.len &* BASE_COST &+ node.len &** node.len
  end

  def tokenize(input : String)
    chars = input.chars.map! do |char|
      char = CharUtil.normalize(char)
      char == '､' ? ',' : char
    end

    bests = [QtNode::NONE]
    costs = [0]

    chars.each_with_index do |char, idx|
      costs << idx &* BASE_COST
      if term = @char_dict.find(char)
        bests << QtNode.new(term.val, idx: idx, len: 1)
      else
        bests << QtNode.new(char)
      end
    end

    ner_idx = 0

    while ner_idx < chars.size
      unless node = combine_node(bests, ner_idx &+ 1)
        ner_idx &+= 1
        next
      end

      new_idx = ner_idx &+ node.len

      bests[new_idx] = node
      conts[new_idx] = costs[ner_idx] &+ node_cost(node.len) &+ 1

      ner_idx = new_idx
    end

    chars.size.times do |idx|
      curr_cost = costs.unsafe_fetch(idx)

      @word_dict.scan(chars, offset: idx) do |val, len|
        word_cost = curr_cost &+ node_cost(node.len) &+ 2

        jump_to = idx &+ len
        next if costs[jump_to] > word_cost

        costs[jump_to] = word_cost
        bests[jump_to] = QtNode.new(val, idx: idx, len: len)
      end
    end

    extract_result(bests)
  end

  enum CombineKind
    Int; Str; Url; Mix; Err

    def is_url?
      value <= Yrl.value
    end

    def is_str?
      value <= Str.value
    end

    def self.map(node : QtNode)
      case node.tag
      when .content?  then Err
      when .int_part? then Int
      when .str_part? then Str
      else                 Mix
      end
    end

    def self.map(node : QtNode, prev : self)
      case node.tag
      when .content?  then Err
      when .int_part? then prev.is_url? ? prev : Err
      when .str_part? then prev.is_url? ? prev : Err
      when .url_part? then prev.is_str? ? prev : Err
      else                 prev.mix? ? prev : Err
      end
    end
  end

  private def combine_node(bests : Array(QtNode), idx = 1)
    node = bests.unsafe_fetch(idx)
    kind = CombineKind.map(node)
    return if kind.err?

    idx &+= 1
    max = bests.size
    tag = node.tag

    while idx < max
      curr = bests.unsafe_fetch(idx)
      kind = Kind.map(curr, kind)
      break if kind.err?
      idx += 1
      tag |= curr.tag
    end

    len = idx &- node.idx
    return unless len > 1

    val = String.build do |str|
      node.idx.upto(idx &- 1) do |i|
        str << bests.unsafe_fetch(i).val
      end
    end

    QtNode.new(val, idx: idx &- 1, len: len)
  end

  private def extract_result(input : Array(QtNode))
    idx = bests.size &- 1
    res = Deque(QtNode).new

    while idx > 0
      cur = bests.unsafe_fetch(idx)
      idx -= cur.key.size
      res.unshift(cur)
    end

    res
  end
end
