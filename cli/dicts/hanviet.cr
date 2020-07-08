require "./utils/common"
require "../../src/engine/cv_dict"
require "../../src/kernel/value_set"

class Hanviet
  COMMONS = ValueSet.load(Utils.inp_path("autogen/common-hanzi.txt"))
  HANZIDB = ValueSet.load(Utils.inp_path("initial/hanzidb.txt"))

  TRADSIM = CvDict.load(Utils.out_path("shared/tradsim.txt"))
  PINYINS = CvDict.load(Utils.out_path("shared/pinyins.txt"))

  def should_keep_hanviet?(input : String)
    return true if COMMONS.includes?(input)
    return true if HANZIDB.includes?(input)

    input.split("").each do |char|
      return false if TRADSIM.has_key?(char)
    end

    true
  end

  @dict = CvDict.new(Utils.out_path("shared/hanviet.dic"))

  def import_lacviet_chars!
    input = CvDict.load

    input.each do |node|
      @dict.upsert(node.key, node.vals)
    end
  end

  def import_dict!(file : String)
    if file.ends_with?(".txt")
      input = CvDict.load_legacy(file)
    else
      input = CvDict.load(file)
    end

    input.each do |item|
      if item.key.ends_with?("章")
        next if item.key.size > 1
      end

      @dict.upsert(item.key) do |node|
        if node.removed? || node.vals.includes?(item.vals.first)
          # node.vals = item.vals.concat(node.vals)
        else
          # if COMMONS.includes?(node.key)
          # puts "#{node.key}=#{item.vals.join("/")}|#{node.vals.join("/")}"
          # end
        end

        node.vals.concat(item.vals)
        node.vals.uniq!
      end
    end
  end

  def transform_from_trad!
    HANZIDB.each do |key|
      next unless trad = TRADSIM.find(key)
      next unless item = @dict.find(key)

      @dict.upsert(trad.vals.first) do |node|
        break unless node.vals.empty?
        node.vals = item.vals
        puts item
      end
    end
  end

  def save!
    COMMONS.each do |key|
      next if @dict.has_key?(key)
      puts "#{key}="
    end

    @dict.save!
  end
end

worker = Hanviet.new

worker.import_dict!(Utils.inp_path("hanviet/verified-chars.txt"))
worker.import_dict!(Utils.inp_path("autogen/lacviet-chars.dic"))
worker.import_dict!(Utils.inp_path("hanviet/localqt-chars.txt"))
worker.import_dict!(Utils.inp_path("hanviet/checked-chars.txt"))
worker.import_dict!(Utils.inp_path("hanviet/trichdan-chars.txt"))
worker.import_dict!(Utils.inp_path("hanviet/verified-words.txt"))

# worker.transform_from_trad!
worker.save!

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
#   cv_dicts = {
#     "#{localqt_dir}/vietphrase.txt",
#     "#{localqt_dir}/names1.txt",
#     "#{localqt_dir}/names2.txt",
#   }
#   recovered = 0

#   cv_dicts.each do |file|
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
