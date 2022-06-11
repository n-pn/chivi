require "../../_init/remote_info"

# for source like `hetushu` or `69shu` that can download book info/book text form
# internet

class CV::Nvseed
  def remote_regen!(ttl : Time::Span, force : Bool = false, lbl = "-/-") : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl, lbl: lbl)
    changed = parser.last_schid != self.last_schid

    return unless force || changed
    chinfos = parser.chap_infos
    return if chinfos.empty?

    spawn { ChList.save!(_repo.fseed, chinfos, mode: "w") }
    _repo.store!(chinfos, reset: force)

    self.reset_cache!
    self.stime = FileUtil.mtime_int(parser.info_file)

    if parser.update_str.empty?
      mftime = changed ? self.stime : self.utime
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
