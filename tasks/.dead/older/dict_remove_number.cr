require "../../src/mtlv1/*"

DIR = "var/vpdicts"

def remove_numbers(dname : String)
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
  return true if term.ptag.nhanzis?
  return true if term.ptag.ndigits?
  return true if term.key.starts_with?("百分之")

  return false unless term.ptag.number? || term.ptag.nqiffy?
  term.key =~ /[零〇一二两三四五六七八九十百千万亿兆多几余来]/
end

remove_numbers("regular")
remove_numbers("suggest")
CV::VpDict.udicts.each do |udict|
  remove_numbers(udict)
end

CV::VpDict.regular.set!(CV::VpTerm.new("几十", ["mấy mươi"], "m", mtime: 0))
