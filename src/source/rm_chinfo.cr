require "./rm_spider"

require "../utils/time_utils"
require "../utils/text_utils"

class CV::RmChinfo
  getter sname : String
  getter snvid : String

  def initialize(@sname, @snvid, valid = 1.month)
    file = RmSpider.chinfo_file(@sname, @snvid)
    link = RmSpider.chinfo_link(@sname, @snvid)

    html = RmSpider.fetch(file, link, sname: @sname, valid: valid)
    @rdoc = Myhtml::Parser.new(html)
  end

  getter status_int : Int32 do
    case @sname
    when "hetushu"
      klass = node_attr(".book_info", "class")
      klass.includes?("finish") ? 1 : 0
    when "69shu", "zhwenpg"
      0
    else
      RmSpider.map_status(meta_data("og:novel:status"))
    end
  end

  getter update_int : Int64 { RmSpider.fix_mftime(update_str, @sname) }

  getter update_str : String do
    case @sname
    when "69shu"
      node_text(".mu_beizhu").sub(/.+时间：/m, "")
    when "bqg_5200"
      node_text("#info > p:last-child").sub("最后更新：", "")
    else
      meta_data("og:novel:update_time")
    end
  end

  def changed?(prev_chid : String)
    prev_chid != last_chid
  end

  getter last_chid : String do
    case @sname
    when "69shu"   then extract_last_chid_69shu
    when "hetushu" then extract_last_chid("#dir :last-child a:last-of-type")
    when "zhwenpg" then extract_last_chid(".fontwt0 + a")
    else                extract_last_chid_by_meta
    end
  end

  private def extract_last_chid_69shu
    unless node = @rdoc.css("#catalog").first?
      return extract_last_chid(".mulu_list:first-of-type a:first-of-type")
    end

    return "" unless link = node.css("li:last-of-type > a").first?
    extract_chid(link.attributes["href"])
  end

  private def extract_last_chid(sel : String)
    node = find_node(sel).not_nil!
    extract_chid(node.attributes["href"])
  end

  private def extract_last_chid_by_meta
    href = meta_data("og:novel:latest_chapter_url").not_nil!
    @sname != "bqg_5200" ? extract_chid(href) : File.basename(href, ".htm")
  end

  alias Chlist = Array(Array(String))

  getter chapters : Chlist do
    res = chap_list
    res.each_with_index(1) { |list, idx| list.unshift(idx.to_s) }
    res
  end

  getter chap_list : Chlist do
    case @sname
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
        if inner = node.css("b").first?
          label = inner.inner_text
        else
          label = node.inner_text
        end

        label = label.gsub(/《.*》/, "").strip
        label = label == "正文" ? "" : label.sub(/\s{2,}/, " ")
      when :dd
        next if label.includes?("最新章节")
        next unless link = node.css("a").first?
        next unless href = link.attributes["href"]?

        title, label = TextUtils.format_title(link.inner_text, label)
        chlist << [extract_chid(href), title, label] unless title.empty?
      end
    rescue err
      puts err.colorize.red
    end

    chlist
  end

  def extract_69shu_chlist
    nodes = @rdoc.css(".catalog").to_a
    nodes = @rdoc.css(".mu_contain").to_a if nodes.empty?

    chlist = Chlist.new
    return chlist if nodes.empty?

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
            next unless href = link.attributes["href"]?

            title, _ = TextUtils.format_title(link.inner_text, trim: true)
            next if title.empty? || title.starts_with?("我要报错！")

            chlist << [extract_chid(href), title, label]
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

      output << [extract_chid(href), title, label] unless title.empty?
    end

    # check if the list is in correct orlder
    output.reverse! if last_chid == output[0].first

    output
  end

  private def extract_duokan8_chlist
    chlist = Chlist.new

    @rdoc.css(".chapter-list a").each do |link|
      next unless href = link.attributes["href"]?
      title, label = TextUtils.format_title(link.inner_text)
      chlist << [extract_chid(href), title, label] unless title.empty?
    end

    chlist
  end

  private def extract_chid(href : String)
    case @sname
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
