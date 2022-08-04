# Method required for all chroot types

require "../nvchap/ch_list"
require "../nvchap/ch_repo"
require "../../mtlv1/mt_core"

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

  def set_latest(chap : Chinfo, other : self = chap.chroot, force : Bool = false) : Nil
    return if !force && chap.chidx < self.chap_count

    self.last_schid = chap.schid
    self.chap_count = chap.chidx

    if self.sname != other.sname
      self.last_sname = other.sname
      self.utime = other.utime if self.utime < other.utime
    else
      self.last_sname = ""
    end
  end

  ############

  getter is_remote : Bool { SnameMap.remote?(self.sname) }

  def pg_vi(chidx : Int16)
    (chidx &- 1) // VI_PSIZE
  end

  VI_PSIZE = 32
  @vpages = {} of Int16 => Array(Chinfo)

  def chpage(vi_pg : Int16)
    chmin = vi_pg * VI_PSIZE
    chmax = chmin + VI_PSIZE
    chmax = self.chap_count if chmax > self.chap_count

    Chinfo.query.where(chroot_id: self.id)
      .where("chidx > #{chmin} and chidx <= #{chmax}")
      .order_by(chidx: :asc).with_mirror(&.with_chroot).with_viuser
      .to_a.tap(&.each(&.chroot = self))
  end

  getter lastpg : Array(Chinfo) do
    Chinfo.query.where(chroot_id: self.id)
      .where("chidx <= #{self.chap_count}")
      .order_by(chidx: :desc).with_mirror(&.with_chroot).with_viuser
      .limit(4).to_a.tap(&.each(&.chroot = self))
  end

  #####

  def chinfo(chidx : Int16 | Int32) : Chinfo?
    return unless chinfo = Chinfo.find({chroot_id: id, chidx: chidx})
    chinfo.tap(&.chroot = self)
  end
end
