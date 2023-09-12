require "http/client"
require "../../cv_env"
require "../../mt_sp/util/*"

module MT::MtTranUtil
  extend self

  WN_TXT_DIR = "var/wnapp/chtext"
  WN_NLP_DIR = "var/wnapp/nlp_wn"
  WN_VTL_DIR = "var/wnapp/chtran"

  def txt_path(cpath : String)
    "#{WN_TXT_DIR}/#{cpath}.txt"
  end

  def read_txt(cpath : String)
    File.read_lines(self.txt_path(cpath), chomp: true)
  end

  def vtl_path(cpath : String, _kind : String = "bzv")
    "#{WN_VTL_DIR}/#{cpath}.#{_kind}.txt"
  end

  def con_path(cpath : String, _algo : String)
    "#{WN_NLP_DIR}/#{cpath}.#{_algo}.con"
  end

  def get_wntext_con_data(cpath : String, _algo : String = "avail", auto_gen = false)
    hmeg_path = self.con_path(cpath, "hmeg")
    hmeb_path = self.con_path(cpath, "hmeb")

    if _algo == "hm_eb"
      con_path = hmeb_path
    elsif _algo == "hm_eg"
      con_path = hmeg_path
    elsif File.file?(hmeg_path) # mode == avail
      return read_con_file(hmeg_path, "hm_eg")
    elsif File.file?(hmeb_path) # mode == avail
      return read_con_file(hmeb_path, "hm_eb")
    else
      con_path = hmeg_path
      _algo = "hm_eg"
    end

    return read_con_file(con_path, _algo) if File.file?(con_path)
    raise "data not parsed!" if !auto_gen

    txt_path = "#{WN_TXT_DIR}/#{cpath}.txt"
    call_hanlp_file_api(txt_path, con_path, _algo)
  end

  def read_con_file(con_path : String, _algo : String)
    lines = File.read_lines(con_path, chomp: true)
    {lines, _algo}
  end

  def call_hanlp_file_api(txt_path : String, con_path : String, _algo : String)
    link = "#{CV_ENV.lp_host}/#{_algo}/file?file=#{txt_path}"

    HTTP::Client.get(link) do |res|
      raise "error: #{res.body}" unless res.status.success?

      cdata = res.body_io.gets_to_end

      spawn do
        Dir.mkdir_p(File.dirname(con_path))
        File.write(con_path, cdata)
      end

      {cdata.lines, _algo}
    end
  end

  def call_hanlp_text_api(ztext : String, _algo : String)
    link = "#{CV_ENV.lp_host}/#{_algo}/text"

    HTTP::Client.post(link, body: ztext) do |res|
      raise "error: #{res.body}" unless res.status.success?

      cdata = res.body_io.gets_to_end
      # TODO: save to disk?

      cdata.lines(chomp: true)
    end
  end

  def get_wntext_btran_data(cpath : String, force : Bool = false)
    vtl_path = self.vtl_path(cpath, "bzv")

    if File.file?(vtl_path)
      return File.read_lines(vtl_path, chomp: true)
    elsif !force
      raise "Chưa tồn tại thông tin dịch trên hệ thống!"
    end

    btran = SP::Btran.free_translate(read_txt(cpath), target: "vi")

    spawn do
      Dir.mkdir_p(File.dirname(vtl_path))
      File.write(vtl_path, btran.join('\n'))
    end

    return btran
  end

  def get_wntext_oldmt_data(cpath : String)
    url = "#{CV_ENV.m1_host}/_m1/qtran/wntext?cpath=#{cpath}"
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
