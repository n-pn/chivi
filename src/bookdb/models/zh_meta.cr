require "json"

class ZhMeta
  include JSON::Serializable

  property hash = ""

  property votes = 0_i32
  property score = 0_f64
  property tally = 0_f64

  property hidden = 0_i32

  # property chap_count = 0
  # property word_count = 0

  def initialize(@hash : String)
  end
end
