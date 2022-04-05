require "tabkv"
require "file_utils"

require "../../src/_init/remote_info"
require "./bootstrap"

module CV::SeedUtil
  extend self

  def save_maps!(clean = false)
    @@status_map.try(&.save!(clean: clean))
  end

  def parse_status(status_str : String)
    return 0 if status_str.empty?

    unless status_int = status_map.fval(status_str)
      print " - status int for <#{status_str}>: "

      if status_int = gets.try(&.strip)
        status_map.set!(status_str, status_int)
      end
    end

    status_int.try(&.to_i?) || 0
  end

  def get_mtime(file : String) : Int64
    File.info?(file).try(&.modification_time.to_unix) || 0_i64
  end

  def cv_ztext(ztext : String, bname : String)
    lines = ztext.split("\n").map(&.strip).reject(&.empty?)
    cv_ztext(lines, bname)
  end

  def cv_ztext(lines : Array(String), dname : String)
    cvmtl = MtCore.generic_mtl(dname)
    lines.map { |x| "<p>#{cvmtl.cv_plain(x)}</p>" }.join("\n")
  end
end

# puts CV::SeedUtil.last_snvid("69shu")
