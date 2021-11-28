require "../src/cvmtl/*"

DIR = "var/vpdicts/_fix"

DELETE = Set(String).new File.read_lines("#{DIR}/delete.txt")

def cleanup(dname : String, uniq = false)
  vdict = CV::VpDict.load(dname)
  count = 0

  vdict.data.each do |term|
    next unless should_delete?(term, uniq)
    term._flag = 2
    count += 1
  end

  puts "- count: #{count}"
  vdict.save!
end

def should_delete?(term, uniq)
  return true if term.empty? || term._flag == 1
  DELETE.includes?(term.key)
end

cleanup("regular")
cleanup("suggest")
cleanup("combine")
CV::VpDict.udicts.each do |udict|
  cleanup(udict)
end
