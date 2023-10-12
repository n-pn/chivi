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

    last_ch_no: number
    last_cinfo: Rdchap

    mark_ch_no: number
    mark_cinfo: Rdchap

    atime: number
    rtime: number
  }
}
