require "uri"
require "colorize"

require "./rmhost"
require "./rmpage"
require "../shared/chinfo"
require "../../_util/chap_util"

class ZR::RawRmstem
  ####

  def self.from_link(rlink : String, stale : Time = Time.utc - 1.years)
    hostname, path = URI.parse(rlink).try { |x| {x.host, x.path} }
    hostname = hostname.as(String).sub("www.", "")

    host = Rmhost.from_host!(hostname)
    new(host, b_id: host.extract_bid(path.as(String)), stale: stale)
  end

  def self.from_stem(sname : String, b_id : String | Int32, stale : Time = Time.utc - 1.years)
    new(Rmhost.from_name!(sname), b_id: b_id.to_s, stale: stale)
  end

  def self.new(host : Rmhost, b_id : String | Int32, stale : Time)
    stem_href = host.stem_href(b_id)
    save_path = host.stem_file(b_id)

    stale = Time.utc - 100.years unless host.active?
    html = host.load_page(stem_href, save_path, stale: stale)

    new(html, host, b_id: b_id.to_s, base: host.full_url(stem_href))
  end

  ###

  getter base : String

  def initialize(html : String, @host : Rmhost, @b_id : String,
                 base : String = host.stem_url(b_id))
    @base = base.ends_with?('/') ? base.rchop('/') : File.dirname(base)
    @page = Rmpage.new(html)
  end

  getter latest_cid : String { @host.extract_cid(@page.get!(@host.cata_latest)) }

  getter status_str : String do
    return "" unless matcher = @host.cata_status
    @page.get!(matcher).sub(/(book_info|状态：)\s*/, "")
  end

  getter update_str : String do
    return "" unless matcher = @host.cata_update
    @page.get!(matcher).sub(/^\s*更新(时间)?\s*[: ：]\s*/, "")
  end

  getter update_int : Int64 do
    update_str = self.update_str
    update_str.empty? ? 0_i64 : @host.parse_time(update_str).to_unix
  rescue ex
    puts [update_str, ex]
    0_i64
  end

  def content_changed?(prev_latest : String, prev_update : String)
    (prev_latest != latest_cid) || (update_str != prev_update)
  end

  private def full_url(href : String)
    case href
    when .starts_with?("http") then href
    when .starts_with?("//")   then "https//:#{href}"
    when .starts_with?('/')    then "#{@base}#{href}"
    else                            "#{@base}.#{href}"
    end
  end

  @chlist = [] of Chinfo

  def chap_list
    extract_chlist!(@host.cata_type) if @chlist.empty?
    @chlist
  end

  def extract_chlist!(chap_type : String = "anchor")
    case chap_type
    when "anchor"     then extract_type_anchor(@host.cata_elem)
    when "subdiv"     then extract_type_subdiv(@host.cata_elem)
    when "wenku8"     then extract_type_wenku8(@host.cata_elem)
    when "uukanshu"   then extract_type_uukanshu(@host.cata_elem)
    when "ymxwx"      then extract_type_ymxwx(@host.cata_elem)
    when "00kxs"      then extract_type_00kxs(@host.cata_elem)
    when "paopaoxs"   then extract_type_paopaoxs(@host.cata_elem)
    when "51shucheng" then extract_type_51shucheng(@host.cata_elem)
    else                   raise "unsupported parser type: #{chap_type}"
    end
  end

  private def add_chap(node : Lexbor::Node?, subdiv = "")
    return unless node && (href = node.attributes["href"]?)

    ctitle = node.inner_text("  ")
    return if ctitle.empty?

    ch_no = @chlist.size &+ 1
    rlink = self.full_url(href)

    sc_id = @host.extract_cid(href)
    spath = "#{@host.seedname}/#{@b_id}/#{sc_id}"

    ctitle, subdiv = ChapUtil.split_ztitle(ctitle, subdiv)

    @chlist << Chinfo.new(ch_no: ch_no, rlink: rlink, spath: spath, ztitle: ctitle, zchdiv: subdiv)
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
        subdiv = ChapUtil.clean_zchdiv(inner.inner_text)
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
      when "vcss" then subdiv = ChapUtil.clean_zchdiv(node.inner_text)
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
        subdiv = ChapUtil.clean_zchdiv(node.inner_text)
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
        subdiv = ChapUtil.clean_zchdiv(node.inner_text)
      when "mulu-list quanji"
        node.css("a").each { |link| add_chap(link, subdiv) }
      end
    end
  end
end
