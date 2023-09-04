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
    raise "error: #{res.body}" unless res.status.success?
    true
  end

  def get_con_data_from_hanlp(ztext : String, _algo : String)
    _algo = _algo == "auto" ? "hceg" : _algo.replace("hm", "hc")
    link = "#{CV_ENV.lp_host}/#{_algo}/text"

    res = HTTP::Client.post(link, body: ztext)
    raise "error: #{res.body}" unless res.status.success?

    res.body_io.gets_to_end
  end

  def load_chap_con_data(cpath : String, _algo : String = "auto", _auto = false)
    if _algo == "auto"
      path = "#{WN_NLP_DIR}/#{cpath}.hmeg.con"
      return {File.read(path), "hmeg"} if File.file?(path)
      _algo = "hmeb"
    elsif !_algo.in?("hmeg", "hmeb")
      _algo = "hmeb"
    end

    con_path = "#{WN_NLP_DIR}/#{cpath}.#{_algo}.con"

    unless File.file?(con_path)
      Dir.mkdir_p(File.dirname(con_path))

      raise "not found" unless _auto
      call_hanlp_file_api(cpath, _algo)
    end

    {File.read(con_path), _algo}
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
