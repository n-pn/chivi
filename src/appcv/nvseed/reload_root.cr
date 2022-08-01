# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Nvseed
  # auto generate `=base` seed

  def reseed_base!(mode : Int8 = 0) : Nil
    chmin = 0_i16

    others = Nvseed.query.filter_nvinfo(self.nvinfo_id).to_a
    others.sort_by! { |x| SnameMap.zseed(x.sname) }

    others.first(5).each_with_index(1) do |other, idx|
      other.reseed_from_disk! if !other.seeded

      if mode > 0 && other.remote?(force: mode > 1)
        other.reload_remote!(1.days * idx, lbl: "#{idx}/#{others.size}")
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

  # clone remote seed, return chmax
  def mirror_other!(other : self, chmin : Int16 = self.chap_count.to_i16) : Int16
    start = chmin > 0 ? Chinfo.match_chidx(other, chmin) : 0_i16
    infos = [] of Chinfo

    Chinfo.query.range(other.id, start + 1, nil).each do |input|
      chmin += 1

      infos << Chinfo.new({
        chroot: self, chidx: chmin, schid: input.schid,
        mirror_id: input.mirror_id || input.id,
      })
    end

    return chmin unless last = infos.last?
    Chinfo.bulk_upsert(infos, trans: false)
    self.set_latest(last, other)

    chmin
  end

  def reload_base!(mode = 1_i8)
    return self.reseed_base!(mode: mode) if mode > 1 || !seeded
    return if self.last_sname.empty?

    source = Nvseed.load!(self.nvinfo, self.last_sname).tap(&.reload!(mode: mode))
    self.mirror_other!(source)
  end

  ###################

  def reseed_user!(mode : Int8 = 0) : Nil
    others = Nvseed.query.filter_nvinfo(self.nvinfo_id).to_a
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
      Chinfo.bulk_upsert(infos, trans: false)

      self.set_latest(last, other)
    end

    self.seeded = true
    self.save!
  end

  def reload_user!(mode : Int8 = 1)
    return reseed_user!(mode: mode) if mode > 1 || !seeded
    return if self.last_sname.empty?

    source = Nvseed.load!(self.nvinfo, self.last_sname)
    self.mirror_other!(source)
  end

  ##############

  def reload_self!(mode = 1)
    return reseed_from_disk! if mode > 1 || !seeded
    return if self.last_sname.empty?

    source = Nvseed.load!(self.nvinfo, self.last_sname)
    self.mirror_other!(source)
  end
end
