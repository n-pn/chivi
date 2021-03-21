require "file_utils"
require "../../engine/cvmtl"

module CV::NvBintro
  extend self

  DIR = "_db/nvdata/bintros"
  ::FileUtils.mkdir_p(DIR)

  def intro_path(bhash : String, lang : String = "vi")
    File.join(BINTRO_DIR, "#{bhash}-#{lang}.txt")
  end

  CACHE = {} of String => String

  def get_intro_vi(bhash : String) : Array(String)
    CACHE[bhash] ||= begin
      vi_file = intro_path(bhash, "vi")
      File.exists?(vi_file) ? File.read_lines(vi_file) : [] of String
    end
  end

  def get_intro_zh(bhash : String) : String
    intro_file = intro_path(bhash, lang: "zh")
    File.exists?(intro_file) ? File.read(intro_file) : ""
  end

  def set_intro(bhash : String, lines : Array(String), force : Bool = false) : Nil
    zh_file = intro_path(bhash, lang: "zh")
    return unless force || !File.exists?(zh_file)

    File.write(zh_file, lines.join("\n"))

    engine = Cvmtl.generic(bhash)
    output = lines.map { |line| engine.tl_plain(line) }

    vi_file = intro_path(bhash, lang: "vi")
    File.write(vi_file, output.join("\n"))
  end
end
