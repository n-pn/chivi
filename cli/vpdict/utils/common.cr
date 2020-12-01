require "file_utils"

require "../../../src/engine/library"
require "../../../src/kernel/mapper/old_value_set"

module Utils
  extend self

  INP_DIR = File.join("var", "libcv", "initial")
  OUT_DIR = File.join("var", "libcv", "lexicon")

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
    @@ondicts ||= ValueSet.read!(inp_path("autogen/ondicts-words.txt"))
  end

  def has_hanzi?(input : String)
    input =~ /\p{Han}/
  end

  def load_legacy(file : String)
    dict = BaseDict.new(file, preload: false)
    dict.tap(&.load_legacy!(file))
  end

  def convert(dict : Engine::BaseDict, input : String, sep = "")
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
