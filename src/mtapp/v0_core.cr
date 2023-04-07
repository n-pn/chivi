require "../_util/char_util"
require "./data/v0_dict"
require "./core/v0_data"

class MT::V0Core
  class_getter sino_vi : self { new(V0Dict.sino_vi) }
  class_getter hv_name : self { new(V0Dict.hv_name) }
  class_getter pin_yin : self { new(V0Dict.pin_yin) }

  def self.tl_hvname(name : String)
    return name unless name.matches?(/\p{Han}/)
    self.hv_name.tokenize(str).to_txt(cap: false)
  end

  def self.tl_sinovi(str : String, cap : Bool = false)
    self.sino_vi.tokenize(str).to_txt(cap: cap)
  end

  def self.tl_pinyin(str : String, cap : Bool = false)
    self.pin_yin.tokenize(str).to_txt(cap: cap)
  end

  def initialize(@dict : V0Dict)
  end

  @[Flags]
  enum NerOpts
    Enabled
    Persist
  end

  def tokenize(input : String, ner_opts : NerOpts = :enabled)
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

    cursor = 0
    output = V0Data.new

    while cursor < bests.size
      node = bests.unsafe_fetch(cursor)
      output << node
      cursor &+= node.len
    end

    @dict.clear_entities! unless ner_opts.persist?
    output
  end
end
