require "./shared/*"
require "../../src/engine/library"

puts "\n[Load deps]".colorize.cyan.bold

LEXICON = ValueSet.load(".result/lexicon.txt", true)
CHECKED = ValueSet.load(".result/checked.txt", true)

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

inp_regular = QtDict.load(".result/regular.txt", true)
out_regular = Chivi::Library.regular

inp_regular.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)

    unless Engine.hanviet(key).vi_text.downcase == vals.first.downcase
      next if Engine.cv_plain(key, "combine").vi_text == vals.first
    end
  end

  out_regular.upsert(key, vals)
end

puts "- load hanviet".colorize.cyan.bold

Engine::Library.hanviet.each do |node|
  next if node.key.size > 1
  out_regular.upsert(node.key, freeze: false) do |item|
    item.vals = node.vals if item.vals.empty?
  end
end

out_regular.save!

puts "\n[Export suggest]".colorize.cyan.bold

inp_suggest = QtDict.load(".result/suggest.txt", true)
out_suggest = Chivi::Library.suggest

inp_suggest.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if key =~ /[的了是]/
    next if should_skip?(key)
    next if Engine.hanviet(key, false).vi_text == vals.first
    next if Engine.cv_plain(key, "combine").vi_text.downcase == vals.first.downcase
  end

  out_suggest.upsert(key, vals)
end
out_suggest.save!

puts "\n[Export combine]".colorize.cyan.bold

inp_combine = QtDict.load(".result/combine.txt", true)
out_combine = Chivi::Library.load("uniq/_tonghop", 0)

inp_combine.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
  end

  out_combine.upsert(key, vals)
end
out_combine.save!

puts "\n[Export recycle]".colorize.cyan.bold

inp_recycle = QtDict.load(".result/recycle.txt", true)
out_recycle = Chivi::Library.load("salvation", 0)

inp_recycle.to_a.sort_by(&.[0].size).each do |key, vals|
  unless should_keep?(key)
    next if should_skip?(key)
  end

  out_recycle.upsert(key, vals)
end
out_recycle.save!
