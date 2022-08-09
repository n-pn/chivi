# Method required for all chroot types

# require "../nvchap/ch_list"
# require "../nvchap/ch_repo"
require "../../mtlv1/mt_core"
require "../ch_repo_2"

class CV::Chroot
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

  def set_latest(chap : ChInfo2, force : Bool = false) : Nil
    return if !force && chap.ch_no! < self.chap_count

    Log.info { [chap.ch_no, self.chap_count, force] }

    self.last_schid = chap.s_cid.to_s
    self.chap_count = chap.ch_no!
    self.last_sname = self.sname != chap.sname ? chap.sname : ""
  end

  getter _repo : ChRepo2 do
    repo = ChRepo2.new(self.sname, self.s_bid)

    if self.stage == 1 && repo.stype != 2
      repo.sync_db!
      self.stage = 2_i16
    elsif self.stage < 1
      repo.get(self.chap_count).try { |x| self.set_latest(x) }
      self.stage = 3_i16
    end

    self.save!
    repo
  end

  def bump_stage!
    case self.stage
    when 0 then self.stage = 3_i16
    when 1 then self.stage = 2_i16
    end
  end

  ############

  getter is_remote : Bool { _repo.stype > 2 }

  def pg_vi(ch_no : Int32)
    (ch_no &- 1) // VI_PSIZE
  end

  VI_PSIZE = 32
  @vpages = {} of Int32 => Array(ChInfo2)

  def chpage(vi_pg : Int32)
    @vpages[vi_pg] ||= begin
      chmin = VI_PSIZE &* vi_pg

      chmax = VI_PSIZE &+ chmin
      chmax = self.chap_count if chmax > self.chap_count

      infos = self._repo.all(chmin &+ 1, chmax)

      cvmtl = self.nvinfo.cvmtl
      infos.each(&.trans!(cvmtl))

      infos
    end
  end

  getter lastpg : Array(ChInfo2) do
    chmax = self.chap_count
    chmin = chmax &- 3
    infos = self._repo.all(chmin, chmax, "desc")

    cvmtl = self.nvinfo.cvmtl
    infos.each(&.trans!(cvmtl))

    infos
  end

  #####

  def chinfo(ch_no : Int32) : ChInfo2?
    vpage = self.chpage(self.pg_vi(ch_no))

    min = 0
    max = vpage.size &- 1

    while min < max
      mid = (min &+ max) // 2

      chap = vpage.unsafe_fetch(mid)
      c_id = chap.ch_no!

      case
      when c_id < ch_no then min = mid &+ 1
      when c_id > ch_no then max = mid
      else                   return chap
      end
    end

    chap = vpage.unsafe_fetch(max)
    return chap if chap.ch_no! == ch_no
  end

  # def chtext(chinfo : ChInfo2, cpart : Int16, redo : Bool = false, uname : String = "")
  #   chtext = ChText.load(self.chroot, self.chidx)
  # end
end
