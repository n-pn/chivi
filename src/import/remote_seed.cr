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

  @status : Int32? = nil

  def get_status : Int32
    @status ||=
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
        raise "Seed `#{@seed}` not supported!"
      end
  end

  @mftme : Int64? = nil

  def get_mftime : Int64
    @mftime ||=
      case @seed
      when "jx_la", "nofff", "rengshu", "xbiquge", "duokan8", "paoshu8"
        text = meta_data("og:novel:update_time").not_nil!

        Utils.parse_time(text).to_unix_ms
      when "69shu"
        text = node_text(".mu_beizhu").not_nil!.sub(/.+时间：/m, "")
        Utils.parse_time(text).to_unix_ms
      when "hetushu", "zhwenpg"
        0_i64
      else
        raise "Seed `#{@seed}` not supported!"
      end
  end

  @latest : ChapItem? = nil

  def get_latest
    @latest ||= begin
      latest = ChapItem.new("", "", mftime: get_mftime)

      case @seed
      when "jx_la", "nofff", "rengshu", "xbiquge", "duokan8", "paoshu8"
        if href = meta_data("og:novel:latest_chapter_url")
          text = meta_data("og:novel:latest_chapter_name").not_nil!
          text = text.sub(/^章节目录\s+/, "") if @seed = "duokan8"
          latest.set_title(text)

          latest.scid = extract_scid(href)
        end
      when "zhwenpg"
        if node = find_node(".fontwt0 + a")
          latest.set_title(node.inner_text.strip)
          latest.scid = extract_scid(node.attributes["href"])
        end
      when "69shu"
        if node = find_node(".mulu_list:first-of-type a:first-child")
          latest.set_title(node.inner_text.strip)
          latest.scid = extract_scid(node.attributes["href"])
        end
      when "hetushu"
        if node = find_node("#dir > dd:last-child > a")
          latest.set_title(node.inner_text.strip)
          latest.scid = extract_scid(node.attributes["href"])
        end
      else
        raise "Seed `#{@seed}` not supported!"
      end

      latest
    end
  end

  private def extract_scid(href : String)
    case @seed
    when "jx_la", "nofff", "rengshu", "xbiquge", "duokan8", "paoshu8", "hetushu"
      File.basename(href, ".html")
    when "zhwenpg"
      href.sub("r.php?id=", "")
    when "69shu"
      File.basename(href)
    else
      raise "Seed `#{@seed}` not supported!"
    end
  end

  @chaps : Array(ChapItem)? = nil

  def get_chaps : Array(ChapItem)
    @chaps ||=
      case @seed
      when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
        extract_generic_chaps("#list dl")
      when "hetushu"
        extract_generic_chaps("#dir")
      when "duokan8"
        extract_duokan8_chaps
      when "zhwenpg"
        extract_zhwenpg_chaps
      when "69shu"
        extract_69shu_chaps
      else
        raise "Seed `#{@seed}` not supported!"
      end
  end

  private def extract_duokan8_chaps
    chaps = [] of ChapItem

    @doc.css(".chapter-list a").each do |link|
      if href = link.attributes["href"]?
        scid = extract_scid(href)
        title = link.inner_text
        chaps << ChapItem.new(scid, title)
      end
    end

    chapss
  end

  private def extract_69shu_chaps
    chaps = [] of ChapItem

    @doc.css(".mu_contain").each do |node|
      label = node.css("h2").first.inner_text.strip
      next if label.ends_with?("最新6章")

      node.css(".mulu_list:first-child > li > a").each do |link|
        text = link.inner_text
        # next if text.starts_with?("我要报错！")

        scid = extract_scid(link.attributes["href"])
        chaps << ChapItem.new(scid, text, label)
      end
    end

    chaps
  end

  private def extract_generic_chaps(selector : String)
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
          scid = extract_scid(href)
          title = link.inner_text

          volumes << SeedVolume.new if volumes.empty?
          volumes.last.chaps << ChapItem.new(scid, title, volumes.last.label)
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

  private def extract_zhwenpg_chaps
    chaps = [] of ChapItem

    @doc.css("#dulist > li > a").each do |link|
      scid = extract_scid(link.attributes["href"])
      chaps << ChapItem.new(scid, link.inner_text)
    end

    chaps.reverse! if get_latest.scid == chaps.first.scid
    chaps
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
end

class RemoteSeed
  getter seed : String
  getter sbid : String
  getter type : Int32

  def initialize(@seed, @sbid, @type = 0, expiry = 6.hours, freeze = false)
    html = RemoteUtil.info_html(@seed, @sbid, expiry, freeze)
    @parser = SeedParser.new(@seed, html)
  end

  def extract_uuid!
    Utils.gen_uuid(@parser.get_title, @parser.get_author)
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
    @misc ||= BookMisc.get_or_create!(extract_uuid!)
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
    if better_seed?(misc, mftime)
      misc.set_seed_sbid(@seed, @sbid)
      misc.set_seed_type(@seed, @type)

      misc.set_seed_chap(@seed, @parser.get_latest)
      misc.mftime = misc.seed_chaps[@seed].mftime
    end

    misc
  end

  def better_seed?(misc : BookMisc::Data, mftime : Int64)
    sbid = misc.seed_sbids[@seed]?
    return true if sbid.nil? || sbid == @sbid

    misc.seed_chaps[@seed]?.try(&.mftime.<= mftime) || true
  end
end
