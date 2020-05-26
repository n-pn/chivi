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

  def load_list(info : VpInfo, site : String, refresh = false) : ChapList
    unless bsid = info.cr_anchors[site]?
      return ChapList.new
    end

    file = ChapList.path_for(info.uuid, site)
    expiry = refresh ? 6.minutes : gen_expiry(info.status)

    unless Utils.outdated?(file, expiry)
      return ChapList.read!(file)
    end

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

  def load_chap(info : VpInfo, site : String, csid : String, user = "guest", mode = 0, unique : Bool = false)
    bsid = info.cr_anchors[site]
    uuid = VpText.uuid_for(info.uuid, site, bsid)

    json_file = VpText.path_for(uuid, csid, user)
    text_file = File.join("data", "zh_texts", uuid, "#{csid}.txt")

    if File.exists?(json_file) && mode == 0
      return VpText.load!(json_file)
    end

    if File.exists?(text_file) && mode == 1
      lines = File.read_lines(text_file)
    else
      spider = TextSpider.load(site, bsid, csid, expiry: 10.years, frozen: false)
      lines = [spider.get_title!].concat(spider.get_paras!)

      FileUtils.mkdir_p(File.dirname(text_file))
      File.write(text_file, lines.join("\n"))
    end

    book = unique ? info.uuid : nil
    paras = Engine.convert(lines, mode: :mixed, book: book, user: user)

    FileUtils.mkdir_p(File.dirname(json_file))
    File.write(json_file, paras.to_json)
    paras
  end
end

# info = BookRepo.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
