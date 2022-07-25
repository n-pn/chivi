# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Nvseed
  # auto generate `=base` seed

  def autogen_base!(seeds = self.nvinfo.seed_list.other, mode : Int32 = 0) : Nil
    chmin = 0

    seeds.first(5).each_with_index(1) do |other, idx|
      if mode > 0 && other.remote?(force: mode > 1)
        other.refresh_remote!(1.days * idx, lbl: "#{idx}/#{seeds.size}")
      end

      chmin = self.clone_remote!(other, chmin: chmin)
    end

    self.reset_cache!(raws: true)
    self.save!
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  # clone remote seed, return chmax
  def clone_remote!(remote : self, chmin = self.chap_count) : Int32
    return chmin if remote.chap_count == 0

    if chmin == 0 || !(last_chap = self.chinfo(chmin - 1))
      return self.clone_range!(remote, chmin: chmin)
    end

    start = chmin > 5 ? chmin &- 5 : chmin
    infos = remote.clone_chaps(start)
    return chmin if infos.empty?

    10.times do
      break if infos.size < 2
      chap_info = infos.shift
      next unless chap_info.title == last_chap.title

      offset = chap_info.chidx &- last_chap.chidx
      infos.each(&.chidx.&+ offset) if offset != 0

      self.patch_chaps!(infos, remote.utime, save: false)
      return infos.last.chidx
    end

    chmin
  end

  def reload_base!(mode = 1)
    if mode > 1 || self.chap_count == 0 || self.last_sname.empty?
      return self.autogen_base!(mode: mode)
    end

    return if self.last_sname == self.sname

    source = Nvseed.load!(self.nvinfo, self.last_sname)
    source.refresh!(mode: mode)

    self.refresh_mirror!(source)
  end

  ###################

  def autogen_user!(seeds = self.nvinfo.seed_list.users, mode : Int32 = 0)
    exist = Set(Int32).new

    seeds.first(5).each do |other|
      infos = other.clone_chaps.reject! { |x| exist.includes?(x.chidx) }
      infos.each { |x| exist << x.chidx }
      self.patch_chaps!(infos, other.utime, save: false)
    end

    self.save!
  end

  def reload_user!(mode = 1)
    if mode > 1 || self.chap_count == 0 || self.last_sname.empty?
      return autogen_user!(mode: mode)
    end

    source = Nvseed.load!(self.nvinfo, self.last_sname)
    self.refresh_mirror!(source)
  end

  ##############

  def reload_self!(mode = 1)
    return if self.last_sname.empty? || self.last_sname == self.sname
    upstream = Nvseed.load!(self.nvinfo, self.last_sname)
    self.refresh_mirror!(upstream)
  end
end
