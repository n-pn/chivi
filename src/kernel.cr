require "./engine"
require "./kernel/*"

module Kernel
  extend self

  @@serials : Serials? = nil

  def serials(preload = true)
    @@serials ||= Serials.new("data/txt-out/serials/", preload: preload)
  end

  def list_chaps(book : String)
    if book = find_book(book)
      site = book.favor_scrap
      return [] of VpChap if site.empty?
      bsid = book.scrap_links[site]

      file_tmp = "data/txt-tmp/chlists/#{site}/#{bsid}.json"
      file_out = "data/txt-out/chlists/#{site}/#{bsid}.json"
      if File.exists?(file_out)
        return Array(VpChap).from_json File.read(file_out)
      elsif File.exists?(file_tmp)
        puts "Translate it!"
      end
    end

    return [] of VpChap
  end

  def load_text(book : String, csid : String)
    if book = find_book(book)
      site = book.favor_scrap
      return nil if site.empty?
      bsid = book.scrap_links[site]

      file_tmp = "data/txt-tmp/chtexts/#{site}/#{bsid}.json"
      file_out = "data/txt-out/chtexts/#{site}/#{bsid}.json"
      if File.exists?(file_out)
        return Array(VpChap).from_json File.read(file_out)
      elsif File.exists?(file_tmp)
        puts "Translate it!"
      end
    end

    return [] of VpChap

    text_file = "data/txt-tmp/#{book}/#{slug}.txt"
    return nil unless File.exists?(text_file)
    File.read_lines(text_file)
  end
end
