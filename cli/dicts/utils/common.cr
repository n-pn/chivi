require "file_utils"

require "../../../src/kernel/dict_repo"
require "../../../src/kernel/value_set"

module Utils
  extend self

  INP_DIR = File.join("var", ".dict_inits")
  OUT_DIR = File.join("var", "dict_repos")

  def inp_path(file : String)
    File.join(INP_DIR, file)
  end

  def out_path(file : String)
    File.join(OUT_DIR, file)
  end

  def mkdir!(file : String)
    FileUtils.mkdir_p(File.dirname(file))
  end

  @@known : ValueSet? = nil

  def known_words : ValueSet
    @@known ||= ValueSet.new(inp_path("autogen/known-words.txt"), true)
  end

  def has_hanzi?(input : String)
    input =~ /\p{Han}/
  end

  def load_legacy(file : String)
    dict = DictRepo.new(file, preload: false)
    dict.tap(&.load_legacy!(file))
  end

  def convert(dict : DictRepo, input : String, sep = "")
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
