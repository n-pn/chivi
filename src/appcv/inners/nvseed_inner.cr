module CV::NvseedInner
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

  def set_genres(genres : Array(String), mode : Int32 = 0)
    return unless mode > 0 || self.bgenre.empty?
    self.bgenre = genres.join('\t')
    self.nvinfo.set_genres(genres, force: mode > 1)
  end

  def set_bintro(bintro : Array(String), mode : Int32 = 0) : Nil
    return unless mode > 0 || self.bintro.empty?
    self.bintro = bintro.join('\n')
    self.nvinfo.set_bintro(bintro, force: mode > 1)
  end

  def set_bcover(bcover : String, mode : Int32 = 0) : Nil
    return unless mode > 0 || self.bcover.empty?
    self.bcover = bcover
    self.nvinfo.set_bcover(bcover, force: mode > 1)
  end

  ############

  def remote?(force : Bool = true)
    type = SnameMap.map_type(sname)
    type == 4 || (force && type == 3)
  end

  def staled?(privi : Int32 = 4, force : Bool = false)
    return true if self.chap_count == 0
    tspan = Time.utc - Time.unix(self.stime)
    tspan >= map_ttl(force: force) * (4 - privi)
  end

  STALES = {1.days, 5.days, 10.days, 30.days}

  def map_ttl(force : Bool = false)
    return 5.minutes if force
    STALES[self.nvinfo.status]? || 60.days
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
