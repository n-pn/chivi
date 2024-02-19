require "../../mt_ai/core/qt_core"
require "../../_data/member/uquota"
require "../../_data/member/xquota"

require "./_sp_ctrl_base"
require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp/qtran"

  @[AC::Route::GET("/:qkind")]
  def tl_line(qkind : String, zh ztext : String,
              pd pdict = "combine", op otype = "txt",
              rg regen : Int32 = 0, ls l_sep : Int32 = 0)
    qdata = QtData.from_ztext(ztext, cache: false)
    qdata.set_opts(pdict, udict: "qt#{self._vu_id}", regen: regen, h_sep: 0, l_sep: l_sep, otype: otype)
    do_translate(qdata, qkind)
  end

  @[AC::Route::POST("/:qkind")]
  def tl_post(qkind : String, pd pdict = "combine", op otype = "json",
              rg regen : Int32 = 0, hs h_sep : Int32 = 1, ls l_sep : Int32 = 0)
    ztext = self._read_body
    qdata = QtData.from_ztext(ztext)
    qdata.set_opts(pdict, "qt#{self._vu_id}", regen, h_sep, l_sep, otype)
    do_translate(qdata, qkind)
  end

  @[AC::Route::GET("/:qkind/:qhash")]
  def tl_file(qkind : String, qhash : String, pd pdict = "combine", op otype = "json",
              rg regen : Int32 = 0, hs h_sep : Int32 = 1, ls l_sep : Int32 = 0)
    qdata = QtData.from_fname(qhash)
    qdata.set_opts(pdict, "qt#{self._vu_id}", regen, h_sep, l_sep, otype)
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

    vdata = qdata.get_vtran(qkind)

    spawn log_activity(charge, wcount, qkind)

    response.headers["X-Quota"] = quota.quota_limit.to_s
    response.headers["X-Using"] = quota.quota_using.to_s

    response.content_type = "text/plain; charset=utf-8"
    render text: vdata
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end

  private def log_activity(charge, wcount, qkind)
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
end
