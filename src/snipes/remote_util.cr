require "myhtml"
require "colorize"
require "file_utils"
require "../_utils/file_utils"

module RemoteUtil
  extend self

  DIR = File.join("var", "appcv", ".cache")
  FileUtils.mkdir_p(DIR)

  def mkdir!(seed : String)
    FileUtils.mkdir_p(info_root(seed))
  end

  def info_root(seed : String)
    File.join(DIR, seed, "infos")
  end

  def info_path(seed : String, sbid : String)
    File.join(info_root(seed), "#{sbid}.html")
  end

  def info_url(seed : String, sbid : String)
    case seed
    when "nofff"
      "https://www.nofff.com/#{sbid}/"
    when "69shu"
      "https://www.69shu.com/#{sbid}/"
    when "jx_la"
      "https://www.jx.la/book/#{sbid}/"
    when "rengshu"
      "http://www.rengshu.com/book/#{sbid}"
    when "xbiquge"
      "https://www.xbiquge.cc/book/#{sbid}/"
    when "hetushu"
      "https://www.hetushu.com/book/#{sbid}/index.html"
    when "duokan8"
      group = sbid.to_i // 1000
      "http://www.duokan8.com/#{group}_#{sbid}/"
    when "paoshu8"
      group = sbid.to_i // 1000
      "http://www.paoshu8.com/#{group}_#{sbid}/"
    when "zhwenpg"
      "https://novel.zhwenpg.com/b.php?id=#{sbid}"
    else
      raise "- seed `#{seed}` not supported!"
    end
  end

  def info_html(seed : String, sbid : String, expiry = 6.hours, freeze = true)
    path = info_path(seed, sbid)

    unless html = Utils.read_file(path, expiry)
      html = Utils.fetch_html(info_url(seed, sbid))
      File.write(path, html) if freeze
    end

    html
  end

  # --------------------------------------------

  def mkdir!(seed : String, sbid : String)
    FileUtils.mkdir_p(text_root(seed, sbid))
  end

  def text_root(seed : String, sbid : String)
    File.join(DIR, seed, "texts", sbid)
  end

  def text_path(seed : String, sbid : String, scid : String)
    File.join(text_root(seed, sbid), "#{scid}.html")
  end

  def text_url(seed : String, sbid : String, scid : String)
    case seed
    when "nofff"
      "https://www.nofff.com/#{sbid}/#{scid}/"
    when "69shu"
      "https://www.69shu.com/txt/#{sbid}/#{scid}"
    when "jx_la"
      "https://www.jx.la/book/#{sbid}/#{scid}.html"
    when "rengshu"
      "http://www.rengshu.com/book/#{sbid}/#{scid}"
    when "xbiquge"
      "https://www.xbiquge.cc/book/#{sbid}/#{scid}.html"
    when "hetushu"
      "https://www.hetushu.com/book/#{sbid}/#{scid}.html"
    when "duokan8"
      group = sbid.to_i // 1000
      "http://www.duokan8.com/#{group}_#{sbid}/#{scid}.html"
    when "paoshu8"
      group = sbid.to_i // 1000
      "http://www.paoshu8.com/#{group}_#{sbid}/#{scid}.html"
    when "zhwenpg"
      "https://novel.zhwenpg.com/r.php?id=#{scid}"
    else
      raise "- seed `#{seed}` not supported!"
    end
  end
end
