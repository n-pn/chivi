require "json"

class ZhStat
  include JSON::Serializable

  property title = ""
  property author = ""

  property votes = 0_i32
  property score = 0_f64
  property tally = 0_f64

  property status = 0_i32
  property shield = 0_i32

  # property chap_count = 0
  property word_count = 0_i32
  property crit_count = 0_i32

  def initialize
  end

  def merge(other : self)
    @votes += other.votes
    @score += other.score
    @tally = (@votes * @score * 2).round / 2
  end
end
