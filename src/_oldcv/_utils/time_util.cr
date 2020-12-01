require "colorize"

module Oldcv::TimeUtil
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

  EPOCH = Time.utc(2020, 1, 1)

  # return total minutes since `EPOCH`
  def mtime(rtime = Time.utc)
    # rtime: real time
    (rtime - EPOCH).total_minutes.round.to_i
  end

  # return real time from mtime value
  def rtime(mtime = 0)
    EPOCH + mtime.minutes
  end
end

# puts TimeUtil.parse("5/14/2020 7:00:48 AM")
# puts TimeUtil.parse("2020-09-08 10:00")
