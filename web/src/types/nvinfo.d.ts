declare namespace CV {
  interface Author {
    zname: string
    vname: string
  }

  interface Nvinfo {
    id: number

    bslug: string
    bhash: string

    btitle_zh: string
    btitle_hv: string
    btitle_vi: string

    author_zh: string
    author_vi: string

    bintro: string
    bcover: string
    genres: string[]

    scover: string
    zintro: string
    zgenres: string[]

    status: number
    mftime: number

    voters: number
    rating: number

    ys_snvid: string
    pub_link: string
    pub_name: string
  }
}
