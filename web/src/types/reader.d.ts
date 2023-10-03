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
    title: string
    chdiv: string

    rlink: string
    fpath: string

    ztext: string[]
    error: number
    zsize: number

    plock: number
    mtime: number
    uname: string

    _prev: string
    _next: string
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }

  interface Chopts {
    zpage: Mtpage
    rtype: string
    rmode: string
    m_alg: string
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
    tspan: number
    mtime?: number
    ztext?: Array<string>
    error?: string
  }

  interface Rdstem {
    zname: string
    sname: string

    stype: string
    sn_id: string

    plock: number
    multp: number

    chmax: number
    gifts: number
  }
}
