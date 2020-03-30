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

  def load_text(site : String, bsid : String, csid : String, user = "admin")
    file_out = "data/txt-out/chtexts/#{site}/#{bsid}.json"
    file_tmp = "data/txt-tmp/chtexts/#{site}/#{bsid}.txt"

    if File.exists?(file_out)
      return Array(Array(Chivi::Token)).from_json File.read(file_out)
    elsif File.exists?(file_tmp)
      lines = File.read_lines(file_tmp)
      paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)
      File.write(file_out, paras.to_json)

      paras
    else
      crawler = CrText.new(site, bsid, csid)
      crawler.crawl!(persist: true)
      lines = [crawler.title].concat(crawler.paras)

      paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)
      File.write(file_out, paras.to_json)

      paras
    end
  end
end

book = Kernel.serials.get("chuế-tế")
puts book.to_pretty_json

# list = Kernel.chlists.get(book.favor_crawl, book.crawl_bsid.as(String))
# puts list.first(10)

# text = Kernel.load_text("jx_la", "285", "10612432")
# puts text
