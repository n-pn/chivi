require "./shared/html_parser"
require "../appcv/nvchap/ch_info"

class CV::RemoteMulu
  getter chaps : Array(ChInfo)

  def initialize(@doc : HtmlParser, @sname : String, @chaps = [] of ChInfo)
  end

  def extract_schid(href : String)
    case @sname
    when "zhwenpg" then href.sub("r.php?id=", "")
    when "69shu"   then File.basename(href)
    when "kanshu8" then File.basename(href, ".html").sub("read_", "")
    else                File.basename(href, ".html")
    end
  end

  def extract_chaps! : Nil
    case @sname
    when "ptwxz"    then extract_chapters_plain(".centent li > a")
    when "69shu"    then extract_chapters_plain("#catalog li > a")
    when "uukanshu" then extract_chapters_uukanshu
    when "uuks"     then extract_chapters_plain(".box_con li > a")
    when "yannuozw"
      extract_chapters_plain(".booklist .book > a")
    when "5200"    then extract_chapters_chvol(".listmain > dl")
    when "hetushu" then extract_chapters_chvol("#dir")
    when "kanshu8"
      extract_chapters_plain(".pt-chapter-cont-detail.full > a")
    when "133txt"
      extract_chapters_chvol(".box_con:last-of-type > div:last-of-type > dl")
    when "zhwenpg"
      extract_chapters_plain(".clistitem > a")

      # reverse the list if chap list is reversed
      last_schid = extract_schid(@doc.attr(".fontwt0 + a", "href"))
      if @chaps.first.schid == last_schid
        chaps.reverse!
        chaps.each_with_index(1) { |chinfo, chidx| chinfo.chidx = chidx.to_i16 }
      end
    when "duokan8"
      extract_chapters_plain(".chapter-list a")
    else
      extract_chapters_chvol("#list > dl")
    end
  end

  def clean_chvol(chvol : String)
    chvol.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
  end

  def add_chap(node : Lexbor::Node?, chvol = "")
    return unless node && (href = node.attributes["href"]?)

    chidx = @chaps.size.to_i16 &+ 1
    schid = extract_schid(href)
    title = node.inner_text

    chap = ChInfo.new(chidx, schid, title, chvol)
    @chaps << chap unless chap.invalid?
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

  def extract_chapters_uukanshu(selector = "#chapterList")
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
