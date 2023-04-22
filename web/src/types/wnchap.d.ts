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
    ztext: string
    cvmtl: string
    title: string
    //
    grant: boolean
    privi: number
    cpart: number
    //
    _path?: string
  }

  interface Wnchap {
    chidx: number
    title: string
    chvol: string
    uslug: string

    chars: number
    parts: number
    utime: number
    uname: string

    sname: string
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }
}
