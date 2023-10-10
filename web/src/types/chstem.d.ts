declare namespace CV {
  interface Chstem {
    sroot: string
    stype: string

    sname: string
    sn_id: string

    chmax: number // chap_count
    utime?: number // updated_at

    plock: number
    multp: number

    zname: string
    gifts: number = 2
  }

  interface Wnstem {
    sname: string
    sn_id: number

    rlink: string
    rtime: number

    chmax: number
    utime: number

    multp: number
    gifts: number
  }

  interface Upstem {
    owner: number
    wn_id: number

    id: number

    sname: string
    mtime: number

    zname: string
    vname: string
    uslug: string

    vintro: string
    labels: string[]

    guard: number
    gifts: number
    multp: number
    wndic: boolean

    chap_count: number
    view_count: number
  }

  interface Rmstem {
    sname: string
    sn_id: string

    wn_id: number

    rlink: string
    rtime: number

    btitle_zh: string
    btitle_vi: string

    author_zh: string
    author_vi: string

    intro_zh: string
    intro_vi: string

    genre_zh: string[]
    genre_vi: string[]

    status_int: number
    update_int: number

    chap_count: number
    chap_avail: number

    gifts: number
    multp: number
  }
}
