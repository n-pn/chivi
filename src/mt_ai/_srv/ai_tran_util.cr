require "http/client"
require "../../cv_env"
require "../../mt_sp/util/*"

module MT::AiTranUtil
  extend self

  WN_TXT_DIR = "var/wnapp/chtext"
  WN_NLP_DIR = "var/wnapp/nlp_wn"

  def call_hanlp_file_api(cpath : String, _algo : String)
    file = "#{WN_TXT_DIR}/#{cpath}.txt"
    link = "#{CV_ENV.lp_host}/#{_algo}/file?file=#{file}"

    res = HTTP::Client.get(link)
    res.status.success?
  end

  def get_con_data_from_hanlp(ztext : String, _algo : String)
    _algo = _algo == "auto" ? "hceg" : _algo.replace("hm", "hc")
    link = "#{CV_ENV.lp_host}/#{_algo}/text"

    res = HTTP::Client.post(link, body: ztext)
    raise "error: #{res.body}" unless res.status.success?

    res.body_io.gets_to_end.lines(chomp: true)
  end

  def load_chap_con_data(cpath : String, _algo : String = "auto", _auto = false)
    if _algo == "auto"
      path = "#{WN_NLP_DIR}/#{cpath}.hmeg.con"
      return {File.read(path), "hmeg"} if File.file?(path)
      _algo = "hmeb"
    elsif !_algo.in?("hmeg", "hmeb")
      _algo = "hmeb"
    end

    txt_path = "#{WN_TXT_DIR}/#{cpath}."
    con_path = "#{WN_NLP_DIR}/#{cpath}.#{_algo}.con"

    unless File.file?(con_path)
      Dir.mkdir_p(File.dirname(con_path))

      raise "not found" unless _auto
      raise "can't call api" unless call_hanlp_file_api(cpath, _algo)
    end

    lines = File.read_lines(con_path, chomp: true)
    gtime = File.info(con_path).modification_time.to_unix

    ztime = File.info?(txt_path).try(&.modification_time.to_unix) || 0_i64

    {lines, gtime, ztime, _algo}
  end

  def read_dual_wntext(cpath : String, _kind : String = "bzv") : String
    case _kind
    when "bzv"
      url = "#{CV_ENV.sp_host}/_sp/btran/wntext?cpath=#{cpath}"
    when "old"
      url = "#{CV_ENV.m1_host}/_m1/qtran/wntext?cpath=#{cpath}"
    else
      raise "invalid dual_kind #{_kind}"
    end

    HTTP::Client.get(url, &.body_io.gets_to_end)
  end

  def call_free_btran(ztext : String) : String
    SP::Btran.free_translate(ztext, target: "vi").join('\n')
  end

  def get_v1_qtran_mtl(ztext : String, pdict : String) : String
    wn_id = pdict.sub("book/", "").to_i? || 0
    url = "#{CV_ENV.m1_host}/_m1/qtran?wn_id=#{wn_id}&format=mtl"
    HTTP::Client.post(url, body: ztext, &.body_io.gets_to_end)
  end
end
