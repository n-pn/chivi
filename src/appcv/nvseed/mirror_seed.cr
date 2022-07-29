# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Nvseed
  def clone_range!(other : self, chmin : Int16 = 1_i16,
                   chmax : Int16 = other.chap_count.to_i16, offset = 0_i16) : Int16
    return chmin if other.chap_count < chmin

    infos = other.clone_chaps(chmin, chmax, offset: offset)
    return chmin if infos.empty?

    self.patch_chaps!(infos, other.utime, save: false)
    infos.last.chidx # return latest patched chapter
  end

  # proxy seeds like =base, =user, @username can have blank chapters
  getter can_have_gaps : Bool { sname[0].in?('@', '=') || sname == "users" }

  def clone_chaps(chmin = 1_i16, chmax = self.chap_count.to_i16, offset = 0_i16)
    infos = _repo.clone!(chmin.to_i16, chmax.to_i16, offset: offset.to_i16)
    infos.reject!(&.title.empty?) if can_have_gaps
    infos
  end

  def patch_chaps!(chaps : Array(ChInfo), utime : Int64, save = true) : Nil
    return if chaps.empty?
    _repo.patch!(chaps)

    self.set_mftime(utime, force: false)
    self.set_latest(chaps.last, force: false)

    self.reset_cache!
    self.save! if save
  end

  def patch_chaps!(chap : ChInfo, utime : Int64 = Time.utc.to_unix) : Nil
    patch_chaps!([chap], utime)
  end

  ######

  def refresh_mirror!(force = false) : Nil
    return unless last_chap = self.chinfo(self.chap_count &- 1)
    return unless proxy = last_chap.proxy

    self.last_sname = proxy.sname
    return if self.last_sname == self.sname

    target = Nvseed.load!(self.nvinfo, self.last_sname)
    target.refresh!(force: force)

    return if target.chap_count == proxy.chidx

    offset = last_chap.chidx &- proxy.chidx
    self.clone_range!(target, last_chap.chidx, offset: offset)
  end

  def refresh_mirror!(upstream : Nvseed, force : Bool = false) : Nil
    return unless last_chap = self.chinfo(self.chap_count.to_i16 &- 1)
    return unless proxy = last_chap.proxy

    offset = last_chap.chidx &- proxy.chidx
    self.clone_range!(upstream, last_chap.chidx, offset: offset)
  end
end
