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
}
