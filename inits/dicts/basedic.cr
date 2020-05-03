require "../../src/engine/cutil"

require "./shared/*"

require "http/client"
require "zip"

require "json"
require "time"

def outdated?(file : String)
  return true unless File.exists?(file)
  mtime = File.info(file).modification_time
  Time.local - mtime > 1.days
end

URL = "https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip"

def read_zip(zip_file : String = "data/dic-inp/routine/cedict.zip") : String
  print "-- fetching latest CC_CEDICT file from internet... ".colorize(:blue)

  if outdated?(zip_file)
    HTTP::Client.get(URL) { |res| File.write(zip_file, res.body_io) }
  end

  Zip::File.open(zip_file) do |zip|
    zip["cedict_ts.u8"].open do |io|
      puts "done.\n"
      io.gets_to_end
    end
  end
end

def repeat_itself?(defn : String, simp : String) : Bool
  return true if defn =~ /variant of #{simp}/
  return true if defn =~ /also written #{simp}/
  return true if defn =~ /see #{simp}/

  false
end

def cleanup_defn(defn, simp) : String
  defn.gsub(/\p{Han}+\|/, "")                          # remove hantrads
    .gsub(/(?<=\[)(.*?)(?=\])/) { |p| pinyinfmt(p) }   # number to tones
    .split("/").reject { |x| repeat_itself?(x, simp) } # clean trad defs
    .join("; ")
end

LINE_RE = /^(.+?) (.+?) \[(.+?)\] \/(.+)\/$/

def load_input(inp_file : String = "data/dic-inp/routine/cedict.txt")
  puts "- Load input from #{inp_file.colorize(:yellow)}"

  if outdated?(inp_file)
    input = read_zip("data/dic-inp/routine/cedict.zip")

    print "-- parsing...".colorize(:blue)
    output = [] of Array(String)

    input.split("\n").each do |line|
      entry = line.strip
      next if entry.empty? || entry[0] == '#'

      _, trad, simp, pinyin, defn = entry.match(LINE_RE).not_nil!

      lookup = cleanup_defn(defn, simp)
      next if lookup.empty?

      trad = CUtil.normalize(trad).join
      simp = CUtil.normalize(simp).join
      pinyin = pinyinfmt(pinyin)

      output << [trad, simp, pinyin, lookup]
    end

    File.write(inp_file, output.map(&.join("ǁ")).join("\n"))
  else
    output = File.read_lines(inp_file).map(&.split("ǁ"))
  end

  puts " done. Entries: [#{output.size}]"
  output
end

def export_cedict(input)
  puts "\n- [Export cc_cedict]".colorize(:cyan)

  output = Cvdict.new("data/dic-out/cc_cedict.dic")

  input.each do |rec|
    _trad, simp, pinyin, lookup = rec
    output.add(simp, "[#{pinyin}] #{lookup}")
  end

  output.save!
end

alias Counter = Hash(String, Int32)

def export_pinyins(input, hanzidb)
  puts "\n- [Export pinyins]".colorize(:cyan)

  counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }

  input.each do |rec|
    _trad, simp, pinyin, lookup = rec
    next if is_trad?(lookup)

    chars = simp.split("")
    pinyins = pinyin.split(" ")
    next if chars.size != pinyins.size

    chars.each_with_index do |char, i|
      next if char =~ /\P{Han}/
      pinyin = pinyins[i]
      counter[char][pinyin] += 1
    end
  end

  output = Cvdict.new("data/dic-out/pinyins.dic")
  output.load!("data/dic-inp/routine/pinyins.txt")

  counter.each do |char, count|
    best = count.to_a.sort_by { |pinyin, value| -value }.first(3).map(&.first)
    output.set(char, best)
  end

  hanzidb.data.each do |key, val|
    next if val.empty? || output.includes?(key)
    output.set(key, val)
  end

  output.save!(sort: true)
  output
end

def is_trad?(input : String)
  input.includes?("old variant of") || input.includes?("archaic variant of")
