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
    grant: boolean
    privi: number
  }

  interface WnSeed {
    links: string[]
    stime: number
    _flag: number
    fresh: boolean
    //
    min_privi: number
    gift_chap: number
  }
}
