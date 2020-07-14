require "json"
require "colorize"
require "file_utils"

require "../src/engine"
require "../src/models/book_info"
require "../src/models/chap_list"
require "../src/source/remote_info"

def translate(input : String, dname : String)
  return input if input.empty?
  Engine.cv_title(input, dname).vi_text
end

def gen_expiry(status : Int32)
  case status
  when 0 then 10.hours
  when 1 then 10.days
  when 2 then 10.weeks
  else        10.months
  end
end

def translate_chap(chap : ChapItem, dname : String)
  if chap.label_vi.empty?
    chap.label_vi = translate(chap.label_zh, dname)
  end

  if chap.title_vi.empty?
    chap.title_vi = translate(chap.title_zh, dname)
    chap.set_slug(chap.title_vi)
  end

  chap
end

SKIP_PAOSHU8 = ARGV.includes?("skip_paoshu8")

def update_infos(info, label)
  return if info.seed_infos.empty?
  puts "- <#{label}> #{info.ubid}--#{info.slug}".colorize.cyan.bold

  expiry = gen_expiry(info.status)

  info.seed_infos.each_value do |seed|
    next if seed.type > 0
    next if SKIP_PAOSHU8 && seed.name == "paoshu8"

    remote = RemoteInfo.new(seed.name, seed.sbid, expiry: expiry, freeze: true)
    remote.emit_book_info(info)

    if info.changed?
      latest = translate_chap(seed.latest, info.ubid)
      info.update_seed(seed.name, seed.sbid, remote.mftime, latest)
      info.save!
    end

    if ChapList.outdated?(info.ubid, seed.name, Time.unix_ms(info.mftime))
      chaps = remote.emit_chap_list
    else
      chaps = ChapList.get!(info.ubid, seed.name)
    end

    chaps.each_with_index do |chap, idx|
      chaps.upsert(translate_chap(chap, info.ubid), idx)
    end

    chaps.save! if chaps.changed?
  rescue err
    puts "- <cv_chap_list> error loading: [#{seed.name}/#{seed.sbid}]:  #{err}".colorize.red
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
