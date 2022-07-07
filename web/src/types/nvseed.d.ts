declare namespace CV {
  interface Nvseed {
    sname: string
    snvid: string

    chmax: number // chap_count
    utime: number // updated_at

    stype: number
    slink: string

    stime: number = 0
    fresh: bool = false

    lasts: Chinfo[]

    free_chap: number = 40
    privi_map: [number, number, number] = [0, 1, 1]
  }

  interface Nslist {
    _base: Nvseed
    _user: Nvseed
    users: Array<Nvseed>
    other: Array<Nvseed>
  }
}
