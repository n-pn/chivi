require "../../_init/remote_info"

module CV::RemoteSeed
  def remote_regen!(ttl : Time::Span, force : Bool = false, lbl = "-/-") : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl, lbl: lbl)
    changed = parser.last_schid != self.last_schid

    return unless force || changed
    chinfos = parser.chap_infos
    return if chinfos.empty?

    spawn { ChList.save!(_repo.fseed, chinfos, mode: "w") }
    _repo.store!(chinfos, reset: force)

    self.reset_cache!
    self.stime = FileUtil.mtime_int(parser.info_link)

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
end
