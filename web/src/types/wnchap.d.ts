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

  interface Chdata {
    privi: number
    rlink: string

    cbase: string
    sizes: number[]
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }

  interface Chopts {
    wn_id: number
    cpart: number
    rtype: string
    rmode: string
  }

  interface Mtdata {
    lines: Array<CV.Cvtree>
    tspan: number
    mtime?: number
    error?: string
    _algo?: string
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
}
