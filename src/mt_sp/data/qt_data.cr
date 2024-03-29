require "../../_util/hash_util"
require "../../_util/text_util"
require "../../cv_env"
require "../util/*"
require "./v_cache"

class SP::QtData
  getter lines : Array(String)

  property pdict = "combine"
  property udict = "qt0"

  property regen = 0
  property h_sep = 0
  property l_sep = 0
  property otype = "json"

  def initialize(ztext : String)
    @lines = CharUtil.canonize(ztext).lines
  end

  def initialize(@lines)
  end

  def set_opts(@pdict, @udict, @regen, @h_sep, @l_sep, @otype = "json")
  end

  getter zsize : Int32 { @lines.sum { |x| x.size &+ 1 } }

  def get_vtran(qtype : String) : String
    return "" if @lines.empty?

    case qtype
    when .starts_with?("mtl")
      return call_mtran(qtype)
    when "qt_v1"
      return call_qt_v1(chunk: 3000)
    when "hname"
      return @lines.join('\n') { |line| MT::QtCore.tl_hvname(line) }
    when "hviet"
      return @lines.join('\n') { |line| MT::QtCore.tl_hvword(line) }
    end

    load_vtext(qtype) || raise "Lỗi dịch nhanh với chế độ #{qtype}"
  end

  def load_vtext(qtype : String) : String?
    vobj = VCache::Obj.parse(qtype)

    cached, remain = VCache.get_val(obj: vobj, raws: @lines)
    return cached.join('\n') if remain.empty?

    missing = remain.map { |idx| @lines[idx] }

    case vobj
    when .bd_zv? # baidu translator
      vlines = BdTran.api_translate(missing, tl: "vie")
    when .bd_ze? # baidu translator
      vlines = BdTran.api_translate(missing, tl: "en")
    when .ms_zv? # microsoft transltor
      vlines = MsTran.free_translate(missing, sl: "zh", tl: "vi").map(&.first)
    when .dl_ze? # deepl
      vlines = DlTran.translate(missing, sl: "ZH", tl: "EN")
    when .dl_je? # deepl
      vlines = DlTran.translate(missing, sl: "JE", tl: "EN")
    when .c_gpt? # GPT Tien Hiep
      vlines = call_c_gpt(missing)
    when .m_gpt? # GPT Hien Dai
      vlines = call_m_gpt(missing)
    else
      raise "Không hỗ trợ cách dịch nhanh [#{qtype}]"
    end

    return unless vlines
    VCache.cache!(obj: vobj, raws: missing, vals: vlines)

    vlines.each_with_index { |vtext, idx| cached[remain[idx]] = vtext }
    cached.join('\n')
  end

  private def call_qt_v1(chunk = 3000)
    wn_id = @pdict.starts_with?("wn") ? @pdict[2..].to_i : 0
    q_url = "#{CV_ENV.m1_host}/_m1/qtran?wn=#{wn_id}&hs=#{@h_sep}&op=txt"
    HTTP::Client.post(q_url, body: @lines.join('\n'), &.body_io.gets_to_end)
  end

  MT_AI_API = "#{CV_ENV.ai_host}/_ai/qtran"

  def call_mtran(qtype : String)
    url = "#{MT_AI_API}?qt=#{qtype}&op=#{@otype}&pd=#{@pdict}&ud=#{@udict}&hs=#{h_sep}&ls=#{l_sep}&rg=#{regen}"
    HTTP::Client.post(url, body: @lines.join('\n'), &.body_io.gets_to_end)
  end

  JSON_HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

  private def call_c_gpt(lines : Array(String))
    body = {test_key: lines.join('\n')}.to_json

    HTTP::Client.post(CV_ENV.c_gpt_host, headers: JSON_HEADERS, body: body) do |res|
      result = res.body_io.gets_to_end
      break unless res.status.success?

      result = NamedTuple(result: String).from_json(result)[:result]
      result.gsub(/\n+/, '\n').lines
    end
  end

  private def call_m_gpt(lines : Array(String))
    body = {test_key: lines.join('\n')}.to_json

    HTTP::Client.post(CV_ENV.m_gpt_host, headers: JSON_HEADERS, body: body) do |res|
      result = res.body_io.gets_to_end
      break unless res.status.success?

      result = NamedTuple(result: String).from_json(result)[:result]
      result.gsub(/\n+/, '\n').lines
    end
  end

  # test = from_ztext("“石仙子”")
  # puts test.get_vtran("c_gpt", redo: true)
  # puts test.get_vtran("ms_zv", redo: true)
end
