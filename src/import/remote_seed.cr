require "myhtml"
require "colorize"
require "file_utils"

require "../kernel/book_info"
require "../kernel/book_misc"
require "../kernel/chap_list"

require "../utils/han_to_int"
require "../utils/html_utils"
require "../utils/time_utils"
require "../utils/text_utils"

require "./remote_util"

class SeedVolume
  getter label : String
  getter chaps = [] of ChapItem

  def initialize(@label = "正文")
  end

  INDEX_RE = /([零〇一二两三四五六七八九十百千]+|\d+)[集卷]/

  def label_index
    if match = INDEX_RE.match(@label)
      Utils.han_to_int(match[1])
    else
      0
    end
  end
end

class SeedParser
  getter seed : String

  def initialize(@seed, @doc : Myhtml::Parser)
  end

  def initialize(@seed, html : String)
    @doc = Myhtml::Parser.new(html)
  end

  @title : String? = nil

  def get_title : String
    @title ||= begin
      title =
        case @seed
        when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
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

      title ? title.sub(/\(.+\)$/, "") : ""
    end
  end

  @author : String? = nil

  def get_author : String
    @author ||= begin
      author =
        case @seed
        when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
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

      author ? author.sub(/\(.+\)|.QD$/, "") : ""
    end
  end

  @intro : String? = nil

  def get_intro : String
    @intro ||= begin
      intro =
        case @seed
        when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
          meta_data("og:description")
        when "zhwenpg"
          node_text("tr:nth-of-type(3)")
        when "hetushu"
          @doc.css(".intro > p").map(&.inner_text).join("\n")
        when "69shu"
          nil # TODO: extract 69shu book intro
        else
          raise "Unknown seed type [#{@seed}]!"
        end

      intro ? Utils.clean_text(intro) : ""
    end
  end

  @cover : String? = nil

  def get_cover : String?
    @cover ||= begin
      cover =
        case @seed
        when "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
          meta_data("og:image")
        when "zhwenpg"
          node_attr(".cover_wrapper_m img", "data-src")
        when "jx_la"
          meta_data("og:image").try(&.sub("qu.la", "jx.la"))
        when "hetushu"
          if href = node_attr(".book_info img", "src")
            "https://www.hetushu.com#{href}"
          end
        when "69shu"
          nil # TODO: extract 69shu book cover
        else
          raise "Unknown seed type [#{@seed}]!"
        end

      cover || ""
    end
  end

  @genre : String? = nil

  def get_genre : String
    @genre ||= begin
      genre =
        case @seed
        when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
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

      genre ? Utils.fix_genre(genre) : ""
    end
  end

  @tags : Array(String)? = nil

  def get_tags : Array(String)
    @tags ||=
      if @seed == "hetushu"
        @doc.css(".tag a").map(&.inner_text).to_a
      else
        [] of String
      end
  end

  def get_status : Int32
    case @seed
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      case meta_data("og:novel:status")
      when "完成", "完本", "已经完结", "已经完本", "完结"
        1
      else
        0
      end
    when "hetushu"
      classes = node_attr(".book_info", "class").not_nil!
      classes.includes?("finish") ? 1 : 0
    when "zhwenpg", "69shu"
      0
    else
      raise "Site not supported!"
    end
  end

  def get_mftime : Int64
    case @seed
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      text = meta_data("og:novel:update_time").not_nil!
      Utils.parse_time(text).to_unix_ms
    when "69shu"
      text = node_text(".mu_beizhu").not_nil!.sub(/.+时间：/m, "")
      Utils.parse_time(text).to_unix_ms
    when "hetushu", "zhwenpg"
      0_i64
    else
      raise "Site not supported!"
    end
  end

  def get_chaps : Array(ChapItem)
    output = [] of ChapItem

    case @seed
    when "duokan8"
      @doc.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text
          output << ChapItem.new(csid, title)
        end
      end
    when "69shu"
      volumes = @doc.css(".mu_contain").to_a.map do |node|
        volume = SeedVolume.new

        node.css("a").each do |link|
          if href = link.attributes["href"]?
            csid = File.basename(href)
            title = link.inner_text
            next if title.starts_with?("我要报错！")

            volume.chaps << ChapItem.new(csid, title)
          end
        end

        volume
      end

      volumes.shift if volumes.size > 1
      volumes.each { |volume| output.concat(volume.chaps) }
    when "zhwenpg"
      latest_chap = node_text(".fontchap")

      @doc.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          output << ChapItem.new(csid, link.inner_text)
        end
      end

      output.reverse! if latest_chap == output.first.title
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      output = extract_volumes("#list dl")
    when "hetushu"
      output = extract_volumes("#dir")
    else
      raise "Site not supported!"
    end

    output
  end

  private def extract_volumes(selector)
    output = [] of ChapItem
    return output unless parent = @doc.css(selector).first?

    nodes = parent.children
    volumes = [] of SeedVolume

    nodes.each do |node|
      if node.tag_sym == :dt
        label = node.inner_text.gsub(/《.*》/, "").strip
        volumes << SeedVolume.new(label)
      elsif node.tag_sym == :dd
        link = node.css("a").first?
        next unless link

        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          volumes << SeedVolume.new if volumes.empty?
          volumes.last.chaps << ChapItem.new(csid, title, volumes.last.label)
        end
      end
    end

    volumes.shift if volumes.first.label.includes?("最新章节")

    if @seed == "jx_la"
      order = 0

      volumes.sort_by! do |volume|
        if volume.label == "作品相关"
          {-1, 0}
        else
          index = volume.label_index
          order += 1 if index == 0
          {order, index}
        end
      end
    end

    volumes.each { |volume| output.concat(volume.chaps) }
    output
  end

  private def meta_data(selector : String)
    node_attr("meta[property=\"#{selector}\"]", "content")
  end

  private def node_attr(selector : String, attribute : String)
    if node = @doc.css(selector).first?
      node.attributes[attribute]?
    end
  end

  private def node_text(selector : String)
    if node = @doc.css(selector).first?
      node.inner_text.strip
    end
  end
end

class RemoteSeed
  getter seed : String
  getter sbid : String
  getter type : Int32

  def initialize(@seed, @sbid, @type = 0, expiry = 6.hours, freeze = false)
    html = RemoteUtil.info_html(@seed, @sbid, expiry, freeze)
    @parser = SeedParser.new(@seed, html)
  end

  @info : BookInfo::Data?

  def default_info
    @info ||= BookInfo.find_or_create!(@parser.get_title, @parser.get_author)
  end

  def extract_info!(info : BookInfo::Data = default_info)
    info.set_genre!(@parser.get_genre)
    info.tap(&.fix_uuid!(info.changed?))
  end

  @misc : BookMisc::Data?

  def default_misc
    @misc ||= begin
      uuid = Utils.gen_uuid(@parser.get_title, @parser.get_author)
      BookMisc.get_or_create!(uuid)
    end
  end

  def extract_misc!(misc : BookMisc::Data = default_misc)
    misc.intro_zh = @parser.get_intro if misc.intro_zh.empty?

    if @seed == "hetushu"
      misc.add_tags(@parser.get_tags)
    else
      misc.add_tag(@parser.get_genre)
    end

    misc.add_cover(@parser.get_cover)
    misc.status = @parser.get_status

    mftime = @parser.get_mftime

    # TODO: skip if @sbid mftime < misc.seed_sbids[@seed] mftime
    # TODO: add seed_lasts

    misc.set_seed_sbid(@seed, @sbid)
    misc.set_seed_type(@seed, @type)

    misc.mftime = mftime

    misc
  end
end
