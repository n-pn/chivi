require "../../_init/remote_info"

# for source like `hetushu` or `69shu` that can download book info/book text form
# internet

class CV::Nvseed
  def refresh_remote!(ttl : Time::Span, force : Bool = false, lbl = "-/-") : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl, lbl: lbl)
    changed = parser.changed?(self.last_schid, self.utime)

    return unless force || changed

    chinfos = parser.chap_infos
    return if chinfos.empty?

    _repo.store!(chinfos, reset: force)
    self.stime = FileUtil.mtime_int(parser.info_file)

    if parser.update_str.empty?
      mftime = changed ? self.stime : self.utime
    elsif sname.in?("69shu", "biqu5200", "ptwxz")
      mftime = changed ? parser.update_int : self.utime
    else
      mftime = parser.update_int
    end

    self.set_mftime(mftime)
    self.set_status(parser.status_int)
    self.set_latest(chinfos.last, force: true)

    self.save!
  rescue err
    puts err.inspect_with_backtrace
  end

  def update_remote!(mode : Int32) : Nil
    self.reset_cache!(raws: true)
    self.refresh_remote!(ttl: map_ttl(force: mode > 0), force: mode > 1)

    nslist = self.nvinfo.seed_list

    nslist._base.try do |base|
      next unless base.last_sname == self.sname
      base.refresh_mirror!(self, force: mode > 0)
    end

    nslist.users.each do |user|
      next unless user.last_sname == self.sname
      user.refresh_mirror!(self, force: mode > 0)
    end
  end

  ############

  def remote?(force : Bool = true)
    type = SnameMap.map_type(sname)
    type == 4 || (force && type == 3)
  end

  def fresh?(privi : Int32 = 4, force : Bool = false)
    return false if self.chap_count == 0

    ttl = map_ttl(force)
    Time.unix(self.stime) > Time.utc - ttl * (4 &- privi)
  end

  TTL = {1.days, 5.days, 10.days, 30.days}

  def map_ttl(force : Bool = false)
    force ? 2.minutes : TTL[self.nvinfo.status]? || 10.days
  end
end
