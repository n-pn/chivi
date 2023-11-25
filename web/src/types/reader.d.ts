declare namespace CV {
  interface Wnchap {
    ch_no: number
    uslug: string

    title: string
    chdiv: string

    psize: number
    mtime: number

    flags: string
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

  interface Chrepo {
    sroot: string
    owner: number

    stype: number
    sn_id: number

    vname: string
    zname: string
    wn_id: number

    chmax: number
    avail: number

    plock: number
    gifts: number
    multp: number

    mtime: Int64
    rtime: Int64

    view_count: number
    like_count: number
    star_count: number
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
