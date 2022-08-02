# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Chroot
  def mirror_other(other : self, chmin : Int16, chmax : Int16, new_chmin : Int16)
    return if other.id == self.id

    infos = Chinfo.fetch_as_mirror(other, self, chmin, chmax, new_chmin)
    return chmin unless last = infos.last?

    Chinfo.bulk_upsert(infos, trans: false)
    self.set_latest(last, other)

    self.save!
  end
end
