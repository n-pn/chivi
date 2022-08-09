# method releted to primary (zseed == 0) chroot type
# this chroot type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Chroot
  def clear_cache!
    # Log.info { "clearing [#{sname}/#{s_bid}] cache!".colorize.cyan }
    @lastpg = nil
    @vpages.clear
  end

  def reload_mirror!(mode = 0_i8) : Nil
    self.clear_cache!
    return if self.last_sname.empty?

    source = Chroot.load!(self.nvinfo, self.last_sname)

    if source.remote?(force: mode > 0)
      source.reload_remote!(mode: mode)
    elsif !source.last_sname.empty?
      source.reload_mirror!(mode: mode)
    end

    self.mirror_other!(source) if self.chap_count < source.chap_count
  end

  ###################

  # auto generate `=base` seed
  def reload_base!(mode : Int8 = 0) : Nil
    # Log.info { "reload [=base] #{s_bid}, #{mode}, #{stage}".colorize.cyan }

    self.reseed_base!(mode: mode) if mode > 1 || self.stage < 2
    self.reload_mirror!(mode: mode) if mode > 0
  end

  def reseed_base!(mode : Int8 = 0) : Nil
    c_min = 0

    others = Chroot.query.filter_nvinfo(self.nvinfo_id).to_a
    others.sort_by! { |x| SnameMap.zseed(x.sname) }

    others.first(5).each do |other|
      if mode > 0 && other.remote?(force: mode > 1)
        other.reload_remote!(mode: mode &- 1)
      end

      next if other.chap_count <= c_min
      c_min = self.mirror_other!(other, c_min: c_min)
    end

    self.stage = 3_i16 if self.stage < 3
    self.save!
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  ##############

  def reload_user!(mode : Int8 = 0)
    # Log.info { "reload [=user] #{s_bid}, #{mode}, #{stage}".colorize.cyan }

    self.reseed_user!(mode: mode) if mode > 1 || self.stage < 2
    self.reload_mirror!(mode: mode) if mode > 0
  end

  def reseed_user!(mode : Int8 = 0) : Nil
    others = Chroot.query.filter_nvinfo(self.nvinfo_id).to_a
    others.select!(&.sname.starts_with?('@')).sort_by!(&.utime.-)

    checks = Set(Int32).new

    others.first(5).each do |other|
      infos = other._repo.all(0, other.chap_count)

      infos.reject! { |x| checks.includes?(x.ch_no!) }
      checks.concat(infos.map(&.ch_no!))

      next unless last = infos.last?
      self._repo.bulk_upsert(infos)

      self.set_mftime(other.utime)
      self.set_latest(last)
    end

    self.stage = 3_i16 if self.stage < 3
    self.save!
  end

  #####

  def reload_self!(mode : Int8 = 1)
    self.reload_mirror!(mode: mode) if mode > 0
  end

  ###

  def reload_frozen!(mode : Int8 = 1)
    self._repo.sync_db! if mode > 1
    self.clear_cache! if mode > 0
  end
end
