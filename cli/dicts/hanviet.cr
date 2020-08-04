require "./utils/common"
require "./utils/clavis"

require "../../src/libcv/library"
require "../../src/appcv/lookup/value_set"

class Hanviet
  CRUCIAL = ValueSet.read!(Utils.inp_path("autogen/crucial-chars.txt"))
  HANZIDB = ValueSet.read!(Utils.inp_path("initial/hanzidb.txt"))

  TRADSIM = Libcv::BaseDict.tradsim
  BINH_AM = Libcv::BaseDict.binh_am

  def should_keep_hanviet?(input : String)
    return true if CRUCIAL.includes?(input)
    return true if HANZIDB.includes?(input)

    input.split("").each do |char|
      return false if TRADSIM.has_key?(char)
    end

    true
  end

  getter output : Libcv::BaseDict { Libcv::BaseDict.load("_hanviet", mode: 0) }

  def import_dict!(file : String, mode = :old_first)
    input = Clavis.load(file)

    input.each do |key, vals|
      next if key =~ /\P{Han}/

      output.upsert(key) do |node|
        if node.removed?
          node.vals = vals
        else
          case mode
          when :keep_old
            # do nothing
          when :keep_new
            node.vals = vals
          when :old_first
            node.vals.concat(vals).uniq!
          when :new_first
            node.vals = vals.concat(node.vals).uniq!
          when :first_if_exists
            if node.vals.includes?(vals.first)
              node.vals = vals.concat(node.vals).uniq!
            else
              node.vals.concat(vals).uniq!
            end
          end
        end

        node.vals.concat(vals).uniq!
      end
    end
  end

  def transform_from_trad!
    HANZIDB.each do |key|
      next unless trad = TRADSIM.find(key)
      next unless item = output.find(key)

      output.upsert(trad.vals.first) do |node|
        break unless node.vals.empty?
        node.vals = item.vals
        puts item
      end
    end
  end

  def extract_conflicts
    conflict = Clavis.load("hanviet/conflict.txt", false)
    resolved = Clavis.load("hanviet/verified-chars.txt", true)
    # lacviet = Clavis.load("localqt/hanviet.txt", true)

    output.each do |node|
      next if node.vals.size < 2
      next unless CRUCIAL.includes?(node.key)
      next if resolved.has_key?(node.key)
      conflict.upsert(node.key, node.vals)
    end

    conflict.save!
  end

  def save!
    CRUCIAL.each do |key|
      next if output.has_key?(key)
      puts "#{key}="
    end

    output.save!
  end
end

worker = Hanviet.new

worker.import_dict!("localqt/hanviet.txt", mode: :old_first)
worker.import_dict!("hanviet/checked-chars.txt", mode: :old_first)
worker.import_dict!("hanviet/lacviet-chars.txt", mode: :old_first)
worker.import_dict!("hanviet/lacviet-words.txt", mode: :old_first)
worker.import_dict!("hanviet/trichdan-chars.txt", mode: :old_first)
worker.import_dict!("hanviet/trichdan-words.txt", mode: :old_first)
worker.import_dict!("hanviet/verified-chars.txt", mode: :keep_new)
worker.import_dict!("hanviet/verified-words.txt", mode: :keep_new)

worker.extract_conflicts
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
#   base_dicts = {
#     "#{localqt_dir}/vietphrase.txt",
#     "#{localqt_dir}/names1.txt",
#     "#{localqt_dir}/names2.txt",
#   }
#   recovered = 0

#   base_dicts.each do |file|
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
