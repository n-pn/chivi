require "uri"
require "colorize"

require "./rmconf"
require "./rmpage"

class RawRmcata
  class Chap
    getter ch_no : Int32
    getter s_cid : String
    getter cpath : String

    getter ctitle : String
    getter subdiv : String

    def initialize(@ch_no, @s_cid, @cpath, @ctitle, @subdiv)
    end

    def as_mirror!(conf : Rmconf)
      @cpath = conf.full_path(@cpath)
      @s_cid = @ch_no.to_s
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

  ####

  def self.from_link(rlink : String, stale : Time = Time.utc - 1.years)
    host, path = URI.parse(rlink).try { |x| {x.host, x.path} }
    conf = Rmconf.from_host!(host.as(String))
    new(conf, b_id: conf.extract_bid(path.as(String)), stale: stale)
  end

  def self.from_seed(sname : String, b_id : String | Int32, stale : Time = Time.utc - 1.years)
    new(Rmconf.load!(sname), b_id: b_id.to_s, stale: stale)
  end

  def self.new(conf : Rmconf, b_id : String, stale : Time)
    lpath = conf.make_cata_path(b_id)
    lfile = conf.cata_file_path(b_id)

    html = conf.load_page(lpath, lfile, stale: stale)
    new(html, conf, lpath: lpath)
  end

  ###

  def initialize(html : String, @conf : Rmconf, @lpath : String)
    @page = Rmpage.new(html)
  end

  getter latest_cid : String { @conf.extract_cid(@page.get!(@conf.cata_latest)) }

  getter status_str : String do
    return "" unless matcher = @conf.cata_status
    @page.get!(matcher).sub(/(book_info|状态：)\s*/, "")
  end

  getter update_str : String do
    return "" unless matcher = @conf.cata_update
    @page.get!(matcher).sub(/^\s*更新(时间)?\s*[: ：]\s*/, "")
  end

  getter update_int : Int64 do
    update_str = self.update_str
    update_str.empty? ? 0_i64 : @conf.parse_time(update_str).to_unix
  rescue ex
    puts [update_str, ex]
    0_i64
  end

  def content_changed?(prev_latest : String, prev_update : String)
    (prev_latest != latest_cid) || (update_str != prev_update)
  end

  def get_chap_path(href : String)
    case href
    when .starts_with?('/')
      href[1] == '/' ? href.sub("//#{@conf.hostname}", "") : href
    when .starts_with?("http")
      href.sub(/^https?:\/\/[^\/]+/, "")
    else
      "#{@lpath}#{href}"
    end
  end

  @chaps = [] of Chap

  def chap_list(as_mirror : Bool = false)
    extract_chaps!(@conf.cata_type) if @chaps.empty?
    @chaps.each(&.as_mirror!(@conf)) if as_mirror
    @chaps
  end

  def extract_chaps!(chap_type : String = "anchor")
    case chap_type
    when "anchor"     then extract_type_anchor(@conf.cata_elem)
    when "subdiv"     then extract_type_subdiv(@conf.cata_elem)
    when "wenku8"     then extract_type_wenku8(@conf.cata_elem)
    when "uukanshu"   then extract_type_uukanshu(@conf.cata_elem)
    when "ymxwx"      then extract_type_ymxwx(@conf.cata_elem)
    when "00kxs"      then extract_type_00kxs(@conf.cata_elem)
    when "paopaoxs"   then extract_type_paopaoxs(@conf.cata_elem)
    when "51shucheng" then extract_type_51shucheng(@conf.cata_elem)
    else                   raise "unsupported parser type: #{chap_type}"
    end
  end

  private def add_chap(node : Lexbor::Node?, subdiv = "")
    return unless node && (href = node.attributes["href"]?)

    ctitle = node.inner_text("  ")
    return if ctitle.empty?

    ch_no = @chaps.size &+ 1

    s_cid = @conf.extract_cid(href)
    cpath = self.get_chap_path(href)

    ctitle, subdiv = Chap.split_ctitle(ctitle, subdiv)

    @chaps << Chap.new(ch_no, s_cid, cpath, ctitle, subdiv)
  rescue ex
    Log.error(exception: ex) { ex.message.colorize.red }
  end

  # extract chapter info by finding <a> elements
  private def extract_type_anchor(selector : String)
    @page.css(selector).each { |node| add_chap(node) }
  end

  # extract chapter info + subdiv by scanning <dt> and <dd> elements
  private def extract_type_subdiv(selector : String)
    return unless container = @page.find(selector)
    subdiv = ""

    container.children.each do |node|
      case node.tag_sym
      when :dt
        inner = node.css("b", &.first?) || node
        subdiv = Chap.clean_subdiv(inner.inner_text)
        add_chap(node.css("a", &.first?), subdiv)
      when :dd
        next if subdiv.includes?("最新章节")
        add_chap(node.css("a", &.first?), subdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_wenku8(selector : String)
    return unless container = @page.find(selector)
    subdiv = ""

    container.css("td").each do |node|
      case node.attributes["class"]?
      when "vcss" then subdiv = Chap.clean_subdiv(node.inner_text)
      when "ccss" then add_chap(node.css("a", &.first?), subdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_uukanshu(selector : String)
    return unless container = @page.find(selector)
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
    return unless container = @page.find(selector)
    subdiv = ""

    container.children.each do |node|
      next unless node.tag_sym == :li

      case node.attributes["class"]?
      when "col1 volumn"
        subdiv = Chap.clean_subdiv(node.inner_text)
      when "col3"
        next if subdiv.includes?("最新九章")
        add_chap(node.css("a", &.first?), subdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_00kxs(selector : String)
    return unless container = @page.find(selector)
    container.children.each { |node| node.remove! if node.tag_sym != :li }
    container.css("a").each { |node| add_chap(node, "") }
  end

  # extract chap info for some certain website
  private def extract_type_paopaoxs(selector : String)
    @page.css(selector).each do |node|
      node.css(".chapter_date").each(&.remove!)
      add_chap(node)
    end
  end

  # extract chap info for some certain website
  private def extract_type_51shucheng(selector : String)
    return unless container = @page.find(selector)
    subdiv = ""

    container.children.each do |node|
      case node.attributes["class"]?
      when "mulu-title"
        subdiv = Chap.clean_subdiv(node.inner_text)
      when "mulu-list quanji"
        node.css("a").each { |link| add_chap(link, subdiv) }
      end
    end
  end
end
