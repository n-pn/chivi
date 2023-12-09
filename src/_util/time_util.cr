module TimeUtil
  extend self

  LOCATION = Time::Location.fixed(3600 * 8) # chinese timezone

  TIME_FMT = {
    "%-m/%-d/%Y %r",
    "%-m/%-d/%Y %T",
    "%Y/%-m/%-d %T",
    "%F %T",
    "%F %R",
    "%F",
  }

  # parse remote source info update times
  def parse_time(input : String) : Time
    raise "<parse_time> error: empty string" if input.empty?

    begin
      Time.parse_utc(input, "%FT%T.%3NZ")
    rescue
      TIME_FMT.each do |format|
        return Time.parse(input, format, LOCATION)
      rescue
        next
      end

      raise "<parse_time> [#{input}] error: invalid format]"
    end
  end

  def parse_time(input : String, format : String)
    Time.parse(input, format, LOCATION)
  end

  def get_date(time : Time)
    sprintf("%04d-%02d-%02d", *time.date)
  end

  CV_EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.cv_mtime(rtime : Time = Time.utc)
    ((rtime.to_unix &- CV_EPOCH) // 60).to_i
  end

  def self.cv_utime(mtime : Int32)
    mtime > 0 ? CV_EPOCH &+ mtime &* 60 : 0
  end
end

# puts TimeUtil.parse_time("5/14/2020 7:00:48 AM")
# puts TimeUtil.parse_time("2020-09-08 10:00")
# puts TimeUtil.parse_time("2020-09-11T16:00:00.000Z")

# puts TimeUtil.get_date(Time.local)
