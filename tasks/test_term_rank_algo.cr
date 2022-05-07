require "colorize"

BONUS = {
  -2, 0, 7,
  -4, 0, 16,
  -6, 0, 24,
  -8, 0, 32,
}

def calc(size : Int32, rank = 1)
  base = size &* 8 &+ (size &- 1) &* 6
  base &+ BONUS[3 &* (size > 4 ? 3 : size &- 1) &+ rank]
end

alias List = Array(Tuple(Int32, Int32))

def calc(input : List)
  input.sum { |size, rank| calc(size, rank) }
end

def serialize(rank : Int32)
  {"_", "~", "*"}[rank]
end

def serialize(list : List)
  list.map { |size, rank| serialize(rank) * size }.join(" ")
end

def assert_gt(lhs : List, rhs : List)
  raise "size not equal!" if lhs.sum(&.first) != rhs.sum(&.first)

  color = calc(lhs) > calc(rhs) ? :green : :red
  puts "[#{serialize(lhs)}] (#{calc(lhs)}) \t>\t [#{serialize(rhs)}] (#{calc(rhs)})".colorize(color)
end

assert_gt [{2, 1}], [{1, 1}, {1, 1}]
assert_gt [{3, 1}], [{1, 1}, {1, 1}, {1, 1}]
puts

assert_gt [{3, 1}], [{2, 1}, {1, 1}]
assert_gt [{3, 2}], [{2, 2}, {1, 2}]
puts

assert_gt [{1, 2}], [{1, 1}]
assert_gt [{2, 2}], [{2, 1}]
assert_gt [{2, 2}], [{1, 2}, {1, 2}]
puts

assert_gt [{2, 2}, {1, 1}], [{1, 2}, {1, 2}, {1, 2}]
assert_gt [{3, 2}, {1, 1}], [{4, 1}]
assert_gt [{4, 2}], [{2, 2}, {2, 1}]
puts

assert_gt [{4, 0}], [{2, 0}, {2, 1}]
assert_gt [{4, 0}], [{3, 0}, {1, 2}]
assert_gt [{4, 1}], [{3, 1}, {1, 2}]
puts

assert_gt [{2, 1}, {2, 1}], [{4, 0}]
assert_gt [{3, 1}, {1, 1}], [{4, 0}]
puts

assert_gt [{4, 2}], [{2, 2}, {2, 2}]
assert_gt [{3, 1}], [{2, 1}, {1, 1}]
assert_gt [{2, 2}, {1, 1}], [{3, 1}]
puts

assert_gt [{4, 1}], [{2, 2}, {2, 1}]
puts

assert_gt [{2, 1}, {2, 1}], [{3, 0}, {1, 1}]
assert_gt [{2, 1}, {2, 0}], [{3, 0}, {1, 1}]
puts

assert_gt [{1, 2}, {1, 1}], [{2, 1}]
puts
