require "../src/libcv/*"

def remove_dead_entries(dname : String, uniq = false)
  vdict = CV::VpDict.load(dname)
  count = 0
  vdict.data.each do |term|
    next unless term.empty? || term._flag == 1
    term._flag = 2
    count += 1
  end

  puts "- count: #{count}"
  vdict.save!
end

remove_dead_entries("regular")
remove_dead_entries("suggest")
remove_dead_entries("combine")
CV::VpDict.udicts.each do |udict|
  remove_dead_entries(udict)
end
