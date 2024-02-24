require "./_sp_ctrl_base"
require "../data/wd_dict"
require "../data/wd_defn"

class SP::WsegCtrl < AC::Base
  base "/_sp/wseg"

  LOG_DIR = "var/ulogs/mtapp"
  Dir.mkdir_p(LOG_DIR)

  struct WsegForm
    include JSON::Serializable

    getter zstr : String
    getter wseg : String = ""

    getter pdict : String = "combine"
    getter srank : Int32 = 0

    def after_initialize
      @zstr = @zstr.gsub(/\p{C}+/, " ").strip
      @wseg = @wseg.gsub(/\p{C}+/, " ").strip
      @wseg = @zstr if @wseg.empty?
      @srank = 2 unless @srank.in?(0..3)
    end

    def action_url
      if @wseg.includes?('|')
        "#{CV_ENV.lp_host}/force_term?zstr=#{URI.encode_www_form(@zstr)}&wseg=#{URI.encode_www_form(@wseg)}"
      else
        "#{CV_ENV.lp_host}/combine_term?zstr=#{URI.encode_www_form(@zstr)}"
      end
    end
  end

  @[AC::Route::PUT("/", body: :sform)]
  def upsert(sform : WsegForm)
    guard_privi 2, "sửa thêm tách từ"
    self._log_action("add-wseg", data: sform, ldir: LOG_DIR)

    resp = HTTP::Client.get(sform.action_url)
    render status: resp.status, text: resp.body
  end
end
