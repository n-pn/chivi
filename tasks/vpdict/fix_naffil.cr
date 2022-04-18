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
  return CV::TlUtil.translate(inp, "nn") if inp.size > 2
  return CV::TlUtil.convert(inp, TAGS) unless val = SHORTS[inp[-1]]?
  val.sub("?", CV::TlUtil.convert(inp[0].to_s))
end

def fix_terms(file : String, dry_mode = true)
  vdict = CV::VpDict.new(file)
  fixed = 0

  vdict.list.each do |term|
    next if term._flag > 0 || term.uname != "~" || term.key.size == 1
    next unless term.attr == "nn"

    old_val = term.val.first
    new_val = translate(term.key)

    if dry_mode
      color = old_val != new_val ? :red : (term.key.size > 2 ? :green : :blue)
      puts "- [#{term.key}] #{old_val} => #{new_val}".colorize(color)
      next
    end

    if old_val != new_val
      term.force_fix!(term.val.unshift(new_val).uniq!)
      fixed += 1
    end
  end

  vdict.save! if fixed > 0
end

dry_mode = ARGV.includes?("--dry")

files = Dir.glob("#{DIR}/*.tsv")
files = files.sample(100) if dry_mode

files.each_with_index(1) do |file, idx|
  puts "\n[#{idx}/#{files.size}] #{File.basename(file)}"
  fix_terms(file, dry_mode: dry_mode)
end
