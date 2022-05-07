require "colorize"

MAP = {
  4, 6, 8,
  9, 13, 19,
  15, 20, 30,
  24, 33, 40,
}

def calc(size : Int32, rank = 1)
  MAP[(size &- 1) &* 3 &+ rank]? || size &* (MAP[rank] &+ 1)
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
assert_gt [{4, 2}], [{3, 2}, {1, 2}]

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
