require "../../src/_util/char_util"
require "../../src/mt_ai/data/mt_term"

INP_PATH = "var/mtdic/fixed/common-main.dic"

regular = [] of {String, String, String, Int32}
suggest = [] of {String, String, String, Int32}

DB.connect("sqlite3:#{INP_PATH}?immutable=1") do |db|
  db.query_each "select zstr, vstr, vmap, xpos, _flag from defns" do |rs|
    zstr, vstr, vmap, xpos, flag = rs.read(String, String, String, String, Int32)

    zstr = CharUtil.to_canon(zstr)
    vstr = "" if vstr == "⛶"

    xpos = "_" if xpos.includes?(' ')

    if flag > 1
      regular << {zstr, xpos, vstr, flag}
    else
      suggest << {zstr, xpos, vstr, flag}
    end

    next if vmap.empty?

    vmap.split('ǀ') do |item|
      ptag, vstr = item.split(':')
      regular << {zstr, ptag, vstr, flag}
    end
  end
end

regular.uniq! { |x| {x[0], x[1]} }
suggest.uniq! { |x| {x[0], x[1]} }

puts regular.size, suggest.size

regular_out = regular.map do |zstr, ptag, vstr, flag|
  term = AI::MtTerm.new(zstr, ptag)
  term.vstr = vstr
  term._flag = flag
  term
end

AI::MtTerm.db("base-main").open_tx do |db|
  regular_out.each(&.upsert!(db: db))
end

suggest_out = suggest.map do |zstr, ptag, vstr, flag|
  term = AI::MtTerm.new(zstr, ptag)
  term.vstr = vstr
  term._flag = flag
  term
end

AI::MtTerm.db("base-init").open_tx do |db|
  suggest_out.each(&.upsert!(db: db))
end
