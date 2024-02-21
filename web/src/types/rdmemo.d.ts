declare namespace CV {
  interface Rdchap {
    title: string
    rmode: string
    qt_rm: string
    mt_rm: string
  }

  interface Rdmemo {
    vu_id: number
    rd_id: number

    sname: string
    sn_id: string

    // vname: string
    // rpath: string

    rd_state: number
    rd_stars: number
    rd_track: number

    rmode: string
    qt_rm: string
    mt_rm: string

    lc_mtype: number
    lc_ch_no: number
    lc_title: string

    atime: number
    rtime: number
  }
}
