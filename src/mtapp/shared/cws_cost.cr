module MT::CwsCost
  extend self

  BASE_COSTS = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def node_cost(size : Int32, base : Int32 = 2) : Int32
    BASE_COSTS[(size &- 1) &* 4 &+ base]? || size &* (base &* 2 &+ 7) &* 2
  end
end
