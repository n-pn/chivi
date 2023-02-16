# require "../v1_defn"
# require "../v1_dict"
# require "../../vp_dict/vp_term"

# def load_file(dict_path : String, dic : Int32, res : Array(M1::DbDefn))
#   puts dict_path

#   File.each_line(dict_path) do |line|
#     next if line.blank?

#     term = CV::VpTerm.new(line.split('\t'), 1)
#     defn = M1::DbDefn.new

#     defn.dic = dic
#     defn.tab = term._mode + 1

#     defn.key = term.key
#     defn.val = term.vals.join(CV::VpTerm::SPLIT)

#     defn.ptag = term.tags.join(' ')
#     defn.prio = term.prio.to_i

#     defn.mtime = term.mtime
#     defn.uname = term.uname

#     res << defn
#   end

#   res
# end

# def load_name(dname : String, scope : String, dic = 1)
#   tsv_file = "var/dicts/v1/#{scope}/#{dname}.tsv"
#   tab_file = "var/dicts/v1/#{scope}/#{dname}.tab"

#   res = [] of M1::DbDefn

#   load_file(tsv_file, dic: dic, res: res) if File.file?(tsv_file)
#   load_file(tab_file, dic: dic, res: res) if File.file?(tab_file)

#   res = res.uniq! { |x| {x.mtime, x.uname, x.key} }.sort_by!(&.mtime)

#   (res.size - 1).downto(0) do |idx|
#     newer = res[idx]
#     next if newer._flag < 0

#     newer._flag = 0
#     newer._prev = 0

#     (idx - 1).downto(0) do |new_idx|
#       older = res[new_idx]
#       next if newer.uname != older.uname || newer.key != older.key

#       older._flag = newer.mtime < older.mtime + 10 ? -2 : -1
#     end
#   end

#   res.reject!(&._flag.< -1).tap { |x| puts x.size }
# end

# def load_dict(dname : String, scope : String) : Nil
#   dic = M1::DbDict.get_id(scope == "novel" ? "-#{dname}" : dname)
#   return puts "#{dname} not found!" if dic == 0
#   DEFNS.concat load_name(dname, scope, dic: dic)
# end

# DEFNS = [] of M1::DbDefn

# basics = {"essence", "fixture", "regular", "combine"}
# others = {"hanviet", "pin_yin", "surname"}
# cvmtls = {"fix_nouns", "fix_verbs", "fix_adjts", "fix_advbs", "fix_u_zhi", "qt_nouns", "qt_verbs", "qt_times", "v_dircom", "v_rescom", "v_ditran", "verb_obj"}

# basics.each { |dname| load_dict(dname, "basic") }
# others.each { |dname| load_dict(dname, "other") }
# cvmtls.each { |dname| load_dict(dname, "cvmtl") }

# books = Dir.children("var/dicts/v1/novel").map!(&.split('.', 2).first).uniq!
# books.each { |dname| load_dict(dname, "novel") }

# puts DEFNS.size
# DEFNS.sort_by! { |x| {x.mtime, x.key, x.dic.abs, x.tab} }

# M1::DbDefn.repo.open_tx do |db|
#   DEFNS.each(&.save!(db))
# end
