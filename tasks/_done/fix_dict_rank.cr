require "../../src/mt_v2/vp_dict"

INP = "var/dicts/v1"
OUT = "var/dicts/v1.fix"

{"basic", "mt_v2", "novel", "other"}.each do |kind|
  inp_dir = File.join(INP, kind)
  out_dir = File.join(OUT, kind)
  files = Dir.children(inp_dir)
  Dir.mkdir_p(out_dir)

  files.each do |file|
    inp_file = File.join(inp_dir, file)
    out_file = File.join(out_dir, file)
    fix_dict(inp_file, out_file)
  end
end

def fix_dict(inp_file : String, out_file : String)
  utime = File.info(inp_file).modification_time + 1.minutes
  input = CV::VpDict.new(inp_file, type: 2, mode: :main)

  puts [input.file, input.size]
  return if input.size == 0

  out_io = File.open(out_file, "w")

  input.list.each do |term|
    next if term._flag == 2
    term.to_s(out_io)
    out_io << '\n'
  end

  out_io.close
  File.utime(utime, utime, out_file)
end
