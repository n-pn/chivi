require "../../src/library/base_dict"

test = Libcv::BaseDict.new "spec/fixtures/test.txt"

print "\nset abc to abc: ", test.set("abc", "abc")

print "\nput a to a: ", test.put("a", "a")
print "\nput b to b: ", test.set("b", "b")

print "\nset a to c: ", test.set("a", "c")

print "\nfind abc: ", test.find("abc")
print "\nfind ab: ", test.find("ab")

print "\nscan abc: ", test.scan("abc").map { |x| "[#{x}]" }.join(" ")
print "\nscan ab: ", test.scan("ab".chars).map { |x| "[#{x}]" }.join(" ")

print "\ndel b: ", test.del "b"

puts "\n size: #{test.size}"

pp test.to_a

# test.save!
