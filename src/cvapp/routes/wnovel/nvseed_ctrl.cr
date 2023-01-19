require "../_ctrl_base"
require "../../views/*"

class CV::NvseedCtrl < CV::BaseCtrl
  base "/_db/seeds/:book_id"

  getter! nvinfo : Nvinfo

  @[AC::Route::Filter(:before_action)]
  def get_nvinfo(book_id : Int64)
    @nvinfo = Nvinfo.load!(book_id)
  end

  @[AC::Route::GET("/")]
  def index(book_id : Int64)
    seeds = Chroot.query.where(nvinfo_id: book_id).where("stype >= 0").to_a
    seeds.sort_by!(&.stype)
    render json: seeds.map { |x| ChrootView.new(x, full: false) }
  end

  @[AC::Route::GET("/:sname")]
  def show(sname : String, mode : Int8 = 0_i8)
    chroot = get_chroot(nvinfo.id, sname)
    reload_chroot(chroot, mode: mode) if mode > 0

    fresh = chroot.fresh?(_viuser.privi, force: false)
    render json: ChrootView.new(chroot, full: true, fresh: fresh)
  end

  private def max_mode_by_privi : Int8
    privi = _viuser.privi
    privi < 0 ? 0_i8 : privi > 1 ? 2_i8 : 1_i8
  end

  private def reload_chroot(chroot : Chroot, mode : Int8 = 0) : Nil
    case chroot._repo.stype
    when -2_i8 then chroot.reload_base!(mode: mode)
    when -1_i8 then chroot.reload_user!(mode: mode)
    when 0_i8 # @users
      return unless chroot.sname == "@" + _viuser.uname
      chroot.reload_self!(mode: mode) if mode > 0
    when 3_i8 # slow source
      chroot.reload_remote!(mode: mode) if mode > 0
    when 4_i8 # fast souce
      chroot.reload_remote!(mode: mode)
    else # miscs, zxcs_me, bxwxorg
      chroot.reload_frozen!(mode: mode)
    end

    chroot.stime = Time.utc.to_unix if mode > 0
    chroot.save! if chroot.changed?
  end

  @[AC::Route::GET("/:sname/:pg_no")]
  def chaps(sname : String, pg_no : Int16)
    chroot = get_chroot(nvinfo.id, sname)
    chaps = chroot.chpage(pg_no &- 1)

    render json: {
      pgidx: pg_no,
      pgmax: CtrlUtil.pgmax(chroot.chap_count, 32_i16),
      chaps: ChinfoView.list(chaps),
    }
  end

  @[AC::Route::PUT("/")]
  def create(sname : String, snvid s_bid : Int32)
    raise Unauthorized.new "Quyền hạn không đủ!" unless _viuser.can?(:level2)

    chroot = Chroot.upsert!(nvinfo, sname, s_bid, force: true)
    nvinfo.seed_list.other.push(chroot).sort! { |x| SnameMap.zseed(x.sname) }

    render json: {sname: sname, snvid: s_bid}
  end

  private def load_guarded_chroot(sname : String, min_privi = 1) : Chroot
    return get_chroot(nvinfo.id, sname) if action_allowed?(sname, min_privi)
    raise Unauthorized.new("Bạn không đủ quyền hạn")
  end

  # modes: 0 => patch, 1 => trunc, 2 => prune

  private def action_allowed?(sname : String, min_privi = 1)
    privi = _viuser.privi
    return true if privi > 3

    case sname[0]?
    when '=' then privi >= min_privi
    when '@' then privi >= min_privi && sname == '@' + _viuser.uname
    else          privi > min_privi
    end
  end

  struct PatchForm
    include JSON::Serializable

    getter o_sname : String
    getter chmin : Int32 = 1

    property chmax : Int32 = 9999
    property! i_chmin : Int32

    def after_initialize
      @i_chmin ||= @chmin
    end
  end

  @[AC::Route::GET("/:sname/patch")]
  def preview_patch(sname : String, o_sname : String,
                    chmin : Int32 = 1, chmax : Int32 = 1,
                    i_chmin : Int32? = nil)
    # chroot = load_guarded_chroot(min_privi: 1)
    # target = Chroot.load!(nvinfo, o_sname)

    # new_chmin = i_chmin || chmin
    # new_chmax = chmax + new_chmin - chmin

    render 400, text: "TODO!"
  end

  @[AC::Route::PUT("/:sname/patch", body: :form)]
  def patch(sname : String, form : PatchForm)
    chroot = load_guarded_chroot(sname, min_privi: 1)
    target = Chroot.load!(nvinfo, form.o_sname)

    form.chmax = chroot.chap_count if form.chmax > chroot.chap_count
    form.i_chmin ||= form.chmin

    chroot.mirror_other!(target, form.chmin, form.chmax, form.i_chmin)
    chroot.clear_cache!

    render json: {pgidx: CtrlUtil.pg_no(form.i_chmin, 32)}
  end

  @[AC::Route::PUT("/:sname/trunc", body: :form)]
  def trunc(sname : String, form : NamedTuple(chidx: Int32))
    unless _viuser.can?(sname[1..], :level2)
      raise Unauthorized.new("Bạn không đủ quyền hạn")
    end

    chroot = get_chroot(nvinfo.id, sname, mode: :find)
    trunc_from = form[:chidx]
    trunc_from = chroot.chap_count if trunc_from > chroot.chap_count

    if chinfo = chroot.chinfo(trunc_from &- 1)
      last_sname = chinfo.sname
      last_schid = chinfo.s_cid.to_s
    else
      last_sname = ""
      last_schid = ""
    end

    chroot.update({
      chap_count: trunc_from &- 1,
      last_sname: last_sname,
      last_schid: last_schid,
    })

    chroot.clear_cache!
    render json: {pgidx: CtrlUtil.pg_no(trunc_from, 32)}
  end

  @[AC::Route::DELETE("/:sname/prune")]
  def prune(sname : String)
    unless _viuser.can?(sname[1..], :level2)
      raise Unauthorized.new("Bạn không đủ quyền hạn")
    end

    chroot = get_chroot(nvinfo.id, sname, mode: :find)

    chroot.update({
      chap_count: 0_i16,
      last_sname: "", last_schid: "",
      shield: _viuser.privi > 2 ? 4 : 3,
    })

    chroot.clear_cache!
    render json: {shield: chroot.shield}
  end
end
