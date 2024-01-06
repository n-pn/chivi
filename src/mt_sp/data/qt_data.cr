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

  def initialize(@lines, @fbase, @cache = true)
  end

  def get_vtran(type : String, opts : String = "", redo : Bool = false)
    return {[] of String, 0_i64} if @lines.empty?
    fpath = "#{@fbase}.#{type}.txt"

    read_file(fpath, redo ? 5.minutes : 2.weeks) || begin
      mdata = load_vtext(type, opts)
      raise "Lỗi dịch nhanh với chế độ #{type}" unless mdata

      File.write(fpath, mdata[0].join('\n')) if @cache
      mdata
    end
  end

  def read_file(fpath : String, tspan = 2.weeks) : {Array(String), Int64}?
    return unless @cache && (info = File.info?(fpath))
    return unless info.modification_time >= Time.utc - tspan

    {File.read_lines(fpath), info.modification_time.to_unix}
  end

  def load_vtext(type : String, opts : String) : {Array(String), Int64}?
    return {call_qt_v1(opts), Time.utc.to_unix} if type == "qt_v1"
    vobj = VCache::Obj.parse(type)

    cached, remain, mtime = VCache.get_val(obj: vobj, raws: @lines)
    return {cached, mtime} if remain.empty?

    missing = remain.map { |idx| @lines[idx] }

    case vobj
    when .bd_zv? # baidu translator
      vlines = BdTran.api_translate(missing, tl: "vie")
    when .bd_ze? # baidu translator
      vlines = BdTran.api_translate(missing, tl: "en")
    when .ms_zv? # microsoft transltor
      vlines = MsTran.free_translate(missing, token: opts, sl: "zh", tl: "vi").map(&.first)
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
    {cached, mtime}
  end

  QT_V1_API = "#{CV_ENV.m1_host}/_m1/qtran"

  private def call_qt_v1(opts : String = "0,1", format = "txt")
    wn_id, _sep, title = opts.partition(':')
    wn_id = "0" if wn_id.empty?
    title = "1" if title.empty?

    url = "#{QT_V1_API}?format=#{format}&wn_id=#{wn_id}&title=#{title}"
    HTTP::Client.post(url, body: @lines.join('\n'), &.body_io.gets_to_end.lines)
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
