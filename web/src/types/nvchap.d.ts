declare namespace CV {
  interface Chseed {
    sname: string
    wlink?: string
    utime: number
    atime?: number
    _type: number
    _seed?: boolean
    chaps: number // chap_count
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
