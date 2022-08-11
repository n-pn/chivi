class CV::ChtranCtrl < CV::BaseCtrl
  def list
    chroot = load_chroot(params["sname"], :find)
    chinfo = load_chinfo(chroot)

    items = ChapTran.query.where({
      chroot_id: chroot.id, ch_no: chinfo.ch_no!,
      part_no: params.read_i16("part_no", min: 0_i16),
      line_no: params.read_i16("line_no", min: 0_i16),
    }).with_viuser.to_a

    serv_json(items)
  end

  def create
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, :find)
    chinfo = load_chinfo(chroot)

    part_no = params.read_i16("part_no", min: 0_i16)
    line_no = params.read_i16("line_no", min: 0_i16)

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

    serv_text("ok.")
  end
end
