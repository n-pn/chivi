require "file_utils"
require "../../src/engine/vp_dict"

def parse_term(cols : Array(String), dlock = 1)
  key = cols[0]
  vals = (cols[1]? || "").split(/[\/¦]/)

  mtime = cols[2]?.try(&.to_i?) || 0

  uname = cols[3]? || "<init>"
  uname = "<init>" if uname == "Guest"

  CV::VpTerm.new(key, vals, plock: dlock).tap do |x|
    x.mtime = mtime
    x.uname = uname
  end
end

def load_relic(file : String, dlock : Int32)
  input = {} of String => Array(String)

  input.values.map { |cols| parse_term(cols, dlock) }.sort_by(&.mtime)
end

def migrate(file : String, uniq = false)
  puts file
  input = {} of String => Array(String)

  File.each_line(file) do |line|
    next if line.empty?
    cols = line.split("ǁ")

    input[cols[0]] = cols
  end

  dname = File.basename(file, ".log")
  return if dname == "_tonghop"
  dname = "regular" if dname == "generic"

  vdict = CV::VpDict.load(dname)

  input.each_value do |cols|
    key = cols[0]
    vals = cols.fetch(1, "").sub("", "").strip.split(/[\/¦\/]/).uniq

    entry = CV::VpEntry.new(key, vals)

    if mtime = cols[2]?.try(&.to_i?) || 0
      uname = cols[3]? || "Guest"
      uname = "_" if uname == "Guest"

      next if dname == "hanviet" && uname != "Nipin"

      power = cols[4]?.try(&.to_i?) || 4

      power = vdict.p_min if power > vdict.p_min
      emend = CV::VpEmend.new(mtime, uname, power)
    end

    vdict.add(entry, emend)

    next unless uniq
    CV::VpDict.suggest.add(entry, emend)

    next if vals.empty?
    next if vals[0].downcase == vals[0]
    next if CV::VpDict.regular.find(key)
    CV::VpDict.various.add(entry, emend)
  end

  vdict.save!
end

Dir.glob("_db/dictdb/legacy/core/*.log").each { |x| migrate(x) }
Dir.glob("_db/dictdb/legacy/uniq/*.log").each { |x| migrate(x, uniq: true) }

CV::VpDict.suggest.save!
CV::VpDict.various.save!
