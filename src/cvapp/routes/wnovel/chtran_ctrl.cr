require "../_ctrl_base"

class CV::ChtranCtrl < CV::BaseCtrl
  base "/_db/texts/:book_id/:sname/:ch_no"

  getter! chroot : Chroot
  getter! chinfo : Chinfo

  @[AC::Route::Filter(:before_action)]
  def load_resources(book_id : Int64, sname : String, ch_no : Int32)
    @chroot = get_chroot(book_id, sname, :find)
    @chinfo = get_chinfo(chroot, ch_no)
  end

  @[AC::Route::GET("/:part_no/:line_no")]
  def edits(part_no : Int32, line_no : Int32)
    edits = ChapTran.query.where({
      chroot_id: chroot.id, ch_no: chinfo.ch_no!,
      part_no: part_no,
      line_no: line_no,
    }).with_viuser.to_a

    render json: edits
  end

  @[AC::Route::POST("/:part_no/:line_no")]
  def create(part_no : Int32, line_no : Int32)
    guard_privi min: 2

    orig = TextUtil.clean_spaces(params["orig"]? || "")
    tran = TextUtil.clean_spaces(params["tran"])

    Clear::SQL.transaction do
      item = ChapTran.new({
        viuser: _viuser, chroot: chroot, ch_no: chinfo.ch_no!,
        part_no: part_no, line_no: line_no,
        orig: orig, tran: tran, flag: 0_i16,
      })

      ChapTran.query.where({
        chroot_id: chroot.id, ch_no: item.ch_no,
        part_no: item.part_no, line_no: item.line_no,
        flag: 0,
      }).to_update.set("flag = 1")

      item.save!
    end

    render :accepted, text: "created"
  end
end
