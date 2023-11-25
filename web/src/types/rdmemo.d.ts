declare namespace CV {
  interface Rdchap {
    title: string
    p_idx: number
    rmode: string
    qt_rm: string
    mt_rm: string
  }

  interface Rdmemo {
    vu_id: number

    sname: string
    sn_id: string

    vname: string
    rpath: string

    rstate: number
    rating: number
    recomm: number

    rmode: string
    qt_rm: string
    mt_rm: string

    lc_mtype: number
    lc_ch_no: number
    lc_p_idx: number
    lc_title: string

    atime: number
    rtime: number
  }
}
