class CV::ChRepo
  DIR = "var/chtexts"

  def initialize(@sname : String, @snvid : String)
    @fraw = "#{DIR}/#{sname}/_/#{snvid}.tsv"
    @flog = "#{DIR}/#{sname}/_/#{snvid}.log"
    FileUtils.mkdir_p("#{DIR}/#{@sname}/#{@snvid}")
  end

  PSIZE = 128

  def pgidx(chidx : Int32)
    (chidx - 1) // PSIZE
  end

  LISTS = RamCache(String, ChList).new(4096, 3.days)

  def chlist(pgidx : Int32)
    label = "#{@sname}/#{@snvid}/#{pgidx}"
    LISTS.get(label) { ChList.new("#{DIR}/#{label}.tsv") }
  end

  def chinfo(chidx : Int32)
    self.chlist(chidx).data[chidx]?
  end

  # expand data from @fraw and @flog to pages
  def reset!
    infos = ChList.new(@fraw).data.values.sort_by(&.chidx)

    if infos.empty?
      case SeedUtil.map_type(@sname)
      when 2 then infos = fetch!(10.years) # dead remote
      when 3 then infos = fetch!(1.months) # slow remote
      when 4 then infos = fetch!(1.weeks)  # fast remote
      end
    end

    self.store!(infos, reset: true)
    infos.last?
  end

  def fetch!(ttl = 10.years)
    parser = RemoteInfo.new(@sname, @snvid, ttl: ttl)
    output = parser.chap_infos
    output.empty? && ttl != 1.hours ? fetch!(1.hours) : output
  end

  # save all infos, bail early if result is the same
  def store!(infos : Array(ChInfo), reset = false) : Nil
    ChList.save!(@fraw, infos, mode: "w")

    pgmax = self.pgidx(infos.size)
    chmin = pgmax * PSIZE

    chlist = self.chlist(pgmax)
    chmin.upto(infos.size - 1).each { |index| chlist.store(infos[index]) }
    chlist.save!

    (pgmax - 1).downto(0).each do |pgidx|
      chlist = self.chlist(pgidx)
      changed = true

      PSIZE.times do
        chmin -= 1
        chlist.store(infos.unsafe_fetch(chmin)).tap { |x| changed ||= x }
      end

      changed ? chlist.save! : (break unless reset)
    end
  end

  def patch!(input : Array(ChInfo)) : Nil
    ChList.save!(@fraw, input, "a") if @sname == "users"
    ChList.save!(@flog, input, "a") unless @sname == "chivi"

    input.group_by { |x| self.pgidx(x.chidx) }.each do |pgidx, infos|
      self.chlist(pgidx).tap(&.patch(infos)).save!
    end
  end

  def fetch_as_proxies!(chmin : Int32, chmax : Int32) : Array(ChInfo)
    pgmin = self.pgidx(chmin)
    pgmax = self.pgidx(chmax) + 1
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

  def remote?(privi : Int32 = 4, special_case : Bool = false) : Bool
    remote?(privi) { special_case }
  end

  def remote?(privi : Int32 = 4) : Bool
    case @sname
    when "biqu5200", "rengshu", "sdyfcm"
      privi >= 0 || yield
    when "hetushu", "bxwxorg", "xbiquge", "biqugee"
      privi >= 1 || yield
    when "69shu", "paoshu8", "duokan8" # , "5200"
      privi >= 2 || yield
    when "shubaow", "zhwenpg"
      privi > 4
    else false
    end
  end
end
