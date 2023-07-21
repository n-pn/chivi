require "./_base"

class Rmchap
  getter ch_no : Int32
  getter s_cid : String

  getter ctitle : String
  getter subdiv : String

  def initialize(@ch_no, @s_cid, @ctitle, @subdiv)
  end

  def self.clean_subdiv(subdiv : String)
    subdiv.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
  end

  HAN_NUMS = "零〇一二两三四五六七八九十百千"
  HAN_SUBS = "集卷季"

  SUBDIV_RE = {
    /^(第?[#{HAN_NUMS}\d]+[#{HAN_SUBS}].*?)(第?[#{HAN_NUMS}\d]+[章节幕回折].*)$/,
    # /^(第?[#{HAN_NUMS}\d]+[#{HAN_SUBS}].*?)(（\p{N}+）.*)$/,
    /^【(第?[#{HAN_NUMS}\d]+[#{HAN_SUBS}])】(.+)$/,
  }

  def self.split_ctitle(ctitle : String, subdiv = "") : Tuple(String, String)
    ctitle = Rmutil.clean_text(ctitle)
    return {ctitle, subdiv} unless subdiv.empty?

    SUBDIV_RE.each do |regex|
      next unless match = regex.match(ctitle)
      return {match[2].lstrip, match[1].rstrip}
    end

    {ctitle, subdiv}
  end
end

class Rmcata
  def initialize(@conf : Rmconf, html : String)
    @doc = Rmpage.new(html)
  end

  getter latest_cid : String { @conf.extract_cid(@doc.get!(@conf.cata_latest)) }
  getter update_str : String { @conf.cata_update.try { |x| @doc.get!(x) } || "" }

  def content_changed?(prev_latest : String, prev_update : String)
    (prev_latest != latest_cid) || (update_str != prev_update)
  end

  @chaps = [] of Rmchap

  def chap_list
    extract_chaps!(@conf.cata_type) if @chaps.empty?
    @chaps
  end

  def extract_chaps!(chap_type : String = "anchor")
    case chap_type
    when "anchor"   then extract_type_anchor(@conf.cata_elem)
    when "subdiv"   then extract_type_subdiv(@conf.cata_elem)
    when "wenku8"   then extract_type_wenku8(@conf.cata_elem)
    when "uukanshu" then extract_type_uukanshu(@conf.cata_elem)
    when "ymxwx"    then extract_type_ymxwx(@conf.cata_elem)
    else                 raise "unsupported parser type: #{chap_type}"
    end
  end

  private def add_chap(node : Lexbor::Node?, subdiv = "")
    return unless node && (href = node.attributes["href"]?)

    ctitle = node.inner_text("  ")
    return if ctitle.empty?

    ch_no = @chaps.size &+ 1
    s_cid = @conf.extract_cid(href)

    ctitle, subdiv = Rmchap.split_ctitle(ctitle, subdiv)

    @chaps << Rmchap.new(ch_no, s_cid, ctitle, subdiv)
  rescue ex
    Log.error(exception: ex) { ex.message.colorize.red }
  end

  # extract chapter info by finding <a> elements
  private def extract_type_anchor(selector : String)
    @doc.css(selector).each { |node| add_chap(node) }
  end

  # extract chapter info + subdiv by scanning <dt> and <dd> elements
  private def extract_type_subdiv(selector : String)
    return unless container = @doc.find(selector)
    subdiv = ""

    container.children.each do |node|
      case node.tag_sym
      when :dt
        inner = node.css("b", &.first?) || node
        subdiv = Rmchap.clean_subdiv(inner.inner_text)
        add_chap(node.css("a", &.first?), subdiv)
      when :dd
        next if subdiv.includes?("最新章节")
        add_chap(node.css("a", &.first?), subdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_wenku8(selector : String)
    return unless container = @doc.find(selector)
    subdiv = ""

    container.css("td").each do |node|
      case node.attributes["class"]?
      when "vcss" then subdiv = Rmchap.clean_subdiv(node.inner_text)
      when "ccss" then add_chap(node.css("a", &.first?), subdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_uukanshu(selector : String)
    return unless container = @doc.find(selector)
    subdiv = ""

    # NOTE: chapters are in reversed order
    container.children.to_a.reverse_each do |node|
      if node.attributes["class"]? == "volume"
        subdiv = node.inner_text.strip
      else
        add_chap(node.css("a").first?, subdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_ymxwx(selector : String)
    return unless container = @doc.find(selector)
    subdiv = ""

    container.children.each do |node|
      next unless node.tag_sym == :li

      case node.attributes["class"]?
      when "col1 volumn"
        subdiv = Rmchap.clean_subdiv(node.inner_text)
      when "col3"
        next if subdiv.includes?("最新九章")
        add_chap(node.css("a", &.first?), subdiv)
      end
    end
  end
end
