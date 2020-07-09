require "myhtml"
require "colorize"
require "file_utils"

require "../kernel/book_info"
require "../kernel/chap_seed"

require "../_utils/han_to_int"
require "../_utils/html_utils"
require "../_utils/time_utils"
require "../_utils/text_utils"

require "./remote_util"

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
          if text = meta_data("og:description")
            Utils.split_text(text).join("\n")
          end
        when "zhwenpg"
          # TODO: trad to simp?
          if text = node_text("tr:nth-of-type(3)")
            Utils.split_text(text).join("\n")
          end
        when "hetushu"
          @doc.css(".intro > p").map(&.inner_text).join("\n")
        when "69shu"
          nil # TODO: extract 69shu book intro
        else
          raise "Unknown seed type [#{@seed}]!"
        end

      intro || ""
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
        raise "Seed `#{@seed}` unsupported!"
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
        raise "Seed `#{@seed}` unsupported!"
      end
  end

  @latest : ChapItem? = nil

  def get_latest
    @latest ||= begin
      latest = ChapItem.new("", "")

      case @seed
      when "jx_la", "nofff", "rengshu", "xbiquge", "duokan8", "paoshu8"
        if href = meta_data("og:novel:latest_chapter_url")
          text = meta_data("og:novel:latest_chapter_name").not_nil!
          text = text.sub(/^章节目录\s+/, "") if @seed == "duokan8"

          latest.scid = extract_scid(href)
          latest.set_title(text)
        end
      when "zhwenpg"
        if node = find_node(".fontwt0 + a")
          latest.scid = extract_scid(node.attributes["href"])
          latest.set_title(node.inner_text.strip)
        end
      when "69shu"
        if node = find_node(".mulu_list:first-of-type a:first-child")
          latest.scid = extract_scid(node.attributes["href"])
          latest.set_title(node.inner_text.strip)
        end
      when "hetushu"
        if node = find_node("#dir > dd:last-child > a")
          latest.scid = extract_scid(node.attributes["href"])
          latest.set_title(node.inner_text.strip)
        end
      else
        raise "Seed `#{@seed}` unsupported!"
      end

      latest
    end
  end

  private def extract_scid(href : String)
    case @seed
    when "jx_la", "nofff", "rengshu", "xbiquge", "duokan8", "paoshu8", "hetushu"
      File.basename(href, ".html")
    when "69shu"
      File.basename(href)
    when "zhwenpg"
      href.sub("r.php?id=", "")
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  @chapters : Array(ChapItem)? = nil

  def get_chaps : Array(ChapItem)
    @chapters ||=
      case @seed
      when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
        extract_generic_chaps("#list > dl")
      when "hetushu"
        extract_generic_chaps("#dir")
      when "duokan8"
        extract_duokan8_chaps
      when "zhwenpg"
        extract_zhwenpg_chaps
      when "69shu"
        extract_69shu_chaps
      else
        raise "Seed `#{@seed}` unsupported!"
      end
  end

  private def extract_duokan8_chaps
    chaps = [] of ChapItem

    @doc.css(".chapter-list a").each do |link|
      if href = link.attributes["href"]?
        scid = extract_scid(href)
        chaps << ChapItem.new(scid, link.inner_text)
      end
    end

    chaps
  end

  private def extract_69shu_chaps
    chaps = [] of ChapItem

    @doc.css(".mu_contain").each do |node|
      label = node.css("h2").first.inner_text.strip
      next if label.ends_with?("最新6章")

      node.css(".mulu_list:first-of-type > li > a").each do |link|
        text = link.inner_text
        # next if text.starts_with?("我要报错！")

        scid = extract_scid(link.attributes["href"])
        chaps << ChapItem.new(scid, text, label)
      end
    end

    chaps
  end

  private def extract_zhwenpg_chaps
    chaps = [] of ChapItem

    @doc.css("#dulist a").each do |link|
      scid = extract_scid(link.attributes["href"])
      chaps << ChapItem.new(scid, link.inner_text)
    end

    chaps.reverse! if get_latest.scid == chaps.first.scid
    chaps
  end

  private def extract_generic_chaps(selector : String)
    chaps = [] of ChapItem
    return chaps unless node = find_node(selector)

    label = "正文"

    node.children.each do |node|
      case node.tag_sym
      when :dt
        label = node.inner_text.gsub(/《.*》/, "").strip
      when :dd
        next if label.includes?("最新章节")
        next unless link = node.css("a").first?
        next unless href = link.attributes["href"]?

        chaps << ChapItem.new(extract_scid(href), link.inner_text, label)
      else
        # skip
      end
    end

    if @seed == "jx_la"
      label_idx = 0
      label_acc = 0
      title_idx = 0

      chaps.sort_by! do |chap|
        if idx = label_index(chap.label)
          label_idx = idx
          label_acc = 0
        else
          label_acc += 1
        end

        title_idx += 1
        {label_idx, label_acc, title_idx}
      end
    end

    chaps
  end

  INDEX_RE  = /([零〇一二两三四五六七八九十百千]+|\d+)[集卷]/
  IDX_CACHE = {} of String => Int32

  private def label_index(label : String) : Int32?
    return 0 if label == "作品相关"

    unless index = IDX_CACHE[label]?
      index = INDEX_RE.match(label).try { |x| Utils.han_to_int(x[1]).to_i } || 0
      IDX_CACHE[label] = index
    end

    return index if index > 0
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

  getter parser : SeedParser
  forward_missing_to parser

  def initialize(@seed, @sbid, expiry = 6.hours, freeze = false)
    html = RemoteUtil.info_html(@seed, @sbid, expiry, freeze)
    @parser = SeedParser.new(@seed, html)
  end

  def get_uuid : String
    title = @parser.get_title
    author = @parser.get_author
    return "--" if title.empty? || author.empty?

    Utils.gen_uuid(title, @parser.get_author)
  end

  def emit_book_info(info : BookInfo? = nil) : BookInfo
    info ||= BookInfo.find_or_create(@parser.get_title, @parser.get_author)

    info.set_genre(@parser.get_genre)
    info.add_tag(@parser.get_genre)
    info.add_tags(@parser.get_tags)

    info.add_cover(@parser.get_cover)
    info.intro_zh = @parser.get_intro if info.intro_zh.empty?
    info.status = @parser.get_status

    info.add_seed(@seed, @type)

    latest = @parser.get_latest
    mftime = @parser.get_mftime

    seed = info.update_seed(@seed, @sbid, latest.scid, mftime) do |seed|
      seed.latest.title = latest.title
      seed.latest.label = latest.label
    end

    info.mftime = seed.mftime
    info
  end

  def emit_chap_list(old_list = ChapSeed.init!(get_uuid, @seed), mode = 0)
    new_list = @parser.get_chaps

    size = old_list.size
    size = new_list.size if size > new_list.size

    0.upto(size - 1).each do |i|
      old_chap = old_list[i]
      new_chap = new_list[i]

      if old_chap.scid != new_chap.scid || mode > 0
        old_chap.scid = new_chap.scid
        old_chap.title = new_chap.title
        old_chap.label = new_chap.label
      end
    end

    size.upto(new_list.size - 1) do |i|
      old_list << new_list[i]
    end

    old_list
  end
end
