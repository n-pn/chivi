require "json"
require "colorize"

require "./models/zh_texts"
require "./models/vp_texts"

require "./import/source_text"

require "../engine/lexicon"
require "../engine/convert"

module ChapText
  extend self

  def load(site : String, bsid : String, csid : String, user : String = "local", dict = "tong-hop", mode : Int32 = 0)
    vp_text = VpText.new(site, bsid, csid, user)
    zh_text = ZhText.new(site, bsid, csid)

    if vp_text.cached?
      vp_text.load!

      unless zh_text.cached?
        zh_text.lines = zh_lines(vp_text.lines)
        zh_text.save!
      end

      return vp_text.lines if mode == 1
    end

    if mode == 1 && zh_text.cached?
      zh_text.load!
    else
      zh_text.lines = SourceText.fetch!(site, bsid, csid, keep_html: false)
      zh_text.save!
    end

    dicts = Lexicon.convert(dict, user)
    vp_text.lines = zh_text.lines.map_with_index do |line, idx|
      convert(line, dicts, idx > 0)
    end

    vp_text.save!
    vp_text.lines
  end

  def convert(line : String, dicts : Array(Tuple(LxDict, LxDict)), plain : Bool = true)
    nodes = plain ? Convert.plain(line, dicts) : Convert.title(line, dicts)
    vp_line(nodes)
  end

  SEP_0 = "ǁ"
  SEP_1 = "¦"

  def vp_line(cv_nodes : CvNodes)
    cv_nodes.map { |token| {token.key, token.val, token.dic}.join(SEP_1) }.join(SEP_0)
  end

  def zh_lines(vp_lines : Array(String)) : Array(String)
    vp_lines.map { |line| zh_line(line) }
  end

  def zh_line(vp_line : String) : String
    vp_line.split(SEP_0).map { |x| x.split(SEP_1, 2)[0] }.join("")
  end

  def vi_lines(vp_lines : Array(String)) : Array(String)
    vp_lines.map { |line| vi_line(line) }
  end

  def vi_line(vp_line : String) : String
    vp_line.split(SEP_0).map { |x| x.split(SEP_1, 3)[1] }.join("")
  end
end
