require "json"
require "colorize"
require "file_utils"

require "../src/engine"
require "../src/models/book_info"
require "../src/models/chap_list"

require "../src/spider/info_spider"

def translate(input : String)
  return input if input.empty?
  Engine.translate(input, title: true, book: nil, user: "local")
end

def gen_expiry(status : Int32)
  case status
  when 0 then 10.hours
  when 1 then 10.days
  else        10.weeks
  end
end

def update_infos(info, label)
  return if info.cr_anchors.empty?

  puts "- <#{label.colorize(:cyan)}> #{info.zh_title.colorize(:cyan)}--#{info.zh_author.colorize(:cyan)}"

  expiry = gen_expiry(info.status)
  update = false

  info.cr_anchors.each do |site, bsid|
    out_file = ChapList.path_for(info.uuid, site)

    time = site == "paoshu8" ? 10.months : expiry
    spider = InfoSpider.load(site, bsid, expiry: time, frozen: true)

    mftime = spider.get_mftime!
    next unless Utils.outdated?(out_file, Time.unix_ms(mftime))

    info.set_status(spider.get_status!)

    info.set_mftime(mftime)
    info.cr_mftimes[site] = mftime
    update = true

    chaps = spider.get_chaps!
    chaps.each do |item|
      item.vi_title = translate(item.zh_title)
      item.vi_volume = translate(item.zh_volume)
      item.gen_slug(20)
    end

    ChapList.save!(out_file, chaps) if update
  rescue err
    puts "- [#{site}-#{bsid}] #{err}".colorize(:red)
  end

  BookInfo.save!(info)
end

FileUtils.mkdir_p(ChapList::DIR)

infos = BookInfo.load_all.values.sort_by!(&.tally.-)
puts "- input: #{infos.size}"

puts translate("WARM UP!")

limit = 10
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
