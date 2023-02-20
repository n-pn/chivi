require "../_util/char_util"
require "./core/*"

class SP::MtCore
  class_getter sino_vi : self { new(MtDict.sino_vi) }
  class_getter pin_yin : self { new(MtDict.pin_yin) }

  def self.tl_sinovi(str : String, cap : Bool = false)
    self.sino_vi.tokenize(str).to_txt(cap: cap)
  end

  def self.tl_pinyin(str : String, cap : Bool = false)
    self.pin_yin.tokenize(str).to_txt(cap: cap)
  end

  def initialize(@dict : MtDict)
  end

  def tokenize(input : String)
    chars = input.chars.map! do |char|
      char = CharUtil.normalize(char)
      char == '､' ? ',' : char
    end

    costs = Array(Int32).new(chars.size + 1, 0)
    bests = chars.map_with_index { |char, idx| MtNode.new(char, idx: idx) }

    entities = SpNers.scan_all(bests, 0)

    (chars.size - 1).downto(0) do |index|
      best_cost = 0

      if entity = entities[index]?
        last_cost = costs.unsafe_fetch(index &+ entity.size)
        best_cost = last_cost &+ entity.cost

        costs[index] = best_cost
        bests[index] = entity
      end

      @dict.scan(chars, start: index) do |node|
        last_cost = costs.unsafe_fetch(index &+ node.size)
        curr_cost = last_cost &+ node.cost

        next if best_cost > curr_cost

        costs[index] = best_cost = curr_cost
        bests[index] = node.dup!(index)
      end
    end

    index = 0
    mt_data = MtData.new

    while index < bests.size
      node = bests.unsafe_fetch(index)
      mt_data << node
      index &+= node.size
    end

    mt_data
  end
end
