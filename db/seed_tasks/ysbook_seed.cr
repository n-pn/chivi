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
    ysbook = Ysbook.upsert!(entry._id.to_i64)

    if ysbook.info_stime < entry.stime
      ysbook.btitle = entry.btitle
      ysbook.author = entry.author

      ysbook.voters = entry.voters
      ysbook.scores = entry.voters &* entry.rating

      ysbook.pub_name = entry.pub_name
      ysbook.pub_link = entry.pub_link

      ysbook.list_total = entry.list_count
      ysbook.crit_total = entry.crit_count

      ysbook.list_count = entry.list_count if ysbook.list_count == 0
      ysbook.crit_count = entry.crit_count if ysbook.crit_count == 0

      ysbook.utime = entry.update_int
      ysbook.status = entry.status

      ysbook.word_count = entry.word_count
      ysbook.info_stime = entry.stime
    end

    NvinfoSeed.seed!(entry) do |nvinfo|
      ysbook.nvinfo_id = nvinfo.id
      ysbook.save!

      if old_entry = load_ysbook(nvinfo.ysbook_id, ysbook.id)
        return if ysbook.voters <= old_entry.voters

        puts "!! override: #{old_entry.id} (#{old_entry.voters}) \
              => #{entry._id} (#{entry.voters})".colorize.yellow
      end

      nvinfo.set_shield(entry.shield)
      nvinfo.fix_scores!(ysbook.voters, ysbook.scores)

      nvinfo.ysbook_id = ysbook.id
      nvinfo.pub_name = entry.pub_name
      nvinfo.pub_link = entry.pub_link
    end
  end

  def load_ysbook(id : Int64, curr_id : Int64)
    return if id == 0 || id == curr_id
    Ysbook.find({id: id})
  end

  def load_entry(ynvid : Int32, mode = 0) : YsbookInit?
    return unless entry = YsbookInit.load(ynvid, mode: mode)
    NvinfoSeed.fix_names!(entry)

    return entry if entry.keep? || NvinfoSeed.get_author(entry.author)
  rescue err
    puts [ynvid, err.colorize.red]
  end

  ##################

  MAX_FILE = "_db/yousuu/limit.txt"

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
