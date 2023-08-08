require "../_util/char_util"
require "./sp_core/*"

class MT::SpCore
  class_getter hv_name : self { new(SpDict.hv_name) }
  class_getter sino_vi : self { new(SpDict.sino_vi) }
  class_getter pin_yin : self { new(SpDict.pin_yin) }

  def self.tl_hvname(str : String)
    return CharUtil.normalize(str) unless str.matches?(/\p{Han}/)
    self.hv_name.tokenize(str).to_txt(cap: false)
  end

  def self.tl_sinovi(str : String, cap : Bool = false)
    self.sino_vi.tokenize(str).to_txt(cap: cap)
  end

  def self.tl_pinyin(str : String, cap : Bool = false)
    self.pin_yin.tokenize(str).to_txt(cap: cap)
  end

  def initialize(@dict : SpDict)
  end

  def tokenize(input : String)
    chars = input.chars.map { |x| CharUtil.normalize(x) }

    index = 0
    output = SpData.new

    while index < chars.size
      term = @dict.find_best(chars, start: index)
      output << SpNode.new(term, index)
      index &+= term.len
    end

    output
  end
end
