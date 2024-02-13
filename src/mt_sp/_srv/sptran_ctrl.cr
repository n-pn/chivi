require "../../mt_ai/core/qt_core"
require "../../_data/member/uquota"
require "../../_data/member/xquota"

require "./_sp_ctrl_base"
require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp/qtran"

  @[AC::Route::POST("/:qkind")]
  def tl_text(qkind : String, pd pdict = "combine", op otype = "mtl",
              rg regen : Int32 = 0, hs h_sep : Int32 = 1, ls l_sep : Int32 = 0)
    ztext = self._read_body
    # Log.info { ztext.size }
    # if ztext.size > 3000 &+ 2000 * self._privi
    #   raise BadRequest.new("Nội dung dịch không hợp lệ!")
    # end

    qdata = QtData.from_ztext(ztext)
    qdata.set_opts(pdict, regen, h_sep, l_sep, otype)
    do_translate(qdata, qkind)
  end

  @[AC::Route::GET("/:qkind/:qhash")]
  def tl_file(qkind : String, qhash : String, pd pdict = "combine", op otype = "mtl",
              rg regen : Int32 = 0, hs h_sep : Int32 = 1, ls l_sep : Int32 = 0)
    qdata = QtData.from_fname(qhash)
    qdata.set_opts(pdict, regen, h_sep, l_sep, otype)
    do_translate(qdata, qkind)
  end

  LOG_DIR = "var/ulogs/xquota"
  Dir.mkdir_p(LOG_DIR)

  private def do_translate(qdata : QtData, qkind : String)
    sleep 10.milliseconds * (1 << (5 - self._privi))

    wcount, charge = qdata.quota_using(qkind)

    vu_id = self._vu_id != 0 ? self._vu_id : Uquota.guest_id(self.client_ip)
    quota = Uquota.load(vu_id)
    quota.add_quota_spent!(wcount)

    if qkind.starts_with?("mtl_")
      vdata, mtime = qdata.get_mtran(qkind, udict: "qt#{self._vu_id}")
    else
      vdata, mtime = qdata.get_vtran(qkind)
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
            jb.field "type", qkind
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
