require "../../src/cvmtl/cv_data/*"

class Term
  getter key : String
  getter val : String = ""
  getter alt : String? = nil

  getter ptag : String
  getter wseg : Int32

  getter time : Int64
  getter user : String

  property _keep = true

  def initialize(args : Array(String))
    @key = args[0]
    return unless vals = args[1]?.try(&.split('ǀ'))

    @val = vals[0]
    @alt = vals[1]?

    @ptag = fix_ptag(args[2]?, vals.join('|'))
    @wseg = map_wseg(args[3]?)

    @time = args[4]?.try(&.to_i64) || 0_i64
    @user = args[5]? || ""
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

  def fix_ptag(pos : String?, line : String)
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

  def map_wseg(seg : String?)
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

  def changes(dic : Int32)
    fields = ["dic"]
    values = [] of DB::Any
    values << dic

    {% for ivar in @type.instance_vars %}
      {% if ivar.name.stringify != "_keep" %}
        fields << {{ ivar.name.stringify }}
        values << @{{ ivar.name.id }}
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

    @terms.sort_by!(&.time)

    @terms.group_by(&.key).each do |_key, group|
      next if group.size < 2
      # group.sort_by!(&.time)

      last = group.last
      time = last.time - TIME_FRAME

      (group.size - 2).downto(0) do |i|
        term = group[i]

        if term.time >= time
          term._keep = false
          dup += 1
        else
          last = term
          time = term.time - TIME_FRAME
        end
      end
    end

    puts "-<#{@file}> duplicate: #{dup}"
  end

  def save!(type : String)
    dict_id = get_dict_id(type)

    MT::DbRepo.open_db(type) do |db|
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
  end

  MAP_TYPE = {"core", "book", "pack", "user", "else"}

  def get_dict_id(type : String)
    name = File.basename(@file, File.extname(@file))

    MT::DbRepo.open_db(type) do |db|
      if dict_id = db.query_one?("select id from dicts where name = ?", name, as: Int32)
        return dict_id
      end

      query = "insert into dicts (name, type) values (?, ?)"
      res = db.exec(query, args: [name, MAP_TYPE.index(name) || 0])
      res.last_insert_id.to_i
    end
  end
end

def load_dict(file : String, type : String)
  dict = Dict.new(file)
  dict.remove_trash!
  dict.save!(type)
end

def load_files(dir_name : String, out_type : String)
  files = Dir.glob("var/dicts/v1/#{dir_name}/*")
  files.map!(&.sub(".tab", ".tsv")).uniq!

  files.each do |file|
    load_dict(file, out_type)
  end
end

DIR = "var/dicts/v1"

# Dict::MAP_TYPE.each do |type|
#   MT::DbRepo.init_dict_db!(type)
#   MT::DbRepo.init_term_db!(type)
# end

# load_dict("#{DIR}/basic/essence.tsv", "core")
# load_dict("#{DIR}/basic/fixture.tsv", "core")
# load_dict("#{DIR}/basic/regular.tsv", "core")

# load_files("cvmtl", "else")
load_files("novel", "book")
