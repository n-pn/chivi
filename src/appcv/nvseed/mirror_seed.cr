# method releted to primary (zseed == 0) nvseed type
# this nvseed type do not store text file in storage, it will instead reuse texts
# from other sources

class CV::Nvseed
  def mirror_regen!(force : Bool = false, fetch : Bool = true) : Nil
    seeds = self.nvinfo.nvseeds.to_a.sort_by!(&.zseed)

    seeds.shift if seeds.first?.try(&.sname.== "=base")
    users_seed = seeds.pop if seeds.last?.try(&.sname.== "users")

    ttl = map_ttl(force: force)
    chmin = 1

    seeds = seeds.first(5)
    seeds.each_with_index(1) do |other, idx|
      if fetch && other.remote?(force: force)
        ttl *= 2
        other.remote_regen!(ttl: ttl, force: false, lbl: "#{idx}/#{seeds.size}")
        self.stime = other.stime if self.stime < other.stime
      end

      chmin = self.mirror_other!(other, chmin: chmin)
    rescue err
      Log.error { err.colorize.red }
    end

    users_seed.try { |x| self.mirror_other!(x, chmin: 1) }

    self.reset_cache!
    self.save!
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  def mirror_other!(other : self, chmin = 1, chmax = other.chap_count, offset = 0) : Int32
    return chmin if other.chap_count < chmin
    infos = other._repo.clone!(chmin, chmax, offset: 0)

    if other.sname[0]?.in?('=', '@') || other.sname == "users"
      infos.reject!(&.title.empty?)
    end

    return chmin if infos.empty?
    self.patch!(infos, other.utime, save: false)
    infos.last.chidx + 1 # return latest patched chapter
  end
end
