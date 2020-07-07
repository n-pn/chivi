# EXCEPT = {"連", "嬑", "釵", "匂", "宮", "夢", "滿", "闇", "詞", "遊", "東", "獅", "劍", "韻", "許", "雲", "異", "傳", "倫", "爾", "龍", "瑩", "蟲", "亞", "鷹", "馬", "鮮", "萊", "義", "筆", "災", "萇", "珎", "風", "俠", "雖", "離", "楓", "時", "卝", "輪", "迴", "笀", "當", "偍"}

# def keep_hanviet?(tradsim, input : String)
#   return true if EXCEPT.includes?(input)
#   input.split("").each do |char|
#     return false if tradsim.includes?(char)
#   end

#   true
# end

# def export_hanviet(tradsim, pinyins, hanzidb)
#   puts "\n- [Export hanviet]".colorize(:cyan)

#   hanviet_dir = File.join(INP_DIR, "hanviet")
#   localqt = Cvdict.load!("#{hanviet_dir}/localqt.txt")

#   checked_files = {
#     "#{hanviet_dir}/checked/chars.txt",
#     "#{hanviet_dir}/checked/words.txt",
#   }

#   checked_files.each do |file|
#     Cvdict.load!(file).data.each do |key, val|
#       localqt.set(key, val, mode: :keep_new)
#     end
#   end

#   localqt.merge!("#{hanviet_dir}/lacviet/chars.txt", mode: :keep_old)
#   localqt.merge!("#{hanviet_dir}/trichdan/chars.txt", mode: :keep_old)

#   localqt.merge!("#{hanviet_dir}/lacviet/words.txt", mode: :keep_old)
#   localqt.merge!("#{hanviet_dir}/trichdan/words.txt", mode: :keep_old)

#   puts "\n- input: #{localqt.size.colorize(:yellow)}"

#   puts "\n- Split trad/simp, trad: #{tradsim.size}".colorize(:blue)

#   out_hanviet = Cvdict.new("#{OUT_DIR}/core_root/hanviet.dic")
#   out_hantrad = Cvdict.new("#{OUT_DIR}/core_user/hanviet.local.dic")

#   localqt.data.each do |key, val|
#     if keep_hanviet?(tradsim, key)
#       out_hanviet.set(key, val)
#     else
#       out_hantrad.set(key, val)
#     end
#   end

#   converted = 0
#   # if trad hanzi existed, but not for simp evaquilent
#   out_hantrad.data.each do |trad, val|
#     if simp = tradsim.get_first(trad)
#       next if out_hanviet.includes?(simp)
#       out_hanviet.set(simp, val)
#       out_hantrad.del(trad)
#       converted += 1
#     end
#   end

#   puts "- hanviet: #{out_hanviet.size.colorize(:yellow)}, hantrad: #{out_hantrad.size.colorize(:yellow)}, trad-to-simp: #{converted.colorize(:yellow)}"

#   puts "\n- [Check missing hanviet]".colorize(:cyan)

#   missing = [] of String

#   ce_dict_count = 0
#   hanzidb_count = 0

#   tradsim.data.each do |key, val|
#     next if key.size > 1
#     next if out_hanviet.includes?(val[0])
#     missing << val[0]
#     ce_dict_count += 1
#   end

#   hanzidb.data.each_key do |key|
#     next if out_hanviet.includes?(key)
#     missing << key
#     hanzidb_count += 1
#   end

#   puts "- MISSING ce_dict: #{ce_dict_count.colorize(:yellow)}, hanzidb: #{hanzidb_count.colorize(:yellow)}, total: #{missing.size.colorize(:yellow)}"

#   puts "\n- Fill missing hanviet from vietphrase".colorize(:blue)

#   localqt_dir = File.join(INP_DIR, "localqt")
#   dict_repos = {
#     "#{localqt_dir}/vietphrase.txt",
#     "#{localqt_dir}/names1.txt",
#     "#{localqt_dir}/names2.txt",
#   }
#   recovered = 0

#   dict_repos.each do |file|
#     Cvdict.load!(file).data.each do |key, val|
#       next if key.size > 1 || !missing.includes?(key)
#       out_hanviet.add(key, val.first)
#       missing.delete(key)
#       recovered += 1
#     end
#   end

#   puts "- recovered: #{recovered.colorize(:yellow)}, still missing: #{missing.size.colorize(:yellow)}"

#   puts "\n- Guess hanviet from pinyins".colorize(:blue)

#   pinmap = Hash(String, Array(String)).new { |h, k| h[k] = Array(String).new }

#   # TODO: replace key with hanviet[key]?

#   pinyins.data.each do |key, val|
#     val.each { |v| pinmap[v] << key }
#   end

#   puts "- pinyinis count: #{pinmap.size.colorize(:blue)}"

#   missing.each do |key|
#     if val = pinyins.get_first(key)
#       hvs = pinmap[val].compact_map { |x| out_hanviet.get(x) }.flatten.uniq
#       next if hvs.empty?

#       vals = hvs.tally.to_a.sort_by(&.[1].-).first(3).map(&.[0])
#       out_hanviet.set(key, vals)
#       missing.delete(key)
#     else
#       puts "-- NO PINYIN: #{key}".colorize(:red)
#     end
#   end

#   puts "- still missing #{missing.size.colorize(:yellow)} chars."

#   puts "- write results".colorize(:blue)

#   out_hanviet.data.each do |key, val|
#     if key =~ /\w/
#       puts "-- NO HANZI: [#{key}, #{val}]"
#       out_hanviet.del(key)
#     end
#   end

#   out_hanviet.save!(keep: 4, sort: true)
#   out_hantrad.save!(keep: 4, sort: true)

#   miss_file = "#{TMP_DIR}/hanmiss.txt"
#   File.write miss_file, missing.map { |x| "#{x}=#{pinyins.get(x)}" }.join("\n")
#   puts "- saving [#{miss_file.colorize(:green)}]... done, entries: #{missing.size.colorize(:green)}"
# end
