require "colorize"

module Utils
  TIME_DEF = Time.utc(2000, 1, 1)
  TIME_LOC = Time::Location.fixed(3600 * 8)

  TIME_FMT = {
    "%F %T", "%F %R", "%F",
    "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T",
  }

  def self.parse_time(input : String, fallback : Time = TIME_DEF)
    TIME_FMT.each do |format|
      return Time.parse(input, format, TIME_LOC)
    rescue
      next
    end

    puts "- <parse_time> error parsing `#{input}`: unknown time format!".colorize(:red)
    fallback
  end

  def self.correct_time(time : Time) : Time
    time < Time.utc ? time : TIME_DEF
  end
end

# puts Utils.parse_time("5/14/2020 7:00:48 AM")
