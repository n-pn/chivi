require "colorize"

module CV::TimeUtils
  extend self

  LOCATION = Time::Location.fixed(3600 * 8) # chinese timezone
  DEF_TIME = Time.utc(2020, 1, 1)

  TIME_FMT = {
    "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T",
    "%F %T", "%F %R", "%F",
  }

  # parse remote source info update times
  def parse_time(input : String) : Time
    TIME_FMT.each do |format|
      return Time.parse(input, format, LOCATION)
    rescue
      next
    end

    puts "[ERROR parsing time <#{input}>: unknown format]".colorize.red
    DEF_TIME
  end

  # :ditto:
  def parse_time(input : Nil) : Time
    Time.utc
  end
end

# puts CV::TimeUtils.parse_time("5/14/2020 7:00:48 AM")
# puts CV::TimeUtils.parse_time("2020-09-08 10:00")
