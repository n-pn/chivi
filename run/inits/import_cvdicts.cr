require "sqlite3"
require "../../src/cvmtl/cvdict/*"

INP      = "var/dicts"
DIC_FILE = "#{INP}/cv_full.db"
MT::CvRepo.init!(DIC_FILE) unless File.exists?(DIC_FILE)
DIC = DB.open "sqlite3://./#{DIC_FILE}"

class Term
  getter key : String
  getter val : String = ""
  getter alt : String? = nil

  getter pos : String
  getter seg : Int32

  getter uname : String
  getter mtime : Int64

  property _keep = true

  def initialize(args : Array(String))
    @key = args[0]
    return unless vals = args[1]?.try(&.split('ǀ'))

    @val = vals[0]
    @alt = vals[1]?

    @pos = fix_pos(args[2]?, vals.join('|'))
    @seg = map_seg(args[3]?)

    @mtime = args[4]?.try(&.to_i64) || 0_i64
    @uname = args[5]? || ""
  end

  NEW_POS = {
    # literal
    "-"  => "l",
    "_"  => "l",
    "xt" => "lt",
    "xq" => "lq",
    # phrases
    "~dp" => "+dp",
    "~sa" => "+sa",
    "~sv" => "+sv",
    "~pp" => "+pp",
    "~na" => "+sa",
    "~pn" => "+pp",
    "~ap" => "al",
    "~vp" => "vl",
    "~np" => "nl",
    "dp"  => "d",
    # proper nouns
    "Nl"  => "Nb",
    "Nal" => "Ns",
    "Nag" => "Nt",
    "Na"  => "Nt",
    "Nr"  => "Nr",
    "Nrf" => "Nr",
    "nz"  => "Nz",
    "ns"  => "Ns",
    "nn"  => "Ns",
    "nr"  => "Nr",
    "nx"  => "Nz",
    "nw"  => "Nz",

    # unique
    "[\"vi\"]" => "vi",
    "[\"Nr\"]" => "Nr",
    "ahao"     => "!",
    "false"    => "",
    # sounds
    "e"  => "y",
    "o"  => "y",
    "y"  => "y",
    "xe" => "y",
    "xo" => "y",
    "xy" => "y",
    "xc" => "y",
    # special verbs
    "vyou" => "v!",
    "vshi" => "v!",
    "vf"   => "v!",
    "vm"   => "v!",
    "vx"   => "v!",
    "vc"   => "v!",
    # other
    "cc" => "c",
    "i"  => "li",
    "il" => "li",
    # special adjts
    "b"  => "a!",
    "bg" => "a!",
    "bl" => "a!",
    "ab" => "a!",

    # noun
    "nf" => "s",
    "nt" => "t",
    "nj" => "nl",
    "np" => "nl",
    "vp" => "vl",
    "nv" => "no",
    "nc" => "nc",
    # string
    "xx"  => "x",
    "xl"  => "x",
    "qx"  => "~q",
    "mqx" => "~m",
    "h"   => "!",
    "dbu" => "!",
  }

  SAME_POS = {
    "a", "v", "n", "vi", "c", "d", "m", "q", "u", "x", "w",
    "Nz", "Nr", "!", "nh", "vo", "Nw", "Nz", "na", "nl", "al",
    "mq", "vl", "az", "no",
  }

  def fix_pos(pos : String?, line : String)
    return "" unless pos && pos != ""
    NEW_POS[pos]?.try { |x| return x }

    case pos
    when "vd", "vn", "ad", "an" then "~" + pos
    when .ends_with?('g')       then pos.tr("g", "")
    when .starts_with?('u')     then "u"
    when .starts_with?('p')     then "p"
    when .starts_with?('k')     then "k"
    when .starts_with?('r')     then "r"
    when .starts_with?('q')     then "q"
    else
      puts "unknown_tag : #{pos} [#{line}]" unless SAME_POS.includes?(pos)
      pos
    end
  end

  def map_seg(seg : String?)
    case seg
    when nil then 2
    when ""  then 2
    when "^" then 3
    when "v" then 1
    when "x" then 0
    when "4" then 3
    when "2" then 1
    when "1" then 1
    else
      Log.warn { "unknown seg #{seg}" }
      2
    end
  end

  def changes(dict_id : Int32)
    fields = ["dict_id"]
    values = [] of DB::Any
    values << dict_id

    {% for ivar in @type.instance_variables %}
      {% if ivar.name.stringify != "_keep" %}
        fields << {% ivar.name.stringify %}
        values << @{% ivar.name.id %}
      {% end %}
    {% end %}

    {fields, values}
  end
end

class Dict
  @terms = [] of Term

  def initialize(@file : String)
    load_data(file)
  end

  def load_data(file_1 : String, file_2 = file_1.sub(".tsv", ".tab"))
    {file_1, file_2}.each do |file|
      next unless File.exists?(file)
      File.each_line(file) do |line|
        @terms << Term.new(line.split('\t')) unless line.empty?
      end
    end
  end

  TIME_FRAME = 60 * 24 # 60 minutes x 24 hours

  def remove_trash!
    dup = 0

    @terms.sort_by!(&.mtime)

    @terms.group_by(&.key).each do |_key, group|
      next if group.size < 2
      # group.sort_by!(&.mtime)

      last = group.last
      mtime = last.mtime - TIME_FRAME

      (group.size - 2).downto(0) do |i|
        term = group[i]

        if term.mtime >= mtime
          term._keep = false
          dup += 1
        else
          last = term
          mtime = term.mtime - TIME_FRAME
        end
      end
    end

    puts "-<#{@file}> duplicate: #{dup}"
  end

  def save!(db : DB::Connection, dict_id : Int32)
    db.exec "begin transaction"

    @terms.each do |term|
      next unless term._keep

      fields, values = term.changes(dict_id)
      holder = Array.new(fields.size, "?").join(", ")

      db.exec <<-SQL, args: values
        replace into terms (#{fields.join(", ")}) values (#{holder})
      SQL
    end

    db.exec "commit"
    puts "Total: #{db.scalar "select count(*) from terms"}"
  end

  def get_dict_id(db : DB::Connection)
    dtype, prefix = map_dtype(File.basename(File.dirname(@file)))
    dname = prefix + File.basename(@file, File.extname(@file))

    db.query_one?("select id from dicts where dname = ?", dname, as: Int32) || begin
      res = db.exec("insert into dicts (dname, dtype) values (?, ?)", args: [dname, dtype])
      res.last_insert_id
    end
  end

  def map_dtype(label : String)
    case label
    when "theme" then {1, "!"}
    when "novel" then {2, "-"}
    when "cvmtl" then {3, "~"}
    when "other" then {4, "$"}
    else              {0, ""}
    end
  end
end

def load_dict(file : String)
  dict = Dict.new(file)
  dict.remove_trash!

  # dict_id = get_dict_id(file)
end

def load_files(dir)
  files = Dir.glob("#{INP}/v1/#{dir}/*")
  files.map!(&.sub(".tab", ".tsv")).uniq!

  files.each do |file|
    load_dict(file)
  end
end

load_files("basic")
# load_files("cvmtl")
# load_files("novel")

DIC.close
