require "../../src/mt_v2/mt_name"

DIR = "var/vpdicts/v1/novel"

def fix_terms(file : String, dry_mode = true)
  vdict = CV::VpDict.new(file)
  fixed = 0

  vdict.list.each do |term|
    next if term._flag > 0 || term.uname != "~" || term.key.size == 1
    next unless term.attr == "Na"

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
