require "colorize"
require "file_utils"

require "../../../src/mt_v2/vp_dict"
require "../../../src/mt_v2/vp_hint"

module QtUtil
  DIR = "_db/vpinit"

  extend self

  def path(file : String)
    File.join(DIR, file)
  end

  PINYINS = Hash(String, String).from_json File.read("#{__DIR__}/../consts/binh_am.json")

  def fix_pinyin(input : String)
    input
      .downcase
      .gsub("u:", "ü")
      .split(/[\s\-]/x)
      .map { |x| PINYINS.fetch(x, x) }
      .join(" ")
  end

  def convert(dict : CV::VpDict, text : String, join = "")
    output = [] of String

    chars = text.chars
    caret = 0

    while caret < chars.size
      char = chars[caret]
      keep = CV::VpTerm.new(char.to_s, [char.to_s], mtime: 0)

      dict.scan(chars, caret) do |term|
        keep = term unless term.empty?
      end

      output << keep.val.first
      caret += keep.key.size
    end

    output.join(join)
  end
end