end

def export_tradsim(input, hanzidb)
  puts "\n- [Export tradsim]".colorize(:cyan)

  tswords = Cvdict.new("data/dic-tmp/tswords.txt")
  counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }

  input.each do |rec|
    trad, simp, _pinyin, lookup = rec
    next if is_trad?(lookup)

    tswords.add(trad, simp) if trad.size > 1

    simps = simp.split("")
    trads = trad.split("")

    trads.each_with_index do |trad, i|
      counter[trad][simps[i]] += 1
    end
  end

  output = Cvdict.new("data/dic-out/tradsim.dic")

  counter.each do |trad, counts|
    best = counts.to_a.sort_by { |simp, count| -count }.map(&.first)
    next if best.includes?(trad)
    next if hanzidb.includes?(trad) # ignore if still in used
    output.set(trad, best[0]) unless trad == best[0]
  end

  puts "- single traditional char count: #{output.size.colorize(:green)}"

  output.set("扶馀", "扶余") # exception

  tswords.data.each do |trad, simp|
    simp.uniq!

    next if simp.size > 1
    next if simp[0] == trad
    next if simp[0] == output.translate(trad)
    output.set(trad, simp)
  end

  output.save!(sort: true)
  output
end

def extract_ondicts(cedict, tradsim)
  puts "\n- [Export ondicts]".colorize(:cyan)
  ondicts = Set(String).new

  ondicts.concat cedict.keys.reject { |x| tradsim.includes?(x) }
  ondicts.concat Cvdict.load!("data/dic-inp/routine/lacviet.txt").keys
  ondicts.concat Cvdict.load!("data/dic-inp/hanviet/checked/words.txt").keys
  ondicts.concat Cvdict.load!("data/dic-inp/hanviet/trichdan/words.txt").keys

  out_file = "data/dic-tmp/ondicts.txt"
  ondicts = ondicts.to_a.reject(&.!~(/\p{Han}/))
  File.write(out_file, ondicts.join("\n"))

  puts "- saving [#{out_file.colorize(:green)}]... done, entries: #{ondicts.size.colorize(:green)}"
end

EXCEPT = {"連", "嬑", "釵", "匂", "宮", "夢", "滿", "闇", "詞", "遊", "東", "獅", "劍", "韻", "許", "雲", "異", "傳", "倫", "爾", "龍", "瑩", "蟲", "亞", "鷹", "馬", "鮮", "萊", "義", "筆", "災", "萇", "珎", "風", "俠", "雖", "離", "楓", "時", "卝", "輪", "迴", "笀", "當", "偍"}

def keep_hanviet?(tradsim, input : String)
  return true if EXCEPT.includes?(input)
  input.split("").each do |char|
    return false if tradsim.includes?(char)
  end

  true
end

