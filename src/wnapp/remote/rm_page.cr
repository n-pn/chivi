require "log"
require "lexbor"
require "colorize"
require "http/client"

require "../../_util/zstd_util"
require "../../_util/text_util"

class ZH::RmPage
  getter doc : Lexbor::Parser
  delegate css, to: @doc

  # forward_missing_to @doc

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
    @doc.css(selector).inner_text("\n").lines.map { |x| TextUtil.trim_spaces(x) }
  end

  private def extract(node : Lexbor::Node, attr : String)
    text = attr == "text" ? node.inner_text : node.attribute_by(attr) || ""
    TextUtil.trim_spaces(text)
  end

  def remove!(node : Lexbor::Node, *tags : Symbol)
    node.children.each { |x| x.remove! if tags.includes?(x.tag_sym) }
  end

  ###

  def self.load!(link : String, file : String, encoding : String = "UTF-8")
    html = ZstdUtil.load!(file) do
      # puts "GET: #{link}".colorize.magenta

      HTTP::Client.get(link) do |res|
        bio = res.body_io

        raise "#{res.status} request failed! " unless res.status.success?
        bio.set_encoding(encoding, invalid: :skip)

        body = bio.gets_to_end.lstrip
        raise "invalid content!" unless body[0] == '<'

        encoding == "UTF-8" ? body : body.sub(/set="?#{encoding}"?/i, "set=utf-8")
      end
    end

    new(html)
  end
end
