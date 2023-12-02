declare namespace CV {
  interface Wnchap {
    ch_no: number

    title: string
    chdiv: string

    psize: number
    mtime: number

    flags: string
    rlink: string
  }

  interface Chpart {
    ch_no: number
    p_idx: number
    p_max: number

    zname: string
    rlink: string

    title: string
    chdiv: string

    ztext: string[]
    fpath: string

    error: number
    plock: number
    multp: number
    zsize: number

    mtime: number
    uname: string

    _prev: string
    _next: string
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }

  interface Rdopts {
    fpath: string
    pdict: string
    wn_id: number

    rmode: string
    qt_rm: string
    mt_rm: string
  }

  interface Mtdata {
    lines: Array<CV.Cvtree>
    tspan: number
    dsize?: [number, number, number]
    mtime?: number
    error?: string
    m_alg?: string
  }

  interface Qtdata {
    lines: Array<string>
    tspan: number
    mtime?: number
    error?: string
  }

  interface Hvdata {
    hviet: Array<Array<[string, string]>>
    ztext: Array<string>
    tspan: number
    mtime?: number
    error?: string
  }

  interface Tsrepo {
    sroot: string
    owner: number

    sname: string
    stype: number
    sn_id: number

    vname: string
    zname: string
    cover: string

    wn_id: number
    pdict: string

    chmax: number
    mtime: Int64

    plock: number

    multp: number

    rm_slink: string
    rm_stime: number
    rm_chmin: number

    view_count: number
    like_count: number
    star_count: number

    rd_track: number
    rd_state: number
    rd_stars: number

    rmode: string
    qt_rm: string
    mt_rm: string

    lc_title: string
    lc_mtype: number
    lc_ch_no: number
    lc_p_idx: number

    vu_atime: number
    vu_rtime: number
  }

  // interface Chstem {
  //   sroot: string
  //   stype: string

  //   sname: string
  //   sn_id: string

  //   chmax: number // chap_count
  //   utime?: number // updated_at

  //   plock: number
  //   multp: number

  //   zname: string
  //   gifts: number = 2
  // }
}
