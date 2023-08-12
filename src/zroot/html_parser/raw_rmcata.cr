require "uri"
require "colorize"

require "./rmconf"
require "./rmpage"
require "../shared/chinfo"

class ZR::RawRmcata
  # class Chap
  #   getter ch_no : Int32
  #   getter s_cid : String
  #   getter rpath : String

  #   getter title : String
  #   getter chdiv : String

  #   def initialize(@ch_no, @s_cid, @rpath, @title, @chdiv)
  #   end

  #   def as_mirror!(conf : Rmconf)
  #     @rpath = conf.full_path(@rpath)
  #     @s_cid = @ch_no.to_s
  #   end

  # end

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
    cbase = conf.make_cata_path(b_id)
    cfile = conf.cata_file_path(b_id)

    html = conf.load_page(cbase, cfile, stale: stale)
    new(html, conf, cbase: cbase)
  end

  ###

  def initialize(html : String, @conf : Rmconf, @cbase : String)
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

  def gen_cpath(href : String)
    case href
    when .starts_with?('/')
      href[1] == '/' ? href.sub("//#{@conf.hostname}", "") : href
    when .starts_with?("http")
      href.sub(/^https?:\/\/[^\/]+/, "")
    else
      "#{@cbase}#{href}"
    end
  end

  @chlist = [] of Chinfo

  def chap_list(as_mirror : Bool = false)
    extract_chlist!(@conf.cata_type) if @chlist.empty?
    @chlist.each(&.as_mirror!(@conf)) if as_mirror

    @chlist
  end

  def extract_chlist!(chap_type : String = "anchor")
    case chap_type
    when "anchor"     then extract_type_anchor(@conf.cata_elem)
    when "chdiv"      then extract_type_chdiv(@conf.cata_elem)
    when "wenku8"     then extract_type_wenku8(@conf.cata_elem)
    when "uukanshu"   then extract_type_uukanshu(@conf.cata_elem)
    when "ymxwx"      then extract_type_ymxwx(@conf.cata_elem)
    when "00kxs"      then extract_type_00kxs(@conf.cata_elem)
    when "paopaoxs"   then extract_type_paopaoxs(@conf.cata_elem)
    when "51shucheng" then extract_type_51shucheng(@conf.cata_elem)
    else                   raise "unsupported parser type: #{chap_type}"
    end
  end

  private def add_chap(node : Lexbor::Node?, chdiv = "")
    return unless node && (href = node.attributes["href"]?)

    title = node.inner_text("  ")
    return if title.empty?

    ch_no = @chlist.size &+ 1

    s_cid = @conf.extract_cid(href)
    rpath = self.gen_cpath(href)

    title, chdiv = Chinfo.split_title(title, chdiv)
    @chlist << Chinfo.new(ch_no: ch_no, rpath: rpath, s_cid: s_cid, title: title, chdiv: chdiv)
  rescue ex
    Log.error(exception: ex) { ex.message.colorize.red }
  end

  # extract chapter info by finding <a> elements
  private def extract_type_anchor(selector : String)
    @page.css(selector).each { |node| add_chap(node) }
  end

  # extract chapter info + chdiv by scanning <dt> and <dd> elements
  private def extract_type_chdiv(selector : String)
    return unless container = @page.find(selector)
    chdiv = ""

    container.children.each do |node|
      case node.tag_sym
      when :dt
        inner = node.css("b", &.first?) || node
        chdiv = Chinfo.clean_chdiv(inner.inner_text)
        add_chap(node.css("a", &.first?), chdiv)
      when :dd
        next if chdiv.includes?("最新章节")
        add_chap(node.css("a", &.first?), chdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_wenku8(selector : String)
    return unless container = @page.find(selector)
    chdiv = ""

    container.css("td").each do |node|
      case node.attributes["class"]?
      when "vcss" then chdiv = Chinfo.clean_chdiv(node.inner_text)
      when "ccss" then add_chap(node.css("a", &.first?), chdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_uukanshu(selector : String)
    return unless container = @page.find(selector)
    chdiv = ""

    # NOTE: chapters are in reversed order
    container.children.to_a.reverse_each do |node|
      if node.attributes["class"]? == "volume"
        chdiv = node.inner_text.strip
      else
        add_chap(node.css("a").first?, chdiv)
      end
    end
  end

  # extract chap info for some certain website
  private def extract_type_ymxwx(selector : String)
    return unless container = @page.find(selector)
    chdiv = ""

    container.children.each do |node|
      next unless node.tag_sym == :li

      case node.attributes["class"]?
      when "col1 volumn"
        chdiv = Chinfo.clean_chdiv(node.inner_text)
      when "col3"
        next if chdiv.includes?("最新九章")
        add_chap(node.css("a", &.first?), chdiv)
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
    chdiv = ""

    container.children.each do |node|
      case node.attributes["class"]?
      when "mulu-title"
        chdiv = Chinfo.clean_chdiv(node.inner_text)
      when "mulu-list quanji"
        node.css("a").each { |link| add_chap(link, chdiv) }
      end
    end
  end
end
