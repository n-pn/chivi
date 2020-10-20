require "./utils/common"
require "./utils/clavis"

require "../../src/libcv"
require "../../src/kernel/lookup/value_set"

puts "\n[Load deps]".colorize.cyan.bold

CHECKED = ValueSet.read!(Utils.inp_path("autogen/checked.txt"))
ONDICTS = Utils.ondicts_words

REJECT_STARTS = File.read_lines("cli/dicts/cfgs/reject-starts.txt")
REJECT_ENDS   = File.read_lines("cli/dicts/cfgs/reject-ends.txt")

def should_keep?(key : String)
  return true if key.size == 1
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
out_generic = Libcv::BaseDict.load("core/generic", mode: 0)

inp_generic.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)

    unless Libcv.hanviet(key).vi_text.downcase == vals.first.downcase
      next if Libcv.cv_plain(key, "combine").vi_text == vals.first
    end
  end

  out_generic.upsert(key, vals)
end

puts "- load hanviet".colorize.cyan.bold

Libcv::Library.hanviet.each do |node|
  next if node.key.size > 1
  out_generic.upsert(node.key, freeze: false) do |item|
    item.vals = node.vals if item.vals.empty?
  end
end

out_generic.save!

puts "\n[Export suggest]".colorize.cyan.bold

inp_suggest = Clavis.load("autogen/output/suggest.txt", true)
out_suggest = Libcv::BaseDict.load("core/suggest", 0)

inp_suggest.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if key =~ /[的了是]/
    next if should_skip?(key)
    next if Libcv.hanviet(key, false).vi_text == vals.first
    next if Libcv.cv_plain(key, "combine").vi_text.downcase == vals.first.downcase
  end

  out_suggest.upsert(key, vals)
end
out_suggest.save!

puts "\n[Export combine]".colorize.cyan.bold

inp_combine = Clavis.load("autogen/output/combine.txt", true)
out_combine = Libcv::BaseDict.load("uniq/_tonghop", 0)

inp_combine.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
  end

  out_combine.upsert(key, vals)
end
out_combine.save!

puts "\n[Export recycle]".colorize.cyan.bold

inp_recycle = Clavis.load("autogen/output/recycle.txt", true)
out_recycle = Libcv::BaseDict.load("salvation", 0)

inp_recycle.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
  end

  out_recycle.upsert(key, vals)
end
out_recycle.save!
