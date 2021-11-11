require "../src/libcv/*"

def remove_dead_entries(dname : String, uniq = false)
  vdict = CV::VpDict.load(dname)
  count = 0

  vdict.data.each do |term|
    next unless should_delete?(term)
    term._flag = 2
    count += 1
  end

  puts "- count: #{count}"
  vdict.save!
end

TIME = (Time.utc(2021, 7, 1, 0, 0, 0).to_unix - CV::VpTerm::EPOCH) // 60

def should_delete?(term)
  return true if term.empty? || term._flag == 1
  return false unless term.is_priv
  term.mtime < TIME
end

remove_dead_entries("regular")
remove_dead_entries("suggest")
remove_dead_entries("combine")
CV::VpDict.udicts.each do |udict|
  remove_dead_entries(udict)
end
