require "./utils/common"
require "./utils/clavis"

require "../../src/kernel/dict_repo"
require "../../src/kernel/value_set"

puts "\n[Load inputs]".colorize(:cyan)

CHECKED = ValueSet.load(Utils.inp_path("autogen/checked.txt"))
KNOWNED = ValueSet.load(Utils.inp_path("autogen/known-words.txt"))

inp_generic = Clavis.new(Utils.inp_path("autogen/generic.txt"), true)
inp_suggest = Clavis.new(Utils.inp_path("autogen/suggest.txt"), true)
inp_combine = Clavis.new(Utils.inp_path("autogen/combine.txt"), true)
inp_recycle = Clavis.new(Utils.inp_path("autogen/recycle.txt"), true)

puts "\n[Export output]".colorize(:cyan)

out_generic = DictRepo.new(Utils.out_path("shared/generic.dic"), false)
inp_generic.to_a.sort_by(&.[0].size).each do |key, vals|
  out_generic.upsert(key, vals)
end

out_generic.save!

out_suggest = DictRepo.new(Utils.out_path("shared/suggest.dic"), false)
inp_suggest.each do |key, vals|
  # unless CHECKED.includes?(key) || !KNOWNED.includes?(key)
  #   next if Utils.convert(out_generic, key, " ") == vals.first
  # end

  out_suggest.upsert(key, vals)
end
out_suggest.save!

out_combine = DictRepo.new(Utils.out_path("shared/combine.dic"), false)
inp_combine.each do |key, vals|
  # unless CHECKED.includes?(key) || !KNOWNED.includes?(key)
  #   next if Utils.convert(out_generic, key, " ") == vals.first
  # end

  out_combine.upsert(key, vals)
end
out_combine.save!

out_recycle = DictRepo.new(Utils.out_path("shared/recycle.dic"))
inp_recycle.each do |key, vals|
  # unless CHECKED.includes?(key) || !KNOWNED.includes?(key)
  #   next if Utils.convert(out_generic, key, " ") == vals.first
  # end

  out_recycle.upsert(key, vals)
end
out_recycle.save!
