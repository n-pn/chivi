require "../../mt_ai/core/qt_core"
require "../../_data/member/uquota"
require "../../_data/member/xquota"

require "./_sp_ctrl_base"
require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp/qtran"

  @[AC::Route::POST("/:type")]
  def tl_text(type : String, opts : String = "", redo : Bool = false)
    ztext = self._read_body
    raise BadRequest.new("Nội dung dịch không hợp lệ!") if ztext.size > 5000

    qdata = QtData.from_ztext(ztext)
    do_translate(qdata, type, opts, redo)
  end

  @[AC::Route::GET("/:type/:name")]
  def tl_file(type : String, name : String, opts : String = "", redo : Bool = false)
    qdata = QtData.from_fname(name)
    do_translate(qdata, type, opts, redo)
  end

  LOG_DIR = "var/ulogs/xquota"
  Dir.mkdir_p(LOG_DIR)

  private def do_translate(qdata : QtData, type : String, opts = "", redo = false)
    sleep 10.milliseconds * (1 << (5 - self._privi))

    wcount, charge = qdata.quota_using(type, opts)

    quota = Uquota.load(self._vu_id)
    quota.add_using!(wcount)

    if type.starts_with?("mtl_")
      opts = opts.split(/[,:]/, remove_empty: true)
      pdict = opts[0]? || "combine"
      t_seg = opts[1]? || "1"

      vdata, mtime = qdata.get_mtran(
        m_alg: type,
        udict: "qt#{self._vu_id}",
        pdict: pdict,
        t_seg: t_seg,
        regen: redo)
    else
      vdata, mtime = qdata.get_vtran(type, opts: opts, redo: redo)
    end

    spawn do
      time_now = Time.local
      log_file = "#{LOG_DIR}/#{time_now.to_s("%F")}.log"
      File.open(log_file, "a") do |file|
        JSON.build(file) do |jb|
          jb.object do
            jb.field "uname", self._uname
            jb.field "vu_ip", self.client_ip
            jb.field "mtime", time_now.to_unix
            jb.field "charge", charge
            jb.field "wcount", wcount
            jb.field "type", type
            jb.field "orig", request.headers["Referer"]? || ""
          end
        end

        file.puts
      end
    end

    response.headers["ETag"] = mtime.to_s
    response.headers["X-Quota"] = quota.quota_limit.to_s
    response.headers["X-Using"] = quota.quota_using.to_s

    response.content_type = "text/plain; charset=utf-8"
    render text: vdata
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end
end
