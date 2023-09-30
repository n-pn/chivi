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
    fpath: string
    plock: number

    ztext: Array<String>
    zsize: number

    _prev: string
    _succ: string
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }

  interface Chopts {
    zpage: Mtpage
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
