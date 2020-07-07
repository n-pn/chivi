require "file_utils"

require "./engine"

require "./kernel/book_info"
require "./kernel/book_meta"
require "./kernel/chap_list"
require "./kernel/chap_text"

require "./kernel/import/remote_info"
require "./kernel/import/remote_text"

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
    return {ChapList.new, 0_i64} unless bsid = info.cr_sitemap[site]?

    file = ChapList.path_for(info.uuid, site)
    expiry = reload ? 6.minutes : gen_expiry(info.status)

    mftime = info.last_times[site]? || InfoSpider::EPOCH
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
      if changed?(latest, info.last_csids[site]?)
        info.last_csids[site] = latest.csid
        info.last_texts[site] = latest.vi_title
        info.last_slugs[site] = latest.title_slug

        if new_mftime <= mftime
          if info.mftime > mftime
            new_mftime = info.mftime
          else
            new_mftime = Time.local.to_unix_ms
          end
        end

        mftime = new_mftime
        info.set_mftime(mftime)
        info.last_times[site] = mftime

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
    new_latest.csid != old_latest
  end
end

# info = BookRepo.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
