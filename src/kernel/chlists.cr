require "file_utils"

# require "../engine"
require "../crawls/*"
require "../models/*"

class Chlists
  def initialize(@dir = "data/txt-out/chlists")
  end

  def get(book : VpBook, time : Time = Time.utc - 7.days)
    site = book.prefer_site
    bsid = book.prefer_bsid
    return [] of VpChap if bsid.empty?

    get(site, bsid.as(String), time)
  end

  def get(site : String, bsid : String, time : Time = Time.utc - 7.days)
    file_out = File.join(@dir, site, "#{bsid}.json")

    if CrUtil.outdated?(file_out, time)
      crawler = CrInfo.new(site, bsid)

      if crawler.cached?(time)
        crawler.load_cached!(chlist: true)
      else
        crawler.reset_cache
        crawler.crawl!(persist: true)
      end

      save(site, bsid, crawler.chlist)
    else
      Array(VpChap).from_json File.read(file_out)
    end
  end

  def save(site, bsid, inp_list : CrInfo::ChList)
    out_list = inp_list.map do |chap|
      VpChap.new(chap._id, chap.title, chap.volume)
    end

    out_dir = File.join(@dir, site)
    FileUtils.mkdir_p(out_dir)

    out_file = File.join(out_dir, "#{bsid}.json")
    File.write(out_file, out_list.to_pretty_json)

    out_list
  end
end
