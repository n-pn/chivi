require "colorize"

MAP = {
  3, 6, 8,
  13, 16, 22,
  18, 27, 35,
  34, 40, 50,
  50, 60, 75,
}

def calc(size : Int32, rank = 1)
  MAP[(size &- 1) &* 3 &+ rank]? || size &* (rank &+ 6) &* 2
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

assert_gt [{2, 0}], [{1, 1}, {1, 1}]
puts

assert_gt [{2, 1}], [{1, 1}, {1, 1}]
assert_gt [{3, 1}], [{1, 1}, {1, 1}, {1, 1}]
puts

assert_gt [{3, 1}], [{2, 1}, {1, 1}]
assert_gt [{3, 2}], [{2, 2}, {1, 2}]
assert_gt [{3, 0}], [{2, 1}, {1, 1}]
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
assert_gt [{4, 0}], [{2, 1}, {2, 1}]
assert_gt [{4, 0}], [{3, 1}, {1, 1}]
assert_gt [{3, 2}, {1, 1}], [{4, 0}]
assert_gt [{2, 2}, {2, 1}], [{4, 0}]

assert_gt [{4, 1}], [{3, 1}, {1, 2}]
assert_gt [{4, 1}], [{2, 1}, {2, 2}]
puts

assert_gt [{4, 2}], [{2, 2}, {2, 2}]
assert_gt [{4, 2}], [{3, 2}, {1, 2}]

assert_gt [{3, 1}], [{2, 1}, {1, 1}]
assert_gt [{2, 2}, {1, 1}], [{3, 1}]
puts

assert_gt [{4, 1}], [{2, 2}, {2, 1}]
assert_gt [{3, 1}, {1, 1}], [{2, 1}, {2, 1}]
assert_gt [{2, 1}, {2, 1}], [{3, 0}, {1, 1}]
assert_gt [{4, 1}, {1, 1}], [{3, 1}, {2, 1}]
assert_gt [{3, 1}, {2, 1}], [{4, 0}, {1, 1}]
puts

assert_gt [{2, 1}, {2, 1}], [{3, 0}, {1, 1}]
assert_gt [{2, 1}, {2, 0}], [{3, 0}, {1, 1}]
puts

assert_gt [{2, 1}], [{1, 2}, {1, 1}]
assert_gt [{1, 2}, {1, 1}], [{2, 0}]
puts

assert_gt [{5, 2}], [{3, 2}, {2, 2}]
assert_gt [{5, 2}], [{4, 2}, {1, 2}]
assert_gt [{5, 1}], [{4, 1}, {1, 2}]
assert_gt [{5, 1}], [{3, 1}, {2, 2}]
assert_gt [{5, 0}], [{3, 1}, {2, 2}]

assert_gt [{6, 0}], [{3, 2}, {3, 2}]
# assert_gt [{4, 2}, {2, 2}], [{6, 0}]
assert_gt [{6, 0}], [{4, 2}, {2, 1}]
assert_gt [{5, 2}, {1, 2}], [{6, 0}]
