declare namespace CV {
  interface Wnstem {
    sname: string
    sn_id: number

    rlink: string
    rtime: number

    chmax: number
    utime: number

    multp: number
  }

  interface Upstem {
    owner: number
    wn_id: number

    id: number

    sname: string
    mtime: number
    rlink: string

    zname: string
    vname: string

    au_zh: string
    au_vi: string

    img_og: string
    img_cv: string

    zdesc: string
    vdesc: string

    labels: string[]

    multp: number
    wndic: boolean

    chap_count: number
    word_count: number
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

    cover_rm: string
    cover_vi: string

    genre_zh: string
    genre_vi: string

    status_int: number
    update_int: number

    chap_count: number
    view_count: number

    multp: number
  }
}
