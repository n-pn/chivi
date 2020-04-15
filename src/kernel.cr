require "./engine"

require "./spider/*"
require "./entity/*"

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

  def load_text(site : String, bsid : String, csid : String, user = "admin")
    file_out = "data/txt-out/chtexts/#{site}/#{bsid}/#{csid}.json"
    file_tmp = "data/txt-tmp/chtexts/#{site}/#{bsid}/#{csid}.txt"

    if File.exists?(file_out)
      return Array(Array(Chivi::Token)).from_json File.read(file_out)
    elsif File.exists?(file_tmp)
      lines = File.read_lines(file_tmp)
      paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)

      FileUtils.mkdir_p File.dirname(file_out)
      File.write(file_out, paras.to_json)

      paras
    else
      crawler = CrText.new(site, bsid, csid)

      FileUtils.mkdir_p File.dirname(crawler.html_file)
      FileUtils.mkdir_p File.dirname(crawler.text_file)

      crawler.crawl!(persist: true)
      lines = [crawler.title].concat(crawler.paras)

      paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)
      FileUtils.mkdir_p File.dirname(file_out)
      File.write(file_out, paras.to_json)

      paras
    end
  end
end

# book = Kernel.serials.get("chue-te")
# puts book.to_pretty_json

# list = Kernel.chlists.get(book.favor_crawl, book.crawl_bsid.as(String))
# puts list.first(10)

# text = Kernel.load_text("jx_la", "285", "10612432")
# puts text
