ENV["CV_ENV"] ||= "production"

require "../../src/_data/member/ubmemo"
require "../../src/rdapp/data/rdmemo"

inputs = CV::Ubmemo.query.to_a
puts "input: #{inputs.size}"

exists = RD::Rdmemo.get_all(&.<< "where sname = 'wn~avail'")
mapper = exists.to_h { |memo| {"#{memo.vu_id}/#{memo.sn_id}", memo} }

tosave = inputs.map do |ubmemo|
  output = mapper["#{ubmemo.viuser_id}/#{ubmemo.nvinfo_id}"]? || begin
    RD::Rdmemo.new(ubmemo.viuser_id, "wn~avail", ubmemo.nvinfo_id.to_s)
  end

  output.rd_state = ubmemo.status.to_i16
  output.atime = {output.atime, ubmemo.atime}.max

  if output.lc_ch_no < 1 && ubmemo.lr_chidx > 0
    output.lc_ch_no = ubmemo.lr_chidx
    output.lc_p_idx = ubmemo.lr_cpart
    output.lc_title = ubmemo.lc_title
    output.rtime = ubmemo.utime
    output.lc_mtype = ubmemo.locked ? 2_i16 : 1_i16
  end

  output
end

PGDB.transaction do |tx|
  tosave.each(&.upsert!(db: tx.connection))
end
