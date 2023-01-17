require "../_util/char_util"
require "./core/*"

class SP::Engine
  class_getter hanviet : self do
    new(CharDict.load("hanviet"), WordDict.load("hanviet"))
  end

  class_getter binh_am : self do
    new(CharDict.load("binh_am"), WordDict.load("binh_am"))
  end

  def initialize(@char_dict : CharDict, @word_dict : WordDict)
  end

  BASE_COST = 64

  private def node_cost(size : Int32) : Int32
    size &* BASE_COST &+ size &** size
  end

  def convert(input : String)
    chars = input.chars.map! do |char|
      char = CharUtil.normalize(char)
      char == '､' ? ',' : char
    end

    bests = [MtNode::NONE]
    costs = [0]

    chars.each_with_index do |char, idx|
      costs << idx

      if val = @char_dict.find(char)
        bests << MtNode.new(val, len: 1, idx: idx)
      else
        bests << MtNode.new(char, idx: idx)
      end
    end

    ner_idx = 1

    while ner_idx < chars.size
      unless node = combine_node(bests, ner_idx)
        ner_idx &+= 1
        next
      end

      new_idx = ner_idx &+ node.len &- 1

      bests[new_idx] = node
      costs[new_idx] = costs[ner_idx] &+ node_cost(node.len) &+ 1

      ner_idx = new_idx &+ 1
    end

    chars.size.times do |idx|
      curr_cost = costs.unsafe_fetch(idx)

      @word_dict.scan(chars, offset: idx) do |val, len|
        word_cost = curr_cost &+ node_cost(len) &+ 2

        jump_to = idx &+ len
        next if costs[jump_to] > word_cost

        costs[jump_to] = word_cost
        bests[jump_to] = MtNode.new(val, idx: idx, len: len)
      end
    end

    extract_result(bests)
  end

  enum CombineKind
    Int; Str; Url; Mix; Err

    def is_url?
      value <= Url.value
    end

    def is_mix?
      value <= Str.value
    end

    def self.map(node : MtNode)
      return Err if node.val.blank?

      case node.tag
      when .content?  then Err
      when .int_part? then Int
      when .str_part? then Str
      else                 Mix
      end
    end

    def self.map(node : MtNode, prev : self)
      case node.tag
      when .content?  then Err
      when .int_part? then prev.is_url? ? prev : Err
      when .str_part? then prev.is_url? ? prev : Err
      when .url_part? then prev.mix? ? prev : Url
      else                 prev.mix? ? prev : Err
      end
    end
  end

  private def combine_node(bests : Array(MtNode), idx = 1)
    node = bests.unsafe_fetch(idx)
    kind = CombineKind.map(node)
    return if kind.err?

    max = bests.size &- 1
    tag = node.tag

    loop do
      idx &+= 1
      break if idx > max

      curr = bests.unsafe_fetch(idx)
      kind = CombineKind.map(curr, kind)

      break if kind.err?

      tag =
        case kind
        when .mix? then tag
        when .url? then MtNode::Tag::None
        else            MtNode::Tag::Content
        end
    end

    len = idx &- node.idx &- 1
    return unless len > 1

    val = String.build do |str|
      (node.idx &+ 1).upto(idx &- 1) do |i|
        str << bests.unsafe_fetch(i).val
      end
    end

    MtNode.new(val, idx: node.idx, len: len, tag: tag)
  end

  private def extract_result(input : Array(MtNode))
    idx = input.size &- 1
    res = MtData.new

    while idx > 0
      cur = input.unsafe_fetch(idx)
      idx -= cur.len
      res.unshift(cur)
    end

    res
  end
end
