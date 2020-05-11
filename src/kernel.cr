require "./engine"

require "./spider/info_spider"
require "./spider/text_spider"

require "./models/book_info"
require "./models/chap_list"
require "./models/chap_text"

require "./kernel/book_repo"

module Kernel
  extend self

  def gen_expiry(status)
    case status
    when 0
      5.hours
    when 1
      5.days
    else
      5.weeks
    end
  end

  def load_list(info : BookInfo, site : String, refresh = false)
    return {site, ChapList.new} unless bsid = info.cr_anchors[site]?

    file = ChapList.path_for(info.uuid, site)
    expiry = refresh ? 10.minutes : gen_expiry(info.status)

    return ChapList.read!(file) unless Utils.outdated?(file, expiry)

    old_mftime = info.cr_mftimes[site]? || 0

    spider = InfoSpider.load(site, bsid, expiry: expiry, frozen: false)
    mftime = spider.get_mftime!

    if mftime > old_mftime
      info.set_status(spider.get_status!)
      info.set_mftime(mftime)
      info.cr_mftimes[site] = mftime
      BookRepo.save!(info)
    end

    chaps = spider.get_chaps!

    if File.exists?(file)
      old_chaps = ChapList.read!(file)
      old_chaps.each_with_index do |old_chap, idx|
        break unless new_chap = chaps[idx]
        next unless new_chap.zh_title == old_chap.zh_title

        new_chap.vi_title = old_chap.vi_title
        new_chap.vi_volume = old_chap.vi_volume
        new_chap.title_slug = old_chap.title_slug
      end
    end

    chaps.each do |item|
      if item.vi_title.empty?
        item.vi_title = Engine.translate(item.zh_title, title: true)
        item.gen_slug(20)
      end

      if item.vi_volume.empty?
        item.vi_volume = Engine.translate(item.zh_volume, title: true)
      end
    end

    ChapList.save!(file, chaps)
    chaps
  end

  def translate(input : String, title = true)
    return input if input.empty?
    Engine.translate(input, title: title, book: nil, user: "local")
  end

  # def load_text(site : String, bsid : String, csid : String, book : String? = nil, user = "local")
  #   file_out = "data/txt-out/chtexts/#{site}/#{bsid}/#{csid}.json"
  #   VText.mkdir(site, bsid)

  #   file_tmp = "data/txt-tmp/chtexts/#{site}/#{bsid}/#{csid}.txt"

  #   if data = VText.load(site, bsid, csid)
  #     return data
  #   end

  #   spider = TextCrawler.new(site, bsid, csid)

  #   if spider.cached?
  #     lines = File.read_lines(spider.text_file)
  #   else
  #     spider.mkdirs!
  #     spider.crawl!(persist: true)
  #     lines = [spider.title].concat(spider.paras)
  #   end

  #   paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)
  #   File.write(file_out, paras.to_json)

  #   paras
  # end
end

# info = BookRepo.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(10)
