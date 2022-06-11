declare namespace CV {
  interface Nvseed {
    sname: string
    snvid: string

    chaps: number // chap_count
    utime: number

    stype: number
    slink: string

    stime: number = 0
    fresh: bool = false

    lasts: Chinfo[]
  }
}
