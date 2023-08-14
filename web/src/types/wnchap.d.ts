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
    chdiv: string
    uslug: string

    sizes: number
    mtime: number
    uname: string
  }

  interface Chlist extends Paginate {
    chaps: Wnchap[]
  }
}
