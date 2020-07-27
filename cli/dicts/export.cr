require "./utils/common"
require "./utils/clavis"

require "../../src/engine"
require "../../src/lookup/value_set"

puts "\n[Load deps]".colorize.cyan.bold

CHECKED = ValueSet.read!(Utils.inp_path("autogen/checked.txt"))
ONDICTS = Utils.ondicts_words

REJECT_STARTS = File.read_lines("cli/dicts/cfgs/reject-starts.txt")
REJECT_ENDS   = File.read_lines("cli/dicts/cfgs/reject-ends.txt")

def should_keep?(key : String)
  return true if ONDICTS.includes?(key)
  return true if CHECKED.includes?(key)
  return true if key.ends_with?("目的")

  false
end

def should_skip?(key : String)
  REJECT_STARTS.each { |word| return true if key.starts_with?(word) }
  REJECT_ENDS.each { |word| return true if key.ends_with?(word) }

  key !~ /\p{Han}/
end

puts "\n[Export generic]".colorize.cyan.bold

inp_generic = Clavis.load("autogen/output/generic.txt", true)
out_generic = BaseDict.load("core/generic", mode: 0)

inp_generic.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)

    unless Engine.hanviet(key).vi_text.downcase == vals.first.downcase
      next if Engine.cv_plain(key, "tonghop").vi_text == vals.first
    end
  end
  out_generic.upsert(key, vals)
end
out_generic.save!

puts "\n[Export suggest]".colorize.cyan.bold

inp_suggest = Clavis.load("autogen/output/suggest.txt", true)
out_suggest = BaseDict.load("core/suggest", 0)

inp_suggest.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
    next if key =~ /[的了是]/
    next if Engine.hanviet(key).vi_text.downcase == vals.first.downcase
    next if Engine.cv_plain(key, "tonghop").vi_text.downcase == vals.first.downcase
  end

  out_suggest.upsert(key, vals)
end
out_suggest.save!

puts "\n[Export combine]".colorize.cyan.bold

inp_combine = Clavis.load("autogen/output/combine.txt", true)
out_combine = BaseDict.load("uniq/_tonghop", 0)

inp_combine.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
  end
  out_combine.upsert(key, vals)
end
out_combine.save!

puts "\n[Export recycle]".colorize.cyan.bold

inp_recycle = Clavis.load("autogen/output/recycle.txt", true)
out_recycle = BaseDict.load("salvation", 0)

inp_recycle.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
    next if key =~ /[的了是]/
  end
  out_recycle.upsert(key, vals)
end
out_recycle.save!
