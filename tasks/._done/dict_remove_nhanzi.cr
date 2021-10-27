require "../src/libcv/*"

DIR = "var/vpdicts"

def remove_nhanzi(dname : String)
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
  return true if term.ptag.nhanzi?
  return true if term.key.starts_with?("百分之")
  false
end

remove_nhanzi("regular")
remove_nhanzi("suggest")
CV::VpDict.udicts.each do |udict|
  remove_nhanzi(udict)
end
