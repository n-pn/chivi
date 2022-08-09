# method releted to primary (zseed == 0) chroot type
# this chroot type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Chroot
  def reload!(mode : Int8 = 0_i8) : Nil
    self.clear_cache! if mode > 0

    case
    when sname == "=base"
      self.reload_base!(mode: mode)
    when sname == "=user"
      self.reload_user!(mode: mode)
    when sname.starts_with?('@')
      self.reload_self!(mode: mode)
    when self.is_remote
      self.reload_remote!(mode: mode)
    else
      self.reload_frozen!(mode: mode)
    end

    self.nvinfo.set_utime(self.utime, force: false)
    self.nvinfo.save! if self.nvinfo.changed?

    Nvinfo.cache!(self.nvinfo)
  end

  def clear_cache!
    Log.info { "clearing [#{sname}/#{s_bid}] cache!".colorize.cyan }
    @lastpg = nil
    @vpages.clear
  end

  def reload_frozen!(mode : Int8 = 1_i8)
    clear_cache!
  end

  ###################

  def reload_base!(mode = 0_i8)
    return self.reseed_base!(mode: mode) if mode > 1 || self.stage < 1
    return if mode < 1 || self.last_sname.empty?

    source = Chroot.load!(self.nvinfo, self.last_sname).tap(&.reload!(mode: mode))
    self.mirror_other!(source)
  end

  # auto generate `=base` seed

  def reseed_base!(mode : Int8 = 0) : Nil
    c_min = 0

    others = Chroot.query.filter_nvinfo(self.nvinfo_id).to_a
    others.sort_by! { |x| SnameMap.zseed(x.sname) }

    others.first(5).each_with_index(1) do |other, idx|
      if mode > 0 && other.remote?(force: mode > 1)
        other.reseed_remote!(1.days * (idx**2), lbl: "#{idx}/#{others.size}")
      end

      next if other.chap_count == 0
      c_min = self.mirror_other!(other, c_min: c_min)
    end

    self.bump_stage!
    self.save!
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  ##############

  def reload_user!(mode : Int8 = 0)
    return reseed_user!(mode: mode) if mode > 1 || self.stage < 1
    return if self.last_sname.empty?

    source = Chroot.load!(self.nvinfo, self.last_sname)
    self.mirror_other!(source)
  end

  def reseed_user!(mode : Int8 = 0) : Nil
    others = Chroot.query.filter_nvinfo(self.nvinfo_id).to_a
    others.select!(&.sname.starts_with?('@')).sort_by!(&.utime.-)

    checks = Set(Int32).new

    others.first(5).each do |other|
      infos = other._repo.all(0, other.chap_count)
      infos.reject! { |x| checks.includes?(x.ch_no!) }

      next unless last = infos.last?
      self._repo.bulk_upsert(infos)
      self.set_mftime(other.utime)
      self.set_latest(last)
    end

    self.bump_stage!
    self.save!
  end

  #####

  def reload_self!(mode = 1)
    return if self.last_sname.empty?
    source = Chroot.load!(self.nvinfo, self.last_sname)
    self.mirror_other!(source)
  end
end
