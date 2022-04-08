require "../shared/bootstrap"
require "../shared/nvseed_data"

class CV::RemoteSeed
  INP_DIR = "_db/.cache/"
  OUT_DIR = "var/zhinfos"

  def initialize(@sname : String)
    @out_dir = File.join(OUT_DIR, @sname)
  end

  def init!(mode : Int32 = 0)
    indir = File.join(INP_DIR, @sname, "infos")
    input = Dir.glob("#{indir}/*.html.gz").compact_map do |file|
      snvid = File.basename(file, ".html.gz")
      next if snvid.includes?("mulu")

      stime = File.info(file).modification_time.to_unix
      {snvid, stime}
    end

    puts "[#{@sname}], parsing: #{input.size}\n".colorize.cyan.bold

    parts = input.group_by { |x| (x[0].to_i? || 0) // 1000 }

    parts.each do |group, items|
      output = load_data(group)

      items.sort_by(&.[0].to_i).each do |snvid, stime|
        if bindex = output._index[snvid]?
          next unless mode == 2 || bindex.stime < stime
        end

        next unless input = RemoteInfo.new(@sname, snvid).get_parser
        output.add!(input, snvid, stime)
      rescue err
        puts [snvid, err.message.colorize.red]
      end

      output.save!(clean: true)
    end
  end

  CACHE = {} of String => NvseedData

  def load_data(slice : String | Int32)
    CACHE[slice.to_s] ||= NvseedData.new(@sname, "#{OUT_DIR}/#{slice}")
  end

  def seed!(force = false)
    NvinfoData.print_stats(@sname)

    input = Dir.children(OUT_DIR).compact_map(&.to_i?).sort
    input.each_with_index(1) do |child, index|
      load_data(child).seed!(force: force, label: "#{index}/#{input.size}")
    end
  end
end

snames = ["hetushu"]
init_mode = 1
seed_mode = 1

OptionParser.parse(ARGV) do |parser|
  parser.banner = "Usage: remote_seed [arguments]"
  parser.on("-i INIT", "Init mode: 0 => skip, 1 => only updated, 2 => reinit all") { |x| init_mode = x.to_i }
  parser.on("-s SEED", "Seed mode: 0 => skip, 1 => only updated, 2 => reseed all") { |x| seed_mode = x.to_i }

  parser.unknown_args { |x| snames = x unless x.empty? }

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: `#{flag}` is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

snames.each do |sname|
  task = CV::RemoteSeed.new(sname)
  task.init!(mode: init_mode) if init_mode > 0
  task.seed!(force: seed_mode == 2) if seed_mode > 0
end
