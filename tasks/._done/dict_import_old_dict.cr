require "../../src/cvmtl/*"

DIR = "_db/vpdict/logs"

def import_old(dname : String, uniq = false)
  vdict = CV::VpDict.load(dname)

  ofile = "#{dname}.appcv.tsv"
  odict = CV::VpDict.new(uniq ? "#{DIR}/books/#{ofile}" : "#{DIR}/#{ofile}")
  count = 0

  odict.data.each do |oterm|
    next unless nterm = vdict.find(oterm.key)
    next if nterm.mtime >= oterm.mtime
    next if similar?(oterm, nterm)
    vdict.set(oterm)
    nterm._flag = 2
    count += 1
  end

  puts "- replaced: #{count}"
  vdict.save!
end

def similar?(oterm, nterm)
  return false if oterm.rank != nterm.rank
  return false if oterm.ptag != nterm.ptag
  oterm.val == nterm.val
end

import_old("regular")
import_old("suggest")
CV::VpDict.udicts.each do |udict|
  import_old(udict)
end

CV::VpDict.regular.set!(CV::VpTerm.new("几十", ["mấy mươi"], "m", mtime: 0_u32))
