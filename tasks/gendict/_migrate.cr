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

def migrate(file : String)
  label = File.basename(file, ".log")

  label = "regular" if label == "generic"
  dlock = dlock_df(label)

  input = {} of String => Array(String)

  File.each_line(file) do |line|
    next if line.empty?
    cols = line.split("ǁ")
    input[cols[0]] = cols
  end

  out_file = Chivi::Library.file_path(label).sub("active", "remote")
  out_dict = Chivi::VpDict.new(out_file, dlock: dlock, preload: true)

  values = input.values.sort_by { |cols| cols[2]?.try(&.to_i?) || 0 }

  values.each do |cols|
    key = cols[0]
    vals = (cols[1]? || "").split(/[\/¦]/)

    mtime = cols[2]?.try(&.to_i?) || 0
    uname = cols[3]? || "<init>"
    uname = "<init>" if uname == "Guest"

    term = Chivi::VpTerm.new(key, vals, plock: dlock).tap do |x|
      x.mtime = mtime
      x.uname = uname
    end

    out_dict.upsert(term)
  end

  FileUtils.mkdir_p(File.dirname(out_dict.file))
  out_dict.save!
end

files = Dir.glob("_db/cvdict/legacy/**/*.log")
files.each { |file| migrate(file) }
