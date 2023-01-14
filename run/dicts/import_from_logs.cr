require "../../src/mt_v2/cv_data/*"

DICTS = {} of String => MT::CvDict?

def get_dict(dname : String)
  DICTS[dname] ||= begin
    case dname
    when "generic", "fixture", "essense" then MT::CvDict.get!(1)
    when .starts_with?('-')              then MT::CvDict.find(dname)
    else                                      nil
    end
  end
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

  "nn" => "Ns",
  "nr" => "Nr",
  "nx" => "Nz",
  "nw" => "Nz",

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
  "nj" => "nl",
  "np" => "nl",
  "vp" => "vl",
  "nv" => "no",
  "nc" => "nc",
  "nf" => "s",
  "ns" => "s",
  "nt" => "t",

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

def fix_ptag(pos : String?)
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
  else                             pos
  end
end

def map_wseg(seg : String?)
  case seg
  when "^" then 3
  when "v" then 1
  when "x" then 0
  else          2
  end
end

EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

def init_term(dict : MT::CvDict, args : Array(String))
  term = MT::CvTerm.new

  term.dic = dict.id < 0 ? -dict.id : dict.id
  term.key = args[2]

  vals = args[3].split('ǀ')
  term.val = vals[0]
  term.alt = vals[1]?.try { |x| x unless x.empty? }

  term.ptag = fix_ptag(args[4].split(' ').first)
  term.wseg = map_wseg(args[5])

  term.user = args[6]? || ""
  term.time = (args[0].to_i - EPOCH) // 60

  mode = args[7]?.try(&.to_i) || 0
  return term if mode < 1

  term.dic = -term.dic
  term.flag = -1 if mode == 2

  term
end

BOOK_DIC = DB.open("sqlite3://var/dicts/book.dic")
CORE_DIC = DB.open("sqlite3://var/dicts/core.dic")
at_exit { BOOK_DIC.close; CORE_DIC.close }

def find_term(db : DB::Database, term : MT::CvTerm)
  query = "select * from terms where dic = ? and key = ? and time >= ? and user = ? limit 1"
  args = [term.dic, term.key, term.time - 5, term.user]
  db.query_one? query, args: args, as: MT::CvTerm
end

def apply_log(file : String)
  File.each_line(file) do |line|
    args = line.split('\t')
    next unless dict = get_dict(args[1])

    term = init_term(dict, args)
    db = dict.id < 0 ? BOOK_DIC : CORE_DIC

    if existed = find_term(db, term)
      if existed.time > term.time
        puts "#{line} existed".colorize.light_gray
        next
      end

      id = existed.id
      puts "overwrite: #{id}".colorize.yellow
    end

    # puts dict.label, args
    term.save!(db, id)
  end
end

BOOK_DIC.exec "begin transaction"
CORE_DIC.exec "begin transaction"

files = Dir.glob("var/dicts/ulogs/*.log").sort!

files.select! do |file|
  name = File.basename(file, ".log")
  date = Time.parse(name, "%F", Time::Location.local)
  date >= Time.utc(2022, 10, 19)
end

files.each do |file|
  puts file
  apply_log(file)
end

BOOK_DIC.exec "commit"
CORE_DIC.exec "commit"
