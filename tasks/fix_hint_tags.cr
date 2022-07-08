INP = "var/vphints/postag"
OUT = "var/dicts/vx/postag"

{"bd_lac", "cvuser"}.each do |folder|
  inp_dir = File.join(INP, folder)
  out_dir = File.join(OUT, folder)

  Dir.mkdir_p(out_dir)
  files = Dir.children(inp_dir)

  files.each do |file|
    inp_file = File.join(inp_dir, file)
    out_file = File.join(out_dir, file)
    fix_hint_tags(inp_file, out_file)
  end
end

def fix_hint_tags(inp_file : String, out_file : String)
  input = File.read_lines(inp_file).map(&.split('\t'))
  puts [inp_file, input.size]
  return if input.size == 0

  out_io = File.open(out_file, "w")

  input.each do |array|
    array = array.map_with_index { |x, i| i > 0 ? fix_attr(x) : x }
    array.join(out_io, '\t')
    out_io << '\n'
  end

  out_io.close
  utime = File.info(inp_file).modification_time + 1.minutes
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
