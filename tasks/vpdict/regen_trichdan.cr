require "./shared/qt_util"
require "./shared/qt_dict"

def cleanup(input : String)
  input.split("\\t")
    .join("; ")
    .gsub(/(\]|}); /) { |_, x| x[1] + " " }
end

out_dict = CV::VpHint.trich_dan

TRADSIM = {} of String => String

File.each_line("_db/vpinit/system/trichdan.txt") do |line|
  key, vals = line.split("=", 2)
  if match = vals.match(/Giản thể của chữ (\p{Han}+)/)
    TRADSIM[key] = match[1]
  end

  vals = vals.split("\\n").map { |x| cleanup(x) }

  out_dict.add(key, vals)
rescue err
  puts err
end

TRADSIM.each do |trad, simp|
  next unless vals = out_dict.find(trad)
  out_dict.extend(simp, vals)
end

out_dict.save!
