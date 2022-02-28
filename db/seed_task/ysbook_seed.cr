require "./nvinfo_seed"

class CV::YsbookSeed
  def seed!(upper = 27000, mode = 0)
    1.upto(upper) do |ynvid|
      NvinfoSeed.log("yousuu", "#{ynvid}/#{upper}") if ynvid % 1000 == 0
      seed_entry!(ynvid, mode: mode)
    end

    NvinfoSeed.log("yousuu", "#{upper}/#{upper}")
  end

  def seed_entry!(ynvid : Int32, mode = 0)
    load_entry(ynvid, mode: mode).try { |entry| seed_entry!(entry) }
  end

  def seed_entry!(entry : YsbookInit)
    NvinfoSeed.seed!(entry) do |nvinfo|
      if nvinfo.ys_snvid != entry._id
        return if nvinfo.ys_voters >= entry.voters
        puts "!! override: #{nvinfo.ys_snvid} (#{nvinfo.ys_voters}) \
              => #{entry._id} (#{entry.voters})".colorize.red
      end

      nvinfo.shield = entry.shield
      nvinfo.set_ys_scores(entry.voters, entry.rating)

      nvinfo.ys_snvid = entry._id.to_i64
      nvinfo.ys_utime = entry.utime_int

      nvinfo.pub_name = entry.pub_name
      nvinfo.pub_link = entry.pub_link

      nvinfo.yslist_count = entry.list_count
      nvinfo.yscrit_count = entry.crit_count

      nvinfo.ys_word_count = entry.word_count
    end
  end

  def load_entry(ynvid : Int32, mode = 0) : YsbookInit?
    return unless entry = YsbookInit.load(ynvid, mode: mode)
    NvinfoSeed.fix_names!(entry)

    return entry if entry.good? || NvinfoSeed.get_author(entry.author)
  rescue err
    puts [ynvid, err.colorize.red]
  end

  ##################

  MAX_FILE = "tasks/_config/ysbook_max.txt"

  def self.run!(argv = ARGV)
    upper = File.read(MAX_FILE).strip.to_i
    mode = 0

    OptionParser.parse(argv) do |opt|
      opt.on("-u UPPER", "Max ynvid") { |i| upper = i.to_i }
      opt.on("-m MODE", "Seed mode") { |i| mode = i.to_i }
      opt.unknown_args { |x| argv = x }
    end

    new.seed!(upper: upper, mode: mode)
  end
end

CV::YsbookSeed.run!
