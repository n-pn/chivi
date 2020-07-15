require "colorize"

module TimeUtil
  extend self

  LOCATION = Time::Location.fixed(3600 * 8)
  DEF_TIME = Time.utc(2000, 1, 1)

  TIME_FMT = {
    "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T",
    "%F %T", "%F %R", "%F",
  }

  def parse(input : String)
    TIME_FMT.each do |format|
      return Time.parse(input, format, LOCATION)
    rescue
      next
    end

    puts "- <time_util> error parsing `#{input}`: unknown time format!".colorize.red
    DEF_TIME
  end

  def correct_time(time : Time) : Time
    time < Time.utc ? time : DEF_TIME
  end
end

# puts Utils.parse_time("5/14/2020 7:00:48 AM")
