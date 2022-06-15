# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Nvseed
  def init_base!(force : Bool = false, fetch : Bool = true) : Nil
    seeds = self.nvinfo.seed_list
    chmin = 0

    seeds.other.first(5).each do |other|
      chmin = self.clone_remote!(other, chmin: chmin)
    end

    if _user = seeds._user
      chmin = self.clone_range!(_user, chmin: 1)
    end

    self.reset_cache!

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

      self.patch_chaps!(infos, remote.utime, save: false)
      return infos.last.chidx
    end

    chmin
  end

  def clone_range!(other : self, chmin = 1, chmax = other.chap_count, offset = 0) : Int32
    return chmin if other.chap_count < chmin

    infos = other.clone_chaps(chmin, chmax, offset: 0)
    return chmin if infos.empty?

    self.patch_chaps!(infos, other.utime, save: false)
    infos.last.chidx # return latest patched chapter
  end

  # proxy seeds like =base, =user, @username can have blank chapters
  getter can_have_gaps : Bool { sname[0].in?('@', '=') || sname == "users" }

  def clone_chaps(chmin = 1, chmax = self.chap_count, offset = 0)
    infos = _repo.clone!(chmin, chmax, offset: offset)
    infos.reject!(&.title.empty?) if can_have_gaps
    infos
  end

  def patch_chaps!(chaps : Array(ChInfo), utime : Int64, save = true) : Nil
    _repo.patch!(chaps)

    self.set_mftime(utime, force: false)
    self.set_latest(chaps.last, force: false)

    self.reset_cache!
    self.save! if save
  end

  def patch_chaps!(chap : ChInfo, utime : Int64 = Time.utc.to_unix) : Nil
    patch_chaps!([chap], utime)
  end
end
