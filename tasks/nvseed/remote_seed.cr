require "./zhinfo_data"

class CV::RemoteSeed
  INP_DIR = "_db/.cache/"
  OUT_DIR = "var/zhinfos"

  getter data : ZhinfoData
  delegate seed!, to: @data

  def initialize(@sname : String, @group : Int32, @total : Int32)
    @lower = @group &* 1000 &+ 1
    @upper = @lower &+ 999
    @upper = total if @upper > total

    @inp_dir = "#{INP_DIR}/#{sname}/infos"
    @out_dir = "#{OUT_DIR}/#{sname}/#{group}"

    @data = ZhinfoData.new(sname, @out_dir)

    Dir.mkdir_p(@inp_dir)
    Dir.mkdir_p(@out_dir)
  end

  def init!(mode : Int32 = 0)
    changed, missing, empties = scan_cached()

    add_changed!(changed)
    add_missing!(missing) if mode > 0
    add_missing!(empties) if mode > 1
    fetch_mulus! if mode > 1 && @sname.in?("69shu", "ptwxz")

    @data.save!(clean: true)
  end

  def fetch_mulus!
    workers = @upper - @lower + 1
    workers = 6 if workers > 6
    channel = Channel(Nil).new(workers)
    encoding = HttpUtil.encoding_for(@sname)

    @lower.upto(@upper).with_index(1) do |index, idx|
      spawn do
        snvid = index.to_s

        file = "_db/.cache/#{@sname}/infos/#{snvid}-mulu.html.gz"
        next if File.exists?(file)

        link = SiteLink.mulu_url(@sname, snvid)
        HttpUtil.cache(file, link, lbl: "#{idx + @lower}/#{@total}", encoding: encoding)
      ensure
        channel.send(nil)
      end

      channel.receive if idx > workers
    end

    workers.times { channel.receive }
  end

  def add_changed!(changed : Hash(String, Int64)) : Nil
    return if changed.empty?

    workers = changed.size
    workers = 6 if workers > 6

    channel = Channel(Nil).new(workers)

    offset = @group &* 1000

    changed.each_with_index(1) do |(snvid, stime), idx|
      spawn do
        parser = RemoteInfo.new(@sname, snvid, lbl: "#{idx &+ offset}/#{@total}")
        @data.add!(parser, snvid, stime)
      rescue err
        Log.error { err.inspect_with_backtrace }
      ensure
        channel.send(nil)
      end

      channel.receive if idx > workers
    end

    workers.times { channel.receive }
  end

  def add_missing!(missing : Array(String)) : Nil
    return if missing.empty?

    workers = ideal_workers
    workers = missing.size if workers > missing.size

    channel = Channel(Nil).new(workers)

    missing.each_with_index(1) do |snvid, idx|
      spawn do
        parser = RemoteInfo.new(@sname, snvid, ttl: 1.days, lbl: "#{snvid}/#{@total}")
        @data.add!(parser, snvid, Time.utc.to_unix)

        throlt_crawl!
      rescue err
        Log.error { err.inspect_with_backtrace }
      ensure
        channel.send(nil)
      end

      channel.receive if idx > workers
    end

    workers.times { channel.receive }
  end

  private def throlt_crawl!
    case @sname
    when "shubaow"
      sleep Random.rand(1000..2000).milliseconds
    when "zhwenpg"
      sleep Random.rand(500..1000).milliseconds
    when "biqu5200"
      sleep Random.rand(100..500).milliseconds
    end
  end

  private def ideal_workers
    case SnameMap.map_type(@sname)
    when 4 then 6
    when 3 then 3
    else        1
    end
  end

  def scan_cached
    workers = @upper - @lower + 1
    workers = 6 if workers > 6

    channel = Channel(Nil).new(workers)

    missing = [] of String
    empties = [] of String
    changed = {} of String => Int64

    @lower.upto(@upper).with_index(1) do |index, idx|
      spawn do
        snvid = index.to_s
        ifile = File.join(@inp_dir, "#{snvid}.html.gz")
        stime = NvinfoUtil.mtime(ifile)

        if !(bindex = @data._index[snvid]?)
          if stime
            changed[snvid] = stime
          else
            missing << snvid
          end
        elsif stime
          if stime > bindex.stime
            changed[snvid] = stime
          elsif bindex.btitle.empty?
            empties << snvid
          end
        end
      ensure
        channel.send(nil)
      end

      channel.receive if idx > workers
    end

    workers.times { channel.receive }

    puts "- from: #{@lower.colorize.yellow}, \
            upto: #{@upper.colorize.yellow}, \
            changed: #{changed.size.colorize.yellow}, \
            missing: #{missing.size.colorize.yellow}, \
            empties: #{empties.size.colorize.yellow}"

    {changed, missing, empties}
  end

  def self.run!(argv = ARGV)
    snames = CV::SnameMap::MAP_INT.keys.reject!(&.in? "union", "staff", "users", "zxcs_me")

    init_mode = 1
    seed_mode = 1

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: remote_seed [arguments]"
      parser.on("-i INIT", "Init mode: 0 => changed only, 1 => missing, 2 => redo empties") { |x| init_mode = x.to_i }
      parser.on("-s SEED", "Seed mode: 0 => skip, 1 => only updated, 2 => reseed all") { |x| seed_mode = x.to_i }

      parser.unknown_args { |x| snames = x unless x.empty? }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    upper_map = Tabkv(Int32).new("var/_common/upper.tsv")

    snames.each do |sname|
      next unless upper = upper_map[sname]?

      pages = (upper &- 1) // 1000

      0.upto(pages) do |group|
        puts "\nPAGE: [#{group}/#{pages}]".colorize.cyan.bold

        task = new(sname, group, upper)
        task.init!(mode: init_mode)
        task.seed!(seed_mode, label: "#{group}/#{pages}") if seed_mode >= 0
      end
    end
  end

  run!(ARGV)
end