def export_hanviet(tradsim, pinyins, hanzidb)
  puts "\n- [Export hanviet]".colorize(:cyan)

  history_file = "data/dic-inp/hanviet/localqt.log"
  history = Set.new(File.read_lines(history_file)[1..].map(&.split("\t", 2)[0]))

  localqt = Cvdict.load!("data/dic-inp/hanviet/localqt.txt")

  localqt.merge!("data/dic-inp/hanviet/lacviet/chars.txt", mode: :old_first)
  localqt.merge!("data/dic-inp/hanviet/trichdan/chars.txt", mode: :old_first)

  checked_files = {
    "data/dic-inp/hanviet/checked/chars.txt",
    "data/dic-inp/hanviet/checked/words.txt",
  }

  checked_files.each do |file|
    Cvdict.load!(file).data.each do |key, val|
      localqt.set(key, val) unless history.includes?(key)
    end
  end

  puts "\n- input: #{localqt.size.colorize(:yellow)}"

  puts "\n- Split trad/simp, trad: #{tradsim.size}".colorize(:blue)

  out_hanviet = Cvdict.new("data/dic-out/hanviet.dic")
  out_hantrad = Cvdict.new("data/dic-out/hantrad.dic")

  localqt.data.each do |key, val|
    if keep_hanviet?(tradsim, key)
      out_hanviet.set(key, val)
    else
      out_hantrad.set(key, val)
    end
  end

  converted = 0
  # if trad hanzi existed, but not for simp evaquilent
  out_hantrad.data.each do |trad, val|
    if simp = tradsim.get_first(trad)
      next if out_hanviet.includes?(simp)
      out_hanviet.set(simp, val)
      out_hantrad.del(trad)
      converted += 1
    end
  end

  puts "- hanviet: #{out_hanviet.size.colorize(:yellow)}, hantrad: #{out_hantrad.size.colorize(:yellow)}, trad-to-simp: #{converted.colorize(:yellow)}"

  puts "\n- [Check missing hanviet]".colorize(:cyan)

  missing = [] of String

  ce_dict_count = 0
  hanzidb_count = 0

  tradsim.data.each do |key, val|
    next if key.size > 1
    next if out_hanviet.includes?(val[0])
    missing << val[0]
    ce_dict_count += 1
  end

  hanzidb.data.each_key do |key|
    next if out_hanviet.includes?(key)
    missing << key
    hanzidb_count += 1
  end

  puts "- MISSING ce_dict: #{ce_dict_count.colorize(:yellow)}, hanzidb: #{hanzidb_count.colorize(:yellow)}, total: #{missing.size.colorize(:yellow)}"

  puts "\n- Fill missing hanviet from vietphrase".colorize(:blue)

  dict_files = {
    "data/dic-inp/localqt/vietphrase.txt",
    "data/dic-inp/localqt/names1.txt",
    "data/dic-inp/localqt/names2.txt",
  }
  recovered = 0

  dict_files.each do |file|
    Cvdict.load!(file).data.each do |key, val|
      next if key.size > 1 || !missing.includes?(key)
      out_hanviet.add(key, val.first)
      missing.delete(key)
      recovered += 1
    end
  end

  puts "- recovered: #{recovered.colorize(:yellow)}, still missing: #{missing.size.colorize(:yellow)}"

  puts "\n- Guess hanviet from pinyins".colorize(:blue)

  pinmap = Hash(String, Array(String)).new { |h, k| h[k] = Array(String).new }

  # TODO: replace key with hanviet[key]?

  pinyins.data.each do |key, val|
    val.each { |v| pinmap[v] << key }
  end

  puts "- pinyinis count: #{pinmap.size.colorize(:blue)}"

  missing.each do |key|
    if val = pinyins.get_first(key)
      hvs = pinmap[val].compact_map { |x| out_hanviet.get(x) }.flatten.uniq
      next if hvs.empty?

      vals = hvs.tally.to_a.sort_by(&.[1].-).first(3).map(&.[0])
      out_hanviet.set(key, vals)
      missing.delete(key)
    else
      puts "-- NO PINYIN: #{key}".colorize(:red)
    end
  end

  puts "- still missing #{missing.size.colorize(:yellow)} chars."

  puts "- write results".colorize(:blue)

  out_hanviet.save!(keep: 4, sort: true)
  out_hantrad.save!(keep: 4, sort: true)

  out_file = "data/dic-tmp/hanmiss.txt"
  File.write out_file, missing.map { |x| "#{x}=#{pinyins.get(x)}" }.join("\n")
  puts "- saving [#{out_file.colorize(:green)}]... done, entries: #{missing.size.colorize(:green)}"
end

input = load_input("data/dic-inp/routine/cedict.txt")
hanzidb = Cvdict.load!("data/dic-inp/routine/hanzidb.txt")

cedict = export_cedict(input)
tradsim = export_tradsim(input, hanzidb)
extract_ondicts(cedict, tradsim)

pinyins = export_pinyins(input, hanzidb)
export_hanviet(tradsim, pinyins, hanzidb)
