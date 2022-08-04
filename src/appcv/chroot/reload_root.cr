# method releted to primary (zseed == 0) chroot type
# this chroot type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Chroot
  def reload!(mode : Int8 = 0_i8) : Nil
    self.clear_cache!
    self.stime = Time.utc.to_unix if mode > 0
    return reseed!(mode: mode) if !seeded

    case
    when sname == "=base" then self.reload_base!(mode: mode)
    when sname == "=user" then self.reload_user!(mode: mode)
    when sname.starts_with?('@')
      self.reload_self!(mode: mode)
    when self.is_remote
      self.reload_remote!(mode: mode)
    else
      self.reload_frozen!(mode: mode)
    end

    self.nvinfo.save! if self.nvinfo.changed?
    Nvinfo.cache!(self.nvinfo)
  end

  def reseed!(mode : Int8 = 0)
    case sname
    when "=base" then self.reseed_base!(mode: mode)
    else              self.reseed_from_disk!(force: mode > 0)
    end
  end

  def clear_cache!
    @lastpg = nil
    @vpages.clear
  end

  def reload_frozen!(mode : Int8 = 1_i8)
    clear_cache!
  end

  ###################

  def reload_base!(mode = 0_i8)
    return self.reseed_base!(mode: mode) if mode > 1 || !seeded
    return if mode < 1 || self.last_sname.empty?

    source = Chroot.load!(self.nvinfo, self.last_sname).tap(&.reload!(mode: mode))
    self.mirror_other!(source)
  end

  # auto generate `=base` seed

  def reseed_base!(mode : Int8 = 0) : Nil
    chmin = 0_i16

    others = Chroot.query.filter_nvinfo(self.nvinfo_id).to_a
    others.sort_by! { |x| SnameMap.zseed(x.sname) }

    others.first(5).each_with_index(1) do |other, idx|
      other.reseed_from_disk! if !other.seeded

      if mode > 0 && other.remote?(force: mode > 1)
        other.reseed_remote!(1.days * (idx**2), lbl: "#{idx}/#{others.size}")
      end

      next if other.chap_count == 0
      chmin = self.mirror_other!(other, chmin: chmin)
    end

    self.nvinfo.set_utime(self.utime, force: false)
    self.seeded = true
    self.save!
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  ##############

  def reload_user!(mode : Int8 = 0)
    return reseed_user!(mode: mode) if mode > 1 || !seeded
    return if self.last_sname.empty?

    source = Chroot.load!(self.nvinfo, self.last_sname)
    self.mirror_other!(source)
  end

  def reseed_user!(mode : Int8 = 0) : Nil
    others = Chroot.query.filter_nvinfo(self.nvinfo_id).to_a
    others.select!(&.sname.starts_with?('@')).sort_by!(&.utime.-)

    checks = Set(Int16).new

    others.first(5).each do |other|
      infos = [] of Chinfo

      Chinfo.query.range(other.id, nil, nil).each do |input|
        next if checks.includes?(input.chidx)
        checks << input.chidx
        infos << Chinfo.new({
          chroot: self, chidx: input.chidx, schid: input.schid,
          mirror_id: input.mirror_id || input.id,
        })
      end

      next unless last = infos.last?
      Chinfo.bulk_upsert(infos)

      self.set_latest(last, other)
    end

    self.seeded = true
    self.save!
  end

  #####

  def reload_self!(mode = 1)
    return reseed_from_disk! if mode > 1 || !seeded
    return if self.last_sname.empty?

    source = Chroot.load!(self.nvinfo, self.last_sname)
    self.mirror_other!(source)
  end

  ####

  TXT_DIR = "var/chtexts"

  def reseed_from_disk!(force : Bool = false)
    return if !force && self.seeded

    input = {} of Int16 => Chinfo
    files = Dir.glob("#{TXT_DIR}/#{self.sname}/#{self.snvid}/*.tsv")

    files.each do |file|
      File.read_lines(file).each do |line|
        next if line.empty?

        entry = Chinfo.new(self, line.split('\t'))
        input[entry.chidx] = entry
      end
    end

    batch = input.values.sort_by!(&.chidx)

    if last = batch.last?
      Chinfo.bulk_upsert(batch)
      self.set_latest(last, last.mirror.try(&.chroot) || self)
    end

    self.seeded = true
    self.save!
  end
end
