require "../../src/engine/vp_dict"

test = Chivi::VpDict.new "test"

print "\nset abc to abc: ", test.upsert("abc", ["abc"])

print "\nput a to a: ", test.upsert("a", ["a"])
print "\nput b to b: ", test.upsert("b", ["b"])

print "\nset a to c: ", test.upsert("a", ["c"])

print "\nfind abc: ", test.find("abc")
print "\nfind ab: ", test.find("ab")

puts "\nscan abc: "
test.scan("abc".chars) { |x| puts x }

puts "\n size: #{test.size}"

# test.save!
