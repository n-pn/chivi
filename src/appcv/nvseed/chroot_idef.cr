# Method required for all nvseed types

require "../nvchap/ch_list"
require "../nvchap/ch_repo"
require "../../mtlv1/mt_core"

class CV::Nvseed
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

  def set_latest(chap : Chinfo, other : self = chap.other, force : Bool = false) : Nil
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

  def chpage(vi_pg : Int16)
    chmin = vi_pg * VI_PSIZE
    Chinfo.query.where(chroot_id: self.id)
      .where("chidx > #{chmin} and chidx <= #{chmin + VI_PSIZE}")
      .order_by(chidx: :asc).with_mirror(&.with_chroot).with_viuser
      .to_a.tap(&.each(&.chroot = self))
  end

  def lastpg : Array(Chinfo)
    Chinfo.query.where(chroot_id: self.id)
      # .where("chidx <= #{self.chap_count}")
      .order_by(chidx: :desc).with_mirror(&.with_chroot).with_viuser
      .limit(4).to_a.tap(&.each(&.chroot = self))
  end

  #####

  def chinfo(chidx : Int16 | Int32) : Chinfo?
    return unless chinfo = Chinfo.find({chroot_id: id, chidx: chidx})
    chinfo.tap(&.chroot = self)
  end

  def reload!(mode : Int8 = 1_i8) : Nil
    self.stime = Time.utc.to_unix if mode > 0
    return reseed! if !seeded

    case
    when sname == "=base" then self.reload_base!(mode: mode)
    when sname == "=user" then self.reload_user!(mode: mode)
    when sname.starts_with?('@')
      self.reload_self!(mode: mode)
    when self.is_remote
      self.update_remote!(mode: mode)
    else
      self.reload_frozen!(mode: mode)
    end

    self.nvinfo.save! if self.nvinfo.changed?
    Nvinfo.cache!(self.nvinfo)
  end

  def reseed!(mode : Int8 = 1)
    case sname
    when "=base" then self.reseed_base!(mode: mode)
    else              self.reseed_from_disk!
    end
  end

  def reload_frozen!(mode : Int8 = 1_i8)
    return if mode < 1

    Log.info { "retranslate content" }

    cvmtl = self.nvinfo.cvmtl
    infos = Chinfo.query
      .where("chroot_id = #{self.id} and mirror_id is null")
      # .select("id, chroot_id, chidx, title, chvol, tl_fixed")
      .to_a

    Chinfo.retranslate(infos, cvmtl: cvmtl)
  end

  TXT_DIR = "var/chtexts"

  def reseed_from_disk!
    Log.info { "load #{self.sname}/#{self.snvid} infos from disk".colorize.yellow }

    files = Dir.glob("#{TXT_DIR}/#{self.sname}/#{self.snvid}/*.tsv")
    cvmtl = self.nvinfo.cvmtl

    input = {} of Int16 => Chinfo
    files.each do |file|
      File.read_lines(file).each do |line|
        next if line.empty?
        entry = Chinfo.new(self, line.split('\t'))
        input[entry.chidx] = entry
      end
    end

    batch = input.values.sort_by!(&.chidx)
    return unless last = batch.last?
    Chinfo.bulk_upsert(batch, cvmtl: cvmtl)

    self.set_latest(last, last.mirror.try(&.chroot) || self)
    self.seeded = true
    self.save!
  end
end
