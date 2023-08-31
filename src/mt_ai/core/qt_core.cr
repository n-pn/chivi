require "../../_util/char_util"

require "./qt_core/*"

class MT::QtCore
  class_getter hv_name : self { new(QtDict.hv_name) }
  class_getter sino_vi : self { new(QtDict.sino_vi) }
  class_getter pin_yin : self { new(QtDict.pin_yin) }

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

  def initialize(@dict : QtDict)
  end

  def tokenize(input : String)
    chars = input.chars.map { |x| CharUtil.normalize(x) }

    index = 0
    output = QtData.new

    while index < chars.size
      term = @dict.find_best(chars, start: index)
      output << QtNode.new(term, index)
      index &+= term.len
    end

    output
  end
end
