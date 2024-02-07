require "../../_util/hash_util"
require "../../_util/text_util"
require "../../cv_env"
require "../util/*"
require "./v_cache"

class SP::QtData
  DIR = "/2tb/var.chivi/cache/qtran"

  def self.from_ztext(ztext : String, cache : Bool = true, cache_dir : String = DIR)
    lines = [] of String

    ztext.each_line do |line|
      line = TextUtil.canon_clean(line)
      lines << line unless line.empty?
    end

    from_ztext(lines, cache: cache, cache_dir: cache_dir)
  end

  def self.from_ztext(lines : Array(String), cache : Bool = true, cache_dir : String = DIR)
    fbase = "#{cache_dir}/#{lines.size}-#{HashUtil.hash_32(lines)}"
    fpath = "#{fbase}.ztext.txt"

    if cache && !File.file?(fpath)
      File.open(fpath, "w") { |file| lines.join(file, '\n') }
    end

    new(lines, fbase)
  end

  def self.from_fname(fname : String, cache_dir : String = DIR)
    fbase = "#{cache_dir}/#{fname}"
    new(File.read_lines("#{fbase}.ztext.txt"), fbase)
  end

  getter lines : Array(String)
  getter fbase : String

  property pdict = "combine"
  property udict = "qt0"

  property regen = 0
  property h_sep = 0
  property l_sep = 0
  property otype = "json"

  def initialize(@lines, @fbase, @cache = true)
  end

  def set_opts(@pdict, @regen, @h_sep, @l_sep, @otype = "json")
  end

  MULTP_MAP = {
    "qt_v1" => 2,
    "mtl_0" => 3,
    "mtl_1" => 4,
    "mtl_2" => 5,
    "mtl_3" => 5,
    "ms_zv" => 8,
    "ms_ze" => 8,
    "bd_zv" => 10,
    "bd_ze" => 10,
    "c_gpt" => 10,
    "dl_ze" => 20,
    "dl_je" => 20,
  }

  def quota_using(qtype : String)
    wcount = @lines.sum { |x| x.size &+ 1 }
    charge = MULTP_MAP.fetch(qtype, 10) * wcount
    {wcount, charge}
  end

  def get_vtran(qtype : String)
    return {"", 0_i64} if @lines.empty?
    fpath = "#{@fbase}.#{qtype}.txt"

    read_file(fpath, regen > 1 ? 5.minutes : 2.weeks) || begin
      mdata = load_vtext(qtype)
      raise "Lỗi dịch nhanh với chế độ #{qtype}" unless mdata
      File.write(fpath, mdata[0]) if @cache
      mdata
    end
  end

  def read_file(fpath : String, tspan = 2.weeks) : {String, Int64}?
    return unless @cache && (info = File.info?(fpath))
    return unless info.modification_time >= Time.utc - tspan

    {File.read(fpath), info.modification_time.to_unix}
  end

  MT_AI_API = "#{CV_ENV.ai_host}/_ai/qtran"

  def get_mtran(qtype : String, udict : String = "")
    url = "#{MT_AI_API}?qt=#{qtype}&op=#{@otype}&pd=#{@pdict}&ud=#{udict}&hs=#{h_sep}&ls=#{l_sep}&rg=#{regen}"
    mdata = HTTP::Client.post(url, body: @lines.join('\n'), &.body_io.gets_to_end)

    {mdata, Time.utc.to_unix}
  end

  def load_vtext(type : String) : {String, Int64}?
    return {call_qt_v1, Time.utc.to_unix} if type == "qt_v1"

    vobj = VCache::Obj.parse(type)

    cached, remain, mtime = VCache.get_val(obj: vobj, raws: @lines)
    return {cached.join('\n'), mtime} if remain.empty?

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
    else
      raise "Không hỗ trợ cách dịch nhanh [#{type}]"
    end

    return unless vlines
    VCache.cache!(obj: vobj, raws: missing, vals: vlines)

    vlines.each_with_index { |vtext, idx| cached[remain[idx]] = vtext }
    {cached.join('\n'), mtime}
  end

  QT_V1_API = "#{CV_ENV.m1_host}/_m1/qtran"

  private def call_qt_v1
    wn_id = @pdict.starts_with?("wn") ? @pdict[2..].to_i : 0
    url = "#{QT_V1_API}?format=text&wn_id=#{wn_id}&title=#{@h_sep}"
    HTTP::Client.post(url, body: @lines.join('\n'), &.body_io.gets_to_end)
  end

  C_GPT_API    = "http://184.174.38.115:9090"
  JSON_HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

  private def call_c_gpt(lines : Array(String))
    body = {test_key: lines.join('\n')}.to_json

    HTTP::Client.post(C_GPT_API, headers: JSON_HEADERS, body: body) do |res|
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
