require "./_up_ctrl_base"
require "../../_util/hash_util"

class UP::UpchapCtrl < AC::Base
  base "/_up/chaps/:up_id"

  @[AC::Route::GET("/")]
  def index(up_id : Int32)
    ustem = get_ustem(up_id)
    # TODO: restrict user access

    _pg_no, limit, offset = _paginate(min: 32, max: 64)
    chaps = ustem.get_chaps(chmin: offset, limit: limit)

    render json: chaps
  end

  @[AC::Route::GET("/:ch_no/:p_idx")]
  def show(up_id : Int32, ch_no : Int32, p_idx : Int32, force : Bool = false)
    ustem = get_ustem(up_id)
    cinfo = get_cinfo(ustem, ch_no)

    plock = ustem.chap_plock(ch_no, _vu_id)

    ztext = [] of String
    zsize = cinfo.sizes[p_idx]? || 0

    if cinfo.cksum.empty? || zsize == 0
      error = 414
      # TODO: recover raw text if missing?
      # TODO: download raw text if is remote
    elsif _privi < plock
      # TODO: substract vcoin if force
      # TODO: check unlocked
      error = 413
    else
      fpath = cinfo.file_path(p_idx: p_idx, ftype: "raw.txt")

      ztext = File.read_lines(fpath, chomp: true)
      ztext.unshift(cinfo.ztitle) unless ztext.first == cinfo.ztitle

      mtime = File.info(fpath).modification_time.to_unix
    end

    output = {
      cinfo: cinfo,
      rdata: {
        spath: cinfo.part_spath(p_idx),
        plock: plock,
        rlink: cinfo.rlink,

        ztext: ztext,
        zsize: zsize,
        mtime: mtime,

        _prev: ustem.clist.prev_part(ch_no, p_idx),
        _next: ustem.clist.next_part(ch_no, p_idx, cinfo.psize),
      },
      error: error,
    }

    render 200, json: output
  end

  # TODO:
  # - add delete
  # - add insert
end
