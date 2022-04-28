require "tabkv"
require "file_utils"

require "./bootstrap"

module CV::SeedUtil
  extend self

  def get_mtime(file : String) : Int64
    File.info?(file).try(&.modification_time.to_unix) || 0_i64
  end

  def cv_ztext(ztext : String, bname : String)
    lines = ztext.split("\n").map(&.strip).reject(&.empty?)
    cv_ztext(lines, bname)
  end

  def cv_ztext(lines : Array(String), dname : String, debug = false)
    cvmtl = MtCore.generic_mtl(dname)
    lines.map { |x| "<p>#{cvmtl.cv_plain(x)}</p>" }.join("\n")
  end
end

# puts CV::SeedUtil.last_snvid("69shu")
