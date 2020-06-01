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
    return {ChapList.new, 0_i64} unless bsid = info.cr_anchors[site]?

    file = ChapList.path_for(info.uuid, site)
    expiry = reload ? 1.minutes : gen_expiry(info.status)

    mftime = info.cr_mftimes[site]? || InfoSpider::EPOCH
    return {ChapList.read!(file), mftime} unless Utils.outdated?(file, expiry)

    spider = InfoSpider.load(site, bsid, expiry: expiry, frozen: false)

    chaps = spider.get_chaps!
    chaps.each do |item|
      item.vi_title = Engine.translate(item.zh_title, info.uuid, user, true)
      item.vi_volume = Engine.translate(item.zh_volume, info.uuid, user, true)
      item.gen_slug(20)
    end

    new_mftime = spider.get_mftime!

    if latest = chaps.last?
      if changed?(latest, info.cr_latests[site]?)
        info.cr_latests[site] = {
          csid: latest.csid,
          name: latest.vi_title,
          slug: latest.title_slug,
        }

        if new_mftime <= mftime &&
           if info.mftime > mftime
             new_mftime = info.mftime
           else
             new_mftime = Time.local.to_unix_ms
           end
        end

        mftime = new_mftime
        info.set_mftime(mftime)
        info.cr_mftimes[site] = mftime
        info.set_status(spider.get_status!)

        BookRepo.save!(info)
      end
    end

    ChapList.save!(file, chaps)

    {chaps, mftime}
  end

  private def changed?(new_latest : ChapItem?, old_latest)
    return false unless new_latest
    return true unless old_latest
    new_latest.csid != old_latest[:csid]
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
