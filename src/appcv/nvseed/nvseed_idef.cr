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

  def get_chvol(chidx : Int16, limit : Int16 = 4)
    chmin = chidx - limit
    chmin = 1 if chmin > 1

    chidx.downto(chmin).each do |index|
      next unless info = self.chinfo(index - 1)
      return info.chvol unless info.chvol.empty?
    end

    ""
  end

  getter _repo : ChRepo { ChRepo.load!(self.sname, self.snvid) }
  delegate chlist, to: _repo

  VI_PSIZE = 32

  @vpages = Hash(Int16, Array(Chinfo)).new

  def reset_cache!(chmin = 1_i16, chmax = self.chap_count, raws : Bool = true)
    @lastpg = nil
    @vpages.clear
    @_repo.try(&.zpages.clear) if raws
  end

  def pg_vi(chidx : Int16)
    (chidx &- 1) // VI_PSIZE
  end

  def chpage(vi_pg : Int16)
    @vpages[vi_pg] ||= begin
      chmin = vi_pg * VI_PSIZE

      Chinfo.query.filter_chroot(self.id)
        .where("chidx > #{chmin} and chidx <= #{chmin + VI_PSIZE}")
        .order_by(chidx: :asc).to_a.tap(&.each(&.chroot = self))
    end
  end

  getter is_remote : Bool { SnameMap.remote?(self.sname) }

  getter lastpg : Array(Chinfo) do
    Chinfo.query.filter_chroot(self.id)
      .where("chidx <= #{self.chap_count}")
      .limit(4).order_by(chidx: :desc)
      .to_a.tap(&.each(&.chroot = self))
  end

  def chinfo(index : Int16) : Chinfo?
    self.chpage(index // VI_PSIZE).find(&.chidx.==(index + 1))
  end

  # def chtext(chidx : Int16, cpart = 0_i16, redo = false, uname = "")
  #   unless chinfo = self.chinfo(chidx)
  #     return [] of String
  #   end

  #   chtext(chinfo, cpart, redo, uname)
  # end

  # def chtext(chinfo : Chinfo, cpart = 0_i16, redo = false, viuser = nil)
  #   if mirror = chinfo.mirror.try(&.chroot)
  #     return mirror.chtext()
  #   if proxy = chinfo.proxy
  #     return chtext_from_mirror(chinfo, proxy, cpart, redo, uname)
  #   end

  #   chtext = ChText.new(sname, snvid, chinfo)
  #   chdata = chtext.load!(cpart)

  #   if @is_remote && (redo || chdata.lines.empty?)
  #     chdata = chtext.fetch!(cpart, ttl: redo ? 1.minutes : 10.years)
  #     chinfo.stats.uname = uname
  #     self.patch!([chinfo])
  #   elsif chinfo.stats.parts == 0
  #     # check if text existed in zip file but not stored in index
  #     chtext.remap!
  #     self.patch!([chinfo])
  #   end

  #   chdata.lines
  # rescue
  #   [] of String
  # end

  # def chtext_from_mirror(chinfo, proxy, cpart, redo, uname)
  #   mirror_repo = ChRepo.load!(proxy.sname, proxy.snvid)
  #   return [] of String unless mirror_info = mirror_repo.chinfo(proxy.chidx)

  #   chtext = mirror_repo.chtext(mirror_info, cpart, redo, uname)
  #   chinfo.stats = mirror_info.stats
  #   patch!([chinfo])
  #   chtext
  # end

  # def save_part_to_zip(chinfo, parts : Hash(Int16, Array(String)))
  #   zh_pg = self.map_pg(chinfo.chidx)
  #   text_dir = "#{@chdir}/#{zh_pg}"
  #   Dir.mkdir_p(text_dir)

  #   zip_path = "#{@chdir}/#{zh_pg}.zip"

  #   parts.each do |cpart, files|
  #     file = File.join(text_dir, "#{chinfo.schid}-#{cpart}.txt")
  #     File.write(file, files.join('\n'))
  #   end

  #   puts chinfo, parts.keys

  #   `zip --include=\\*.txt -rjmq "#{zip_path}" "#{text_dir}"`
  #   File.open("#{text_dir}.tsv", "a") { |io| io << '\n' << chinfo }
  # end
end
