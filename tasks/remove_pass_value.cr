require "../src/mtlv1/vp_dict"

INP = "var/dicts/v1"

{"basic", "cvmtl", "novel", "other"}.each do |kind|
  inp_dir = File.join(INP, kind)
  files = Dir.children(inp_dir)

  files.each do |file|
    inp_file = File.join(inp_dir, file)
    fix_dict(inp_file)
  end
end

def prev_val(term : CV::VpTerm, is_generic = false)
  key = term.key
  while term = term._prev
    return term.val if term.val.first != "[[pass]]"
  end

  return [""] if is_generic || !(base_term = CV::VpDict.regular.find(key))
  prev_val(base_term, is_generic: true)
end

def fix_dict(file : String)
  utime = File.info(file).modification_time + 1.minutes
  input = CV::VpDict.new(file, type: 2, mode: :main)

  puts [input.file, input.size]
  return if input.size == 0

  out_io = File.open(file, "w")

  input.list.each do |term|
    next if term._flag == 2

    if term.val.first == "[[pass]]"
      term.rank = 0
      term.val = prev_val(term)
    end

    term.to_s(out_io)
    out_io << '\n'
  end

  out_io.close
  File.utime(utime, utime, file)
end
