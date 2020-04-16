require "./engine"

require "./spider/info_crawler"
require "./spider/text_crawler"

require "./entity/vbook"
require "./entity/vchap"
require "./entity/vtext"

module Kernel
  extend self

  def update_time(status)
    case status
    when 0
      5.hours
    when 1
      5.days
    else
      5.weeks
    end
  end

  def load_book(slug : String, site : String? = nil)
    slug = CUtil.unaccent(slug).tr(" ", "-")
    book = VBook.get(slug)

    return {nil, "", "", VList.new} unless book

    site = book.prefer_site if site.nil?
    return {book, site, "", VList.new} if site.empty?

    bsid = book.crawl_links[site]?
    return {book, site, "", VList.new} if bsid.nil?

    crawler = InfoCrawler.new(site, bsid, book.mtime)
    FileUtil.mkdir_p("#{VList.dir}/#{site}")
    crawler.mkdirs!

    if crawler.cached?(update_time(book.status), require_html = false)
      crawler.load_cached
    else
      crawler.reset_cache
      crawler.mkdirs!
      crawler.crawl!(persist: true)
    end

    changed = book.update(crawler.sbook)
    VBook.save(book) if changed

    list = VList.load(site, bsid)
    changed = list.update(crawler.slist)
    VList.save(list, bsid, site) if changed

    {book, site, bsid, list}
  end

  def load_text(site : String, bsid : String, csid : String, book : String? = nil, user = "local")
    file_out = "data/txt-out/chtexts/#{site}/#{bsid}/#{csid}.json"
    VText.mkdir(site, bsid)

    file_tmp = "data/txt-tmp/chtexts/#{site}/#{bsid}/#{csid}.txt"

    if data = VText.load(site, bsid, csid)
      return data
    end

    crawler = TextCrawler.new(site, bsid, csid)

    if crawler.cached?
      lines = File.read_lines(crawler.text_file)
    else
      crawler.mkdirs!
      crawler.crawl!(persist: true)
      lines = [crawler.title].concat(crawler.paras)
    end

    paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)
    File.write(file_out, paras.to_json)

    paras
  end
end
