require "../src/cvmtl/vp_dict"

INP = "var/dicts/v1"
OUT = "var/dicts/v1"

{"basic", "cvmtl", "novel", "other"}.each do |kind|
  inp_dir = File.join(INP, kind)
  out_dir = File.join(OUT, kind)

  Dir.mkdir_p(out_dir)
  files = Dir.children(inp_dir)

  files.each do |file|
    inp_file = File.join(inp_dir, file)
    out_file = File.join(out_dir, file)
    fix_dict_tags(inp_file, out_file)
  end
end

def fix_dict_tags(inp_file : String, out_file : String)
  utime = File.info(inp_file).modification_time + 1.minutes
  input = CV::VpDict.new(inp_file, type: 2, mode: :main)

  puts [input.file, input.size]
  return if input.size == 0

  out_io = File.open(out_file, "w")

  input.list.each do |term|
    next if term._flag == 2

    term.attr = fix_attr(term.attr)
    term.to_s(out_io)
    out_io << '\n'
  end

  out_io.close
  File.utime(utime, utime, out_file)
end

def fix_attr(attr : String) : String
  case attr
  when "b"  then "ab"
  when "z"  then "az"
  when "nw" then "nh"  # honorific
  when "nr" then "Nr"  # human name
  when "nf" then "Nrf" # family name
  when "nn" then "Na"  # Affiliate name
  when "ns" then "Nal" # location name
  when "nt" then "Nag" # organization name
  when "nx" then "Nw"  # book title
  when "nz" then "Nz"  # other name
  when "e"  then "xe"  # interjection/exclamation
  when "y"  then "xy"  # modal particle
  when "o"  then "xo"  # onomatopoeia - tượng thanh
  when "l"  then "il"  # Locution
  when "j"  then "nj"  # abbreviation - viết tắt
  when "t"  then "nt"  # timeword
  when "tg" then "nt"  # timeword
  when "s"  then "ns"  # position
  when "f"  then "nf"  # locative
  else           attr
  end
end
