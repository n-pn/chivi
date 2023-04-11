require "../../src/mtapp/mt_core/mt_defn"
require "../../src/mtapp/shared/*"
require "../../src/_util/char_util"

def update_dic(dic : DB::Database, data : Array({String, String, String, Int32}))
  puts "updating: #{data.size}"

  DIC.exec "begin"

  stmt = "update defns set vstr = $1, uname = $2, _flag = $3 where zstr = $4"

  data.each do |zstr, vstr, uname, _flag|
    DIC.exec stmt, vstr, uname, _flag, zstr
  end

  DIC.exec "commit"
end

def normalize(key : String)
  String.build do |io|
    key.each_char do |char|
      if (char.ord & 0xff00) == 0xff00
        io << (char.ord - 0xfee0).chr.downcase
      elsif punct = CharUtil::NORMALIZE[char]?
        io << punct
      else
        io << char.downcase
      end
    end
  end
end

def fill_none_word(dic = DIC)
  data = [] of {String, String, Int32}

  dic.query_each "select zstr, xpos from defns" do |rs|
    zstr, xpos = rs.read(String, String)
    next if zstr =~ /\p{Han}/

    vstr = normalize(zstr)
    _fmt = xpos == "PU" ? MT::FmtFlag.detect(vstr).value.to_i : 0

    data << {zstr, vstr, _fmt}
  end

  puts "updating: #{data.size}"

  DIC.exec "begin"

  stmt = "update defns set vstr = $1, _fmt = $2, uname = '!zh', _flag = 5 where zstr = $3"

  data.each do |zstr, vstr, _fmt|
    DIC.exec stmt, vstr, _fmt, zstr
  end

  DIC.exec "commit"
end

def fill_values
  mains = {} of String => String
  bings = {} of String => String
  prevs = {} of String => String

  DB.open("sqlite3:var/dicts/v1raw/v1_defns.dic") do |db|
    sql = <<-SQL
  select key, val from defns
  where dic > -4 and val <> '' and _flag >= 0
  order by dic asc, tab asc, id desc
  SQL

    db.query_each sql do |rs|
      zstr, vstr = rs.read(String, String)
      mains[normalize(zstr)] ||= vstr.split('ǀ').first.strip
    end
  end

  DB.open("sqlite3:var/dicts/defns/all_terms.dic") do |db|
    db.query_each "select zh, bi from terms where bi <> ''" do |rs|
      zstr, vstr = rs.read(String, String)
      bings[normalize(zstr)] ||= vstr.strip
    end
  end

  output = [] of {String, String, String}
  DIC.query_each "select zstr, xpos from defns where uname != '!zh'" do |rs|
    zstr, xpos = rs.read(String, String)

    nstr = normalize(zstr)

    if from_cv = mains[nstr]?
      output << {zstr, from_cv, "[cv]"}
    elsif from_bi = bings[nstr]?
      output << {zstr, from_bi, "[bi]"}
    elsif zstr !~ /\p{Han}/
      puts zstr
    end
  end
end

# File.each_line("var/inits/vietphrase/combine-propers.tsv") do |line|
#   key, val = line.split('\t', 2)
#   prevs[key] = val.gsub('\t', 'ǀ')
# end

DIC = DB.open("sqlite3:#{MT::MtDefn.db_path("base")}")
at_exit { DIC.close }

fill_none_word(DIC)
