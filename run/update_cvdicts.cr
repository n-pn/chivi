require "sqlite3"
require "colorize"
require "../src/mtlv1/engine/mt_term"
require "../src/mtlv1/pos_tag"

INP = "var/dicts"
DIC = DB.open "sqlite3://./#{INP}/cvdicts.db"
at_exit { DIC.close }

def update_seg_weight
  terms = DIC.query_all <<-SQL, as: CV::CvTerm
    select * from terms
  SQL

  DIC.exec "begin transaction"
  terms.each do |term|
    weight = CV::CvTerm.seg_weight(term.key.size, term.seg_r)
    DIC.exec "update terms set seg_w = ? where id = ?", args: [weight, term.id]
  end

  DIC.exec "commit"
rescue err
  puts err
  # DIC.exec "rollback"
end

def update_pos_tag
  terms = DIC.query_all <<-SQL, as: CV::CvTerm
    select * from terms
  SQL

  DIC.exec "begin transaction"
  terms.each do |term|
    ptag = CV::PosTag.init(term.ptag, term.key, term.val, term.alt_val)

    args = [ptag.tag.to_i, ptag.pos.to_i64, term.id]

    DIC.exec <<-SQL, args: args
      update terms set etag = ?, epos = ? where id = ?
    SQL
  end

  DIC.exec "commit"
  # DIC.exec "rollback"
end

# update_seg_weight
update_pos_tag
