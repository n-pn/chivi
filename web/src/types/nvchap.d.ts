declare namespace CV {
  interface Chseed {
    sname: string
    chaps: number // chap_count
    utime: number
    atime?: number
    _link?: string
    _type: number
    _seed?: boolean
  }

  interface Chinfo {
    chidx: number
    title: string
    chvol: string
    uslug: string

    chars: number
    parts: number
    utime: number
    uname: string

    o_sname?: string
    o_snvid?: string
    o_chidx?: number
  }

  interface Chpage extends Paginate {
    lasts: Chinfo[]
    chaps: Chinfo[]
  }

  interface Chmeta {
    sname: string
    total: number

    clink: string
    cpart: number

    _prev: string
    _next: string
  }
}
