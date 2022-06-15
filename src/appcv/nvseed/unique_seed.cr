# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Nvseed
  # auto generate `=base` seed

  def autogen_base!(mode : Int32 = 0) : Nil
    seeds = self.nvinfo.seed_list
    chmin = 0

    others = seeds.other.first(5)

    others.each_with_index(1) do |other, idx|
      if mode > 0 && other.remote?(force: mode > 1)
        other.refresh_remote!(1.days * idx, lbl: "#{idx}/#{others.size}")
      end

      chmin = self.clone_remote!(other, chmin: chmin)
    end

    _user = seeds._user || Nvseed.load!(self.nvinfo, "=user")
    chmin = self.clone_range!(_user, chmin: 1)

    self.reset_cache!(raws: false)
    self.save!
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  # clone remote seed, return chmax
  def clone_remote!(remote : self, chmin = self.chap_count) : Int32
    if chmin == 0 || !(last_chap = self.chinfo(chmin - 1))
      return self.clone_range!(remote, chmin: chmin)
    end

    start = chmin > 10 ? chmin &- 10 : chmin
    infos = remote.clone_chaps(start)

    20.times do
      break unless chap_info = infos.shift?
      next unless chap_info.title == last_chap.title

      offset = last_chap.chidx &- chap_info.chidx
      infos.each(&.chidx.&+ offset) if offset != 0

      self.patch_chaps!(infos, remote.utime, save: false)
      return infos.last.chidx
    end

    chmin
  end

  def upgrade_base!(mode = 1)
    if mode > 1 || self.chap_count == 0 || self.last_sname.empty?
      return autogen_base!(mode: mode)
    end

    return if self.last_sname == self.sname

    upstream = Nvseed.load!(self.nvinfo, self.last_sname)
    upstream.refresh!(mode: mode)

    self.refresh_mirror!(upstream)
  end

  ###################

  def autogen_user!(mode : Int32 = 0)
    seeds = self.nvinfo.seed_list
    exist = Set(Int32).new

    seeds.users.first(5).each do |other|
      infos = other.clone_chaps.reject! { |x| exist.includes?(x.chidx) }
      infos.each { |x| exist << x.chidx }
      self.patch_chaps!(infos, other.utime, save: false)
    end

    self.save!
  end

  def upgrade_user!(mode = 1)
    if mode > 1 || self.chap_count == 0 || self.last_sname.empty?
      return autogen_user!(mode: mode)
    end

    upstream = Nvseed.load!(self.nvinfo, self.last_sname)
    self.refresh_mirror!(upstream)
  end

  ##############

  def upgrade_self!(mode = 1)
    return if self.last_sname.empty? || self.last_sname == self.sname
    upstream = Nvseed.load!(self.nvinfo, self.last_sname)
    self.refresh_mirror!(upstream)
  end
end
