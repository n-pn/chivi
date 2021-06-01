require "file_utils"
require "./rm_spider"

require "../cutil/time_utils"
require "../cutil/text_utils"
require "../cutil/path_utils"

require "./shared/html_parser"

class CV::RmNvinfo
  # cache folder path
  def self.c_dir(sname : String) : String
    PathUtils.cache_dir(sname, "infos")
  end

  def self.mkdir!(sname : String)
    ::FileUtils.mkdir_p(c_dir(sname))
  end

  def initialize(@sname : String, @snvid : String, valid = 10.years, label = "1/1")
    file = RmSpider.nvinfo_file(sname, snvid)
    link = RmSpider.nvinfo_link(sname, snvid)

    html = RmSpider.fetch(file, link, sname: sname, valid: valid, label: label)
    @html = HtmlParser.new(html)
  end

  getter btitle : String do
    case @sname
    when "zhwenpg" then @html.text(".cbooksingle h2")
    when "hetushu" then @html.text("h2")
    when "69shu"   then @html.text(".weizhi > a:last-child")
    else
      @html.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
    end
  end

  getter author : String do
    case @sname
    when "zhwenpg" then @html.text(".fontwt")
    when "hetushu" then @html.text(".book_info a:first-child")
    when "69shu"   then @html.text(".mu_beizhu > a[target]")
    else                @html.meta("og:novel:author")
    end
  end

  getter genres : Array(String) do
    case @sname
    when "zhwenpg" then [] of String
    when "hetushu"
      genre = @html.text(".title > a:last-child")
      tags = @html.text_list(".tag a")
      [genre].concat(tags).uniq
    when "69shu" then [@html.text(".weizhi > a:nth-child(2)")]
    else              [@html.meta("og:novel:category")]
    end
  end

  getter bintro : Array(String) do
    case @sname
    when "69shu"   then [] of String
    when "hetushu" then @html.text_list(".intro > p")
    when "zhwenpg" then @html.text_para("tr:nth-of-type(3)")
    when "bxwxorg" then @html.text_para("#intro>p:first-child")
    else                @html.meta_para("og:description")
    end
  end

  getter bcover : String do
    case @sname
    when "hetushu"
      image_url = @html.attr(".book_info img", "src")
      "https://www.hetushu.com#{image_url}"
    when "69shu"
      image_url = "/#{@snvid.to_i // 1000}/#{@snvid}/#{@snvid}s.jpg"
      "https://www.69shu.com/files/article/image/#{image_url}"
    when "zhwenpg"
      @html.attr(".cover_wrapper_m img", "data-src")
    when "jx_la"
      @html.meta("og:image").sub("qu.la", "jx.la")
    else
      @html.meta("og:image")
    end
  end

  getter status : String do
    case @sname
    when "69shu", "zhwenpg" then "0"
    when "hetushu"
      @html.attr(".book_info", "class").includes?("finish") ? "1" : "0"
    else
      @html.meta("og:novel:status")
    end
  end

  getter update_int : Int64 { RmSpider.fix_mftime(update_str, @sname) }

  getter update_str : String do
    case @sname
    when "69shu"
      @html.text(".mu_beizhu").sub(/.+时间：/m, "")
    when "bqg_5200"
      @html.text("#info > p:last-child").sub("最后更新：", "")
    else
      @html.meta("og:novel:update_time")
    end
  end
end
