# Method required for all nvseed types

require "../nvchap/ch_list"
require "../nvchap/ch_repo"
require "../../mtlv1/mt_core"

class CV::Nvseed
  def fix_latest(force : Bool = false) : Nil
    return unless force || self.chap_count == 0

    if last_chap = self._repo.regen!(force: force)
      set_latest(last_chap, force: force)
    else
      Log.error { "Missing chapters for #{sname}/#{snvid}".colorize.red }
    end
  rescue err
    Log.error { err.inspect_with_backtrace.colorize.red }
  end

  def set_latest(chap : ChInfo, force : Bool = true) : Nil
    return unless force || self.chap_count <= chap.chidx

    self.last_sname = chap.proxy.try(&.sname) || self.sname
    self.last_schid = chap.schid
    self.chap_count = chap.chidx
  end

  def set_mftime(utime : Int64 = Time.utc.to_unix, force : Bool = false) : Nil
    return unless force || utime > self.utime
    self.utime = utime
    self.nvinfo.set_utime(utime, force: false)
  end

  def set_status(status : Int32, mode : Int32 = 0) : Nil
    return unless mode > 0 || self.status < status || self.status == 3
    self.status = status
    self.nvinfo.set_status(status, force: mode > 1)
  end

  ############

  def get_chvol(chidx : Int32, limit = 4)
    chmin = chidx - limit
    chmin = 1 if chmin > 1

    chidx.downto(chmin).each do |index|
      next unless info = self.chinfo(index - 1)
      return info.chvol unless info.chvol.empty?
    end

    ""
  end

  getter cvmtl : MtCore { MtCore.generic_mtl(nvinfo.dname) }
  getter _repo : ChRepo { ChRepo.new(self.sname, self.snvid) }
  delegate chlist, to: _repo

  VI_PSIZE = 32

  @vpages = Hash(Int32, Array(ChInfo)).new

  def reset_cache!(chmin = 1, chmax = self.chap_count, raws : Bool = true)
    @lastpg = nil
    @vpages.clear
    @_repo.try(&.zpages.clear) if raws
  end

  def pg_vi(chidx : Int32)
    (chidx &- 1) // VI_PSIZE
  end

  def chpage(vi_pg : Int32)
    @vpages[vi_pg] ||= begin
      chmin = vi_pg * VI_PSIZE + 1
      chmax = chmin + VI_PSIZE - 1
      chmax = self.chap_count if chmax > self.chap_count

      chlist = _repo.chlist(vi_pg // 4)
      (chmin..chmax).map { |chidx| chlist.get(chidx).trans!(cvmtl) }
    end
  end

  getter lastpg : Array(ChInfo) do
    chmax = self.chap_count - 1
    chmin = chmax > 3 ? chmax - 3 : 0

    output = [] of ChInfo
    chmax.downto(chmin) do |index|
      output << (self.chinfo(index) || ChInfo.new(index + 1))
    end

    output
  end

  def chinfo(index : Int32) : ChInfo?
    self.chpage(index // VI_PSIZE)[index % VI_PSIZE]?
  end

  def chtext(chinfo : ChInfo, cpart = 0, mode = 0, uname = "")
    return [] of String if chinfo.invalid?

    chtext = ChText.new(sname, snvid, chinfo)
    chdata = chtext.load!(cpart)

    if mode > 1 || (mode == 1 && chdata.lines.empty?)
      # reset mode or text do not exist
      chdata = chtext.fetch!(cpart, ttl: mode > 1 ? 1.minutes : 10.years)
      chinfo.stats.uname = uname
      self.patch_chaps!(chinfo)
    elsif chinfo.stats.parts == 0
      # check if text existed in zip file but not stored in index
      chinfo.set_title!(chtext.remap!)
      self.patch_chaps!(chinfo)
    end

    chdata.lines
  rescue
    [] of String
  end
end
