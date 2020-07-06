require "file_utils"

require "../../../src/dictdb/dict_file"

module Common
  extend self

  INP_DIR = File.join("var", "libcv", ".inits")
  TMP_DIR = File.join("var", "libcv", ".temps")
  OUT_DIR = File.join("var", "libcv")

  def inp_path(file : String)
    File.join(INP_DIR, file)
  end

  def out_path(file : String)
    File.join(OUT_DIR, file)
  end

  def tmp_path(file : String)
    File.join(TMP_DIR, file)
  end

  def mkdir!(file : String)
    FileUtils.mkdir_p(File.dirname(file))
  end

  KNOWN_FILE = tmp_path("known_words.txt")
  FileUtils.touch(KNOWN_FILE) unless File.exists?(KNOWN_FILE)

  KNOWN_WORD = Set(String).new(File.read_lines(KNOWN_FILE))

  def known_word?(word : String)
    KNOWN_WORD.includes?(word)
  end

  def add_to_known(word : String, save = false)
    return if word !~ /\p{Han}/ || known_word?(word)
    KNOWN_WORD << word

    return unless save
    File.open(KNOWN_FILE, "a") { |io| io.puts(word) }
  end

  def save_known_words!
    puts "- [#{KNOWN_FILE.colorize(:blue)}] saved (#{KNOWN_WORD.size.colorize(:blue)} entries)."
    File.write(KNOWN_FILE, KNOWN_WORD.to_a.join("\n"))
  end

  def load_legacy_dict!(file : String)
    dict = DictFile.new(file, preload: false)
    dict.tap(&.load_legacy!(file))
  end

  def load_modern_dict!(file : String, preload = true)
    Common.mkdir!(file)
    DictFile.new(file, preload: preload)
  end

  def convert(dict : DictFile, input : String, sep = "")
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
