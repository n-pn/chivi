require "../../_util/hash_util"
require "../../_util/text_util"
require "../../cv_env"
require "../util/*"

class SP::QtData
  DIR = "/2tb/var.chivi/cache/qtran"

  def self.from_ztext(ztext : String)
    lines = [] of String

    ztext.each_line do |line|
      line = TextUtil.canon_clean(line)
      lines << line unless line.empty?
    end

    fname = "#{lines.size}-#{HashUtil.hash_32(lines)}"
    save_path = "#{DIR}/#{fname}-ztext.txt"

    unless File.file?(save_path)
      File.open(save_path, "w") { |file| lines.join(file, '\n') }
    end

    new(lines, fname)
  end

  def self.from_fname(fname : String)
    lines = File.read_lines("#{DIR}/#{fname}.ztext.txt")
    new(lines, fname)
  end

  getter lines : Array(String)
  getter fname : String

  def initialize(@lines, @fname)
  end

  def get_vtran(type : String, opts : String = "", redo : Bool = false)
    return "" if @lines.empty?

    fpath = "#{DIR}/#{@fname}.#{type}.txt"
    return File.read(fpath) if !redo && File.file?(fpath)

    unless vtext = load_vtext(type, opts)
      raise "Lỗi dịch nhanh với chế độ #{type}"
    end

    File.write(fpath, vtext)
    vtext
  end

  def load_vtext(type : String, opts : String)
    case type
    when "bd_zv" # baidu translator
      vtran = BdTran.translate(@lines.join('\n'), sl: "zh", tl: "vie")
      vtran.join('\n')
    when "ms_zv" # microsoft transltor
      vtran = MsTran.free_translate(@lines, token: opts, sl: "zh", tl: "vi")
      vtran.join('\n')
    when "dl_zv"
      vtran = Deepl.translate(@lines, source: "zh", target: "vi")
      vtran.join('\n', &.[1])
    when "qt_v1"
      call_qt_v1(opts)
    when "c_gpt"
      call_c_gpt(@lines.join('\n'))
    else
      raise "Không hỗ trợ cách dịch nhanh [#{type}]"
    end
  end

  QT_V1_API = "#{CV_ENV.m1_host}/_m1/qtran"

  private def call_qt_v1(opts : String = "0,1", format = "txt")
    wn_id, _sep, title = opts.partition(':')
    wn_id = "0" if wn_id.empty?
    title = "1" if title.empty?

    url = "#{QT_V1_API}?format=#{format}&wn_id=#{wn_id}&title=#{title}"
    HTTP::Client.post(url, body: @lines.join('\n'), &.body_io.gets_to_end)
  end

  C_GPT_API = "http://184.174.38.115:9090"

  HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

  private def call_c_gpt(ztext : String)
    body = {test_key: ztext}.to_json

    HTTP::Client.post(C_GPT_API, headers: HEADERS, body: body) do |res|
      result = res.body_io.gets_to_end
      break unless res.status.success?
      NamedTuple(result: String).from_json(result)[:result]
    end
  end

  # test = from_ztext("“石仙子”")
  # puts test.get_vtran("c_gpt", redo: true)
  # puts test.get_vtran("ms_zv", redo: true)
end
