declare namespace CV {
  interface Chmeta {
    sname: string
    total: number

    clink: string
    cpart: number

    _curr: string
    _prev: string
    _next: string
  }

  interface Zhchap {
    ch_no: number
    parts: string[]

    title: string
    chdiv: string

    uslug: string
    privi: number

    _next?: string
    _prev?: string
    _path?: string
  }

  interface Wnchap {
    ch_no: number

    title: string
    uslug: string

    chdiv: string

    sizes: number[]

    mtime: number
    uname: string
  }

  interface Chdata {
    ch_no: number
    rlink: string

    cbase: string
    cksum: string
    sizes: number[]

    _next?: string
    _prev?: string
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }
}
