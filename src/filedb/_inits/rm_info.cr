require "myhtml"
require "colorize"
require "file_utils"

require "../../shared/*"

class CV::RmInfo
  def self.init(seed : String, sbid : String,
                expiry : Time = Time.utc - 1.hour, freeze : Bool = true)
    file = path_for(seed, sbid)
    expiry = TimeUtils::DEF_TIME if seed == "jx_la"

    unless html = FileUtils.read(file, expiry)
      url = url_for(seed, sbid)
      html = HttpUtils.get_html(url, encoding: HttpUtils.encoding_for(seed))
      File.write(file, html) if freeze
    end

    new(seed, sbid, file: file, html: html)
  end

  def self.path_for(seed : String, sbid : String)
    "_db/.cache/#{seed}/infos/#{sbid}.html"
  end

  def self.url_for(seed : String, sbid : String) : String
    case seed
    when "nofff"      then "https://www.nofff.com/#{sbid}/"
    when "69shu"      then "https://www.69shu.com/#{sbid}/"
    when "jx_la"      then "https://www.jx.la/book/#{sbid}/"
    when "qu_la"      then "https://www.qu.la/book/#{sbid}/"
    when "rengshu"    then "http://www.rengshu.com/book/#{sbid}"
    when "xbiquge"    then "https://www.xbiquge.cc/book/#{sbid}/"
    when "zhwenpg"    then "https://novel.zhwenpg.com/b.php?id=#{sbid}"
    when "hetushu"    then "https://www.hetushu.com/book/#{sbid}/index.html"
    when "duokan8"    then "http://www.duokan8.com/#{prefixed(sbid)}/"
    when "paoshu8"    then "http://www.paoshu8.com/#{prefixed(sbid)}/"
    when "5200"       then "https://www.5200.tv/#{prefixed(sbid)}/"
    when "shubaow"    then "https://www.shubaow.net/#{prefixed(sbid)}/"
    when "biquge5200" then "https://www.biquge5200.com/#{prefixed(sbid)}/"
    else                   raise "Unsupported remote source <#{seed}>!"
    end
  end

  private def self.prefixed(sbid : String)
    "#{sbid.to_i // 1000}_#{sbid}"
  end

  getter seed : String
  getter sbid : String
  getter file : String

  def initialize(@seed, @sbid, @file, html = File.read(@file))
    @rdoc = Myhtml::Parser.new(html)
  end

  def cached?(expiry = Time.utc - 6.months)
    FileUtils.recent?(@file, expiry)
  end

  def uncache!
    File.delete(@file) if File.exists?(@file)
  end

  getter author : String do
    case @seed
    when "hetushu" then node_text(".book_info a:first-child")
    when "zhwenpg" then node_text(".fontwt")
    when "69shu"   then node_text(".mu_beizhu > a[target]")
    else                meta_data("og:novel:author")
    end
  end

  getter btitle : String do
    case @seed
    when "hetushu" then node_text("h2")
    when "zhwenpg" then node_text(".cbooksingle h2")
    when "69shu"   then node_text(".weizhi > a:last-child")
    else                meta_data("og:novel:book_name")
    end
  end

  getter bgenre : Array(String) do
    case @seed
    when "hetushu"
      genre = node_text(".title > a:last-child").not_nil!
      tags = @rdoc.css(".tag a").map(&.inner_text).to_a
      [genre].concat(tags).uniq
    when "zhwenpg" then [] of String
    when "69shu"   then [node_text(".weizhi > a:nth-child(2)")]
    else                [meta_data("og:novel:category")]
    end
  end

  getter bintro : Array(String) do
    case @seed
    when "69shu"   then [] of String
    when "hetushu" then @rdoc.css(".intro > p").map(&.inner_text).to_a
    when "zhwenpg" then TextUtils.split_html(node_text("tr:nth-of-type(3)"))
    else                TextUtils.split_html(meta_data("og:description"))
    end
  end

  getter bcover : String do
    case @seed
    when "hetushu"
      image_url = node_attr(".book_info img", "src")
      "https://www.hetushu.com#{image_url}"
    when "69shu"
      image_url = "/#{@sbid.to_i // 1000}/#{@sbid}/#{@sbid}s.jpg"
      "https://www.69shu.com/files/article/image/#{image_url}"
    when "zhwenpg"
      node_attr(".cover_wrapper_m img", "data-src")
    when "jx_la"
      meta_data("og:image").sub("qu.la", "jx.la")
    else
      meta_data("og:image")
    end
  end

  getter status_str : String do
    case @seed
    when "69shu", "zhwenpg" then "连载"
    when "hetushu"
      node_attr(".book_info", "class").includes?("finish") ? "完本" : "连载"
    else meta_data("og:novel:status")
    end
  end

  getter status_int : Int32 do
    case status = status_str
    when "连载", "连载中....", "连载中", "新书上传",
         "情节展开", "精彩纷呈", "接近尾声",
         ""
      0
    when "完成", "完本", "已经完结", "已经完本",
         "完结", "已完结", "此书已完成", "已完本",
         "全本", "完结申请"
      1
    when "暂停", "暂 停", "暂　停"
      2
    else
      puts "<#{@seed}/#{@sbid}> UNKNOWN STATUS: `#{status}`".colorize.red
      0
    end
  end

  getter updated_at : Time do
    return TimeUtils::DEF_TIME if @seed == "zhwenpg" || @seed == "hetushu"

    timestamp =
      case @seed
      when "69shu"
        node_text(".mu_beizhu").sub(/.+时间：/m, "")
      when "biquge5200"
        node_text("#info > p:last-child").sub("最后更新：", "")
      else
        meta_data("og:novel:update_time")
      end

    return TimeUtils.parse_time(timestamp) unless timestamp.empty?
    puts "- ERROR: <#{RmInfo.url_for(@seed, @sbid)}> missing time!"
    TimeUtils::DEF_TIME
  end

  getter last_chap : Array(String) do
    case @seed
    when "hetushu" then extract_latest_by_css("#dir :last-child a:last-of-type")
    when "69shu"   then extract_latest_by_css(".mulu_list:first-of-type a:first-child")
    when "zhwenpg" then extract_latest_by_css(".fontwt0 + a")
    else                extract_latest_by_meta
    end
  end

  private def extract_latest_by_css(sel : String)
    node = find_node(sel).not_nil!
    href = node.attributes["href"]
    title, label = TextUtils.format_title(node.inner_text)

    [extract_scid(href), title, label]
  end

  private def extract_latest_by_meta
    href = meta_data("og:novel:latest_chapter_url").not_nil!
    text = meta_data("og:novel:latest_chapter_name").not_nil!

    if @seed == "duokan8"
      text = text.sub(/^.*正文\s*/, "").sub(/^.*章节目录\s*/, "")
    elsif @seed == "xbiquge"
      text = text.sub(/^.+?\s/, "")
    end

    scid = @seed != "biquge5200" ? extract_scid(href) : File.basename(href, ".htm")

    title, label = TextUtils.format_title(text)
    [scid, title, label]
  end

  alias Chlist = Array(Array(String))

  getter chap_list : Chlist do
    case @seed
    when "69shu"   then extract_69shu_chlist
    when "zhwenpg" then extract_zhwenpg_chlist
    when "duokan8" then extract_duokan8_chlist
    when "hetushu" then extract_generic_chlist("#dir")
    when "5200"    then extract_generic_chlist(".listmain > dl")
    else                extract_generic_chlist("#list > dl")
    end
  end

  def extract_generic_chlist(sel : String)
    chlist = Chlist.new
    return chlist unless node = find_node(sel)

    label = ""

    node.children.each do |node|
      case node.tag_sym
      when :dt
        label = node.inner_text.gsub(/《.*》/, "").strip
        label = "" if label == "正文"
      when :dd
        next if label.includes?("最新章节")
      end

      next unless link = node.css("a").first?
      href, text = link.attributes["href"], link.inner_text

      title, label = TextUtils.format_title(text, label)
      chlist << [extract_scid(href), title, label]
    rescue err
      puts err.colorize.red
    end

    chlist
  end

  def extract_69shu_chlist
    chlist = Chlist.new
    return chlist unless nodes = @rdoc.css(".mu_contain").to_a

    nodes.shift if nodes.size > 0
    label = ""

    nodes.each do |mulu|
      mulu.children.each do |node|
        case node.tag_sym
        when :h2
          label = node.inner_text.strip
          label = "" if label == "正文"
        when :ul
          node.css("a").each do |link|
            title = link.inner_text
            next if title.starts_with?("我要报错！")
            href = link.attributes["href"]
            chlist << [extract_scid(href), title, label]
          end
        end
      end
    end

    chlist
  end

  def extract_zhwenpg_chlist
    output = Chlist.new

    @rdoc.css(".clistitem > a").each do |link|
      href = link.attributes["href"]
      title, label = TextUtils.format_title(link.inner_text)
      output << [extract_scid(href), title, label]
    end

    # check if the list is in correct orlder
    latest_scid, _ = last_chap
    output.reverse! if latest_scid == output.first.first

    output
  end

  private def extract_duokan8_chlist
    chlist = Chlist.new

    @rdoc.css(".chapter-list a").each do |link|
      next unless href = link.attributes["href"]?
      title, label = TextUtils.format_title(link.inner_text)
      chlist << [extract_scid(href), title, label]
    end

    chlist
  end

  private def extract_scid(href : String)
    case @seed
    when "69shu"   then File.basename(href)
    when "zhwenpg" then href.sub("r.php?id=", "")
    else                File.basename(href, ".html")
    end
  end

  private def node_attr(sel : String, attr : String, df : String? = "")
    find_node(sel).try(&.attributes[attr]?) || df
  end

  private def meta_data(sel : String, df : String? = "")
    node_attr("meta[property=\"#{sel}\"]", "content") || df
  end

  private def node_text(sel : String, df : String? = "")
    find_node(sel).try(&.inner_text.strip) || df
  end

  private def find_node(sel : String)
    @rdoc.css(sel).first?
  end
end
