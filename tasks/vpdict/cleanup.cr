require "../../src/cvmtl/*"

DIR = File.join(__DIR__, "_fixes")

DELETE = Set(String).new File.read_lines("#{DIR}/delete.txt")

def cleanup(dname : String, type = "basic")
  vdict = CV::VpDict.load(dname)
  count = 0

  vdict.data.each do |term|
    next unless should_delete?(term, type)
    term._flag = 2
    count += 1
  end

  return if count == 0
  puts "- count: #{count}"
  vdict.save!
end

def should_delete?(term, type)
  return true if term.empty? || term._flag == 1
  DELETE.includes?(term.key)
end

cleanup("regular")
cleanup("suggest")
cleanup("combine")

CV::VpDict.novels.each { |bdict| cleanup(bdict, "novel") }
