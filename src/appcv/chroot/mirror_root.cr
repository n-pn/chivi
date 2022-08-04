# method releted to primary (zseed == 0) chroot type
# this chroot type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Chroot
  def mirror_other(other : self, chmin : Int16, chmax : Int16, new_chmin : Int16)
    return if other.id == self.id

    infos = Chinfo.fetch_as_mirror(other, self, chmin, chmax, new_chmin)
    return chmin unless last = infos.last?

    Chinfo.bulk_upsert(infos)
    self.set_latest(last, other)

    self.save!
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
    Chinfo.bulk_upsert(infos)
    self.set_latest(last, other)

    chmin
  end
end
