ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"
require "../../src/mt_ai/core/qt_core"

class OldViTerm
  include DB::Serializable

  getter zstr : String
  getter cpos : String

  getter vstr : String = ""
  getter attr : String = ""

  getter uname : String = ""
  getter mtime : Int32 = 0
  getter plock : Int32 = 0

  def initialize(cols : Array(String))
    @zstr = cols[0]
    @cpos = cols[1]
    @vstr = cols[2]? || ""
    @attr = cols[3]? || ""
    @uname = cols[4]? || ""
    @mtime = cols[5]?.try(&.to_i) || 0
    @plock = cols[6]?.try(&.to_i) || 1
  end
end

def fix_cpos(cpos)
  MT::MtEpos.parse?(cpos) ? cpos.strip : "X"
end

def fix_vstr(vstr, attr)
  vstr.empty? && attr.includes?("Hide") ? "⛶" : vstr
end

def fix_attr(attr)
  attr.gsub(/None|Npos/, "").strip
end

def merge_to_db(file : String)
  inputs = {} of {String, String} => OldViTerm

  File.each_line(file) do |line|
    cols = line.split('\t')
    next if cols.size < 2

    term = OldViTerm.new(cols)
    inputs[{term.zstr, term.cpos}] = term
  end

  puts [file, inputs.size]

  outputs = inputs.each_value.compact_map do |input|
    next if input.vstr.empty?

    MT::ViTerm.new(
      zstr: input.zstr,
      cpos: input.cpos,
      vstr: input.vstr,
      attr: input.attr,
      uname: input.uname,
      mtime: input.mtime,
      plock: input.plock
    )
  end

  dname = file.sub(INP, "").sub(".tsv", "")

  MT::ViTerm.db(dname).open_tx do |db|
    outputs.each(&.upsert!(db: db))
  end
end

INP = "/2tb/app.chivi/var/mt_db/mt_ai/"
# merge_to_db "#{INP}regular.tsv"

# Dir.glob("#{INP}*.tsv").each { |file| merge_to_db(file) }
# Dir.glob("#{INP}_old/*.tsv").each { |file| merge_to_db(file) }
Dir.glob("#{INP}wn/*.tsv").each { |file| merge_to_db(file) }
