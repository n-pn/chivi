require "../../src/cvmtl/*"

DIR = "var/vpdicts"

def remove_time(dname : String)
  vdict = CV::VpDict.load(dname)
  count = 0

  vdict.data.each do |term|
    next unless should_remove?(term)
    term._flag = 2
    count += 1
  end

  puts "- removed: #{count}"
  vdict.save!
end

def should_remove?(term)
  return false unless term.ptag.time?
  term.key =~ /^[零〇一二两三四五六七八九十百千万亿兆]+(点|点钟|分|分钟|秒|秒钟|半|点半)$/
end

remove_time("regular")
remove_time("suggest")
CV::VpDict.udicts.each do |udict|
  remove_time(udict)
end

CV::VpDict.regular.set!(CV::VpTerm.new("几十", ["mấy mươi"], "m", mtime: 0))
