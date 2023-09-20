require "../src/mt_ai/data/vi_term"
require "../src/mt_ai/data/vi_term2"
require "../src/mt_ai/core/qt_core"

HV = Hash(String, String).new do |h, k|
  h[k] = MT::QtCore.tl_hvword(k)
end

DB.open("sqlite3:var/mtdic/vi_defns.db3?immutable=1") do |db|
  db.query_each("select zh, hv from terms") do |rs|
    HV[rs.read(String)] = rs.read(String)
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

POSS = {
  "AS",
  "BA",
  "CC",
  "CS",
  "DEC",
  "DEG",
  "DER",
  "DEV",
  "DT",
  "ETC",
  "IJ",
  "LB",
  "LC",
  "M",
  "MSP",
  "ON",
  "P",
  "PN",
  "PU",
  "SB",
  "SP",
  "VC",
  "VE",
}

def fix_plock(input : MT::ViTerm) : Int32
  return input.plock if input.plock < 1
  return input.cpos == "NR" ? 1 : 0 if input.vstr != input.vstr.downcase

  return 0 if input.vstr == HV[input.zstr]
  return 1 unless input.plock > 1

  POSS.includes?(input.cpos) ? 2 : 1
end

def transform(file : String)
  inputs = {} of {String, String} => MT::ViTerm

  DB.open("sqlite3:#{file}?immutable=1") do |db|
    db.query_each "select * from terms order by rowid asc" do |rs|
      term = rs.read(MT::ViTerm)
      inputs[{term.zstr, term.cpos}] = term
    end
  rescue ex
    puts ex
  end

  tsv_file = file.sub(".db3", ".tsv")

  if File.file?(tsv_file)
    File.each_line(tsv_file) do |line|
      next if line.blank?
      term = MT::ViTerm.new(line.split('\t'))
      inputs[{term.zstr, term.cpos}] = term
    end
  end

  puts [file, inputs.size]
  return File.delete(file) if inputs.size == 0

  outputs = inputs.each_value.compact_map do |input|
    vstr = fix_vstr(input.vstr, input.attr)
    next if vstr.empty?

    MT::ViTerm2.new(
      zstr: input.zstr,
      cpos: fix_cpos(input.cpos),
      vstr: vstr,
      attr: fix_attr(input.attr),
      uname: input.uname,
      mtime: input.mtime,
      plock: fix_plock(input)
    )
  end

  dname = file.sub(INP, "").sub(".db3", "")

  MT::ViTerm2.db(dname).open_tx do |db|
    outputs.each(&.upsert!(db: db))
  end
end

INP = "var/mtapp/mt_ai/"

Dir.glob("#{INP}*.db3").each { |file| transform(file) }
Dir.glob("#{INP}_old/*.db3").each { |file| transform(file) }
Dir.glob("#{INP}book/*.db3").each { |file| transform(file) }
