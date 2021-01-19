require "file_utils"
require "../../src/engine/library"

def dlock_df(label)
  case label
  when "tradsim", "binh_am", "hanviet"
    3
  when "regular", "suggest", "various"
    2
  else
    1
  end
end

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

  File.each_line(file) do |line|
    next if line.empty?
    cols = line.split("ǁ")
    input[cols[0]] = cols
  end

  input.values.map { |cols| parse_term(cols, dlock) }.sort_by(&.mtime)
end

def migrate(file : String, unique = false)
  label = File.basename(file, ".log")

  if unique
    return if label == "_tonghop"
    dlock = 1
  else
    label = "regular" if label == "generic"
    dlock = dlock_df(label)
  end

  values = load_relic(file, dlock)

  out_file = CV::VpDict.file_path(label).sub("active", "remote")
  out_dict = CV::VpDict.new(out_file, dlock: dlock, preload: false)

  values.each do |term|
    out_dict.upsert(term)
    CV::VpDict.suggest.upsert(term) if unique && !term.empty?
  end

  out_dict.save!
end

Dir.glob("_db/dictdb/legacy/core/*.log").each { |x| migrate(x) }
Dir.glob("_db/dictdb/legacy/uniq/*.log").each { |x| migrate(x, unique: true) }
CV::VpDict.suggest.save!(mode: :best)

# pp parse_term("保安州ǁBảo An châuǁ319179ǁFenix12ǁ1".split('ǁ'))
