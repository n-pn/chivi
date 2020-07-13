require "myhtml"
require "colorize"
require "file_utils"

require "../kernel/book_info"
require "../kernel/chap_list"

require "../_utils/han_to_int"
require "../_utils/html_utils"
require "../_utils/time_utils"
require "../_utils/text_utils"

require "./remote_util"
require "./source_util"

class RemoteInfo
  getter seed : String
  getter sbid : String
  getter type : Int32

  def initialize(@seed, @sbid, @type = 0, expiry = 6.hours, freeze = false)
    html = RemoteUtil.info_html(@seed, @sbid, expiry, freeze)
    @doc = Myhtml::Parser.new(html)
  end

  @title : String? = nil

  def title : String
    @title ||= extract_title.try { |x| SourceUtil.fix_title(x) } || ""
  end

  def extract_title
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
  end

  @author : String? = nil

  def author : String
    @author ||= extract_author.try { |x| SourceUtil.fix_author(x, title) } || ""
  end

  def extract_author
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
  end

  @intro : String? = nil

  def intro : String
    @intro ||= extract_intro || ""
  end

  def extract_intro
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
  end

  @cover : String? = nil

  def cover : String?
    @cover ||= extract_cover || ""
  end

  def extract_cover
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
  end

  @genre : String? = nil

  def genre : String
    @genre ||= extract_genre.try { |x| SourceUtil.fix_genre(x) } || ""
  end

  def extract_genre
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
  end

  @tags : Array(String)? = nil

  def tags : Array(String)
    @tags ||= extract_tags
  end

  def extract_tags
    return [] of String unless @seed == "hetushu"
    @doc.css(".tag a").map(&.inner_text).to_a.reject! do |tag|
      tag == author || tag == title
    end
  end

  @status : Int32? = nil

  def status : Int32
    @status ||= extract_status || 0
  end

  def extract_status
    case @seed
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      map_status(meta_data("og:novel:status"))
    when "hetushu"
      klass = node_attr(".book_info", "class").not_nil!
      klass.includes?("finish") ? 1 : 0
    when "zhwenpg", "69shu"
      0
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  def map_status(status : String?)
    case status
    when "完成", "完本", "已经完结", "已经完本", "完结"
      1
    else
      0
    end
  end

  @mftime : Int64? = nil

  def mftime : Int64
    @mftime ||= extract_mftime
  end

  def extract_mftime
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

  @latest_chap : ChapItem? = nil

  def latest_chap
    @latest_chap ||= extract_latest_chap || ChapItem.new("", "")
  end

  def extract_latest_chap
    case @seed
    when "jx_la", "nofff", "rengshu", "xbiquge", "duokan8", "paoshu8"
      extract_latest_chap_by_meta_tag()
    when "69shu"
      extract_latest_chap_by_css(".mulu_list:first-of-type a:first-child")
    when "hetushu"
      extract_latest_chap_by_css("#dir :last-child a:last-of-type")
    when "zhwenpg"
      extract_latest_chap_by_css(".fontwt0 + a")
    else
      raise "Seed `#{@seed}` unsupported!"
    end
  end

  def extract_latest_chap_by_meta_tag
    return unless href = meta_data("og:novel:latest_chapter_url")
    text = meta_data("og:novel:latest_chapter_name").not_nil!
    if @seed == "duokan8"
      text = text.sub(/^.*正文\s*/, "").sub(/^.*章节目录\s*/, "")
    end

    ChapItem.new(extract_scid(href), text)
  end

  def extract_latest_chap_by_css(selector)
    return unless node = find_node(selector)
    scid = extract_scid(node.attributes["href"])
    ChapItem.new(scid, node.inner_text.strip)
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

  def chapters : Array(ChapItem)
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

            scid = extract_scid(link.attributes["href"])
            chaps << ChapItem.new(scid, text, label)
          end
        end
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

    chaps.reverse! if latest_chap.scid == chaps.first.scid
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
      end

      next unless link = node.css("a").first?
      next unless href = link.attributes["href"]?
      chaps << ChapItem.new(extract_scid(href), link.inner_text, label)
    end

    if @seed == "jx_la"
      label_idx = 0
      label_acc = 0
      title_idx = 0

      chaps.sort_by! do |chap|
        if idx = label_index(chap.label_zh)
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

  @uuid : String? = nil

  def uuid : String
    @uuid ||= get_uuid
  end

  def get_uuid
    return "--" if title.empty? || author.empty?
    Utils.gen_uuid(title, author)
  end

  def emit_book_info(info : BookInfo? = nil) : BookInfo
    info ||= BookInfo.get_or_create(title, author)

    info.add_genre(genre)
    info.add_tags(tags)

    info.intro_zh = intro if info.intro_zh.empty?
    info.add_cover(cover)
    info.status = status

    info.add_seed(@seed, @type)
    seed = info.update_seed(@seed, @sbid, mftime, latest_chap)
    info.mftime = seed.mftime

    info
  end

  def emit_chap_list(list : ChapList? = nil, mode : Symbol = :check)
    list ||= ChapList.get_or_create(uuid, @seed)
    list.sbid = @sbid
    list.type = @type

    if mode == :reset || (mode == :check && invalid_list?(list))
      list.chaps.clear
      list.index.clear
      chapters.each { |chap| list.append(chap) }
    else
      list.size.upto(chapters.size - 1) { |idx| list.append(chapters[idx]) }
    end

    list
  end

  def invalid_list?(list : ChapList)
    list.rebuild_index! if list.index.empty?

    list.index.each do |scid, idx|
      return true unless chap = chapters[idx]?
      return true if chap.scid != scid
    end

    false
  end
end
