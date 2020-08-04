require "myhtml"
require "colorize"
require "file_utils"

require "../../utils/han_to_int"
require "../../utils/http_util"
require "../../utils/file_util"
require "../../utils/time_util"

require "../models/chap_info"

class SeedInfo
  DIR = File.join("var", "appcv", ".cached")
  FileUtils.mkdir_p(DIR)

  def self.path_for(seed : String)
    File.join(DIR, seed, "infos")
  end

  def self.path_for(seed : String, sbid : String)
    File.join(path_for(seed), "#{sbid}.html")
  end

  def self.info_url(seed : String, sbid : String)
    case seed
    when "nofff"
      "https://www.nofff.com/#{sbid}/"
    when "69shu"
      "https://www.69shu.com/#{sbid}/"
    when "qu_la"
      "https://www.qu.la/book/#{sbid}/"
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
    when "5200"
      group = sbid.to_i // 1000
      "https://www.5200.net/#{group}_#{sbid}/"
    when "zhwenpg"
      "https://novel.zhwenpg.com/b.php?id=#{sbid}"
    else
      raise "- site `#{seed}` not supported!"
    end
  end

  def self.init(seed : String, sbid : String, type = 0, expiry : Time = Time.utc - 6.hours, freeze : Bool = false)
    url = info_url(seed, sbid)
    file = path_for(seed, sbid)

    unless html = FileUtil.read(file, expiry)
      html = HttpUtil.fetch_html(url, HttpUtil.encoding_for(seed))
      File.write(file, html) if freeze
    end

    new(seed, sbid, html, type)
  end

  getter seed : String
  getter sbid : String
  getter type : Int32

  def initialize(@seed, @sbid, html : String, @type = 0)
    @doc = Myhtml::Parser.new(html)
  end

  getter title : String { parse_title || "" }
  getter author : String { parse_author || "" }
  getter intro : String { parse_intro || "" }
  getter cover : String { parse_cover || "" }
  getter genre : String { parse_genre || "" }
  getter tags : Array(String) { parse_tags || [] of String }
  getter status : Int32 { parse_status || 0 }
  getter mftime : Int64 { parse_mftime || 0_i64 }
  getter latest : ChapInfo { parse_latest || ChapInfo.new("", "") }
  getter chapters : Array(ChapInfo) { parse_chapters || [] of ChapInfo }

  def parse_title
    case @seed
    when "qu_la", "jx_la", "duokan8", "nofff",
         "rengshu", "xbiquge", "paoshu8", "5200"
      meta_data("og:novel:book_name")
    when "hetushu"
      node_text("h2")
    when "69shu"
      node_text(".weizhi > a:last-child")
    when "zhwenpg"
      node_text(".cbooksingle h2")
    else
      raise "Unknown seed type [#{@seed}]!"
    end
  end

  def parse_author
    case @seed
    when "qu_la", "jx_la", "duokan8", "nofff",
         "rengshu", "xbiquge", "paoshu8", "5200"
      meta_data("og:novel:author")
    when "hetushu"
      node_text(".book_info a:first-child")
    when "69shu"
      node_text(".mu_beizhu > a[target]")
    when "zhwenpg"
      node_text(".fontwt")
    else
      raise "Unknown seed type [#{@seed}]!"
    end
  end

  def parse_intro
    case @seed
    when "qu_la", "jx_la", "duokan8", "nofff",
         "rengshu", "xbiquge", "paoshu8", "5200"
      return "" unless text = meta_data("og:description")
      TextUtil.split_html(text).join("\n")
    when "zhwenpg"
      return "" unless text = node_text("tr:nth-of-type(3)")
      # TODO: trad to simp?
      TextUtil.split_html(text).join("\n")
    when "hetushu"
      @doc.css(".intro > p").map(&.inner_text).join("\n")
    when "69shu"
      "" # TODO: extract 69shu book intro
    else
      raise "Unknown seed type [#{@seed}]!"
    end
  end

  def parse_cover
    case @seed
    when "qu_la", "duokan8", "nofff", "rengshu",
         "xbiquge", "paoshu8", "5200"
      meta_data("og:image")
    when "zhwenpg"
      node_attr(".cover_wrapper_m img", "data-src")
    when "jx_la"
      meta_data("og:image").try(&.sub("qu.la", "jx.la"))
    when "hetushu"
      return "" unless href = node_attr(".book_info img", "src")
      File.join("https://www.hetushu.com", href)
    when "69shu"
      "" # TODO: extract 69shu book cover
    else
      raise "Unknown seed type [#{@seed}]!"
    end
  end

  def parse_genre
    case @seed
    when "qu_la", "jx_la", "duokan8", "nofff",
         "rengshu", "xbiquge", "paoshu8", "5200"
      meta_data("og:novel:category")
    when "hetushu"
      node_text(".title > a:nth-child(2)")
    when "69shu"
      node_text(".weizhi > a:nth-child(2)")
    when "zhwenpg"
      "" # get it from other place
    else
      raise "Unknown seed type [#{@seed}]!"
    end
  end

  def parse_tags
    return unless @seed == "hetushu"

    @doc.css(".tag a").map(&.inner_text).to_a.reject! do |tag|
      tag == author || tag == title
    end
  end

  def parse_status
    case @seed
    when "qu_la", "jx_la", "duokan8", "nofff",
         "rengshu", "xbiquge", "paoshu8", "5200"
      map_status(meta_data("og:novel:status"))
    when "hetushu"
      classes = node_attr(".book_info", "class").not_nil!
      classes.includes?("finish") ? 1 : 0
    when "zhwenpg", "69shu"
      0
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  private def map_status(status : String?)
    case status
    when "完成", "完本", "已经完结", "已经完本", "完结"
      1
    else
      0
    end
  end

  TIME_DF = Time.utc(2000, 1, 1).to_unix_ms

  def parse_mftime
    case @seed
    when "qu_la", "jx_la", "nofff", "rengshu",
         "xbiquge", "duokan8", "paoshu8", "5200"
      text = meta_data("og:novel:update_time").not_nil!
      TimeUtil.parse(text).to_unix_ms
    when "69shu"
      text = node_text(".mu_beizhu").not_nil!.sub(/.+时间：/m, "")
      TimeUtil.parse(text).to_unix_ms
    when "hetushu", "zhwenpg"
      TIME_DF
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  def parse_latest : ChapInfo?
    case @seed
    when "qu_la", "jx_la", "nofff", "rengshu",
         "xbiquge", "duokan8", "paoshu8", "5200"
      parse_latest_by_meta_tag()
    when "69shu"
      parse_latest_by_css(".mulu_list:first-of-type a:first-child")
    when "hetushu"
      parse_latest_by_css("#dir :last-child a:last-of-type")
    when "zhwenpg"
      parse_latest_by_css(".fontwt0 + a")
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  def parse_latest_by_meta_tag
    return unless href = meta_data("og:novel:latest_chapter_url")
    text = meta_data("og:novel:latest_chapter_name").not_nil!
    if @seed == "duokan8"
      text = text.sub(/^.*正文\s*/, "").sub(/^.*章节目录\s*/, "")
    elsif @seed == "xbiquge"
      text = text.sub(/^.+?\s/, "")
    end

    ChapInfo.new(parse_scid(href), text)
  end

  def parse_latest_by_css(selector)
    return unless node = find_node(selector)
    scid = parse_scid(node.attributes["href"])
    ChapInfo.new(scid, node.inner_text.strip)
  end

  private def parse_scid(href : String)
    case @seed
    when "qu_la", "jx_la", "nofff", "rengshu",
         "xbiquge", "duokan8", "paoshu8", "hetushu",
         "5200"
      File.basename(href, ".html")
    when "69shu"
      File.basename(href)
    when "zhwenpg"
      href.sub("r.php?id=", "")
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  def parse_chapters : Array(ChapInfo)
    case @seed
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      parse_generic_chaps("#list > dl")
    when "5200"
      parse_generic_chaps(".listmain > dl")
    when "hetushu"
      parse_generic_chaps("#dir")
    when "duokan8"
      parse_duokan8_chaps
    when "zhwenpg"
      parse_zhwenpg_chapters
    when "69shu"
      parse_69shu_chaps
    when "qu_la"
      parse_qu_la_chaps
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  private def parse_duokan8_chaps
    chaps = [] of ChapInfo

    @doc.css(".chapter-list a").each do |link|
      if href = link.attributes["href"]?
        scid = parse_scid(href)
        chaps << ChapInfo.new(scid, link.inner_text)
      end
    end

    chaps
  end

  private def parse_69shu_chaps
    chaps = [] of ChapInfo
    return chaps unless nodes = @doc.css(".mu_contain").to_a

    nodes.shift if nodes.size > 0
    label = "正文"

    nodes.each do |mulu|
      mulu.children.each do |node|
        case node.tag_sym
        when :h2
          label = node.inner_text.strip
        when :ul
          node.css("a").each do |link|
            text = link.inner_text
            next if text.starts_with?("我要报错！")

            scid = parse_scid(link.attributes["href"])
            chaps << ChapInfo.new(scid, text, label)
          end
        end
      end
    end

    chaps
  end

  def parse_qu_la_chaps
    chaps = [] of ChapInfo

    @doc.css("h2.layout-tit").each do |h2|
      label = h2.inner_text.strip
      next if label.includes?("最新章节")
      next unless ul = h2.next.try(&.css("ul > ul:first-child").first)

      # puts ul.inner_text

      ul.css("a").each do |link|
        next unless href = link.attributes["href"]?
        chaps << ChapInfo.new(parse_scid(href), link.inner_text, label)
      end
    end

    fix_chapters_order(chaps)
    chaps
  end

  private def parse_zhwenpg_chapters
    chaps = [] of ChapInfo

    @doc.css(".clistitem > a").each do |link|
      scid = parse_scid(link.attributes["href"])
      chaps << ChapInfo.new(scid, link.inner_text)
    end

    chaps.reverse! if latest.scid == chaps.first.scid
    chaps
  end

  private def parse_generic_chaps(selector : String)
    chaps = [] of ChapInfo
    return chaps unless node = find_node(selector)

    label = "正文"

    node.children.each do |node|
      case node.tag_sym
      when :dt
        label = node.inner_text.gsub(/《.*》/, "").strip
      when :dd
        next if label.includes?("最新章节")
      end

      next unless link = node.css("a").first?
      next unless href = link.attributes["href"]?
      chaps << ChapInfo.new(parse_scid(href), link.inner_text, label)
    end

    fix_chapters_order(chaps) if @seed == "jx_la"
    chaps
  end

  private def fix_chapters_order(chapters) : Void
    indexed = {"作品相关" => -1}

    label_idx = 0
    label_acc = 0
    title_idx = 0

    chapters.sort_by! do |chap|
      idx = indexed[chap.zh_label] ||= label_index(chap.zh_label)

      if idx > 0
        label_idx = idx
        label_acc = 0
      else
        label_acc += 1
      end

      title_idx += 1
      {label_idx, label_acc, title_idx}
    end
  end

  INDEX_RE = /([零〇一二两三四五六七八九十百千]+|\d+)[集卷]/

  private def label_index(label : String) : Int32?
    return 0 unless match = INDEX_RE.match(label)
    Utils.han_to_int(match[1]).to_i32
  end

  private def find_node(selector)
    @doc.css(selector).first?
  end

  private def node_attr(selector : String, attribute : String)
    find_node(selector).try(&.attributes[attribute]?)
  end

  private def meta_data(selector : String)
    node_attr("meta[property=\"#{selector}\"]", "content")
  end

  private def node_text(selector : String)
    find_node(selector).try(&.inner_text.strip)
  end

  # def emit_book_info(info : BookInfo? = nil) : BookInfo
  #   info ||= BookInfo.get_or_create(title, author)

  #   info.add_genre(genre)
  #   info.add_tags(tags)

  #   info.zh_intro = intro if info.zh_intro.empty?
  #   info.add_cover(cover)
  #   info.status = status

  #   info.add_seed(@seed, @type)
  #   seed = info.update_seed(@seed, @sbid, mftime, latest)
  #   info.mftime = seed.mftime

  #   info
  # end

  # def emit_chapters(out_list : ChapList? = nil, mode : Symbol = :check)
  #   out_list ||= ChapList.get_or_create(ubid, @seed)
  #   inp_list = chapters

  #   out_list.sbid = @sbid
  #   out_list.type = @type

  #   if mode == :reset || (mode == :check && !out_list.match?(inp_list))
  #     out_list.chaps.clear
  #     out_list.index.clear
  #     inp_list.each { |chap| out_list.append(chap) }
  #   else
  #     out_list.size.upto(inp_list.size - 1) { |idx| out_list.append(inp_list[idx]) }
  #   end

  #   out_list
  # end
end
