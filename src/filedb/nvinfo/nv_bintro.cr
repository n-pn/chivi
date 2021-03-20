require "file_utils"
require "../../engine/cvmtl"

module CV::NvBintro
  extend self

  DIR = "_db/nvdata/bintros"
  ::FileUtils.mkdir_p(DIR)

  def bintro_path(bhash : String, lang : String = "vi")
    File.join(BINTRO_DIR, "#{bhash}-#{lang}.txt")
  end

  def get_bintro(bhash : String) : Array(String)
    vi_file = intro_path(bhash, "vi")
    File.exists?(vi_file) ? File.read_lines(vi_file) : [] of String
  end

  def get_bintro(bhash : String, lang : String = "vi") : String
    intro_file = bintro_path(bhash, lang: lang)
    File.exists?(intro_file) ? File.read(intro_file) : ""
  end

  def set_bintro(bhash : String, lines : Array(String), force : Bool = false) : Nil
    zh_file = bintro_path(bhash, lang: "zh")
    return unless force || !File.exists?(zh_file)

    File.write(zh_file, lines.join("\n"))

    engine = Cvmtl.generic(bhash)
    output = lines.map { |line| engine.tl_plain(line) }

    vi_file = bintro_path(bhash, lang: "vi")
    File.write(vi_file, output.join("\n"))
  end
end
