# add more instance methods to Nvseed class

class CV::Nvseed
  def bintro_lines
    bintro.split('\n')
  end

  def fix_latest(force : Bool = false) : Nil
    return unless force || self.chap_count == 0

    if last_chap = self._repo.regen!(force: force)
      set_latest(last_chap, force: force)
    else
      Log.error { "Missing chapters for #{sname}/#{snvid}".colorize.red }
    end
  rescue err
    Log.error { err.inspect_with_backtrace.colorize.red }
  end

  def set_latest(chap : ChInfo, force : Bool = true) : Nil
    return unless force || self.chap_count <= chap.chidx

    self.last_schid = chap.schid
    self.chap_count = chap.chidx
  end

  def set_mftime(utime : Int64 = Time.utc.to_unix, force : Bool = false) : Nil
    return unless force || self.utime < utime
    self.utime = utime
    self.nvinfo.set_utime(utime)
  end

  def set_status(status : Int32, mode : Int32 = 0) : Nil
    return unless mode > 0 || self.status < status || self.status == 3
    self.status = status
    self.nvinfo.set_status(status, force: mode > 1)
  end

  ############

  def get_chvol(chidx : Int32, limit = 4)
    chmin = chidx - limit
    chmin = 1 if chmin > 1

    chidx.downto(chmin).each do |index|
      next unless info = self.chinfo(index - 1)
      return info.chvol unless info.chvol.empty?
    end

    ""
  end
end
