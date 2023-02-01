declare namespace CV {
  interface Chinfo {
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
    chaps: Chinfo[]
  }

  interface Zhchap {
    ztext: string
    cvmtl: string
    title: string
    //
    grant: boolean
    privi: number
    _path?: string
  }

  interface WnSeed {
    links: string[]
    stime: number
    _flag: number
    fresh: boolean
    //
    read_privi: number
    edit_privi: number
    gift_chaps: number
  }
}
