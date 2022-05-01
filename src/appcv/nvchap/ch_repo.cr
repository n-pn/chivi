require "../../cvmtl/mt_core"

class CV::ChRepo
  DIR = "var/chtexts"

  getter fseed : String
  getter fstat : String

  def initialize(@sname : String, @snvid : String, @dname : String)
    @fseed = "var/chmetas/seeds/#{sname}/#{snvid}.tsv"
    @fstat = "var/chmetas/stats/#{sname}/#{snvid}.log"

    Dir.mkdir_p("var/chmetas/.html/#{sname}/#{snvid}")
    Dir.mkdir_p("#{DIR}/#{@sname}/#{@snvid}")
  end

  getter cvmtl : MtCore { MtCore.generic_mtl(nvinfo.dname) }

  ZH_PSIZE = 128

  @[AlwaysInline]
  def zh_pg(chidx : Int32)
    (chidx &- 1) // ZH_PSIZE
  end

  ZH_LISTS = RamCache(String, ChList).new(4096, 3.days)

  def chlist(zh_pg : Int32)
    label = "#{@sname}/#{@snvid}/#{zh_pg}"
    ZH_LISTS.get(label) { ChList.new("#{DIR}/#{label}.tsv") }
  end

  def regen!(force : Bool = false) : ChInfo?
    infos = ChList.new(@fseed).data.values

    if infos.empty?
      infos = fetch!(10.years)
      spawn ChList.save!(@fseed, infos)
    end

    self.store!(infos, reset: force)
    infos.last?
  end

  private def fetch!(ttl = 10.years)
    parser = RemoteInfo.new(@sname, @snvid, ttl: ttl)
    output = parser.chap_infos
    output.empty? && ttl != 1.hours ? fetch!(1.hours) : output
  end

  # save all infos, bail early if result is the same
  def store!(infos : Array(ChInfo), reset = false) : Nil
    return if infos.empty?

    pgmax = self.zh_pg(infos.size)
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

    input.group_by { |x| self.zh_pg(x.chidx) }.each do |pgidx, infos|
      self.chlist(pgidx).tap(&.patch(infos)).save!
    end
  end

  def fetch_as_proxies!(chmin : Int32, chmax : Int32) : Array(ChInfo)
    pgmin = self.zh_pg(chmin)
    pgmax = self.zh_pg(chmax) + 1
    chaps = [] of ChInfo

    pgmin.upto(pgmax) do |pgidx|
      input = self.chlist(pgidx).data.values.sort_by!(&.chidx)
      input.each do |chap|
        break if chap.chidx > chmax
        chaps << chap.as_proxy!(@sname, @snvid) unless chap.chidx < chmin
      end
    end

    chaps
  end
end
