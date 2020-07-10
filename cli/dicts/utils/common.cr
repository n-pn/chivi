require "file_utils"

require "../../../src/engine/cv_dict"
require "../../../src/kernel/value_set"

module Utils
  extend self

  INP_DIR = File.join("var", ".dict_inits")
  OUT_DIR = File.join("var", "dict_files")

  def inp_path(file : String)
    File.join(INP_DIR, file)
  end

  def out_path(file : String)
    File.join(OUT_DIR, file)
  end

  def mkdir!(file : String)
    FileUtils.mkdir_p(File.dirname(file))
  end

  @@ondicts : ValueSet? = nil

  def ondicts_words : ValueSet
    @@ondicts ||= ValueSet.new(inp_path("autogen/ondicts-words.txt"), true)
  end

  def has_hanzi?(input : String)
    input =~ /\p{Han}/
  end

  def load_legacy(file : String)
    dict = CvDict.new(file, preload: false)
    dict.tap(&.load_legacy!(file))
  end

  def convert(dict : CvDict, input : String, sep = "")
    res = [] of String

    chars = input.chars

    from = 0
    while from < chars.size
      keep = chars[from].to_s
      dict.scan(chars, from) { |node| keep = node.vals.first }

      res << keep
      from += keep.size
    end

    res.join(sep)
  end
end
