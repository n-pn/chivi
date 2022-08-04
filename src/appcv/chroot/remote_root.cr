require "../remote/remote_info"

# for source like `hetushu` or `69shu` that can download book info/book text form
# internet

class CV::Chroot
  def reload_remote!(mode : Int8) : Nil
    return unless mode > 0 || Time.unix(self.stime) + map_ttl(false) > Time.utc

    self.reseed_remote!(ttl: map_ttl(force: mode > 0), force: mode > 1)

    # childs = Chroot.query.filter_nvinfo(self.nvinfo_id)
    #   .where("last_sname = ?", self.sname)

    # childs.each do |other|
    #   other.reseed_from_disk! if !other.seeded
    #   other.mirror_other!(self, other.chap_count)
    # end
  end

  def reseed_remote!(ttl : Time::Span, force : Bool = false, lbl = "-/-") : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl, lbl: lbl)
    changed = parser.changed?(self.last_schid, self.utime)

    return reload_frozen! unless force || changed

    chinfos = parser.chap_infos
    return if chinfos.empty?

    # chmin = force || self.chap_count < 28 ? 0 : self.chap_count &- 28

    output = chinfos.map do |entry|
      Chinfo.new({
        chroot: self,
        chidx: entry.chidx, schid: entry.schid,
        title: entry.title, chvol: entry.chvol,
      })
    end

    Chinfo.bulk_upsert(output)

    # _repo.store!(chinfos, reset: force)
    self.stime = FileUtil.mtime_int(parser.info_file)

    if parser.update_str.empty?
      mftime = changed ? self.stime : self.utime
    elsif sname.in?("69shu", "biqu5200", "ptwxz", "uukanshu")
      mftime = changed ? parser.update_int : self.utime
    else
      mftime = parser.update_int
    end

    self.set_mftime(mftime)
    self.set_status(parser.status_int.to_i)
    self.set_latest(output.last, self, force: true)
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
