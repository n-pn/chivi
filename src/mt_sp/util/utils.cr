module SP::Utils
  extend self

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def mtime(rtime : Time = Time.utc)
    ((rtime.to_unix &- EPOCH) // 60).to_i
  end

  def utime(mtime : Int32)
    mtime > 0 ? EPOCH &+ mtime &* 60 : 0
  end
end
