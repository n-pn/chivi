require "./shared/*"
require "../../src/engine/convert"

puts "\n[Load deps]".colorize.cyan.bold

LEXICON = ValueSet.load(".result/lexicon.tsv", true)
CHECKED = ValueSet.load(".result/checked.tsv", true)

REJECT_STARTS = File.read_lines("#{__DIR__}/consts/reject-starts.txt")
REJECT_ENDS   = File.read_lines("#{__DIR__}/consts/reject-ends.txt")

def should_keep?(key : String)
  return true if key.size == 1
  return true if LEXICON.includes?(key)
  return true if CHECKED.includes?(key)
  return true if key.ends_with?("目的")

  false
end

def should_skip?(key : String)
  REJECT_STARTS.each { |word| return true if key.starts_with?(word) }
  REJECT_ENDS.each { |word| return true if key.ends_with?(word) }

  key !~ /\p{Han}/
end

puts "\n[Export regular]".colorize.cyan.bold

OUT_REGULAR = CV::VpDict.load("regular", regen: true)

HANVIET = CV::Convert.hanviet
REGULAR = CV::Convert.new(OUT_REGULAR)

inp_regular = QtDict.load(".result/regular.txt", true)
inp_regular.to_a.sort_by(&.[0].size).each do |key, vals|
  next unless value = vals.first?
  next if value.empty?
  regex = /^#{Regex.escape(value)}$/i

  unless should_keep?(key)
    next if should_skip?(key)

    unless HANVIET.translit(key, false).to_s =~ regex
      next if REGULAR.cv_plain(key).to_s =~ regex
    end
  end

  OUT_REGULAR.upsert(CV::VpEntry.new(key, vals))
end

puts "\n- load hanviet".colorize.cyan.bold

CV::VpDict.hanviet._root.each do |node|
  next unless entry = node.entry
  next if entry.key.size > 1
  next if OUT_REGULAR.find(entry.key)
  OUT_REGULAR.upsert(entry)
end

OUT_REGULAR.load!("_db/dictdb/remote/common/regular.tab")
OUT_REGULAR.save!

puts "\n[Export suggest]".colorize.cyan.bold

OUT_SUGGEST = CV::VpDict.load("suggest", regen: true)

inp_suggest = QtDict.load(".result/suggest.txt", true)
inp_suggest.to_a.sort_by(&.[0].size).each do |key, vals|
  next if key.size > 4

  next unless value = vals.first?
  next if value.empty?
  regex = /^#{Regex.escape(value)}$/i

  unless should_keep?(key)
    next if key =~ /[的了是]/
    next if should_skip?(key)
    next if HANVIET.translit(key, false).to_s =~ regex
    next if REGULAR.cv_plain(key).to_s =~ regex
  end

  OUT_SUGGEST.upsert(CV::VpEntry.new(key, vals))
rescue err
  pp [err, key, vals]
end

OUT_SUGGEST.load!("_db/dictdb/remote/common/suggest.tab")
OUT_SUGGEST.save!

puts "\n[Export various]".colorize.cyan.bold

OUT_VARIOUS = CV::VpDict.load("various", regen: true)

inp_various = QtDict.load(".result/various.txt", true)
inp_various.to_a.sort_by(&.[0].size).each do |key, vals|
  next if key.size < 2
  next if key.size > 6

  unless should_keep?(key)
    next if should_skip?(key)
  end

  OUT_VARIOUS.upsert(CV::VpEntry.new(key, vals))
end

EXT_VARIOUS = "_db/dictdb/remote/common/various.tab"
OUT_VARIOUS.load!(EXT_VARIOUS)
OUT_VARIOUS.save!

# puts "\n[Export recycle]".colorize.cyan.bold

# inp_recycle = QtDict.load(".result/recycle.txt", true)
# out_recycle = CV::VpDict.load("salvation", 0)

# inp_recycle.to_a.sort_by(&.[0].size).each do |key, vals|
#   unless should_keep?(key)
#     next if should_skip?(key)
#   end

#   out_recycle.upsert(key, vals)
# end
# out_recycle.save!
