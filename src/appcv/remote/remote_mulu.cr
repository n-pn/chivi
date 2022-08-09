require "./html_parser"
require "../ch_info"

class CV::RemoteMulu
  record Chinfo, chidx : Int32, schid : String, title : String, chvol : String

  getter chaps : Array(Chinfo)

  def initialize(@doc : HtmlParser, @sname : String)
    @chaps = [] of Chinfo
  end

  def extract_schid(href : String)
    case @sname
    when "zhwenpg" then href.sub("r.php?id=", "")
    when "69shu"   then File.basename(href)
    when "kanshu8" then File.basename(href, ".html").sub("read_", "")
    else                File.basename(href, ".html")
    end
  end

  STRATEGIES = {
    "ptwxz"    => {:plain, ".centent li > a"},
    "69shu"    => {:plain, "#catalog li > a"},
    "uuks"     => {:plain, ".box_con li > a"},
    "duokan8"  => {:plain, ".chapter-list a"},
    "yannuozw" => {:plain, ".booklist .book > a"},
    "5200"     => {:chvol, ".listmain > dl"},
    "hetushu"  => {:chvol, "#dir"},
    "kanshu8"  => {:plain, ".pt-chapter-cont-detail.full > a"},
    "133txt"   => {:plain, ".box_con:last-of-type > div:last-of-type > dl"},

    "uukanshu" => {:uukanshu, "#chapterList"},
    "zhwenpg"  => {:plain, ".clistitem > a"},

  }

  def extract_chaps! : Nil
    strategy, selector = STRATEGIES[@sname]? || {:chvol, "#list > dl"}
    case strategy
    when :plain    then extract_chapters_plain(selector)
    when :chvol    then extract_chapters_chvol(selector)
    when :uukanshu then extract_chapters_uukanshu(selector)
    end
  end

  def clean_chvol(chvol : String)
    chvol.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
  end

  def add_chap(node : Lexbor::Node?, chvol = "")
    return unless node && (href = node.attributes["href"]?)

    chidx = @chaps.size &+ 1
    schid = extract_schid(href)

    title = node.inner_text
    return if title.empty?

    title, chvol = TextUtil.format_title(title, chvol)
    @chaps << Chinfo.new(chidx, schid, title, chvol)
  rescue err
    puts err, err.message.colorize.red
  end

  def extract_chapters_chvol(selector : String)
    return unless body = @doc.find(selector)

    chvol = ""

    body.children.each do |node|
      case node.tag_sym
      when :dt
        inner = node.css("b").first? || node
        chvol = clean_chvol(inner.inner_text)
        add_chap(node.css("a").first?, chvol)
      when :dd
        next if chvol.includes?("最新章节")
        add_chap(node.css("a").first?, chvol)
      end
    end
  end

  def extract_chapters_plain(selector : String)
    @doc.css(selector).each { |link| add_chap(link) }
  end

  def extract_chapters_uukanshu(selector : String)
    return unless body = @doc.find(selector)
    chvol = ""

    body.children.to_a.reverse_each do |node|
      if node.attributes["class"]? == "volume"
        chvol = node.inner_text.strip
      else
        add_chap(node.css("a").first?, chvol)
      end
    end
  end
end
