require "./init_nvinfo.cr"
require "../shared/ysbook_raw.cr"

class CV::YsbookSeed
  DIR = "_db/yousuu/infos"

  getter seed = InitNvinfo.new("yousuu")

  def init!(redo = false)
    dirs = Dir.children(DIR)
    dirs.each_with_index(1) do |dir, i|
      Log.info { "\n[[#{i}/#{dirs.size}]]\n".colorize.yellow }

      entries = Dir.glob("#{DIR}/#{dir}/*.json").map do |file|
        snvid = File.basename(file, ".json")
        atime = FileUtil.mtime(file).try(&.to_unix) || 0_i64
        {file, snvid, atime}
      end

      entries.sort_by!(&.[1].to_i)
      entries.each do |file, snvid, atime|
        next unless redo || @seed.staled?(snvid, atime)

        entry = YsbookRaw.parse_file(file)
        @seed.add!(entry, snvid, atime)

        @seed.set_val!(:rating, snvid, [entry.voters, entry.rating])
        @seed.set_val!(:origin, snvid, [entry.pub_name, entry.pub_link])
        @seed.set_val!(:extras, snvid, [entry.list_total, entry.crit_count, entry.word_count, entry.shield])
      rescue err
        @seed.set_val!(:_index, snvid.not_nil!, [atime.to_s, "", ""])

        unless err.is_a?(YsbookRaw::InvalidFile)
          Log.error { "- error loading [#{snvid}]:" }
          Log.error { err.inspect_with_backtrace.colorize.red }
        end
      end

      @seed.save_stores!
    end
  end

  def seed!(only_cached = true)
    @seed.seed_all!(only_cached: only_cached)
  end

  def self.run!(argv = ARGV)
    init = false
    redo = false

    OptionParser.parse(argv) do |opt|
      opt.on("-i", "Init info") { init = true }
      opt.on("-r", "Redo init") { redo = true }
      opt.unknown_args { |x| argv = x }
    end

    seeder = new
    seeder.init!(redo: redo) if init
    seeder.seed!(only_cached: init)
  end
end

CV::YsbookSeed.run!
