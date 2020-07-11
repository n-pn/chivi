require "json"
require "colorize"
require "file_utils"

require "../src/engine"
require "../src/kernel/book_info"
require "../src/kernel/chap_list"

require "../src/source/info_spider"

def translate(input : String, book : String)
  return input if input.empty?
  Engine.translate(input, book: book, user: "local", title: true)
end

def gen_expiry(status : Int32)
  case status
  when 0 then 10.hours
  when 1 then 10.days
  else        10.weeks
  end
end

def update_infos(info, label)
  return if info.cr_sitemap.empty?

  puts "- <#{label.colorize(:cyan)}> #{info.zh_title.colorize(:cyan)}--#{info.zh_author.colorize(:cyan)}"

  expiry = gen_expiry(info.status)
  update = false

  info.cr_sitemap.each do |site, bsid|
    # next if site == "duokan8"
    # next if site == "paoshu8" || site == "duokan8"

    out_file = ChapList.path_for(info.uuid, site)
    spider = InfoSpider.load(site, bsid, expiry: expiry, frozen: true)

    mftime = spider.get_mftime!
    next unless Utils.outdated?(out_file, Time.unix_ms(mftime))

    info.set_status(spider.get_status!)

    info.set_mftime(mftime)
    if old_mftime = info.last_times[site]? || 0_i64
      info.last_times[site] = mftime if mftime > old_mftime
    end

    chaps = spider.get_chaps!
    chaps.each do |item|
      item.vi_title = translate(item.zh_title, info.uuid)
      item.vi_volume = translate(item.zh_volume, info.uuid)
      item.gen_slug(20)
    end

    ChapList.save!(out_file, chaps)

    if latest = chaps.last?
      info.cr_latests[site] = {
        csid: latest.csid,
        name: latest.vi_title,
        slug: latest.title_slug,
      }
    end

    update = true
  rescue err
    puts "- [#{site}-#{bsid}] #{err}".colorize(:red)
  end

  VpInfo.save!(info) if update
end

FileUtils.mkdir_p(ChapList::DIR)

infos = VpInfo.load_all.values.sort_by!(&.tally.-)
puts "- input: #{infos.size}"

puts translate("WARM UP!", "tong-hop")

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
