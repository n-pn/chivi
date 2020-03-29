require "./engine"
require "./kernel/*"

module Kernel
  extend self

  @@serials : Serials? = nil

  def serials(preload = true)
    @@serials ||= Serials.new("data/txt-out/serials/", preload: preload)
  end

  def chlists(site : String, bsid : String)
    file_tmp = "data/txt-tmp/chlists/#{site}/#{bsid}.json"
    file_out = "data/txt-out/chlists/#{site}/#{bsid}.json"

    if File.exists?(file_out)
      Array(VpChap).from_json File.read(file_out)
      # elsif File.exists?(file_tmp)
      # TODO: Translate
    else
      [] of VpChap
    end
  end

  def load_text(site : String, bsid : String, csid : String, user = "admin")
    file_out = "data/txt-out/chtexts/#{site}/#{bsid}.json"
    file_tmp = "data/txt-tmp/chtexts/#{site}/#{bsid}.txt"

    if File.exists?(file_out)
      return Array(Array(CvCore::Token)).from_json File.read(file_out)
    elsif File.exists?(file_tmp)
      lines = File.read_lines(file_tmp)
      paras = Engine.convert(lines, mode: :mixed, book: nil, user: user)
      File.write(file_out, paras.to_json)

      paras
    end
  end
end
