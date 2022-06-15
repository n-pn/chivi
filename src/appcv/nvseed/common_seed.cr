# Method required for all nvseed types

require "../nvchap/ch_list"
require "../nvchap/ch_repo"
require "../../mtlv1/mt_core"

class CV::Nvseed
  getter cvmtl : MtCore { MtCore.generic_mtl(nvinfo.dname) }
  getter _repo : ChRepo { ChRepo.new(self.sname, self.snvid) }
  delegate chlist, to: _repo

  VI_PSIZE = 32

  @vpages = Hash(Int32, Array(ChInfo)).new

  def reset_cache!(chmin = 1, chmax = self.chap_count)
    @lastpg = nil
    @vpages.clear
    # @_repo.try(&.zpages.clear)
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
