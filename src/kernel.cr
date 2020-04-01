require "./engine"
require "./crawls/*"
require "./kernel/*"

module Kernel
  extend self

  @@serials : Serials? = nil
  @@chlists : Chlists? = nil

  def serials
    @@serials ||= Serials.new
  end

  def chlists
    @@chlists ||= Chlists.new
  end

  def update_time(status)
    case status
    when 0
      1.hours
    when 1
      1.days
    else
      1.weeks
    end
  end

  def load_book(slug : String, site : String? = nil)
    slug = CUtil.unaccent(slug).tr(" ", "-")
    book = serials.get(slug)
    return {nil, "", "", [] of VpChap} unless book

    site = book.prefer_site if site.nil?
    return {book, site, "", [] of VpChap} if site.empty?

    bsid = book.crawl_links[site]?
    return {book, site, "", [] of VpChap} if bsid.nil?

    crawler = CrInfo.new(site, bsid, book.updated_at)

    unless crawler.cached?(update_time(book.status))
      crawler.reset_cache
      crawler.mkdirs!
      crawler.crawl!(persist: true)

      # TODO: extract to vp_book.cr or serials.cr
      serial = crawler.serial
      book.status = serial.status if book.status < serial.status
      book.updated_at = serial.updated_at if book.updated_at < serial.updated_at
      serials.save(book)

      chlist = chlists.save(site, bsid, crawler.chlist)
    else
      chlist = chlists.get(site, bsid)
    end

    {book, site, bsid, chlist}
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

# book = Kernel.serials.get("chuế-tế")
# puts book.to_pretty_json

# list = Kernel.chlists.get(book.favor_crawl, book.crawl_bsid.as(String))
# puts list.first(10)

# text = Kernel.load_text("jx_la", "285", "10612432")
# puts text
