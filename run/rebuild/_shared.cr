require "../../src/mtapp/mt_core/mt_defn"
require "../../src/mtapp/shared/*"
require "../../src/_util/char_util"

def normalize(key : String)
  String.build do |io|
    key.each_char do |char|
      if (char.ord & 0xff00) == 0xff00
        io << (char.ord - 0xfee0).chr.downcase
      elsif punct = CharUtil::NORMALIZE[char]?
        io << punct
      else
        io << char.downcase
      end
    end
  end
end

def capitalize(a : String)
  return a if a.empty?

  String.build do |io|
    a.each_char_with_index do |char, i|
      io << (i == 0 ? char.upcase : char)
    end
  end
end

def is_lower?(x : String)
  x[0].downcase == x[0]
end
