require "./_up_ctrl_base"
require "../../_util/hash_util"
require "../../_data/member/unlock"
require "../../_data/member/xvcoin"

class UP::UpchapCtrl < AC::Base
  base "/_up/chaps/:up_id"

  @[AC::Route::GET("/")]
  def index(up_id : Int32)
    # TODO: restrict user access?
    ustem = get_ustem(up_id)
    _pg_no, limit, offset = _paginate(min: 32, max: 64)
    chaps = ustem.get_chaps(chmin: offset, limit: limit)

    render json: chaps
  end

  @[AC::Route::GET("/:ch_no/:p_idx")]
  def show(up_id : Int32, ch_no : Int32, p_idx : Int32, force : Bool = false)
    ustem = get_ustem(up_id)
    cinfo = get_cinfo(ustem, ch_no)

    plock = ustem.chap_plock(ch_no, _vu_id)
    ztext, zsize, error = read_chap(ustem, cinfo, p_idx, plock, force: force)

    output = {
      cinfo: cinfo,
      rdata: {
        fpath: cinfo.part_fpath(p_idx),
        plock: plock,

        zsize: zsize,
        ztext: ztext,

        _prev: ustem.clist.prev_part(ch_no, p_idx),
        _next: ustem.clist.next_part(ch_no, p_idx, cinfo.psize),
      },
      error: error,
    }

    render 200, json: output
  end

  def gen_ulkey(ustem : Upstem, cinfo : Chinfo, p_idx : Int32)
    "up:#{ustem.sname}/#{ustem.id}/#{cinfo.ch_no}-#{cinfo.cksum}-#{p_idx}"
  end

  def read_chap(ustem, cinfo, p_idx : Int32, plock : Int32, force : Bool = false)
    vu_id = self._vu_id
    zsize = cinfo.sizes[p_idx]? || 0

    # TODO: recover raw text if missing?
    # TODO: download raw text if is remote
    return {[] of String, zsize, 414} if zsize == 0 || cinfo.cksum.empty?

    ulkey = gen_ulkey(ustem, cinfo, p_idx)

    if _privi < plock && !CV::Unlock.find(vu_id, ulkey)
      return {[] of String, zsize, 413} unless force
      to_user = ustem.viuser_id

      unlock = CV::Unlock.new(vu_id, ulkey, zsize, ustem.multp)
      reason = build_xlog_reason(ustem, cinfo, p_idx)

      unless vcoin_remain = exchange_vcoin(vu_id, to_user, unlock.vcoin, reason)
        return {[] of String, zsize, 415}
      end

      unlock.save!
    end

    fpath = cinfo.file_path(p_idx: p_idx, ftype: "raw.txt")

    ztext = File.read_lines(fpath, chomp: true)
    ztext.unshift(cinfo.ztitle) unless ztext.first == cinfo.ztitle

    {ztext, zsize, 0}
  end

  private def build_xlog_reason(ustem, cinfo, p_idx)
    String.build do |io|
      io << "Mở khóa chương " << cinfo.ch_no
      io << "_#{p_idx}" if p_idx > 1 || cinfo.psize > 1
      io << " nguồn #{ustem.sname}:#{ustem.id}"
    end
  end

  GET_VCOIN_SQL = "select vcoin from viusers where id = $1"

  SUB_VCOIN_SQL = <<-SQL
    update viusers set vcoin = vcoin - $1
    where id = $2 and vcoin >= $1
    returning vcoin
    SQL

  ADD_VCOIN_SQL = "update viusers set vcoin = vcoin + $1 where id = $2"

  private def exchange_vcoin(from_vu : Int32, to_user : Int32, vcoin : Int32, reason : String)
    vcoin = vcoin / 1000 # TODO: convert vcoin to dong

    avail = PGDB.query_one?(GET_VCOIN_SQL, from_vu, as: Float64)
    return if !avail || avail < vcoin

    return unless remain = PGDB.query_one?(SUB_VCOIN_SQL, vcoin, from_vu, as: Float64)
    PGDB.exec ADD_VCOIN_SQL, vcoin, to_user

    CV::Xvcoin.new(
      kind: :privi_ug, sender_id: from_vu, target_id: to_user,
      amount: vcoin, reason: reason,
    ).insert!

    # TODO: send notification

    remain
  end

  # TODO:
  # - add delete
  # - add insert
end
