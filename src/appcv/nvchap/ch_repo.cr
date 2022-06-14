require "../../mtlv1/mt_core"

class CV::ChRepo
  DIR = "var/chtexts"

  # CACHE = RamCache(String, self).new(512, 3.hours)

  # def self.load!(sname : String, snvid : String)
  #   CACHE.get("#{sname}/#{snvid}") { new(sname, snvid) }
  # end

  # def self.load!(seed : Nvseed)
  #   CACHE.get("#{seed.sname}/#{seed.snvid}") do
  #     new(seed.sname, seed.snvid).tap do |x|
  #       x.chmax = seed.chap_count
  #       x.utime = seed.utime
  #     end
  #   end
  # end

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
  end

  def after_initialize
    Dir.mkdir_p(File.dirname(@fseed))
    Dir.mkdir_p(File.dirname(@fstat))
    Dir.mkdir_p(@chdir)

    Dir.mkdir_p("var/chmetas/.html/#{@sname}/#{@snvid}") if @is_remote
  end

  ZH_PSIZE = 128

  def map_pg(chidx : Int32)
    (chidx &- 1) // ZH_PSIZE
  end

  getter zpages = {} of Int32 => ChList

  def reset_cache!(chmin = 1, chmax = 8096)
    return if @zpages.empty?

    pgmin = map_pg(chmin)
    pgmax = map_pg(chmax)
    (pgmin..pgmax).each { |x| @zpages.delete(x) }
  end

  def chlist(pg_zh : Int32)
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

    pgmax = self.map_pg(infos.size)
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

  def clone!(chmin : Int32, chmax : Int32, offset = 0) : Array(ChInfo)
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
end
