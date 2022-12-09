require "log"
require "zstd"
require "lexbor"
require "colorize"
require "http/client"

class ZH::RmPage
  getter doc : Lexbor::Parser
  forward_missing_to @doc

  def initialize(html : String)
    @doc = Lexbor::Parser.new(html)
  end

  def get(query : String)
    sel, attr = query.split('@', 2)
    extract @doc.css(sel, &.first), attr
  end

  def get_all(query : String)
    sel, attr = query.split('@', 2)
    @doc.css(sel).map { |x| extract(x, attr) }
  end

  def lines(selector : String)
    @doc.css(selector).inner_text("\n").lines.map { |x| clean(x) }
  end

  private def extract(node : Lexbor::Node, attr : String)
    text = attr == "text" ? node.inner_text : node.attributes[attr]
    clean(text)
  end

  def clean(text : String)
    text.tr("\t\u00A0\u205F\u3000", " ").strip
  end

  def remove!(node : Lexbor::Node, *tags : Symbol)
    node.children.each { |x| x.remove! if tags.includes?(x.tag_sym) }
  end

  ###

  def self.load!(file : String)
    if File.exists?(file)
      new Zstd::Decompress::IO.open(File.open(file, "r"), sync_close: true, &.gets_to_end)
    else
      html = yield
      cctx = Zstd::Compress::Context.new(level: 3)
      File.write(file, cctx.compress(html.to_slice))
      new html
    end
  end

  def self.fetch!(link : String, file : String, encoding : String = "UTF-8")
    # puts "GET: #{link}".colorize.magenta

    HTTP::Client.get(link) do |res|
      raise res.body_io.gets_to_end unless res.status.success?

      res.body_io.set_encoding(encoding, invalid: :skip)
      body = res.body_io.gets_to_end.lstrip
      encoding == "UTF-8" ? body : body.sub(/charset="?#{encoding}"?/i, "charset=utf-8")
    end
  end
end
