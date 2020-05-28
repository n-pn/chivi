require "file_utils"

require "./engine"

require "./spider/info_spider"
require "./spider/text_spider"

require "./bookdb/book_info"
require "./bookdb/chap_list"
require "./bookdb/chap_text"

module Kernel
  extend self

  def gen_expiry(status)
    case status
    when 0
      6.hours
    when 1
      6.weeks
    else
      6.months
    end
  end

  def load_list(info : VpInfo, site : String, user = "local", reload = false) : Tuple(ChapList, Int64)
    unless bsid = info.cr_anchors[site]?
      return {ChapList.new, 0_i64}
    end

    file = ChapList.path_for(info.uuid, site)
    expiry = reload ? 6.minutes : gen_expiry(info.status)
    unless Utils.outdated?(file, expiry)
      mftime = File.info(file).modification_time.to_unix_ms
      return {ChapList.read!(file), mftime}
    end

    spider = InfoSpider.load(site, bsid, expiry: expiry, frozen: false)
    mftime = spider.get_mftime!
    old_mftime = info.cr_mftimes[site]? || 0

    if mftime > old_mftime
      info.set_status(spider.get_status!)
      info.set_mftime(mftime)
      info.cr_mftimes[site] = mftime

      BookRepo.save!(info)
    end

    chaps = spider.get_chaps!

    chaps.each do |item|
      item.vi_title = Engine.translate(item.zh_title, info.uuid, user, title: true)
      item.vi_volume = Engine.translate(item.zh_volume, info.uuid, user, title: true)

      item.gen_slug(20)
    end

    ChapList.save!(file, chaps)
    {chaps, mftime}
  end

  def load_chap(info : VpInfo, site : String, csid : String, user = "guest", mode = 0, unique : Bool = false)
    bsid = info.cr_anchors[site]
    uuid = VpText.uuid_for(info.uuid, site, bsid)

    json_file = VpText.path_for(uuid, csid, user)
    return VpText.load!(json_file) if mode == 0 && File.exists?(json_file)

    text_file = File.join("data", "zh_texts", uuid, "#{csid}.txt")

    if mode == 1 && File.exists?(text_file)
      lines = File.read_lines(text_file)
    else
      spider = TextSpider.load(site, bsid, csid, expiry: 10.years, frozen: false)
      lines = [spider.get_title!].concat(spider.get_paras!)

      FileUtils.mkdir_p(File.dirname(text_file))
      File.write(text_file, lines.join("\n"))
    end

    content = Engine.convert(lines, book: info.uuid, user: user, mode: :mixed)

    FileUtils.mkdir_p(File.dirname(json_file))
    File.write(json_file, content.to_json)

    content
  end
end

# info = BookRepo.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
