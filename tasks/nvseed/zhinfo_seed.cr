require "../shared/bootstrap"
require "../shared/nvseed_data"

class CV::RemoteSeed
  INP_DIR = "_db/.cache/"
  OUT_DIR = "var/zhinfos"

  def initialize(@sname : String)
    @inp_dir = File.join(INP_DIR, @sname, "infos")
    @out_dir = File.join(OUT_DIR, @sname)

    Dir.mkdir_p(@inp_dir)
    Dir.mkdir_p(@out_dir)
  end

  def prep!(upper : Int32, mode : Int32 = 0)
    workers = ideal_workers
    channel = Channel(Nil).new(workers)

    1.upto(upper) do |snvid|
      spawn do
        file = File.join(@inp_dir, "#{snvid}.html.gz")
        next if mode <= 2 && File.exists?(file)

        seed = load_data(snvid // 1000)
        if bindex = seed._index[snvid.to_s]?
          next if mode <= 1 || !bindex.btitle.empty?
        end

        link = SiteLink.info_url(@sname, snvid.to_s)
        `curl -L -k -s -f -m 30 '#{link}' | gzip > #{file}`

        puts "- <#{snvid}/#{upper} #{file} saved".colorize.green if $?.success?
        throlt_crawl!
      ensure
        channel.send(nil)
      end
      channel.receive if idx > workers
    end

    workers.time { channel.receive }
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

  def init!(upper : Int32, mode : Int32 = 0)
    parts = (1..upper).group_by(&.// 1000)
    pars.each do |group, items|
      workers = 10
      channel = Channel(RemoteInfo)
    end

    input = [] of {Int32, Int64}

    1.upto(upper) do |snvid|
      file = File.join(@inp_dir, "#{snvid}.html.gz")

      next unless info = File.info?(file)
      {snvid, info.modification_time.to_unix}
    end

    puts "[#{@sname}], parsing: #{input.size}\n".colorize.cyan.bold

    parts = input.group_by { |x| (x[0]) // 1000 }

    parts.each do |group, items|
    end
  end

  def init_group!(group : Int32, items : Array(Int32))
    output = load_data(group)

    items.each do |snvid|
      if bindex = output._index[snvid.to_s]?
        next unless mode == 2 || bindex.stime < stime
      end

      next unless input = RemoteInfo.new(@sname, snvid).get_parser
      output.add!(input, snvid, stime)
    rescue err
      puts [snvid, err.message.colorize.red]
    end

    output.save!(clean: true)
  end

  CACHE = {} of String => NvseedData

  def load_data(slice : String | Int32)
    CACHE[slice.to_s] ||= NvseedData.new(@sname, "#{@out_dir}/#{slice}")
  end

  def seed!(force = false)
    return unless File.exists?(@out_dir)
    NvinfoData.print_stats(@sname)

    input = Dir.children(@out_dir).compact_map(&.to_i?).sort
    input.each_with_index(1) do |child, index|
      load_data(child).seed!(force: force, label: "#{index}/#{input.size}")
    end
  end
end

snames = CV::SnameMap::MAP_INT.keys

prep_mode = 1
init_mode = 1
seed_mode = 1

OptionParser.parse(ARGV) do |parser|
  parser.banner = "Usage: remote_seed [arguments]"
  parser.on("-p PREP", "Prep mode: 0 => skip, 1 => only missing, 2 => fixing 404") { |x| init_mode = x.to_i }
  parser.on("-i INIT", "Init mode: 0 => skip, 1 => only updated, 2 => reinit all") { |x| init_mode = x.to_i }
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
  upper = upper_map[sname]? || 0

  task = CV::RemoteSeed.new(sname)
  task.prep!(upper, mode: prep_mode) if prep_mode > 0
  task.init!(upper, mode: init_mode) if init_mode > 0
  task.seed!(force: seed_mode == 2) if seed_mode > 0
end
