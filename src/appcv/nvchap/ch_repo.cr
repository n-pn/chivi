require "../../mtlv1/mt_core"

require "./ch_text"

class CV::ChRepo
  DIR = "var/chtexts"

  # CACHE = RamCache(String, self).new(512, 3.hours)

  REPOS = {} of String => ChRepo

  def self.load!(sname : String, snvid : String)
    REPOS[sname + "/" + snvid] ||= new(sname, snvid)
  end

  ###############

  getter sname : String
  getter snvid : String

  getter fseed : String
  getter fstat : String

  def initialize(@sname : String, @snvid : String)
    @fseed = "var/chmetas/seeds/#{sname}/#{snvid}.tsv"
    @fstat = "var/chmetas/stats/#{sname}/#{snvid}.log"

    @chdir = "var/chtexts/#{sname}/#{snvid}"
    @is_remote = SnameMap.remote?(@sname)

    self.mkdirs!
  end

  def mkdirs!
    Dir.mkdir_p(File.dirname(@fseed))
    Dir.mkdir_p(File.dirname(@fstat))
    Dir.mkdir_p(@chdir)

    return unless @is_remote

    Dir.mkdir_p("var/books/.html/#{@sname}")
    Dir.mkdir_p("var/chaps/.html/#{@sname}/#{@snvid}")
  end

  ZH_PSIZE = 128_i16

  def map_pg(chidx : Int16) : Int16
    (chidx &- 1) // ZH_PSIZE
  end

  getter zpages = {} of Int16 => ChList

  def reset_cache!(chmin = 1_16, chmax = 8096_i16)
    return if @zpages.empty?

    pgmin = map_pg(chmin)
    pgmax = map_pg(chmax)
    (pgmin..pgmax).each { |x| @zpages.delete(x) }
  end

  def chlist(pg_zh : Int16)
    @zpages[pg_zh] ||= ChList.new("#{@chdir}/#{pg_zh}.tsv")
  end

  def regen!(force : Bool = false) : ChInfo?
    infos = ChList.new(@fseed).data.values

    if infos.empty?
      infos = fetch_remote(10.years)
      spawn ChList.save!(@fseed, infos)
    end

    self.store!(infos, reset: force)
    infos.last?
  end

  def fetch_remote(ttl = 10.years)
    parser = RemoteInfo.new(@sname, @snvid, ttl: ttl)
    chlist = parser.chap_infos
    chlist.empty? && ttl != 1.hours ? fetch_remote(1.hours) : chlist
  end

  # save all infos, bail early if result is the same
  def store!(infos : Array(ChInfo), reset = false) : Nil
    return if infos.empty?
    spawn { ChList.save!(@fseed, infos, mode: "w") }

    pgmax = self.map_pg(infos.size.to_i16)
    pgmax.downto(0).each do |pgidx|
      chlist = self.chlist(pgidx)
      update = false

      chmin = pgidx &* ZH_PSIZE
      chmax = pgidx == pgmax ? infos.size : chmin &+ ZH_PSIZE
      chmin.upto(chmax &- 1) do |chidx|
        status = chlist.store(infos[chidx])
        update ||= status
      end

      break unless update || reset
      chlist.save!
    end
  end

  def patch!(input : Array(ChInfo)) : Nil
    spawn ChList.save!(@fstat, input, "a")

    input.group_by { |x| self.map_pg(x.chidx) }.each do |pgidx, infos|
      self.chlist(pgidx).patch!(infos)
    end
  end

  def clone!(chmin : Int16, chmax : Int16, offset = 0_i16) : Array(ChInfo)
    pgmin = map_pg(chmin)
    pgmax = map_pg(chmax)

    chaps = [] of ChInfo

    (pgmin..pgmax).each do |pgidx|
      infos = self.chlist(pgidx).values

      infos.each do |chap|
        next if chap.chidx < chmin
        break if chap.chidx > chmax
        chaps << chap.clone!(@sname, @snvid, chidx: chap.chidx &+ offset)
      end
    end

    chaps
  end

  def chinfo(chidx : Int16)
    self.chlist((chidx &- 1)//128).data[chidx]?
  end

  def chtext(chidx : Int16, cpart = 0_i16, redo = false, uname = "")
    unless chinfo = self.chinfo(chidx)
      return [] of String
    end

    chtext(chinfo, cpart, redo, uname)
  end

  def chtext(chinfo : ChInfo, cpart = 0_i16, redo = false, uname = "")
    if proxy = chinfo.proxy
      return chtext_from_mirror(chinfo, proxy, cpart, redo, uname)
    end

    chtext = ChText.new(sname, snvid, chinfo)
    chdata = chtext.load!(cpart)

    if @is_remote && (redo || chdata.lines.empty?)
      chdata = chtext.fetch!(cpart, ttl: redo ? 1.minutes : 10.years)
      chinfo.stats.uname = uname
      self.patch!([chinfo])
    elsif chinfo.stats.parts == 0
      # check if text existed in zip file but not stored in index
      chtext.remap!
      self.patch!([chinfo])
    end

    chdata.lines
  rescue
    [] of String
  end

  def chtext_from_mirror(chinfo, proxy, cpart, redo, uname)
    mirror_repo = ChRepo.load!(proxy.sname, proxy.snvid)
    return [] of String unless mirror_info = mirror_repo.chinfo(proxy.chidx)

    chtext = mirror_repo.chtext(mirror_info, cpart, redo, uname)
    chinfo.stats = mirror_info.stats
    patch!([chinfo])
    chtext
  end
end
