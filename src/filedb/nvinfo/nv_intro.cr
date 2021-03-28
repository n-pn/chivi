require "file_utils"
require "../../libcv/cvmtl"

module CV::NvIntro
  extend self

  DIR = "_db/nvdata/bintros"
  ::FileUtils.mkdir_p(DIR)

  def intro_path(bhash : String)
    File.join(DIR, "#{bhash}.txt")
  end

  def get_intro(bhash : String) : Array(String)
    file = intro_path(bhash)
    File.exists?(file) ? File.read_lines(file) : [] of String
  end

  def set_intro(bhash : String, lines : Array(String), force : Bool = false) : Nil
    file = intro_path(bhash)
    return unless force || !File.exists?(file)
    File.write(file, lines.join("\n"))
  end
end
