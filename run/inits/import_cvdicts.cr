require "sqlite3"
require "../src/cvmtl/vp_dict/vp_term"

INP = "var/dicts"
DIC = DB.open "sqlite3://./#{INP}/cvdicts.db"

def get_dict_id(file : String)
  dname = File.basename(file, File.extname(file))
  dtype, prefix = map_dtype(File.basename(File.dirname(file)))

  dname = prefix + dname

  DIC.query_one?("select id from dicts where dname = ?", dname, as: Int32) || begin
    fields = "dname, dtype, label"
    values = [dname, dtype, dname]
    holder = values.map { "?" }.join(", ")

    res = DIC.exec("insert into dicts (#{fields}) values (#{holder})", args: values)
    res.last_insert_id
  end
end

def map_dtype(label : String)
  case label
  when "theme" then {10, "!"}
  when "novel" then {20, "-"}
  when "cvmtl" then {30, "~"}
  when "other" then {40, "$"}
  else              {0, ""}
  end
end

def load_terms(file : String, terms = [] of CV::VpTerm)
  return terms unless File.exists?(file)
  puts file

  File.each_line(file) do |line|
    args = line.split('\t')
    terms << CV::VpTerm.new(args) unless args.empty?
  end

  terms
end

def load_file(file : String)
  dict_id = get_dict_id(file)

  terms = load_terms(file)
  terms = load_terms(file.sub(".tsv", ".tab"), terms)

  dup = 0

  terms.group_by(&.key).each do |_key, group|
    next if group.size < 2

    group.sort_by!(&.mtime)

    last = group.last
    mtime = last.mtime - 10

    (group.size - 2).downto(0) do |i|
      term = group[i]

      if term.mtime >= mtime
        term._flag = 1
        dup += 1
      else
        last = term
        mtime = term.mtime - 10
      end
    end
  end

  puts "duplicate: #{dup}"

  DIC.exec "begin transaction"
  terms.each do |term|
    next if term._flag > 0

    input = {} of String => DB::Any

    input["dict_id"] = dict_id
    input["key"] = term.key
    input["val"] = term.vals[0]
    input["alt_val"] = term.vals[1]?

    input["ptag"] = term.tags[0]

    input["seg_r"] = term.prio.to_i
    input["seg_w"] = 0

    input["uname"] = term.uname
    input["mtime"] = term.mtime

    fields = input.keys.join(", ")
    values = input.keys.map { "?" }.join(", ")

    DIC.exec <<-SQL, args: input.values
      replace into terms (#{fields}) values (#{values})
    SQL
  end

  DIC.exec "commit"
  puts "Total: #{DIC.scalar "select count(*) from terms"}"
end

def load_files(dir)
  files = Dir.glob("#{INP}/v1/#{dir}/*")
  files.map!(&.sub(".tab", ".tsv")).uniq!

  files.each do |file|
    load_file(file)
  end
end

load_files("basic")
load_files("cvmtl")
load_files("novel")

DIC.close
