require "json"
require "colorize"
require "file_utils"

class Data
  include JSON::Serializable

  getter _id : String

  def utime
    time = _id[0..7].to_i(base: 16)
    Time.unix(time)
  end
end

DIR = "_db/.keeps/yousuu/"

def transfer(dir : String)
  rdir = "#{DIR}/#{dir}"
  dirs = Dir.children(rdir)
  dirs.each do |ybid|
    puts "rdir/#{ybid}"
    files = Dir.glob("#{rdir}/#{ybid}/*.json")
    files.each do |file|
      transfer_file(file, file.sub(dir, "yscrits"))
    end
  end
end

def transfer_file(file : String, out_file : String)
  if out_info = File.info?(out_file)
    inp_info = File.info(file)
    return if out_info.modification_time > inp_info.modification_time
    File.delete(out_file)
  else
    FileUtils.mkdir_p(File.dirname(out_file))
  end

  File.copy(file, out_file)
end

transfer("yscrits-4")
