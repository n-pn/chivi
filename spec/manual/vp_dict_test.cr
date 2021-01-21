require "../../src/engine/vp_dict"

test = CV::VpDict.new "test"

print "\nset abc to abc: ", test.upsert(["abc", "abc"])

print "\nput a to a: ", test.upsert(["a", "a"])
print "\nput b to b: ", test.upsert(["b", "b"])

print "\nset a to c: ", test.upsert(["a", "c"])

print "\nfind abc: ", test.find("abc")
print "\nfind ab: ", test.find("ab")

puts "\nscan abc: "
test.scan("abc".chars) { |x| puts x }

puts "\n size: #{test.items.size}"

# test.save!

regular = CV::VpDict.regular
puts regular.dtype
if entry = regular.find("码")
  pp entry, entry.worth
end

special = CV::VpDict.load("7c4khz40")
puts special.dtype
if entry = special.find("码")
  pp entry, entry.worth
end
