require "log"

module Utils
  LOCATION = Time::Location.fixed(3600 * 8)
  TIME_FMT = {
    "%F %T",
    "%F %R",
    "%F",
    "%-m/%-d/%Y %r",
    "%-m/%-d/%Y %T",
    "%Y/%-m/%-d %T",
  }

  def self.parse_time(input : String)
    TIME_FMT.each do |format|
      return Time.parse(input, format, LOCATION)
    rescue
      next
    end

    Log.error { "Error parsing <#{input}>: unknown time format!" }
    Time.utc(2010, 1, 1)
  end
end
