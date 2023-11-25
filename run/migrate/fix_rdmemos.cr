ENV["CV_ENV"] ||= "production"
require "../../src/rdapp/data/rdmemo"

memos = RD::Rdmemo.get_all

memos.each do |rmemo|
  next unless cinfo = rmemo.last_cinfo

  rmemo.lc_mtype = 1_i16
  rmemo.lc_ch_no = rmemo.last_ch_no

  rmemo.lc_title = cinfo.title
  rmemo.lc_p_idx = cinfo.p_idx.to_i16

  rmemo.rmode = cinfo.rmode
  rmemo.qt_rm = cinfo.qt_rm
  rmemo.mt_rm = cinfo.mt_rm
end

PGDB.transaction do |tx|
  memos.each(&.upsert!(db: tx.connection))
end
