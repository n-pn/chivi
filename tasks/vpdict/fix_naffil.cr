require "../../src/cvmtl/tl_util"

DIR = "var/vpdicts/v1/novel"

SHORTS = {
  '府' => "? phủ", # '城' => "thành"
  '朝' => "triều ?",
  '国' => "nước ?",
  '人' => "người ?",
  '地' => "đất ?",
  '市' => "thành phố ?",
  '家' => "? gia",
  '村' => "thôn ?",
}

TAGS = ["nn", "ns", "nt", "n", ""]

def translate(inp : String) : String
  if inp.size == 2
    return CV::TlUtil.convert(inp, TAGS) unless val = SHORTS[inp[-1]]?
    return val.sub("?", CV::TlUtil.convert(inp[0].to_s))
  end

  CV::TlUtil.translate(inp, "nn")
end

def fix_terms(file : String)
  vdict = CV::VpDict.new(file)

  fixed = 0

  vdict.list.each do |term|
    next if term._flag > 0 || term.uname != "~" || term.key.size == 1
    next unless term.attr == "nn"

    old_val = term.val.first
    new_val = translate(term.key)

    # term.force_fix!(term.val.unshift(new_val).uniq!)
    # fixed += 1

    color = old_val != new_val ? :red : (term.key.size > 2 ? :green : :blue)
    puts "- [#{term.key}] #{old_val} => #{new_val}".colorize(color)
  end

  vdict.save! if fixed > 0
end

files = Dir.glob("#{DIR}/*.tsv")
# input = files.sample(100)

input.each_with_index(1) do |file, idx|
  puts "\n[#{idx}/#{files.size}] #{File.basename(file)}"
  fix_terms(file)
end
