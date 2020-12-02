module TimeUtils
  extend self

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
