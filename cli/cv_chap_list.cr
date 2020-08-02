require "json"
require "colorize"
require "file_utils"

require "../src/libcv"
require "../src/kernel/bookdb"
require "../src/kernel/chapdb"

def translate(input : String, dname : String)
  return input if input.empty?
  Libcv.cv_title(input, dname).vi_text
end

def gen_expiry(status : Int32)
  case status
  when 0 then 10.hours
  when 1 then 10.days
  when 2 then 10.weeks
  else        10.months
  end
end

def translate_chap(chap : ChapInfo, dname : String)
  if chap.vi_label.empty?
    chap.vi_label = translate(chap.zh_label, dname)
  end

  if chap.vi_title.empty?
    chap.vi_title = translate(chap.zh_title, dname)
    chap.set_slug(chap.vi_title)
  end

  chap
end

SKIP_PAOSHU8 = ARGV.includes?("skip_paoshu8")

def update_infos(info, label)
  return if info.seed_names.empty?
  puts "- <#{label}> #{info.ubid}--#{info.slug}".colorize.cyan.bold

  expiry = Time.utc - gen_expiry(info.status)

  info.seed_sbids.each do |name, sbid|
    next unless info.seed_types[name]? == 0
    next if SKIP_PAOSHU8 && name == "paoshu8"

    remote = SeedInfo.init(name, sbid, expiry: expiry, freeze: true)
    BookDB.update_info(info, remote)

    next unless ChapList.outdated?(info.ubid, name, Time.unix_ms(info.mftime))
    chlist = ChapList.get!(info.ubid, name)

    ChapDB.update_list(chlist, remote)
    chlist.save! if chlist.changed?
  rescue err
    puts "- <cv_chap_list> error loading: [#{name}/#{sbid}]:  #{err}".colorize.red
  end
end

infos = BookInfo.load_all!.sort_by!(&.weight.-)
puts "- input: #{infos.size}"

puts translate("WARM UP!", "combine")

limit = 8
channel = Channel(Nil).new(limit)

infos.each_with_index do |info, idx|
  channel.receive unless idx < limit

  spawn do
    update_infos(info, "#{idx + 1}/#{infos.size}")
  ensure
    channel.send(nil)
  end
end

limit.times { channel.receive }
