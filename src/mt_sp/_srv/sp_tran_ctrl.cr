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
    qdata = QtData.new(ztext)
    qdata.set_opts(pdict, udict: "qt#{self._vu_id}", regen: regen, h_sep: 0, l_sep: l_sep, otype: otype)
    do_translate(qdata, qkind)
  end

  @[AC::Route::POST("/:qkind")]
  def tl_post(qkind : String, pd pdict = "combine", op otype = "json",
              rg regen : Int32 = 0, hs h_sep : Int32 = 1, ls l_sep : Int32 = 0)
    ztext = self._read_body
    qdata = QtData.new(ztext)
    qdata.set_opts(pdict, "qt#{self._vu_id}", regen, h_sep, l_sep, otype)
    do_translate(qdata, qkind)
  end

  # @[AC::Route::GET("/:qkind/:qhash")]
  # def tl_file(qkind : String, qhash : String, pd pdict = "combine", op otype = "json",
  #             rg regen : Int32 = 0, hs h_sep : Int32 = 1, ls l_sep : Int32 = 0)
  #   qdata = QtData.from_fname(qhash)
  #   qdata.set_opts(pdict, "qt#{self._vu_id}", regen, h_sep, l_sep, otype)
  #   do_translate(qdata, qkind)
  # end

  private def do_translate(qdata : QtData, qkind : String)
    sleep 10.milliseconds * (1 << (5 - self._privi))

    quota = check_quota!(qdata, qkind)

    response.headers["X-Quota"] = quota.quota_limit.to_s
    response.headers["X-Using"] = quota.quota_using.to_s
    response.content_type = "text/plain; charset=utf-8"

    vdata = qdata.get_vtran(qkind)
    render text: vdata
  rescue ex : BadRequest
    render :bad_request, text: ex.message
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end

  MULTP = {
    "hviet" => 1, "hname" => 1,
    "qt_v1" => 2, "mtl_0" => 4,
    "mtl_1" => 6, "mtl_2" => 8, "mtl_3" => 8,
    "ms_zv" => 12, "bd_zv" => 16, "c_gpt" => 12,
    "ms_ze" => 12, "bd_ze" => 16, "dl_ze" => 20,
  }

  private def check_quota!(qdata : QtData, qkind : String)
    quota = Uquota.load(self._vu_id, self.client_ip)
    zsize = qdata.zsize
    qcost = MULTP.fetch(qkind, 8) * zsize // 2

    if quota.limit_exceeded?(qcost: qcost)
      if self._vu_id < 1 || !self._cfg_enabled?("_auto_")
        raise BadRequest.new("Bạn đã dùng hết lượng giới hạn ký tự dịch thuật hôm nay! Hãy quay lại vào ngày mai hoặc nâng cấp tài khoản!")
      end

      unless vcoin = quota.spend_vcoin!({qcost + 10_000, 20_000}.max)
        raise BadRequest.new("Tăng giới hạn ký tự dịch thuật thất bại: Số vcoin khả dụng của bạn không đủ!")
      end

      response.headers["X-VCOIN"] = vcoin.round(3).to_s
    end

    quota.add_quota_spent!(qcost)
    spawn log_quota_spent(qcost: qcost, zsize: zsize, qkind: qkind)

    quota
  end

  LOG_DIR = "var/ulogs/xquota"
  Dir.mkdir_p(LOG_DIR)

  private def log_quota_spent(qcost : Int32, zsize : Int32, qkind : String)
    time_now = Time.local
    log_file = "#{LOG_DIR}/spend-#{time_now.to_s("%F")}.log"

    File.open(log_file, "a") do |file|
      JSON.build(file) do |jb|
        jb.object do
          jb.field "uname", self._uname
          jb.field "vu_ip", self.client_ip
          jb.field "mtime", time_now.to_unix
          jb.field "qcost", qcost
          jb.field "zsize", zsize
          jb.field "qkind", qkind
          jb.field "horig", request.headers["Referer"]? || ""
        end
      end

      file.puts
    end
  end

  private def convert_vcoin_to_quota!(quota : Uquota)
    quota_diff = quota.quota_using - quota.quota_limit + 50_000
    vcoin_cost = quota_diff / 100_000

    quota.spend_vcoin!
    unless CV::Xvcoin.subtract(vu_id: quota.vu_id, value: vcoin_cost)
    end
  end
end
