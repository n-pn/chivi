require "../../src/mt_ai/data/mt_defn"

# MT::MtDefn.db("hv_name").open_tx do |db|
#   db.exec "attach 'var/mtdic/mt_ai/.fix/hv_name.dic' as inp"

#   db.exec <<-SQL
#     replace into defns(zstr, cpos, vstr, pecs, uname, mtime, icpos, ipecs, _flag)
#     select zstr, '_' as cpos, vstr, '' as pecs, uname, mtime, 0 as icpos, _fmt as ipecs, _flag
#     from inp.defns
#   SQL
# end

MT::MtDefn.db("hv_word").open_tx do |db|
  db.exec "attach 'var/mtdic/mt_ai/.fix/sino_vi.dic' as inp"

  db.exec <<-SQL
    replace into defns(zstr, cpos, vstr, pecs, uname, mtime, icpos, ipecs, _flag)
    select zstr, '_' as cpos, vstr, '' as pecs, uname, mtime, 0 as icpos, _fmt as ipecs, _flag
    from inp.defns
  SQL
end

MT::MtDefn.db("pin_yin").open_tx do |db|
  db.exec "attach 'var/mtdic/mt_ai/.fix/pin_yin.dic' as inp"

  db.exec <<-SQL
    replace into defns(zstr, cpos, vstr, pecs, uname, mtime, icpos, ipecs, _flag)
    select zstr, '_' as cpos, vstr, '' as pecs, uname, mtime, 0 as icpos, _fmt as ipecs, _flag
    from inp.defns
  SQL
end
