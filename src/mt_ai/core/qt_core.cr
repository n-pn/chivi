require "../../_util/char_util"

require "./qt_core/*"
require "./qt_dict"

class MT::QtCore
  class_getter hv_name : self { new(QtDict.hv_name) }
  class_getter hv_word : self { new(QtDict.hv_word) }
  class_getter pin_yin : self { new(QtDict.pin_yin) }

  def self.tl_hvname(str : String)
    return CharUtil.normalize(str) unless str.matches?(/\p{Han}/)
    self.hv_name.tokenize(str).to_txt(cap: false)
  end

  def self.tl_hvword(str : String, cap : Bool = false)
    self.hv_word.tokenize(str).to_txt(cap: cap)
  end

  def self.tl_pinyin(str : String, cap : Bool = false)
    self.pin_yin.tokenize(str).to_txt(cap: cap)
  end

  def initialize(@dict : QtDict)
  end

  def tokenize(input : String)
    chars = input.chars

    index = 0
    stack = QtData.new

    while index < chars.size
      term, _len, _dic = @dict.find(chars, start: index)
      zstr = chars[index, _len].join
      stack << QtNode.new(zstr, term.vstr, term.attr, _idx: index, _dic: _dic)
      index &+= _len
    end

    stack
  end

  def tokenize_file(fpath : String)
    File.each_line(fpath, chomp: true) do |line|
      next if line.empty?
      yield tokenize(line)
    end
  end

  def translate_file(fpath : String)
    texts = [] of String
    tokenize_file(fpath) { |data| texts << data.to_txt }
    texts
  end
end
