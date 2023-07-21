require "log"
require "yaml"
require "lexbor"
require "../../../_util/text_util"

Log.setup_from_env

alias CssExtract = Tuple(String, String)

class Rmpage
  getter doc : Lexbor::Parser
  delegate css, to: @doc

  # forward_missing_to @doc

  def initialize(html : String)
    @doc = Lexbor::Parser.new(html)
  end

  def purge_tags!(node : Lexbor::Node, *tags : Symbol)
    node.children.each { |x| x.remove! if tags.includes?(x.tag_sym) }
  end

  @[AlwaysInline]
  def find!(query : String)
    @doc.css(query, &.first)
  end

  @[AlwaysInline]
  def find(query : String)
    @doc.css(query, &.first?)
  end

  @[AlwaysInline]
  def inner_text(node : Lexbor::Node, sep = '\n')
    clean_text(node.inner_text(sep))
  end

  private def extract_text(node : Lexbor::Node, extract_type : String)
    case extract_type
    when "", "text" then node.inner_text(' ')
    else                 node.attributes[extract_type]? || ""
    end
  end

  @[AlwaysInline]
  private def clean_text(text : String)
    text.gsub(/\p{Z}/, ' ').strip
  end

  @[AlwaysInline]
  private def clean_text(text : Array(String))
    text.map! { |line| clean_text(line) }
  end

  @[AlwaysInline]
  def get(selector : String, extract_type : String = "") : String?
    find(selector).try do |node|
      text = extract_text(node, extract_type)
      clean_text(text)
    end
  end

  @[AlwaysInline]
  def get(extractor : CssExtract) : String?
    selector, extract_type = extractor
    get(selector, extract_type)
  end

  @[AlwaysInline]
  def get!(query : String, attr : String = "") : String
    get(query, attr) || raise "invalid query: #{query}"
  end

  @[AlwaysInline]
  def get!(extractor : CssExtract) : String?
    get(extractor) || raise "invalid extractor #{extractor}"
  end

  def get_all(query : String, attr : String = "") : Array(String)
    @doc.css(query).map { |x| extract_text(x, attr) }
  end

  def get_lines(query : String, purges : Enumerable(Symbol)) : Array(String)
    return [] of String unless node = find(query)
    node.children.each { |x| x.remove! if purges.includes?(x.tag_sym) }
    get_lines(node)
  end

  @[AlwaysInline]
  def get_lines(query : String) : Array(String)
    get_lines(@doc.css(query))
  end

  def get_lines(node : Lexbor::Node) : Array(String)
    text = node.inner_text('\n')

    text.each_line.compact_map do |line|
      line = clean_text(line)
      line unless line.blank?
    end.to_a
  end
end

class Rmconf
  include YAML::Serializable

  getter seedname : String
  getter hostname : String

  getter? insecure = false
  getter encoding = "GBK"

  getter cookie = ""

  ####

  getter book_page_match = ""
  @[YAML::Field(ignore: true)]
  getter book_page_re : Regex { Regex.new(@book_page_match) }

  getter chap_page_match = ""
  @[YAML::Field(ignore: true)]
  getter chap_page_re : Regex { Regex.new(@chap_page_match) }

  ###

  getter mbid_path = ""
  getter mbid_elem = ""

  ###

  getter book_path = ""
  getter book_type = ""

  ###

  getter cata_path = ""
  getter cata_type = ""
  getter cata_elem = ""

  getter cata_latest = {"meta[property=\"og:novel:latest_chapter_url\"]", "content"}
  getter cata_update : CssExtract? = nil

  ###

  getter chap_path = ""

  def extract_bid(href : String)
    book_page_re.match!(href)[1]
  end

  def extract_cid(href : String)
    chap_page_re.match!(href)[2]
  end

  ####

  ROOT_DIR = "/2tb/var.chivi/.keep"
  BMID_DIR = "#{ROOT_DIR}/latest/%{name}.htm"
  BOOK_DIR = "#{ROOT_DIR}/wnbook/%{site}/%{bid}.htm"
  CHAP_DIR = "#{ROOT_DIR}/wnchap/%{site}/%{bid}/%{cid}.htm"

  def mbid_file_path
    BMID_DIR % {name: @seedname}
  end

  getter root_link : String do
    String.build do |io|
      io << "http"
      io << 's' unless self.insecure?
      io << "://" << @hostname
    end
  end

  def make_full_link(path : String)
    "#{self.root_link}#{path}"
  end

  def make_book_path(bid : Int32 | String)
    case bid
    in Int32  then @book_path % {div: bid // 1000, bid: bid}
    in String then @book_path % {bid: bid}
    end
  end

  def book_file_path(bid : Int32 | String)
    BOOK_DIR % {site: @hostname, bid: bid}
  end

  def make_cata_path(bid : Int32 | String)
    case bid
    in Int32  then @cata_path % {div: bid // 1000, bid: bid}
    in String then @cata_path % {bid: bid}
    end
  end

  def cata_file_path(bid : Int32 | String)
    file_path = book_file_path(bid)
    same_page = @book_path == @cata_path
    same_page ? file_path : file_path.sub(".htm", "-cata.htm")
  end

  def make_chap_path(bid : Int32 | String, cid : Int32 | String)
    case bid
    in Int32  then @chap_path % {div: bid // 1000, bid: bid, cid: cid}
    in String then @chap_path % {bid: bid, cid: cid}
    end
  end

  def chap_file_path(bid : Int32 | String, cid : Int32 | String)
    CHAP_DIR % {site: @hostname, bid: bid, cid: cid}
  end

  #######

  CONF_DIR = "var/_conf/globs"

  def self.load!(hostname : String)
    from_yaml(File.read("#{CONF_DIR}/#{hostname}.yml"))
  end

  struct Known
    include YAML::Serializable

    getter type = 0
    getter host = ""
  end

  class_getter all_known : Hash(String, Known) do
    File.open("#{CONF_DIR}/all_known.yml", "r") do |file|
      Hash(String, Known).from_yaml(file)
    end
  end

  def self.load_known!(seed : String) : self
    load!(self.all_known[seed].host)
  end
end

module Rmutil
  def self.still_fresh?(file_path : String, too_old : Time) : Bool
    File.info?(file_path).try(&.modification_time.> too_old) || false
  end

  def self.clean_text(input : String)
    input.tr("\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000\t\n", " ").strip
  end
end
