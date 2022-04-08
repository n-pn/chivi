require "../shared/bootstrap"
require "../shared/ysbook_data"

class CV::YsbookSeed
  INP_DIR = "_db/yousuu/infos"
  OUT_DIR = "var/ysbooks"
  Dir.mkdir_p(OUT_DIR)

  CACHE = {} of String => NvinfoData

  def load_data(slice : String | Int32)
    CACHE[slice.to_s] ||= YsbookData.new("#{OUT_DIR}/#{slice}")
  end

  def init!(redo = false)
    Dir.each_child(INP_DIR) do |child|
      output = load_data(child.to_i)

      inputs = Dir.glob("#{INP_DIR}/#{child}/*.json").map do |file|
        {file, File.basename(file, ".json")}
      end

      inputs.sort_by(&.[1].to_i).each do |file, snvid|
        stime = NvinfoData.stime(file)

        if bindex = output._index[snvid]?
          next unless redo || bindex.stime < stime
        end

        next unless input = RawYsbook.parse_file(file)
        output.add!(input, snvid, stime)
      rescue err
        puts [file, err.message.colorize.red]
      end

      output.save!(clean: true)
    end
  end

  def seed!(force = false)
    NvinfoData.print_stats("yousuu")

    Dir.children(OUT_DIR).each_with_index(1) do |child, index|
      load_data(child).seed!(force: force, index: index)
    end
  end

  def self.run!(argv = ARGV)
    init = 1
    seed = 1

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: ysbook_seed [arguments]"
      parser.on("-i INIT", "Init mode: 0 => skip, 1 => only updated, 2 => reinit all") { |x| init = x.to_i }
      parser.on("-s SEED", "Seed mode: 0 => skip, 1 => only updated, 2 => reseed all") { |x| seed = x.to_i }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    task = new
    task.init!(redo: init == 2) if init > 0
    task.seed!(force: seed == 2) if seed > 0
  end
end

CV::YsbookSeed.run!(ARGV)
